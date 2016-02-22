component accessors=true {
  property framework;
  property jsonService;
  property dataService;

  property type="numeric" name="maxResults" default=25;
  property type="numeric" name="offset" default=0;
  property type="numeric" name="maxLevel" default=0;

  variables.supportedVerbs = "GET,POST,PUT,DELETE";
  variables.ormEntities = [];

  public component function init() {
    var ormSessionFactory = ormGetSessionFactory();
    variables.ormEntities = structKeyArray( ormSessionFactory.getAllClassMetadata());

    return this;
  }

  // setup and security
  public void function before( required struct rc ) {
    var item = framework.getItem();
    var section = framework.getSection();

    variables.entityName = listLast( section, '.' );
    variables.timer = getTickCount();

    if( arrayFindNoCase( variables.ormEntities, variables.entityName ) == 0 ) {
      return;
    }

    variables.entity = entityNew( variables.entityName );
    variables.props = variables.entity.getInheritedProperties();
    variables.where = { "deleted" = false };


    if( structKeyExists( rc, "id" )) {
      variables.where["id"] = rc.id;
    }

    if( item == "info" ) {
      return;
    }

    var privilegeMapping = {
      "default" = "view",
      "filter"  = "view",
      "search"  = "view",
      "show"    = "view",
      "create"  = "create",
      "update"  = "change",
      "destroy" = "delete"
    };

    writeLog( file="#request.appName#_API", text="#privilegeMapping[item]# #item# by #cgi.remote_addr#" );

    if( !rc.auth.role.can( privilegeMapping[item], variables.entityName )) {
      framework.renderData( "rawjson", jsonService.serialize({ "status" = "not-allowed" }), 405 );
      return;
    }

    param numeric rc.maxResults=25;
    param numeric rc.offset=0;
    param numeric rc.maxLevel=0;

    setMaxResults( rc.maxResults );
    setOffset( rc.offset );
    setMaxLevel( rc.maxLevel );
  }

  // GET (list, search)
  public void function default( required struct rc ) {
    param string rc.filterType = "";

    var filterType = rc.filterType;
    var querySetings = {
      "cacheable" = rc.config.appIsLive,
      "maxResults" = min( 10000, getMaxResults() ),
      "offset" = getOffset()
    };

    structDelete( url, "cacheable" );
    structDelete( url, "filterType" );
    structDelete( url, "maxResults" );
    structDelete( url, "offset" );

    for( var key in url ) {
      if( variables.entity.hasProperty( key )) {
        variables.where[key] = url[key];
      }
    }

    var useAF = false;
    var afCounter = 0;
    var afAlias = "";
    var afWhere = "";

    var HQLSelect = " SELECT e ";
    var HQLFrom   = " FROM #variables.entityName# e ";
    var HQLWhere  = " WHERE 0 = 0 ";
    var HQLOrder  = "";

    if( structKeyExists( variables.props, "sortorder" ) || structKeyExists( variables.props, "name" )) {
      HQLOrder = " ORDER BY ";
      if( structKeyExists( variables.props, "sortorder" )) {
        HQLOrder &= " e.sortorder, ";
      }
      if( structKeyExists( variables.props, "name" )) {
        HQLOrder &= " e.name, ";
      }
      HQLOrder = " " & listChangeDelims( trim( HQLOrder ), "," );
    }

    for( var key in variables.where ) {
      if( isSimpleValue( variables.where[key] )) {
        // NULL:
        if( variables.where[key] == "NULL" ) {
          HQLWhere &= " AND e.#key# IS NULL";
          structDelete( variables.where, key );
          continue;
        }

        // OBJECT IDs:
        if( structKeyExists( props[key], "cfc" )) {
          if( props[key].fieldType contains "to-many" ) {
            HQLFrom &= " JOIN e.#props[key].name# _#key# ";
            HQLWhere &= " AND _#key#.id IN ( :#key# ) ";
            variables.where[key] = listToArray( variables.where[key] );
            continue;
          } else {
            HQLFrom &= " JOIN e.#props[key].name# _#key# ";
            HQLWhere &= " AND _#key#.id = :#key# ";
            continue;
          }
        }

        // WILDCARD:
        if( structKeyExists( props[key], "searchable" )) {
          afAlias = "";
          afWhere = "";
          useAF = false;

          if( structKeyExists( props[key], "alsoFilter" ) && len( trim( props[key].alsoFilter ))) {
            useAF = true;
            afCounter++;

            var afTable = listFirst( props[key].alsoFilter, "." );
            var afField = listLast( props[key].alsoFilter, "." );
            afAlias = "_af_#afTable#_#afCounter#";
            afWhere = "#afAlias#.#afField#";

            HQLFrom &= " LEFT JOIN e.#afTable# #afAlias# ";
          }

          if( isDefined( "filterType" ) && len( trim( filterType ))) {
            if( filterType == "contains" ) {
              variables.where[key] = "%#variables.where[key]#";
            }
            variables.where[key] = "#variables.where[key]#%";

            if( useAF && len( trim( afWhere ))) {
              HQLWhere &= " AND ( e.#key# LIKE :#key# OR #afWhere# LIKE :#key# )";
              continue;
            }

            HQLWhere &= " AND e.#key# LIKE :#key# ";
          }
        }
      }

      // DEFAULT:
      if( useAF && len( trim( afWhere ))) {
        HQLWhere &= " AND ( e.#key# = :#key# OR #afWhere# = :#key# )";
        continue;
      }

      HQLWhere &= " AND e.#key# = :#key# ";
    }

    var HQLText = HQLSelect & HQLFrom & HQLWhere & HQLOrder;
    var data = ORMExecuteQuery( HQLText, variables.where, false, querySetings );

    var HQLTextForRecordCount = "SELECT COUNT( * ) " & HQLFrom & HQLWhere;
    var recordCount = ORMExecuteQuery( HQLTextForRecordCount, variables.where, false, { "cacheable" = rc.config.appIsLive });
    var result = [];

    for( var record in data ) {
      arrayAppend( result, dataService.processEntity( data = record, maxLevel = getMaxLevel() ));
    }

    framework.renderData( "rawjson", jsonService.serialize({
      "status" = "ok",
      "recordCount" = recordCount[1],
      "data" = result,
      "_debug" = {
        "hql" = HQLText,
        "where" = variables.where,
        "querySetings" = querySetings,
        "timer" = ( getTickCount() - variables.timer )
      }
    }));
  }

  // GET (detail)
  public void function show( required struct rc ) {
    var record = entityLoad( variables.entityName, variables.where, true );

    if( isNull( record )) {
      framework.renderData( "rawjson", jsonService.serialize({
        "status" = "not-found"
      }));
      return;
    }

    var result = dataService.processEntity( data = record, maxLevel = getMaxLevel() );

    framework.renderData( "rawjson", jsonService.serialize({
      "status" = "ok",
      "data" = result,
      "_debug" = {
        "where" = variables.where,
        "timer" = ( getTickCount() - variables.timer )
      }
    }));
  }

  // POST (new)
  public void function create( required struct rc ) {
    var payload = toString( GetHttpRequestData().content );

    if( structKeyExists( form, "batch" )) {
      if( isJSON( form.batch )) {
        form.batch = jsonService.deserialize( form.batch );
      } else {
        throw( "batch should be a JSON formatted array" );
      }
    } else if( isJson( payload ) ){
      form.batch = [ jsonService.deserialize( payload ) ];
    } else {
      form.batch= [];
      for( keyVal in listToArray( payload, "&" )){
        var key = urlDecode( listFirst( keyVal, "=" ));
        var val = urlDecode( listRest( keyVal, "=" ));
        form.batch[1][key] = val;
      }
    }

    var result = {
      "status" = "created",
      "data" = []
    };

    for( var objProperties in form.batch ) {
      structDelete( objProperties, "fieldnames" );
      structDelete( objProperties, "batch" );

      var newObject = entityNew( variables.entityName );
      entitySave( newObject );
      newObject.init().save( objProperties );

      arrayAppend( result.data, newObject );
    }

    framework.renderData( "rawjson", jsonService.serialize( result ), 201 );
  }

  // PUT (change)
  public void function update( required struct rc ) {
    var payload = toString( GetHttpRequestData().content );

    if( structKeyExists( form, "batch" )){
      if( isJSON( form.batch )){
        form.batch = jsonService.deserialize( form.batch );
      } else {
        throw( "batch should be a JSON formatted array" );
      }
    } else if( isJson( payload ) ){
      form.batch = [ jsonService.deserialize( payload) ];
    } else{
      form.batch= [];
      for( keyVal in listToArray( payload, "&" )){
        var key = urlDecode( listFirst( keyVal, "=" ));
        var val = urlDecode( listRest( keyVal, "=" ));
        form.batch[1][key] = val;
      }
    }

    var result = {
      "status" = "ok",
      "data" = []
    };

    for( var objProperties in form.batch ) {
      structDelete( objProperties, "fieldnames" );
      structDelete( objProperties, "batch" );

      var updateObject = entityLoad( variables.entityName, variables.where, true );

      if( isNull( updateObject )) {
        framework.renderData( "rawjson", jsonService.serialize({
          "status" = "not-found",
          "where" = variables.where
        }), 404 );
        return;
      }

      updateObject.init();
      objProperties["#variables.entityName#ID"] = updateObject.getID();
      updateObject.save( objProperties );
      arrayAppend( result.data, updateObject );
    }

    framework.renderData( "rawjson", jsonService.serialize( result ), 200 );
  }

  // DELETE
  public void function destroy( required struct rc ) {
    var data = entityLoad( variables.entityName, variables.where, true );

    if( isNull( data )) {
      framework.renderData( "rawjson", jsonService.serialize({
        "status" = "not-found"
      }), 404 );
      return;
    }

    data.init();
    data.save({
      "#variables.entityName#ID" = data.getID(),
      "deleted" = true
    });

    framework.renderData( "rawjson", jsonService.serialize({
      "status" = "no-content"
    }), 204 );
  }

  // INFO
  public void function info( required struct rc ) {
    framework.renderData( "rawjson", jsonService.serialize({
      "status" = "ok",
      "data" = getMetaData( createObject( "root.model.#variables.entityName#" ))
    }));
  }

  // public void function error( required struct rc ) {
  //   writeDump( rc );abort;
  // }

  // CATCH ALL HANDLER:
  public void function onMissingMethod( string missingMethodName, struct missingMethodArguments ) {
    if( listFindNoCase( "after", missingMethodName )) {
      return; // skip framework functions
    }

    var rc = missingMethodArguments.rc;
    var customArgs = {};
    structAppend( customArgs, url, true );
    structAppend( customArgs, form, true );

    if( arrayFindNoCase( variables.ormEntities, variables.entityName ) > 0 ) {
      var service = framework.getBeanFactory().getBean( '#variables.entityName#Service' );

      param string rc.filterType = "";
      param string rc.keywords = "";

      structAppend( customArgs, {
        maxResults = min( 10000, getMaxResults()),
        offset = getOffset(),
        filterType = rc.filterType,
        keywords = rc.keywords,
        cacheable = rc.config.appIsLive
      }, true );

      var executedMethod = evaluate( "service.#missingMethodName#(argumentCollection=customArgs)" );
      var result = [];

      for( var object in executedMethod ) {
        arrayAppend( result, dataService.processEntity( data = object, maxLevel = getMaxLevel()));
      }

      var debugInfo = service.getDebugInfo();
      debugInfo["timer"] = getTickCount() - variables.timer;

      framework.renderData( "rawjson", jsonService.serialize({
        "status" = "ok",
        "recordCount" = service.getRecordCount(),
        "data" = result,
        "_debug" = debugInfo
      }));
    } else {
      var service = framework.getBeanFactory().getBean( '#variables.entityName#Service' );
      var executedMethod = evaluate( "service.#missingMethodName#(argumentCollection=customArgs)" );
      if( !isNull( executedMethod )) {
        framework.renderData( "rawjson", jsonService.serialize( executedMethod ));
      }
    }
  }
}