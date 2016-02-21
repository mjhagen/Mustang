component extends="framework.one" {
  request.context.startTime = getTickCount();

  // set tihs to true during updates:
  downForMaintenance = false;

  // CF application setup:
  this.sessionmanagement = true;
  this.sessiontimeout = createTimeSpan( 0, 2, 0, 0 );
  this.mappings["/root"] = request.root = listChangeDelims( getDirectoryFromPath( getCurrentTemplatePath()), "/", "/\" );

  // Global variables:
  request.appName = "Mustang";
  request.version = "1.0.0";

  // replaces &amp; with & in the query string:
  cleanXHTMLQueryString();

  // Config:
  request.context.config = cfg = getConfig();

  // Reload:
  if( structKeyExists( url, "reload" ) && url.reload != cfg.reloadpw ){
    structDelete( url, "reload" );
  }

  request.reset = structKeyExists( url, "reload" );

  // Config based global variables:
  request.context.debug = cfg.showDebug && ( listFind( cfg.debugIP, cgi.remote_addr ) || !len( trim( cfg.debugIP )));
  request.webroot = cfg.webroot;
  request.fileUploads = cfg.paths.fileUploads;

  // Private variables:
  live = cfg.appIsLive;

  // Datasource settings:
  this.datasource = cfg.datasource;

  this.ormEnabled = true;
  this.ormSettings = {
    CFCLocation = "/root/model",
    DBCreate = ( live ? ( request.reset ? "update" : "none" ) : ( request.reset ? "dropcreate" : "update" )),
    logSQL = live ? false : true,
    SQLScript = cfg.nukescript,
    saveMapping = true,
    secondaryCacheEnabled = live ? true : false,
    cacheProvider = "ehcache"
  };

  // framework settings:
  framework = {
    generateSES = true,
    SESOmitIndex = true,
    base = "/root",
    error = ":app.error",
    baseURL = cfg.webroot,
    diLocations = "/root/services,/root/subsystems/api/services",
    diConfig = {
      constants = {
        root = request.root,
        config = cfg
      }
    },
    routesCaseSensitive = false,
    environments = {
      live = {
        cacheFileExists = true,
        password = cfg.reloadpw,
        trace = cfg.showDebug
      },
      dev = {
        reloadApplicationOnEveryRequest = true,
        trace = cfg.showDebug
      }
    }
  };



  // public functions:

  public void function setupApplication() {
    if( structKeyExists( url, "nuke" )) {
      // rebuild ORM:
      ORMReload();
      writeLog( text = "ORM reloaded", type = "information", file = request.appName );
      structDelete( application, "threads" );
    }

    // empty caches:
    try {
      ORMEvictQueries();
    } catch( any e ) {}

    cacheRemove( arrayToList( cacheGetAllIds()));

    writeLog( text = "application initialized", type = "information", file = request.appName );
  }

  public void function setupSession() {
    structDelete( session, "progress" );
  }

  public void function setupRequest() {
    if( request.reset ) {
      setupSession();
    }

    // globally available utility libraries:
    var beanFactory = getBeanFactory();

    request.context.i18n = i18n = beanFactory.getBean( "translationService" );
    request.context.util = util = beanFactory.getBean( "utilityService" );

    util.setCFSetting( "showdebugoutput", request.context.debug );

    // rate limiter:
    util.limiter();

    // down for maintenance message to non dev users:
    if( downForMaintenance && !listFind( cfg.debugIP, cgi.remote_addr )) {
      writeOutput( 'Geachte gebruiker,
            <br /><br />
            Momenteel is deze applicatie niet beschikbaar in verband met onderhoud.<br />
            Onze excuses voor het ongemak.
            <!-- IP adres: #cgi.remote_addr# -->
      ' );
      abort;
    }

    // security:
    controller( ":security.authorize" );

    // internationalization:
    controller( ":i18n.load" );

    // content:
    if( getSubsystem() == getDefaultSubsystem() || listFindNoCase( cfg.contentSubsystems, getSubsystem())) {
      controller( ":admin-ui.load" );
    }

    // try to queue up crud (admin) actions:
    if( getSubsystem() == getDefaultSubsystem() && !util.fileExistsUsingCache( request.root & "/controllers/#getSection()#.cfc" )) {
      controller( ":crud.#getItem()#" );
    }

    // try to queue up api actions:
    if( getSubsystem() == "api" && !util.fileExistsUsingCache( request.root & "/subsystems/api/controllers/#getSection()#.cfc" )) {
      controller( "api:main.#getItem()#" );
    }
  }

  public void function setupEnvironment( string environment="" ) {
    // App specific globals
    switch( environment ){
      case "dev":
        request.version &= "a" & REReplace( "$Revision: 0 $", "[^\d]+", "", "all" );
        break;
    }
  }

  public string function onMissingView() {
    if( util.fileExistsUsingCache( request.root & "/views/" & getSection() & "/" & getItem() & ".cfm" )) {
      return view( getSection() & "/" & getItem());
    }

    if( util.fileExistsUsingCache( request.root & "/subsystems/" & getSubsystem() & "/views/" & getSection() & "/" & getItem() & ".cfm" )) {
      return view( getSubsystem() & ":" & getSection() & "/" & getItem());
    }

    if( structKeyExists( request.context, "fallbackView" )){
      return view( request.context.fallbackView );
    }

    return view( ":app/notfound" );
  }

  public void function onError( any exception, string event ) {
    if( getSubsystem() == "api" ) {
      if( structKeyExists( exception, "cause" )) {
        return onError( exception.cause, event );
      }

      if( structKeyExists( exception, "message" ) && structKeyExists( exception, "detail" )) {
        var jsonService = getBeanFactory().getBean( "jsonService" );
        var pageContext = getPageContext();
        var response = pageContext.getResponse();

        response.setContentType( "application/json" );
        response.setStatus( 500 );

        writeOutput(jsonService.serialize({
          "status" = "error",
          "error" = "uncaught error: " & exception.message,
          "detail" = exception.detail
        }));
        abort;
      }
    }

    super.onError( argumentCollection = arguments );
  }



  // private functions:

  private void function cleanXHTMLQueryString() {
    for( var kv in url ) {
      if( kv contains ";" ) {
        url[listRest( kv, ";" )] = url[kv];
        structDelete( url, kv );
      }
    };
  }

  private string function getEnvironment() {
    return live ? "live" : "dev";
  }

  private struct function getConfig( string site=cgi.server_name ) {
    // DEFAULT:
    var defaultSettings = {
      "appIsLive"               = true,
      "cfAdminPassword"         = "",
      "contentSubsystems"       = "",
      "datasource"              = "",
      "debugEmail"              = "bugs@mstng.info",
      "debugIP"                 = "127.0.0.1",
      "defaultLanguage"         = "en_US",
      "disableSecurity"         = false,
      "encryptKey"              = "7Wp8Zwz2ccvvtbxZWkvKm32a3v9edes8Y3xxHxeAaMuZkjV84P2uW6s3m3Mj9sMz",
      "log"                     = true,
      "lognotes"                = false,
      "nukescript"              = "",
      "ownerEmail"              = "info@mstng.info",
      "paths" = { "fileUploads" = "#request.root#/../ProjectsTemporaryFiles/files_" & request.appName },
      "reloadpw"                = "1",
      "secureDefaultSubsystem"  = true,
      "securedSubsystems"       = "adminapi,api",
      "showDebug"               = false,
      "webroot"                 = ""
    };

    // try cache:
    if( !structKeyExists( url, "reload" )) {
      var config = cacheGet( "config-#this.name#" );

      // found cached settings, only use it in live apps:
      if( !isNull( config ) &&
          structKeyExists( config, "appIsLive" ) &&
          isBoolean( config.appIsLive ) &&
          config.appIsLive ) {
        return config;
      }
    }

    // read from config file:
    var config = deserializeJSON( fileRead( request.root & "/config/" & site & ".json" ));

    // add default options:
    structAppend( defaultSettings, config, true );

    // store it in cf's default cache:
    cachePut( "config-#this.name#", defaultSettings );

    return defaultSettings;
  }

  private array function getRoutes() {
    var resources = cacheGet( "resources-#this.name#" );

    if( isNull( resources ) || request.reset || !cfg.appIsLive ) {
      var listOfResources = "";
      var modelFiles = directoryList( this.mappings["/root"] & "/model", true, "name", "*.cfc", "name asc" );

      for( var fileName in modelFiles ) {
        listOfResources = listAppend( listOfResources, reverse( listRest( reverse( fileName ), "." )));
      }

      var resources = [
        { "/api/:entity/search/$" = "/api::entity/search/" },
        { "/api/:entity/search/:keyword/$" = "/api::entity/search/keywords/:keyword" },
        { "/api/:entity/filter/$" = "/api::entity/filter/" },
        { "/api/auth/:action" = "/api:auth/:action/" },
        { "$RESOURCES" = { resources = listOfResources, subsystem = "api" }},
        {}
      ];

      cachePut( "resources-#this.name#", resources );
    }

    return resources;
  }
}
