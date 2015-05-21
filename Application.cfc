component extends="framework.one"
{
  // defaults:
  variables.live = true;
  variables.downForMaintenance = false;

  // globals:

  request.version = "1.0.0";
  request.reset = false;
  request.root = getDirectoryFromPath( getCurrentTemplatePath());
  request.context.config = readConfigFile( cgi.server_name );
  request.webroot = request.context.config.webroot;
  request.fileUploads = request.context.config.fileUploads; // request.root & '../files_' & this.name;
  request.adminNotCRUD = ["database"];

  // CF application setup:
  this.sessionmanagement = true;
  this.setclientcookies = true;
  this.sessiontimeout = createTimeSpan( 0, 2, 0, 0 );
  this.mappings = {
    "/#this.name#" = request.root,
    "/model" = request.root & "/model"
  };

  // framework settings:
  variables.framework = {
    error = "common:app.error",
    usingSubsystems = true,
    defaultSubsystem = "admin",
    generateSES = false,
    SESOmitIndex = false,
    baseURL = request.context.config.webroot,
    base = "/app",
    diEngine = "none",
    environments = {
      live = {
        cacheFileExists = true,
        password = request.context.config.reloadpw
      },
      dev = {
        reloadApplicationOnEveryRequest = true,
        trace = false
      }
    }
  };

  // debug settings:
  request.context.debug = false;

  if( listFind( request.context.config.debugIP, cgi.remote_addr ) and request.context.config.showDebug )
  {
    request.context.debug = true;
  }

  if( structKeyExists( url, "reload" ) and url.reload neq request.context.config.reloadpw )
  {
    structDelete( url, "reload" );
  }

  if( structKeyExists( url, "nuke" ))
  {
    request.reset = structKeyExists( url, "reload" );
  }

  variables.live = request.context.config.appIsLive;

  // Datasource settings:
  this.datasource = request.context.config.datasource;
  this.ormEnabled = true;
  this.ormsettings = {
    CFCLocation = "/model",
    DBCreate = ( request.reset ? "update" : ( variables.live ? "none" : "update" )),
    logSQL = variables.live ? false : true,
    sqlscript = request.context.config.nukescript,
    secondaryCacheEnabled = variables.live ? true : false,
    savemapping = false,
    autogenmap = true
  };

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public any function setupApplication()
  {
    if( request.reset )
    {
      ORMReload();
    }

    ORMEvictQueries();
    cacheRemove( arrayToList( cacheGetAllIds()));

    application.i18n = new services.i18n( request.context.config.defaultLanguage );
    application.util = new services.util();

    application.designService = new services.design();
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public any function setupRequest()
    {
    request.context.startTime = getTickCount();

    // globally available utility libraries:
    lock scope="application" timeout="5" type="readOnly"
    {
      request.context.i18n = variables.i18n = application.i18n;
      request.context.util = variables.util = application.util;
      request.context.JSONUtil = variables.JSONUtil = application.JSONUtil;
      request.context.designService = variables.designService = application.designService;
    }

    variables.util.setCFSetting( "showdebugoutput", request.context.debug );

    // rate limiter:
    variables.util.limiter( 10, 50, 5 );

    // alert messages:
    lock scope="session" timeout="5" type="readOnly"
    {
      if( structKeyExists( session, "alert" ) and isStruct( session.alert ) and
          structKeyExists( session.alert, 'class' ) and
          structKeyExists( session.alert, 'text' ))
      {
        request.context.alert = session.alert;

        if( not structKeyExists( request.context.alert, "stringVariables" ))
        {
          request.context.alert.stringVariables = {};
        }

        structDelete( session, "alert" );
      }
    }

    if( variables.downForMaintenance and not request.context.debug )
    {
      writeOutput( 'Geachte gebruiker,
            <br /><br />
            Momenteel is deze applicatie niet beschikbaar in verband met onderhoud.<br />
            Onze excuses voor het ongemak.
            <!-- IP adres: #cgi.remote_addr# -->
      ' );
      abort;
    }

    // security, translations and content:
    if( not request.context.config.disableSecurity )
    {
      controller( "common:security.authorize" );
    }
    else
    {
      request.context.auth.isLoggedIn = true;
      request.context.auth.user = new services.user();
      request.context.auth.role = new services.role();
    }

    controller( "common:i18n.setLanguage" );
    controller( "common:content.getContent" );

    if(
        getSubsystem() eq "admin" and
        not arrayFindNoCase( request.adminNotCRUD, getSection()) and
        not cachedFileExists( '../admin/controllers/#getSection()#.cfc' )
      )
    {
      controller( 'admin:crud.#getItem()#' );
    }

    if(
        getSubsystem() eq "api" and
        not arrayFindNoCase( request.adminNotCRUD, getSection()) and
        not cachedFileExists( '../api/controllers/#getSection()#.cfc' )
      )
    {
      controller( 'api:main.#getItem()#' );
    }
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public any function getEnvironment()
  {
    if( !variables.live )
    {
      request.version &= "b" & REReplace( "$Revision: 0 $", "[^\d]+", "", "all" );
    }

    return variables.live ? "live" : "dev";
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public any function setupEnvironment( environment )
  {
    // App specific globals
    switch( environment )
    {
      case 'dev':
        request.version &= "a" & REReplace( "$Revision: 0 $", "[^\d]+", "", "all" );

        break;
    }
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public any function onMissingView()
  {
    if( fileExists( request.root & "/common/views/" & getSection() & "/" & getItem() & ".cfm" ))
    {
      return view( "common:" & getSection() & "/" & getItem());
    }

    if( structKeyExists( request.context, "fallbackView" ))
    {
      return view( request.context.fallbackView );
    }

    return view( "common:elements/page" );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public any function readConfigFile( site )
  {
    // DEFAULT:
    var defaultSettings = {
      "debugEmail"      = "bugs@mstng.info",
      "showDebug"       = false,
      "ownerEmail"      = "info@mstng.info",
      "cfAdminPassword" = "",
      "appIsLive"       = true,
      "debugIP"         = "",
      "datasource"      = "mustang",
      "log"             = "false",
      "lognotes"        = "false",
      "nukescript"      = "populate.sql",
      "webroot"         = "",
      "reloadpw"        = "1",
      "disableSecurity" = true,
      "fileUploads"     = expandPath( "../ProjectsTemporaryFiles/files_" & this.name ),
      "defaultLanguage"   = "nl_NL",
      "securedSubsystems" = ""
    };

    var config = cacheGet( "config-#this.name#" );

    if( isNull( config ) or
        request.reset or
        (
          structKeyExists( config, "appIsLive" ) and
          not config.appIsLive
        )
      )
    {
      config = deserializeJSON( fileRead( request.root & "/config/" & site & ".json" ));
      cachePut( "config-#this.name#", config );
    }

    for( key in defaultSettings )
    {
      if( structKeyExists( config, key ))
      {
        defaultSettings[key] = config[key];
      }
    }

    return defaultSettings;
  }
}