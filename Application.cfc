component extends="framework.one" {
  request.context.startTime = getTickCount();

  // CF application setup:
  this.sessionmanagement = true;
  this.setclientcookies = true;
  this.sessiontimeout = createTimeSpan( 0, 2, 0, 0 );
  this.mappings["/root"] = getDirectoryFromPath( getCurrentTemplatePath());

  // Global variables:
  request.appName = "Mustang";
  request.version = "1.0.0";
  request.root = this.mappings["/root"];

  // replace &amp; with &
  cleanXHTMLQueryString();

  // Config:
  request.context.config = getConfig( cgi.server_name );

  // Reload:
  if( structKeyExists( url, "reload" ) && url.reload != request.context.config.reloadpw ) {
    structDelete( url, "reload" );
  }
  request.reset = structKeyExists( url, "reload" );

  // Config based global variables:
  request.context.debug = ( listFind( request.context.config.debugIP, cgi.remote_addr ) && request.context.config.showDebug );
  request.webroot = request.context.config.webroot;
  request.fileUploads = request.context.config.fileUploads; // request.root & '../files_' & this.name;

  // Private variables:
  variables.downForMaintenance = true; // true during updates
  variables.live = request.context.config.appIsLive;

  // Datasource settings:
  this.datasource = request.context.config.datasource;
  this.ORMEnabled = true;
  this.ORMSettings = {
    CFCLocation = "/root/model",
    DBCreate = ( variables.live ? ( request.reset ? "update" : "none" ) : ( request.reset ? "dropcreate" : "update" )),
    logSQL = variables.live ? false : true,
    SQLScript = request.context.config.nukescript,
    secondaryCacheEnabled = variables.live ? true : false,
    saveMapping = ( variables.live ? false : ( request.reset ? true : false )),
    autogenMap = ( variables.live ? false : ( request.reset ? true : false )),
    automanageSession = false,
    flushAtRequestend = false
  };

  variables.framework = {
    base = "/root",
    error = "common:app.error",
    usingSubsystems = true,
    defaultSubsystem = "admin",
    baseURL = request.context.config.webroot,
    diEngine = "di1",
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

  private void function setupApplication() {
    if( structKeyExists( url, "nuke" )) {
      // rebuild ORM:
      ORMReload();
    }

    // empty caches:
    ORMEvictQueries();
    cacheRemove( arrayToList( cacheGetAllIds()));

    // store global utility objects in app scope:
    lock scope="application" timeout="5" type="exclusive" {
      application.i18n = new root.lib.i18n( request.context.config.defaultLanguage );
      application.util = new root.lib.util();
      application.design = new root.lib.design();
    }
  }

  private void function setupRequest() {
    // globally available utility libraries:
    lock scope="application" timeout="5" type="readOnly" {
      request.context.i18n = variables.i18n = application.i18n;
      request.context.util = variables.util = application.util;
      request.context.design = variables.design = application.design;
    }

    variables.util.setCFSetting( "showdebugoutput", request.context.debug );

    // rate limiter:
    variables.util.limiter();

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
    if( variables.downForMaintenance && !listFind( request.context.config.debugIP, cgi.remote_addr )) {
      writeOutput( 'Geachte gebruiker,
        <br /><br />
        Momenteel is deze applicatie niet beschikbaar in verband met onderhoud.<br />
        Onze excuses voor het ongemak.
        <!-- IP adres: #cgi.remote_addr# -->
      ' );
      abort;
    }

    // security:
    if( !request.context.config.disableSecurity ) {
      controller( "common:security.authorize" );
    } else {
      request.context.auth.isLoggedIn = true;
      request.context.auth.user = new root.lib.user();
      request.context.auth.role = new root.lib.role();
    }

    // internationalization:
    controller( "common:i18n.setLanguage" );

    // content:
    if( listFindNoCase( request.context.config.contentSubsystems, getSubsystem())) {
      controller( "common:content.get" );
    }

    // try to queue up crud actions:
    if( getSubsystem() eq "admin" && !cachedFileExists( '../admin/controllers/#getSection()#.cfc' )) {
      controller( 'admin:crud.#getItem()#' );
    }

    // try to queue up api actions:
    if( getSubsystem() eq "api" && !cachedFileExists( '../api/controllers/#getSection()#.cfc' )) {
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
    if( cachedFileExists( request.root & "/common/views/" & getSection() & "/" & getItem() & ".cfm" )) {
      return view( "common:" & getSection() & "/" & getItem());
    }

    if( structKeyExists( request.context, "fallbackView" )) {
      return view( request.context.fallbackView );
    }

    return view( "common:elements/page" );
  }

  private string function getEnvironment() {
    return variables.live ? "live" : "dev";
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
      "fileUploads"       = expandPath( "../ProjectsTemporaryFiles/files_" & request.appname ),
      "defaultLanguage"   = "en_US",
      "securedSubsystems" = "admin",
      "contentSubsystems" = "admin,home,common",
      "encryptKey"        = ""
    };

    // retrieve config from cache
    var config = cacheGet( "config-#this.name#" );

    // set config to null on reload or in dev-mode:
    if( structKeyExists( url, "reload" ) ||
        ( !isNull( config ) && structKeyExists( config, "appIsLive" ) && !config.appIsLive )) {
      structDelete( local, "config" );
    }

    // retrieve config from disk
    if( isNull( config )) {
      var config = deserializeJSON( fileRead( request.root & "/config/" & site & ".json" ));
      cachePut( "config-#this.name#", config );
    }

    // add the default settings, so we don't get errors when using rc.config.{any-default-setting}:
    structAppend( defaultSettings, config, true );

    return defaultSettings;
  }

  private array function getRoutes() {
    var resources = cacheGet( "resources-#this.name#" );

    if( isNull( resources ) || request.reset || !request.context.config.appIsLive ) {
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