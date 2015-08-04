component
{
  variables.languageFileName = "";

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public i18n function init( string locale = request.context.config.defaultLanguage ){
    variables.languageFileName = locale & ".json";
    return this;
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public struct function getLanStruct()
  {
    return deserializeJSON( fileRead( '#request.root#/i18n/#languageFileName#', 'utf-8' ));
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public string function translate( required string label, string languageid = "", string alternative = "", struct stringVariables = {}, boolean capFirst = true )
  {
    if( isNull( alternative ) or not len( trim( alternative )))
    {
      alternative = label;
    }

    if( not structKeyExists( request, "infLoopGuard" ))
    {
      request.infLoopGuard = 0;
    }

    request.infLoopGuard++;

    if( request.infLoopGuard gt 4 )
    {
      return alternative;
    }

    var result = "";
    var usecache = request.context.config.appIsLive;
    var translation = "";

    if( structKeyExists( url, "reload" ) )
    {
      usecache = false;
    }

    if( label eq "" and alternative eq "" )
    {
      translation = "Please provide a label to translate.";
    } else {
      translation = cacheRead( label, languageid, !usecache );
    }

    if( not len( trim( translation )))
    {
      translation = alternative;

      // Try some default translation options on FQAs
      if( listLen( label, ":" ) eq 2 and listLen( label, "." ) eq 2 )
      {
        var subsystem  = listFirst( label, ":" );
        var section    = listFirst( listRest( label, ":" ), "." );
        var item       = listRest( listRest( label, ":" ), "." );

        if( label eq "#subsystem#:#section#.default" )
        {
          translation = "{#subsystem#:#section#}";
        }

        if( label eq "#subsystem#:#section#.view" )
        {
          translation = "{#section#}";
        }

        if( label eq "#subsystem#:#section#.edit" )
        {
          translation = "{btn-edit} {#section#}";
        }

        if( label eq "#subsystem#:#section#.new" )
        {
          translation = "{btn-new} {#section#}";
        }

        if( listFirst( label, "-" ) eq "btn" )
        {
          translation = "{btn-#item#} {#section#}";
        }
      }
      else if( listLen( label, ":" ) eq 2 )
      {
        translation = "{#listLast( label, ':' )#s}";
      }
      else if( listLen( label, "-" ) gte 2 and listFirst( label, "-" ) eq "placeholder" )
      {
        translation = "{placeholder} {#listRest( label, '-' )#}";
      }
    }

    result = parseStringVariables( translation, stringVariables );

    // replace {label} with whatever comes out of translate( 'label' )
    for( var _label_ in REMatchNoCase( '{[^}]+}', result ))
    {
      result = replaceNoCase( result, _label_, translate( mid( _label_, 2, len( _label_ ) - 2 )));
    }

    structDelete( request, "infLoopGuard" );

    return capFirst ? request.context.util.capFirst( result ) : result;
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public string function cacheRead( required string label, string languageid = session.languageid, boolean reload = false )
  {
    var result = "";

    // SEARCH CACHE FOR LABEL:
    lock name="fw1_#application.applicationName#_translations_#languageid#" type="exclusive" timeout="30"
    {
      if( reload )
      {
        structDelete( application, "translations" );
      }

      if( structKeyExists( application, "translations" ) and
            structKeyExists( application.translations, languageid ) and
            structKeyExists( application.translations[languageid], label ))
      {
        return application.translations[languageid][label];
      }

      if( not structKeyExists( application, "translations" ))
      {
        application.translations = {};
      }

      if( not structKeyExists( application.translations, languageid ))
      {
        application.translations[languageid] = {};
      }

      if( not structKeyExists( application.translations[languageid], label ))
      {
        var lanStruct = getLanStruct();
        if( structKeyExists( lanStruct, label ))
        {
          application.translations[languageid][label] = lanStruct[label];
        }
      }

      if( structKeyExists( application.translations[languageid], label ))
      {
        result = application.translations[languageid][label];
      }
    }

    return result;
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public string function parseStringVariables( required string stringToParse, struct stringVariables = {} )
  {
    if( isNull( stringVariables ) or not structCount( stringVariables ))
    {
      return stringToParse;
    }

    for( var key in stringVariables )
    {
      stringToParse = replaceNoCase( stringToParse, '###key###', stringVariables[key] );
    }

    return stringToParse;
  }
}