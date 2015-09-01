component {
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public any function init( fw ) {
    variables.fw = fw;

    request.layout = false;
    request.context.util.setCFSetting( "showdebugoutput", false );

    return this;
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  private String function returnAsJSON( Any variable ){
    var statusCode = 200; // default
    var statusCodes = {
      "error"       = 500,
      "not-allowed" = 405,
      "not-found"   = 404,
      "created"     = 201,
      "no-content"  = 204
    };

    if( isStruct( variable ) and
        structKeyExists( variable, "status" ) and
        structKeyExists( statusCodes, variable.status )){
      statusCode = statusCodes[variable.status];
    }

    var pageContext = getPageContext();

    if( listFindNoCase( "lucee,railo", server.ColdFusion.ProductName )){
      pageContext.clear();
    } else {
      pageContext.getcfoutput().clearall();
    }

    var response = pageContext.getResponse();

    response.setHeader( "Access-Control-Allow-Origin", "*" );
    response.setStatus( statusCode );
    response.setContentType( 'application/json; charset=utf-8' );

    writeOutput( serializeJSON( variable ));

    abort;
  }
}