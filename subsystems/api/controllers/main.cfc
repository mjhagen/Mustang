component extends="apibase"{
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public any function before(){
    var action = fw.getItem();

    writeLog( file=request.appName & "-API", text="#action# by #cgi.remote_addr#" );

    if( action eq "info" ){
      return;
    }

    var privilegeMapping = {
      "default" = "view",
      "show"    = "view",
      "create"  = "create",
      "update"  = "change",
      "destroy" = "delete"
    };

    if( structKeyExists( rc, "id" )){
      variables.where["id"] = rc.id;
    }

    if( !request.auth.role.can( privilegeMapping[action], variables.entityName )){
      return returnAsJSON({ "status" = "not-allowed" }); // STOP!
    }
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // utility debug method, can be removed later
  public string function info( Struct rc ){
    return returnAsJSON({ "status" = "ok", "data" = getMetaData( createObject( "root.model.#variables.entityName#" ))});
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // GET
  public string function default( Struct rc ){
    param rc.maxResults = 25;
    param rc.offset = 0;
    param rc.orderby = "";
    param rc.parameters = {};

    rc.parameters["cacheable"] = !request.reset;
    rc.parameters["maxResults"] = min( 10000, rc.maxResults );
    rc.parameters["offset"] = rc.offset;

    structDelete( url, "cacheable" );
    structDelete( url, "maxResults" );
    structDelete( url, "offset" );

    for( var key in url ){
      variables.where[key] = url[key];
    }

    var entity = entityNew( variables.entityName );
    var entityMeta = getMetaData( entity );
    var customProps = {};

    for( var key in variables.where ){
      if( not entity.hasProperty( key )){
        customProps[key] = variables.where[key];
        structDelete( variables.where, key );
      }
    }

    // search JSON fields:
    if( structCount( customProps )){
      var allProps = entity.getInheritedProperties();
      var jsonProps = structFindValue({ struct = allProps }, "json" );
      var jsonFields = [];

      for( var jsonProp in jsonProps ){
        arrayAppend( jsonFields, jsonProp.owner.name );
      }

      if( arrayLen( jsonFields )){
        var tableName = variables.entityName;

        if( structKeyExists( entityMeta, "table" )){
          tableName = entityMeta.table;
        }

        var SQLText = 'SELECT id FROM "#tableName#" WHERE 0 = 0 ';

        for( var jsonField in jsonFields ){
          for( var key in customProps ){
            // TODO: treat numbers as numbers, for now it's text only
            SQLText &= " AND CAST( #jsonField# AS jsonb ) ->> '#key#' = '#customProps[key]#'";
          }
        }

        var jsonParamResult = queryExecute( SQLText );
      }
    }

    var HQLText = "FROM #variables.entityName# e WHERE 0 = 0";

    if( structCount( variables.where )){
      for( var key in variables.where ){
        if( isSimpleValue( variables.where[key] ) and variables.where[key] eq "NULL" ){
          HQLText &= " AND #key# IS NULL";
          structDelete( variables.where, key );
        } else {
          HQLText &= " AND #key# = :#key#";
        }
      }
    }

    if( not isNull( jsonParamResult )){
      if( jsonParamResult.recordCount ){
        HQLText &= " AND e.id IN ( :ids )";
        variables.where["ids"] = listToArray( valueList( jsonParamResult.id ));
      } else {
        // return 0 results when searching on JSON param, but nothing found:
        HQLText &= " AND 0 = 1";
      }
    }

    var data = ORMExecuteQuery( HQLText, variables.where, false, rc.parameters );

    var result = [];
    for( var record in data ){
      arrayAppend( result, processEntity( record ));
    }

    return returnAsJSON({
      "status" = "ok",
      "recordCount" = arrayLen( result ),
      "maxResults" = rc.maxResults,
      "offset" = rc.offset,
      "data" = result
    });
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // GET with ID
  public string function show( Struct rc ){
    var record = entityLoad( variables.entityName, variables.where, true );

    if( isNull( record )){
      return returnAsJSON({
        "status" = "not-found"
      });
    }

    return returnAsJSON({
      "status" = "ok",
      "data" = processEntity( record )
    });
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // POST new
  public string function create( Struct rc ){
    if( structKeyExists( form, "batch" )){
      if( isJSON( form.batch )){
        form.batch = deserializeJSON( form.batch );
      } else {
        throw( "batch should be a JSON formatted array" );
      }
    } else {
      form.batch = [
        duplicate( form )
      ];
    }

    var result = {
      "status" = "created",
      "data" = []
    };

    try{
      transaction{
        for( var objProperties in form.batch ){
          structDelete( objProperties, "fieldnames" );
          structDelete( objProperties, "batch" );

          var newObject = entityNew( variables.entityName );
          entitySave( newObject );
          newObject.save( objProperties );

          arrayAppend( result.data, newObject );
        }

        transactionCommit();
      }
    } catch( Any e ){
      result["error"] = e.message;
      result["detail"] = e.detail;
    }

    if( structKeyExists( result, "error" )){
      result.status = "error";
    }

    return returnAsJSON( result );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // PUT change
  public string function update( Struct rc ){
    if( structKeyExists( form, "batch" )){
      if( isJSON( form.batch )){
        form.batch = deserializeJSON( form.batch );
      } else {
        throw( "batch should be a JSON formatted array" );
      }
    } else {
      form.batch = [
        duplicate( form )
      ];
    }

    var result = {
      "status" = "ok",
      "data" = []
    };

    try{
      transaction{
        for( var objProperties in form.batch ){
          structDelete( objProperties, "fieldnames" );
          structDelete( objProperties, "batch" );

          var updateObject = entityLoad( variables.entityName, variables.where, true );

          if( isNull( updateObject )){
            return returnAsJSON({
              "status" = "not-found",
              "where" = variables.where
            });
          }

          var key = 0;
          var val = 0;

          for( keyVal in listToArray( getHttpRequestData().content, "&" )){
            var key = urlDecode( listFirst( keyVal, "=" ));
            var val = urlDecode( listRest( keyVal, "=" ));
            objProperties[key] = val;
          }

          objProperties["#variables.entityName#ID"] = updateObject.getID();
          updateObject.save( objProperties );
          arrayAppend( result.data, updateObject );
        }

        transactionCommit();
      }
    } catch( Any e ){
      result["error"] = e.message;
      result["detail"] = e.detail;
    }

    if( structKeyExists( result, "error" )){
      result.status = "error";
    }

    return returnAsJSON( result );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // DELETE
  /**
  * Marks an object as deleted
  * @return HTTP 204 OK, or
  * @return HTTP 404 Not found
  */
  public string function destroy( Struct rc ){
    transaction{
      var data = entityLoad( variables.entityName, variables.where, true );

      if( isNull( data )){
        return returnAsJSON({
          "status" = "not-found"
        });
      }

      data.save({
        "#variables.entityName#ID" = data.getID(),
        "deleted" = true
      });

      transactionCommit();
    }

    return returnAsJSON({
      "status" = "no-content"
    });
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  private struct function processEntity( entity ){
    var props = entity.getInheritedProperties();
    var result = {};

    for( var key in props ){
      var prop = props[key];

      if( structKeyExists( prop, "inapi" ) and
          isBoolean( prop.inapi ) and
          not prop.inapi ){
        continue;
      }

      var propVal = evaluate( "entity.get#prop.name#()" );

      if( isNull( propVal )){
        result[lCase( prop.name )] = "";
        continue;
      }

      if( isArray( propVal )){
        var propValArray = [];
        for( var item in propVal ){
          if( isObject( item )){
            arrayAppend( propValArray, getBasics( item ));
          } else if( isSimpleValue( item )){
            if( isJSON( item )){
              arrayAppend( propValArray, deserializeJSON( item ));
            } else {
              arrayAppend( propValArray, item );
            }
          }
       }

        result[lCase( prop.name )] = propValArray;
      } else if( isObject( propVal )){
        result[lCase( prop.name )] = getBasics( propVal );
      } else {
        result[lCase( prop.name )] = propVal;
      }
    }

    var jsonProps = structFindValue( props, "json" );

    for( var jsonProp in jsonProps ){
      if( jsonProp.path contains '.datatype' ){
        var jsonField = jsonProp.owner.name;

        if( structKeyExists( result, jsonField ) and isJSON( result[jsonField] )){
          structAppend( result, deserializeJSON( result[jsonField] ));
          structDelete( result, jsonField );
        }
      }
    }

    return result;
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  private struct function getBasics( entity ){
    var itemProps = entity.getInheritedProperties();
    var itemBasics = {};

    for( var key in itemProps ){
      var itemProp = itemProps[key];

      if( structKeyExists( itemProp, "fieldType" ) and not listFind( "column,id", itemProp.fieldType )){
        continue;
      }

      itemBasics[key] = evaluate( "entity.get#itemProp.name#()" );
    }

    var jsonProps = structFindValue( itemProps, "json" );

    for( var jsonProp in jsonProps ){
      if( jsonProp.path contains '.datatype' ){
        var jsonField = jsonProp.owner.name;

        if( structKeyExists( itemBasics, jsonField ) and isJSON( itemBasics[jsonField] )){
          structAppend( itemBasics, deserializeJSON( itemBasics[jsonField] ));
          structDelete( itemBasics, jsonField );
        }
      }
    }

    return itemBasics;
  }
}