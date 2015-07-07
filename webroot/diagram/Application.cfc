component
{
  this.name = "diagram";
  this.title = "Database Diagram";
  this.modelPath = expandPath( "../../model" );
  this.lmPath = "D:\Accounts\E\Extensions\Linguine Maps\oy-lm-1.4";

  if( listLast( cgi.server_name, "." ) eq "dev" )
  {
    this.lmPath = "C:\Users\mjhagen\Dropbox\Projects\thirdparty\oy-lm-1.4";
  }

  this.mappings["/model"] = this.modelPath;

  public Void function onRequestStart()
  {
    request.title = this.title;
    request.modelPath = this.modelPath;
    request.lmPath = this.lmPath;
  }
}