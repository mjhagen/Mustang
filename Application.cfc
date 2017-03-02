component extends="framework.one" {
  request.context.startTime = getTickCount();

  fixUrl( "mstng.info", false ); // <-- enter main URL in there and whether or not to use SSL

  // set tihs to true during updates:
  downForMaintenance = false;

  // CF application setup:
  this.sessionmanagement = true;
  this.sessiontimeout = createTimeSpan( 0, 2, 0, 0 );
  this.mappings["/root"] = request.root = getDirectoryFromPath( getCurrentTemplatePath());

  this.javaSettings = {
    loadPaths = [ "./lib/java/gson-2.7.jar" ]
  };

  // Global variables:
  request.appName = "Mustang";
  request.version = "1.0.0";

  // replaces &amp; with & in the query string:
  cleanXHTMLQueryString();

  // Config:
  request.context.config = cfg = getConfig( );

  if ( structKeyExists( cfg.paths, "basecfc" ) ) {
    this.mappings[ "/basecfc" ] = cfg.paths.basecfc;
  }

  // Reload:
  if( structKeyExists( url, "reload" ) && url.reload != cfg.reloadpw ) {
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
    // saveMapping = true,
    secondaryCacheEnabled = live ? true : false,
    cacheProvider = "ehcache"
  };

  // framework settings:
  framework = {
    generateSES = true,
    SESOmitIndex = true,
    decodeRequestBody = true,
    base = "/root",
    baseURL = cfg.webroot,
    error = "app.error",
    unhandledPaths = "/inc,/tests,/browser,/cfimage,/diagram",
    diLocations = "/mustang/services,/mustang/controllers,/root/services,/root/subsystems/api/services",
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
    },
    subsystems = {
      api = {
        error = "api:main.error"
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
    } catch ( any e ) {
    }

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
      writeOutput(
        'Geachte gebruiker,
        <br /><br />
        Momenteel is deze applicatie niet beschikbaar in verband met onderhoud.<br />
        Onze excuses voor het ongemak.
        <!-- IP adres: #cgi.remote_addr# -->
      '
      );
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

  public void function setupSubsystem( string subsystem = "" ) {
    if( structKeyExists( framework.subsystems, subsystem ) ) {
      var subsystemConfig = getSubsystemConfig( subsystem );
      variables.framework = mergeStructs( subsystemConfig, framework );
      structDelete( variables.framework.subsystems, subsystem );
    }
  }

  public void function setupEnvironment( string environment="" ) {
    // App specific globals
    switch( environment ) {
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

    if( structKeyExists( request.context, "fallbackView" )) {
      return view( request.context.fallbackView );
    }

    return view( ":app/notfound" );
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
    // cached:
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

    // not cached:
    var computedSettings = { "webroot" = ( cgi.https == 'on' ? 'https' : 'http' ) & "://" & cgi.server_name };

    var defaultSettings = {};

    if( fileExists( request.root & "/config/default.json" )) {
      var defaultConfig = deserializeJSON( fileRead( request.root & "/config/default.json" ));
      defaultSettings = mergeStructs( defaultConfig, computedSettings );
    }

    var siteConfig = deserializeJSON( fileRead( request.root & "/config/" & site & ".json" ));
    var mergedConfig = mergeStructs( siteConfig, defaultSettings );

    cachePut( "config-#this.name#", mergedConfig );

    return mergedConfig;
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

  private struct function mergeStructs( required struct from, struct to={}) {
    // also append nested struct keys:
    for( var key in to ) {
      if( isStruct( to[key] ) && structKeyExists( from, key )) {
        structAppend( to[key], from[key] );
      }
    }

    // copy the other keys:
    structAppend( to, from );

    return to;
  }

  private void function fixUrl( string goHere = "", boolean goSecure = false ) {
    if ( !len( trim( goHere ) ) ) {
      return;
    }

    var isSecure = cgi.server_port_secure != '0';

    if ( cgi.server_name contains 'cvsdev' ) {
      goHere = cgi.server_name;
      if ( cgi.server_name contains '.dev' ) {
        goSecure = false;
      }
    }

    if ( cgi.server_name != goHere || ( goSecure && !isSecure ) ) {
      var qs = cgi.query_string;
      var sn = cgi.script_name;

      if ( left( qs, 4 ) == "404;" ) {
        var originalUrl = listRest( qs, ";" );
        var matcher = reFindNoCase( "^http[s]?:\/\/[\w.:]+(.*)$", originalUrl, 1, true );
        if ( arrayLen( matcher.pos ) > 1 ) {
          var parsedUrl = mid( originalUrl, matcher.pos[ 2 ], matcher.len[ 2 ] );
          var sn = listFirst( parsedUrl, "?" );
          var qs = listRest( parsedUrl, "?" );
        }
      }

      var relocateonce = 'http' & ( goSecure ? 's' : '' ) &
                          ( '://' & goHere ) &
                          ( sn == '/index.cfm' ? '/' : sn ) &
                          ( len( trim( qs ) ) ? '?' & qs : '' );

      location( relocateonce, false, 301 );
    }
  }
}