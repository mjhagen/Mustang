component extends="thirdparty.framework.one"
{
  // defaults:
  variables.live = true;
  variables.reset = false;
  variables.downForMaintenance = false;

  // globals:
  request.root = getDirectoryFromPath( getCurrentTemplatePath());
  request.context.config = getConfig( cgi.server_name );
  request.version = "1.0.0";
  request.webroot = request.context.config.webroot;
  request.fileUploads = request.context.config.fileUploads; // request.root & '../files_' & this.name;
  request.adminNotCRUD = ["database"];

  // CF application setup:
  this.sessionmanagement = true;
  this.setclientcookies = true;
  this.sessiontimeout = createTimeSpan( 0, 2, 0, 0 );
  this.mappings = {
    "/app" = request.root,
    "/framework" = request.root & "/thirdparty/framework",
    "/javaloader" = request.root & "/thirdparty/javaloader",
    "/model" = request.root & "/model"
  };

  // App specific globals
  request.encryptKey = "";

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
    variables.reset = structKeyExists( url, "reload" );
  }

  variables.live = request.context.config.appIsLive;

  // Datasource settings:
  this.datasource = request.context.config.datasource;
  this.ormEnabled = true;
  this.ormsettings = {
    CFCLocation = "/model",
    dbcreate = variables.reset ? ( variables.live ? "update" : "update" ) : ( variables.live ? "none" : "update" ),
    logSQL = variables.live ? false : true,
    sqlscript = request.context.config.nukescript,
    savemapping = false,
    autogenmap = true
  };

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public any function setupApplication()
  {
    if( variables.reset )
    {
      ORMReload();
    }

    ORMEvictQueries();
    cacheRemove( arrayToList( cacheGetAllIds()));

    application.i18n = new app.services.i18n( "nl-NL" );
    application.util = new app.services.util();
    application.designService = new app.services.design();
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
      request.context.designService = variables.designService = application.designService;
    }

    // rate limiter:
    util.limiter( 3, 100 );

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
  public any function getConfig( site )
  {
    // DEFAULT:
    var settings = {
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
      "fileUploads"     = expandPath( "../ProjectsTemporaryFiles/files_" & this.name )
    };

    var config = cacheGet( "config-#site#" );

    if( isNull( config ) or
        structKeyExists( url, "reload" ) or
        (
          structKeyExists( config, "appIsLive" ) and
          not config.appIsLive
        )
      )
    {
      config = deserializeJSON( fileRead( request.root & "/config/" & site & ".json" ));
      cachePut( "config-#site#", config );
    }

    for( key in settings )
    {
      if( structKeyExists( config, key ))
      {
        settings[key] = config[key];
      }
    }

    return settings;
  }
}