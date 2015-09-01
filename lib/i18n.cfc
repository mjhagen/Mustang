component{
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public i18n function init( string locale = request.context.config.defaultLanguage ){
    variables.languageFileName = locale & ".json";
    variables.localeID = "";
    return this;
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public string function translate( required string label, string localeID = variables.localeID, string alternative, struct stringVariables = {}, boolean capFirst = true ){
    if( isNull( alternative )){
      alternative = label;
    }

    var result = "";
    var usecache = request.context.config.appIsLive;
    var translation = "";

    if( structKeyExists( url, "reload" )){
      usecache = false;
    }

    if( label == "" && alternative == "" ){
      translation = "Please provide a label to translate.";
    } else {
      translation = cacheRead( label, localeID, !usecache );
    }

    if( !len( trim( translation ))){
      translation = capFirst ? request.context.util.capFirst( alternative ) : alternative;

      // Try some default translation options on FQAs
      if( listLen( label, ":" ) == 2 && listLen( label, "." ) == 2 ){
        var subsystem  = listFirst( label, ":" );
        var section    = listFirst( listRest( label, ":" ), "." );
        var item       = listRest( listRest( label, ":" ), "." );

        if( label == "#subsystem#:#section#.default" ){
          translation = "{#subsystem#:#section#}";
        }

        if( label == "#subsystem#:#section#.view" ){
          translation = "{#section#}";
        }

        if( label == "#subsystem#:#section#.edit" ){
          translation = "{btn-edit} {#section#}";
        }

        if( label == "#subsystem#:#section#.new" ){
          translation = "{btn-new} {#section#}";
        }

        if( listFirst( label, "-" ) == "btn" ){
          translation = "{btn-#item#} {#section#}";
        }
      } else if( listLen( label, ":" ) == 2 ){
        translation = "{#listLast( label, ':' )#s}";
      } else if( listLen( label, "-" ) gte 2 && listFirst( label, "-" ) == "placeholder" ){
        translation = "{placeholder} {#listRest( label, '-' )#}";
      }
    }

    result = parseStringVariables( translation, stringVariables );

    // replace {label} with whatever comes out of translate( 'label' )
    for( var _label_ in REMatchNoCase( '{[^}]+}', result )){
      result = replaceNoCase( result, _label_, translate( mid( _label_, 2, len( _label_ ) - 2 )));
    }

    return result;
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public string function cacheRead( required string label, string localeID = variables.localeID, boolean reload = false ){
    var result = "";

    // SEARCH CACHE FOR LABEL:
    lock name="fw1_#application.applicationName#_translations_#localeID#" type="exclusive" timeout="30" {
      if( reload ){
        structDelete( application, "translations" );
      }

      if( structKeyExists( application, "translations" ) &&
          structKeyExists( application.translations, localeID ) &&
          structKeyExists( application.translations[localeID], label )){
        return application.translations[localeID][label];
      }

      if( !structKeyExists( application, "translations" )){
        application.translations = {};
      }

      if( !structKeyExists( application.translations, localeID )){
        application.translations[localeID] = {};
      }

      if( !structKeyExists( application.translations[localeID], label )){
        var lanStruct = getLanStruct();

        if( structKeyExists( lanStruct, label )){
          application.translations[localeID][label] = lanStruct[label];
        }
      }

      if( structKeyExists( application.translations[localeID], label )){
        result = application.translations[localeID][label];
      }
    }

    return result;
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public string function parseStringVariables( required string stringToParse, struct stringVariables = {} ){
    if( isNull( stringVariables ) || !structCount( stringVariables )){
      return stringToParse;
    }

    for( var key in stringVariables ){
      stringToParse = replaceNoCase( stringToParse, '###key###', stringVariables[key] );
    }

    return stringToParse;
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public struct function getLanStruct(){
    return deserializeJSON( fileRead( '#request.root#/i18n/#languageFileName#', 'utf-8' ));
  }
}