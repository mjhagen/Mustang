component extends="testbox.system.BaseSpec" {
  variables.ioc = new framework.ioc( "/mustang/services", { constants = { root = request.appRoot, config = request.context.config }});

  function run() {
    describe( "Mustang Services", function() {
      it( "Expects all services to instantiate.", function() {
        writeDump(variables.ioc.getBeanInfo());
        // expect( jsonService.serialize( "I don" & chr( 18 ) & "t know!" ))
        //   .toBe( '"I don\u0012t know!"' );
      });
    });
  }
}