component extends="framework.zero" {
  this.name = request.appName = "mustang-tests";
  this.root = request.appRoot = getDirectoryFromPath( getBaseTemplatePath()) & "../../";
  this.configFiles = request.appRoot & "/config";
  this.defaultConfig.title = "Mustang Testbox";

  cfg = readConfig();
  cfg.log = false;
  cfg.disableSecurity = true;

  request.context = {
    debug = false,
    config = cfg
  };

  this.mappings = {
    "/root" = request.appRoot,
    "/tests" = expandPath( "./" )
  };

  this.ORMEnabled = true;
  this.ORMSettings = {
    datasource = cfg.datasource,
    CFCLocation = cfg.paths.model,
    dbcreate = "dropcreate",
    flushatrequestend = false,
    automanageSession = false,
    sqlscript = request.appRoot & "/" & cfg.nukescript
  };

  public void function onRequestStart( string targetPage ) {
    super.onRequestStart();
    ORMReload();
  }
}