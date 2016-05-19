component extends="testbox.system.BaseSpec" {
  variables.ioc = new framework.ioc( "/mustang/services", { constants = { root = request.appRoot, config = request.context.config }});

  variables.jsonService = variables.ioc.getBean( "jsonService" );

  function run() {
    describe( "JSON Compliance check", function() {
      it( "Expects jsonService to handle ASCII control characters", function() {
        expect( jsonService.serialize( "I don" & chr( 18 ) & "t know!" ))
          .toBe( '"I don\u0012t know!"' );
      });

      it( "Expects escape sequences to work", function() {
        expect( jsonService.serialize( "Text with a" & chr( 9 ) & "(tab)." ))
          .toBe( '"Text with a\t(tab)."' );
        expect( jsonService.serialize( "Text on a" & chr( 10 ) & "new line." ))
          .toBe( '"Text on a\nnew line."' );
        expect( jsonService.serialize( "Text on a" & chr( 13 ) & "new line (using a CR)." ))
          .toBe( '"Text on a\rnew line (using a CR)."' );
      });
    });
  }
}