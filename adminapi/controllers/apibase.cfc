component
{
  request.layout = false;

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  function init( fw )
  {
    variables.fw = fw;
    return this;
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  function returnAsJSON( variable )
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
    return serializeJSON( variable );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  function onMissingMethod( missingMethodName, missingMethodArguments )
  {
    writeDump( arguments );
    abort;

    return super.onMissingMethod();
  }
}