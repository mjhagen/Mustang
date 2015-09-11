component extends="framework.one" {
  request.context.startTime = getTickCount();

  // CF application setup:
  this.sessionmanagement = true;
  this.setclientcookies = true;
  this.sessiontimeout = createTimeSpan( 0, 2, 0, 0 );
  this.mappings["/root"] = listChangeDelims( getDirectoryFromPath( getCurrentTemplatePath()), '/', '/\' );

  // Global variables:
  request.appName = "Mustang";
  request.version = "1.0.0";
  request.root = this.mappings["/root"];

  // replace &amp; with &
  cleanXHTMLQueryString();

  // Config:
  request.context.config = cfg = getConfig( cgi.server_name );

  // Reload:
  if( structKeyExists( url, "reload" ) && url.reload != cfg.reloadpw ){
    structDelete( url, "reload" );
  }

  request.reset = structKeyExists( url, "reload" );

  // Config based global variables:
  request.context.debug = ( listFind( cfg.debugIP, cgi.remote_addr ) && cfg.showDebug );
  request.webroot = cfg.webroot;
  request.fileUploads = cfg.fileUploads;

  // Private variables:
  downForMaintenance = false; // true during updates
  live = cfg.appIsLive;

  // Datasource settings:
  this.datasource = cfg.datasource;
  this.ORMEnabled = true;
  this.ORMSettings = {
    CFCLocation = "/root/model",
    DBCreate = ( live ? ( request.reset ? "update" : "none" ) : ( request.reset ? "dropcreate" : "update" )),
    logSQL = live ? false : true,
    SQLScript = cfg.nukescript,
    secondaryCacheEnabled = live ? true : false,
    saveMapping = ( live ? false : ( request.reset ? true : false )),
    autogenMap = ( live ? false : ( request.reset ? true : false )),
    automanageSession = false,
    flushAtRequestend = false
  };

  framework = {
    base = "/root",
    error = "app.error",
    baseURL = cfg.webroot,
    diLocations = "/root/model/services",
    environments = {
      live = {
        cacheFileExists = true,
        password = cfg.reloadpw
      },
      dev = {
        reloadApplicationOnEveryRequest = true,
        trace = true
      }
    }
  };

  private void function setupApplication() {
    if( structKeyExists( url, "nuke" )) {
      // rebuild ORM:
      ORMReload();
      writeLog( text = "ORM reloaded", type = "information", file = request.appName );
    }

    // empty caches:
    ORMEvictQueries();
    cacheRemove( arrayToList( cacheGetAllIds()));

    lock scope="application" timeout="5" type="exclusive" {
      application.beanFactory = new framework.ioc( "/root/model/services" );
    }

    writeLog( text = "application initialized", type = "information", file = request.appName );
  }

  private void function setupRequest() {
    // globally available utility libraries:
    lock scope="application" timeout="5" type="readOnly" {
      request.context.i18n    = i18n    = application.beanFactory.getBean( 'translationService' );
      request.context.util    = util    = application.beanFactory.getBean( 'utilityService' );
      request.context.design  = design  = application.beanFactory.getBean( 'designService' );
    }

    util.setCFSetting( "showdebugoutput", request.context.debug );

    // rate limiter:
    util.limiter();

    // alert messages:
    lock scope="session" timeout="5" type="readOnly" {
      if( structKeyExists( session, "alert" ) && isStruct( session.alert ) &&
          structKeyExists( session.alert, 'class' ) &&
          structKeyExists( session.alert, 'text' )) {
        request.context.alert = session.alert;

        if( !structKeyExists( request.context.alert, "stringVariables" )) {
          request.context.alert.stringVariables = {};
        }

        structDelete( session, "alert" );
      }
    }

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
    if( !cfg.disableSecurity ) {
      controller( "security.authorize" );
    } else {
      request.context.auth.isLoggedIn = true;
      request.context.auth.user = new root.lib.user();
      request.context.auth.role = new root.lib.role();
    }

    // internationalization:
    controller( "i18n.setLanguage" );

    // content:
    if( getSubsystem() == "" || listFindNoCase( cfg.contentSubsystems, getSubsystem())) {
      controller( "content" );
    }

    // try to queue up crud actions:
    if( getSubsystem() == "admin" && !cachedFileExists( request.root & '/subsystems/admin/controllers/#getSection()#.cfc' )){
      controller( 'admin:crud.#getItem()#' );
    }

    // try to queue up api actions:
    if( getSubsystem() == "api" && !cachedFileExists( request.root & '/subsystems/api/controllers/#getSection()#.cfc' )){
      controller( 'api:main.#getItem()#' );
    }
  }

  private void function setupEnvironment( string environment="" ) {
    // App specific globals
    switch( environment ) {
      case 'dev':
        request.version &= "a" & REReplace( "$Revision: 0 $", "[^\d]+", "", "all" );
        break;
    }
  }

  private void function cleanXHTMLQueryString() {
    for( var kv in url ) {
      if( kv contains ';' ) {
        url[listRest( kv, ';' )] = url[kv];
        structDelete( url, kv );
      }
    };
  }

  private string function onMissingView() {
    if( fileExists( request.root & "/views/" & getSection() & "/" & getItem() & ".cfm" )) {
      return view( getSection() & "/" & getItem());
    }

    if( fileExists( request.root & "/subsystems/" & getSubsystem() & "/views/" & getSection() & "/" & getItem() & ".cfm" )) {
      return view( getSubsystem() & ":" & getSection() & "/" & getItem());
    }

    if( structKeyExists( request.context, "fallbackView" )) {
      return view( request.context.fallbackView );
    }

    return view( "elements/page" );
  }

  private string function getEnvironment() {
    return live ? "live" : "dev";
  }

  private struct function getConfig( string site="" ) {
    // DEFAULT:
    var defaultSettings = {
      "debugEmail"        = "bugs@mstng.info",
      "showDebug"         = false,
      "ownerEmail"        = "info@mstng.info",
      "cfAdminPassword"   = "",
      "appIsLive"         = true,
      "debugIP"           = "",
      "datasource"        = "mustang",
      "log"               = "false",
      "lognotes"          = "false",
      "nukescript"        = "populate.sql",
      "webroot"           = "",
      "reloadpw"          = "1",
      "disableSecurity"   = true,
      "fileUploads"       = "#request.root#/../ProjectsTemporaryFiles/files_" & request.appName,
      "defaultLanguage"   = "en_US",
      "secureDefaultSubsystem" = false,
      "securedSubsystems" = "admin",
      "contentSubsystems" = "admin",
      "encryptKey"        = ""
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
      var modelFiles = directoryList( this.mappings["/root"] & "/model", true, "name", "*.cfc", "name asc" );
      var listOfResources = "";

      for( var fileName in modelFiles ) {
        listOfResources = listAppend( listOfResources, reverse( listRest( reverse( fileName ), "." )));
      }

      var resources = [{ "$RESOURCES" = { resources = listOfResources, subsystem = "api" }}];

      cachePut( "resources-#this.name#", resources );
    }

    return resources;
  }
}