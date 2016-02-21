component extends="crud" {
  public void function view() {
    super.view( rc );
    var linkedEntity = rc.data.getRelatedEntity();
    if( !isNull( linkedEntity )){
      var prevEntries = ORMExecuteQuery( "FROM logentry AS logentry WHERE logentry.relatedEntity=:entity AND logentry.dd<:dd ORDER BY logentry.dd DESC", { "entity" = linkedEntity, "dd" = rc.data.getdd()}, { maxresults = 1 });

      if( arrayLen( prevEntries ) == 1 ) {
        rc.prevEntry = prevEntries[1];
      }

      var nextEntries = ORMExecuteQuery( "FROM logentry AS logentry WHERE logentry.relatedEntity=:entity AND logentry.dd>:dd ORDER BY logentry.dd ASC", { "entity" = linkedEntity, "dd" = rc.data.getdd()}, { maxresults = 1 });

      if( arrayLen( nextEntries ) == 1 ) {
        rc.nextEntry = nextEntries[1];
      }
    }
  }
}