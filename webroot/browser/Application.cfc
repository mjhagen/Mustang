component accessors=true output=false
{
  property name="apiBaseURL";

  this.name = "api-browser";

  public Void function onRequestStart()
  {
    setApiBaseURL( "http#cgi.SERVER_PORT_SECURE?'s':''#://#cgi.SERVER_NAME#/api" );

    if( structKeyExists( url, "reload" ))
    {
      onApplicationStart();
    }

    param url.verb = "GET";
  }

  public Void function onApplicationStart()
  {
    var pegdownLocation = "";

    switch( cgi.SERVER_NAME )
    {
      case  "vgn.dev":
            pegdownLocation = "C:\Users\mjhagen\Dropbox\Projects\thirdparty\pegdown";
            break;

      case  "vgn.home":
            pegdownLocation = "G:\Dropbox\Projects\thirdparty\pegdown";
            break;

      case  "vgn.local":
            pegdownLocation = "";
            break;

      case  "vgn.staging.e-line.nl":
            pegdownLocation = "/sites/lib/pegdown";
            break;
    }

    if( len( trim( pegdownLocation )))
    {
      var jl = new javaloader.javaloader( directoryList( pegdownLocation, false, "path", "*.jar" ), false );
      var pegdown = jl.create( "org.pegdown.PegDownProcessor" );
      var pegDownProcessor = pegDown.init( javaCast( 'int', 32 ));

      for( mdFile in directoryList( expandPath( "./docs" ), false, "path", "*.md" ))
      {
        var dir = getDirectoryFromPath( mdFile );
        var fileName = getFileFromPath( mdFile );
        var noExtFileName = reverse( listRest( reverse( fileName ), "." ));

        fileWrite( dir & "/" & lCase( noExtFileName ) & ".html", pegDownProcessor.markdownToHtml( fileRead( mdFile )), 'utf-8' );
      }
    }
  }
}