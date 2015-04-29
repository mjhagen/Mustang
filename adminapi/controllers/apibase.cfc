component
{
  request.layout = false;

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public any function init( fw )
  {
    variables.fw = fw;
    return this;
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public string function returnAsJSON( variable )
  {
    var pageContext = getPageContext();
    var returnType = "application/json";

    if( cgi.HTTP_USER_AGENT contains 'MSIE' )
    {
      returnType = "text/html";
    }

    createObject( "java", "coldfusion.tagext.lang.SettingTag" ).setShowDebugOutput( false );

    setting showDebugOutput=false;

    pageContext.getFusionContext().getResponse().setHeader( "Content-Type", returnType );
    pageContext.getCfoutput().clearAll();
    writeOutput( serializeJSON( variable ));
  }
}