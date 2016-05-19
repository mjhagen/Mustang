component accessors=true {
  property jsonService;

  function default() {
    writedump( jsonService.serialize( "I don" & chr(18) & "t know!" ));
  }
}