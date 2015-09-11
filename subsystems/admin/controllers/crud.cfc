component accessors=true {
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public any function init( fw ){
    param variables.listitems     = "";
    param variables.listactions   = ".new";
    param variables.lineactions   = ".view,.edit";
    param variables.showNavbar    = true;
    param variables.showSearch    = false;
    param variables.showAlphabet  = false;
    param variables.showPager     = true;
    param variables.entity        = fw.getSection();
    param array variables.submitButtons = [];

    variables.fw = fw;

    return this;
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public void function before( rc ){
    if( !rc.auth.role.getCanAccessAdmin()){
      fw.redirect( "home:" );
    }

    if( fw.getItem() == "edit" && !rc.auth.role.can( "change", fw.getSection())){
      session.alert = {
        "class" = "danger",
        "text"  = "privileges-error-1"
      };
      fw.redirect( "admin:" );
    }

    session.alert = {
      "class" = "danger",
      "text"  = "privileges-error-2"
    };

    if( rc.auth.role.can( "view", fw.getSection()) || fw.getSection() == "main" ){
      structDelete( session, "alert" );
    }

    if( fw.getSection() == "api" ){
      session.alert = {
        "class" = "danger",
        "text"  = "privileges-error-3"
      };
      fw.redirect( "api:" );
    }

    if( structKeyExists( session, "alert" )){
      fw.redirect( "admin:" );
    }

    variables.entity = fw.getSection();
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public void function default( rc ){
    param rc.columns      = [];
    param rc.offset       = 0;
    param rc.maxResults   = 30;
    param rc.d            = 0;// rc.d(escending) default false (ASC)
    param rc.orderby      = "";
    param rc.startsWith   = "";
    param rc.showdeleted  = 0;
    param rc.filters      = [];
    param rc.filterType   = "contains";
    param rc.classColumn  = "";

    // exit controller on non crud items
    switch( fw.getSection()){
      case "main":
        var dashboard = lCase( replace( rc.auth.role.getName(), ' ', '-', 'all' ));
        fw.setView( 'admin:main.dashboard-' & dashboard );
        return;
      break;

      case "profile":
        rc.data = entityLoadByPK( "contact", rc.auth.userid );
        fw.setView( 'profile.default' );
        return;
      break;
    }

    param rc.lineView     = "elements/line";
    param rc.tableView    = "elements/table";
    param rc.fallbackView = "elements/list";

    // default crud behaviour continues:
    rc.entity = variables.entity;

    // exit with error when trying to control a non-persisted entity
    if( !arrayFindNoCase( structKeyArray( ORMGetSessionFactory().getAllClassMetadata()), variables.entity )){
      rc.fallbackView = "app/notfound";
      fw.setView( 'admin:main.#variables.entity#' );
      return;
    }

    var object = entityNew( variables.entity );
    var entityProperties = getMetaData( object );
    var property = "";
    var indexNr = 0;
    var orderNr = 0;
    var columnName = "";
    var columnsInList = [];
    var orderByString = "";
    var queryOptions = { ignorecase = true, maxResults = rc.maxResults, offset = rc.offset };

    rc.recordCounter  = 0;
    rc.deleteddata    = 0;
    rc.properties     = object.getInheritedProperties();
    rc.lineactions    = variables.lineactions;
    rc.listactions    = variables.listactions;
    rc.showNavbar     = variables.showNavbar;
    rc.showSearch     = variables.showSearch;
    rc.showAlphabet   = variables.showAlphabet;
    rc.showPager      = variables.showPager;
    rc.showAsTree     = false;

    // exit out of controller if using a tree view (data retrieval goes through ajax calls instead)
    if( structKeyExists( entityProperties, "list" )){
      rc.tableView  = "elements/" & entityProperties.list;

      if( entityProperties.list == "hierarchy" ){
        rc.allColumns = {};
        rc.allData = [];
        rc.showAsTree = true;
        return;
      }
    }

    if( !rc.auth.role.can( "change", variables.entity )){
      var lineactionPointer = listFind( rc.lineactions, '.edit' );
      if( lineactionPointer ){
        rc.lineactions = listDeleteAt( rc.lineactions, lineactionPointer );
      }
    }

    if( structKeyExists( entityProperties, "classColumn" ) && len( trim( entityProperties.classColumn ))){
      classColumn = entityProperties.classColumn;
    }

    rc.defaultSort = "";

    if( structKeyExists( entityProperties, "defaultSort" )){
      rc.defaultSort = entityProperties.defaultSort;
    } else if( structKeyExists( entityProperties.extends, "defaultSort" )){
      rc.defaultSort = entityProperties.extends.defaultSort;
    }

    if( len( trim( rc.orderby ))){
      local.vettedOrderByString = "";

      for( var orderField in listToArray( rc.orderby )){
        if( orderField contains ';' ){
          continue;
        }

        if( orderField contains ' ASC' || orderField contains ' DESC' ){
          orderField = listFirst( orderField, ' ' );
        }

        if( structKeyExists( rc.properties, orderField )){
          local.vettedOrderByString = listAppend( local.vettedOrderByString, orderField );
        }
      }

      rc.orderby = local.vettedOrderByString;

      if( len( trim( rc.orderby ))){
        rc.defaultSort = rc.orderby & ( rc.d ? ' DESC' : '' );
      }
    }

    rc.orderby = replaceNoCase( rc.defaultSort, ' ASC', '', 'all' );
    rc.orderby = replaceNoCase( rc.orderby, ' DESC', '', 'all' );

    if( rc.defaultSort contains ' DESC' ){
      rc.d = 1;
    } else if( rc.defaultSort contains ' ASC' ){
      rc.d = 0;
    }

    for( orderByPart in listToArray( rc.defaultSort )){
      orderByString = listAppend( orderByString, "mainEntity.#orderByPart#" );
    }

    if( len( trim( rc.startsWith ))){
      rc.filters = [{
        "field" = "name",
        "filterOn" = replace( rc.startsWith, '''', '''''', 'all' )
      }];
      rc.filterType = "starts-with";
    }

      for( var key in rc ){
        if( !isSimpleValue( rc[key] )){
          continue;
        }

        key = urlDecode( key );

        if( listFirst( key, "_" ) == "filter" && len( trim( rc[key] ))){
        arrayAppend( rc.filters, { "field" = listRest( key, "_" ), "filterOn" = replace( rc[key], '''', '''''', 'all' ) });
        }
      }

    if( !structKeyExists( rc, "alldata" )){
      if( arrayLen( rc.filters ))
      {
        var alsoFilterKeys = structFindKey( rc.properties, 'alsoFilter' );
        var alsoFilterEntity = "";
        var whereBlock = " WHERE 0 = 0 ";
        var whereParameters = {};
        var counter = 0;

        if( rc.showdeleted == 0 ){
          whereBlock &= " AND ( mainEntity.deleted IS NULL OR mainEntity.deleted = false ) ";
        }

        for( var filter in rc.filters ){
          if( len( filter.field ) gt 2 && right( filter.field, 2 ) == "id" ){
            whereBlock &= "AND mainEntity.#left( filter.field, len( filter.field ) - 2 )# = ( FROM #left( filter.field, len( filter.field ) - 2 )# WHERE id = :where_id )";
            whereParameters["where_id"] = filter.filterOn;
          } else {
            if( filter.filterOn == "NULL" ){
              whereBlock &= " AND ( ";
              whereBlock &= " mainEntity.#lCase( filter.field )# IS NULL ";
            } else if( structKeyExists( rc.properties[filter.field], "cfc" )){
              whereBlock &= " AND ( ";
              whereBlock &= " mainEntity.#lCase( filter.field )#.id = :where_#lCase( filter.field )# ";
              whereParameters["where_#lCase( filter.field )#"] = filter.filterOn;
            } else {
              if( rc.filterType == "contains" ){
                filter.filterOn = "%#filter.filterOn#";
              }

              filter.filterOn = "#filter.filterOn#%";

              whereBlock &= " AND ( ";
              whereBlock &= " mainEntity.#lCase( filter.field )# LIKE :where_#lCase( filter.field )# ";
              whereParameters["where_#lCase( filter.field )#"] = filter.filterOn;
            }

            for( var alsoFilterKey in alsoFilterKeys ){
              if( alsoFilterKey.owner.name neq filter.field ){
                continue;
              }

              counter++;
              alsoFilterEntity &= " LEFT JOIN mainEntity.#listFirst( alsoFilterKey.owner.alsoFilter, '.' )# AS entity_#counter# ";
              whereBlock &= " OR entity_#counter#.#listLast( alsoFilterKey.owner.alsoFilter, '.' )# LIKE '#filter.filterOn#' ";
              whereParameters["where_#listLast( alsoFilterKey.owner.alsoFilter, '.' )#"] = filter.filterOn;
            }
            whereBlock &= " ) ";
          }
        }

        if( structKeyExists( entityProperties, "where" ) && len( trim( entityProperties.where ))){
          whereBlock &= entityProperties.where;
        }

        var HQLcounter  = " SELECT COUNT( mainEntity ) AS total ";
        var HQLselector  = " SELECT mainEntity ";

        var HQL = "";
        HQL &= " FROM #lCase( variables.entity )# mainEntity ";
        HQL &= alsoFilterEntity;
        HQL &= whereBlock;

        HQLcounter = HQLcounter & HQL;
        HQLselector = HQLselector & HQL;

        if( len( trim( orderByString ))){
          HQLselector &= " ORDER BY #orderByString# ";
        }

        rc.alldata = ORMExecuteQuery( HQLselector, whereParameters, queryOptions );

        if( arrayLen( rc.alldata ) gt 0 ){
          rc.recordCounter = ORMExecuteQuery( HQLcounter, whereParameters, { ignorecase = true })[1];
        }
      } else {
        var HQL = " FROM #lCase( variables.entity )# mainEntity ";

        if( rc.showDeleted ){
          HQL &= " WHERE mainEntity.deleted = TRUE ";
        } else {
          HQL &= " WHERE ( mainEntity.deleted IS NULL OR mainEntity.deleted = FALSE ) ";
        }

        if( len( trim( orderByString ))){
          HQL &= " ORDER BY #orderByString# ";
        }

        try{
          rc.alldata = ORMExecuteQuery( HQL, {}, queryOptions );
        } catch( any e ) {
          writeDump( e );
          abort;
          rc.alldata = [];
        }

        if( arrayLen( rc.alldata ) gt 0 ){
          rc.recordCounter = ORMExecuteQuery( "SELECT COUNT( e ) AS total FROM #lCase( variables.entity )# AS e WHERE e.deleted != :deleted", { "deleted" = true }, { ignorecase = true })[1];
          rc.deleteddata = ORMExecuteQuery( "SELECT COUNT( mainEntity.id ) AS total FROM #lCase( variables.entity )# AS mainEntity WHERE mainEntity.deleted = :deleted", { "deleted" = true } )[1];

          if( rc.showdeleted ){
            rc.recordCounter = rc.deleteddata;
          }
        }
      }
    }

    rc.allColumns     = {};

    var columnsInList = [];
    var property = "";
    var indexNr = 0;
    var orderNr = 0;
    for( var key in rc.properties ){
      property = rc.properties[key];
      orderNr++;
      rc.allColumns[property.name] = property;
      rc.allColumns[property.name].columnIndex = orderNr;
      if( structKeyExists( property, "inlist" )){
        indexNr++;
        columnsInList[indexNr] = property.name;
      }
    }

    if( len( trim( variables.listitems ))){
      columnsInList = [];
      for( var listItem in variables.listitems ){
        arrayAppend( columnsInList, listItem );
      }
    }

    if( variables.entity == 'logged' ){
      arrayAppend( columnsInList, "entityName" );
      arrayAppend( columnsInList, "name" );
      arrayAppend( columnsInList, "createDate" );
      arrayAppend( columnsInList, "updateDate" );
    }

    var numberOfColumns = arrayLen( columnsInList );

    try{
      for( var columnName in columnsInList ){
        if( structKeyExists( rc.allColumns, columnName )){
          var property = rc.allColumns[columnName];
          arrayAppend( rc.columns, {
            name        = columnName,
            orderNr     = structKeyExists( property, "cfc" )?0:property.columnIndex,
            orderInList = structKeyExists( property, "orderinlist" )?property.orderinlist:numberOfColumns++,
            class       = structKeyExists( property, "class" )?property.class:'',
            data        = property
          });
        }
      }
    } catch( any e ) {
      writeDump( cfcatch );
      abort;
    }

    // sort the array based on the orderInList value in the structures:
    for( var i=1; i lte arrayLen( rc.columns ); i++ ){
      for( var j=(i-1)+1; j gt 1; j-- ){
        if( rc.columns[j].orderInList lt rc.columns[j-1].orderInList ){
          // swap values
          var temp = rc.columns[j];
          rc.columns[j] = rc.columns[j-1];
          rc.columns[j-1] = temp;
        }
      }
    }
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public void function new( rc ){
    if( !rc.auth.role.can( "change", fw.getSection())){
      session.alert = {
        "class" = "danger",
        "text"  = "privileges-error"
      };
      fw.redirect( "admin:#fw.getSection()#.default" );
    }
    edit( rc = rc );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public void function view( rc ){
    rc.editable = false;
    edit( rc = rc );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public void function edit( rc ){
    param rc.modal = false;
    param rc.editable = true;
    param rc.inline = false;
    param rc.namePrepend = "";

    rc.submitButtons = variables.submitButtons;
    rc.fallbackView = "elements/edit";

    if( rc.modal ){
      request.layout = false;
      rc.fallbackView = "elements/modaledit";

      if( rc.inline ){
        rc.fallbackView = "elements/inlineedit";
      }
    }

    rc.entity = variables.entity;
    var object = entityNew( rc.entity );

    // is this a loggable object?
    rc.canBeLogged = ( rc.config.log && isInstanceOf( object, "root.model.logged" ));
    if( rc.entity == "logentry" ){
      rc.canBeLogged = false;
    }

    // load form properties
    rc.properties = object.getInheritedProperties();

    var propertiesInForm = [];
    for( var key in rc.properties ){
      if( structKeyExists( rc.properties[key], "inform" )){
        arrayAppend( propertiesInForm, rc.properties[key] );
      }
    }

    rc.entityProperties = getMetaData( object );

    rc.hideDelete = structKeyExists( rc.entityProperties, "hideDelete" );

    if( structKeyExists( rc, "#rc.entity#id" ) && !len( trim( rc["#rc.entity#id"] ))){
      structDelete( rc, "#rc.entity#id" );
    }

    if( structKeyExists( rc, "#rc.entity#id" )){
      rc.data = entityLoadByPK( rc.entity, rc["#rc.entity#id"] );
      if( !isDefined( "rc.data" )){
        fw.redirect( rc.entity );
      }
    }

    if( isNull( rc.data )){
      rc.data = entityNew( rc.entity );
    }

    // prep the form fields and sort them in the right order
    var indexNr = 0;
    var columnsInForm = [];
    var numberOfPropertiesInForm = arrayLen( propertiesInForm ) + 10;

    for( var property in propertiesInForm ){
      if( structKeyExists( property, "orderinform" ) && isNumeric( property.orderinform )){
        indexNr = property.orderinform;
      } else {
        indexNr = numberOfPropertiesInForm++;
      }

      columnsInForm[indexNr] = duplicate( property );
      columnsInForm[indexNr].saved = "";

      var savedValue = evaluate( "rc.data.get#property.name#()" );

      if( !isNull( savedValue )){
        if( isArray( savedValue )){
          var savedValueList = "";
          for( var individualValue in savedValue ){
            savedValueList = listAppend( savedValueList, individualValue.getID() );
          }
          savedValue = savedValueList;
        }

        columnsInForm[indexNr].saved = savedValue;
      } else if( structKeyExists( rc, property.name )) {
        columnsInForm[indexNr].saved = rc[property.name];
      }
    }

    rc.columns = [];

    for( var columnInForm in columnsInForm ){
      if( !isNull( columnInForm )){
        arrayAppend( rc.columns, columnInForm );
      }
    }
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public void function delete( rc ){
    if( !rc.auth.role.can( "delete", fw.getSection())){
      session.alert = {
        "class" = "danger",
        "text"  = "privileges-error"
      };
      fw.redirect( "admin:#fw.getSection()#.default" );
    }

    transaction {
    var entityToDelete = entityLoadByPK( variables.entity, rc["#variables.entity#id"] );

    if( !isNull( entityToDelete )){
      entityToDelete.save({ "deleted" = true });

      if( entityToDelete.hasProperty( "log" )){
          var logentry = entityNew( "logentry", { entity = entityToDelete } );
          rc.log = logentry.enterIntoLog( "removed" );
      }
      }

      transactionCommit();
    }

    fw.redirect( ".default" );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public void function restore( rc ){
    transaction {
    var entityToRestore = entityLoadByPK( variables.entity, rc["#variables.entity#id"] );

    if( !isNull( entityToRestore )){
      entityToRestore.save({ "deleted" = false });

      if( entityToRestore.hasProperty( "log" )){
          var logentry = entityNew( "logentry", { entity = entityToRestore } );
          rc.log = logentry.enterIntoLog( "restored" );
      }
      }

      transactionCommit();
    }

    fw.redirect( ".view", "#variables.entity#id" );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public void function save( rc ){
    if( structCount( form ) == 0 ){
      session.alert = {
        "class" = "danger",
        "text"  = "global-form-error"
      };
      fw.redirect( "admin:#fw.getSection()#.default" );
    }

    if( !rc.auth.role.can( "change", fw.getSection())){
      session.alert = {
        "class" = "danger",
        "text"  = "privileges-error"
      };
      fw.redirect( "admin:#fw.getSection()#.default" );
    }

    transaction {
    // Load existing, or create a new entity
    if( structKeyExists( rc, "#variables.entity#id" )){
      rc.data = entityLoadByPK( variables.entity, rc["#variables.entity#id"] );
    } else {
      rc.data = entityNew( variables.entity );
      entitySave( rc.data );
    }

    // Log create/update time and user if( object supprts it:
      rc.data = rc.data.save( rc );

      transactionCommit();
    }

    if( !( structKeyExists( rc, "dontredirect" ) && rc.dontredirect )){
      if( structKeyExists( rc, "returnto" )){
        fw.redirect( rc.returnto );
      } else {
        fw.redirect( ".default" );
      }
    }
  }
}