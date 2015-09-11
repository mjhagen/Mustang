component extends="crud"{
  public void function view(){
    super.view( rc );
    var linkedEntity = rc.data.getEntity();
    if( not isNull( isNull( rc.linkedEntity ))){
      var prevEntries = ORMExecuteQuery( "FROM logentry AS logentry WHERE logentry.entity=:entity AND logentry.createDate<:createDate ORDER BY logentry.createDate DESC", { "entity" = linkedEntity, "createDate" = rc.data.getCreateDate()}, { maxresults = 1 });

      if( arrayLen( prevEntries ) == 1 ){
        rc.prevEntry = prevEntries[1];
      }

      var nextEntries = ORMExecuteQuery( "FROM logentry AS logentry WHERE logentry.entity=:entity AND logentry.createDate>:createDate ORDER BY logentry.createDate ASC", { "entity" = linkedEntity, "createDate" = rc.data.getCreateDate()}, { maxresults = 1 });

      if( arrayLen( nextEntries ) == 1 ){
        rc.nextEntry = nextEntries[1];
      }
    }
  }
}