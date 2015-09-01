component extends="framework.zero" {
  this.root = getDirectoryFromPath( getBaseTemplatePath()) & "../..";
  this.configFiles = this.root & "/config";
  this.defaultConfig["title"] = "Database Diagram";
  this.defaultConfig["outputImage"] = expandPath( "./output.gif" );
  this.mappings["/model"] = "#this.root#/../../model";
}