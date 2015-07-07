component
{
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public any function init( fw )
  {
    variables.fw = fw;

    request.layout = false;

    request.context.util.setCFSetting( "showdebugoutput", false );

    return this;
  }

  public void function before( rc ){}

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public string function returnAsJSON( variable )
  {
    var pageContext = getPageContext();
    var returnType = "application/json";

    if( cgi.HTTP_USER_AGENT contains 'MSIE' )
    {
      returnType = "text/html";
    }

    if( listFindNoCase( "lucee,railo", server.ColdFusion.ProductName ))
    {
      pageContext.getResponse().setContentType( returnType );
      pageContext.clear();
    }
    else
    {
      pageContext.getFusionContext().getResponse().setHeader( "Content-Type", returnType );
      pageContext.getCfoutput().clearAll();
    }

    writeOutput( serializeJSON( variable ));
  }
}