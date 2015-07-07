component extends="framework.one"
{
  // CF application setup:
  this.sessionmanagement = true;
  this.setclientcookies = true;
  this.sessiontimeout = createTimeSpan( 0, 2, 0, 0 );

  application = {};
  session = {};

  this.mappings["/root"] = getDirectoryFromPath( getCurrentTemplatePath());

  // Global variables:
  request.appName = "Mustang";
  request.version = "1.0.0";
  request.root = this.mappings["/root"];
  request.reset = false;

  // Config:
  request.context.config = generateConfig( cgi.server_name );

  if( structKeyExists( url, "reload" ) and url.reload neq request.context.config.reloadpw )
  {
    structDelete( url, "reload" );
  }

  // Config based global variables:
  request.context.debug = ( listFind( request.context.config.debugIP, cgi.remote_addr ) and request.context.config.showDebug );
  request.webroot = request.context.config.webroot;
  request.fileUploads = request.context.config.fileUploads; // request.root & '../files_' & this.name;
  request.reset = ( structKeyExists( url, "nuke" ) and structKeyExists( url, "reload" ));

  // Private variables:
  variables.downForMaintenance = false; // true during updates
  variables.live = request.context.config.appIsLive;

  // Datasource settings:
  this.datasource = request.context.config.datasource;
  this.ormEnabled = true;
  this.ormsettings = {
    CFCLocation = "/root/model",
    DBCreate = ( request.reset ? "update" : ( variables.live ? "none" : "update" )),
    logSQL = variables.live ? false : true,
    sqlscript = request.context.config.nukescript,
    secondaryCacheEnabled = variables.live ? true : false,
    savemapping = true,
    autogenmap = true
  };

  variables.framework = {
    base = "/root",
    error = "common:app.error",
    usingSubsystems = true,
    defaultSubsystem = "admin",
    generateSES = true,
    SESOmitIndex = true,
    baseURL = request.context.config.webroot,
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
        not cachedFileExists( '../admin/controllers/#getSection()#.cfc' )
      )
    {
      controller( 'admin:crud.#getItem()#' );
    }

    if(
        getSubsystem() eq "api" and
        not cachedFileExists( '../api/controllers/#getSection()#.cfc' )
      )
    {
      controller( 'api:main.#getItem()#' );
    }
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public any function getEnvironment()
  {

    return variables.live ? "live" : "dev";
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public any function setupEnvironment( String environment="" )
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
  public any function generateConfig( String site="" )
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
      "fileUploads"     = expandPath( "../ProjectsTemporaryFiles/files_" & request.appname ),
      "defaultLanguage"   = "nl_NL",
      "securedSubsystems" = "",
      "encryptKey"        = ""
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

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  private array function getRoutes()
  {
    var entityName = 0;
    var entityReference = 0;
    var entityMetaData = 0;
    var modelFiles = 0;
    var listOfResources = "";

    var resources = cacheGet( "resources-#this.name#" );

    if(
        isNull( resources ) or
        request.reset or
        not request.context.config.appIsLive
      )
    {
      modelFiles = directoryList( this.mappings["/root"] & "/model", true, "name", "*.cfc", "name asc" );

      for( var fileName in modelFiles )
      {
        listOfResources = listAppend( listOfResources, reverse( listRest( reverse( fileName ), "." )));
      }

      resources = [{
        "$RESOURCES" = {
          resources = listOfResources,
          subsystem = "api"
        }
      }];

      cachePut( "resources-#this.name#", resources );
    }

    return resources;
  }
}