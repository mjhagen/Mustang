component extends="root.model.logged"
          persistent=true
          discriminatorValue="logentry"
          joinColumn="id"
          defaultSort="createDate DESC"
          classColumn="logaction" {
  property name="entity" fieldType="many-to-one" cfc="root.model.logged" FKColumn="entityid" inform=1 orderinform=1 inlist=1;
  property name="logaction" fieldType="many-to-one" cfc="root.model.logaction" FKColumn="logactionid" inform=1 orderinform=2 inlist=1;
  property persistent=0 name="createContact" inform=1 orderinform=3;
  property persistent=0 name="createDate" inform=1 orderinform=4 inlist=1;
  property name="savedState" fieldType="column" ORMType="string" length=4000 dataType="json" inform=1 orderinform=5;
  property name="note" fieldType="column" ORMType="string" length=1024 inform=1 orderinform=6 editable=1 required=1 inlist=1;
  property name="attachment" fieldType="column" ORMType="string" length=128 inform=1 orderinform=7 editable=1 formfield="file";

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public string function getName(){
    var entity = getEntity();

    if( !isNull( entity )){
      return entity.getName() & " log";
    }

    return "no entity found";
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public any function enterIntoLog( string action="init", struct newState={}){
    transaction {
      var entityToLog = getEntity();
      var logaction = 0;

      if( len( trim( action ))){
        logaction = entityLoad( "logaction", { name = action }, true );
      }

      if( isNull( logaction )){
        logaction = entityLoad( "logaction", { name = "init" }, true );
      }

      if( structCount( newState ) eq 0 ){
        newState = {
          "init" = true,
          "name" = entityToLog.getName()
        };
      }

      save({
        savedState = serializeJSON( newState ),
        logaction = logaction.getID(),
        entity = entityToLog.getID()
      });

      entitySave( this );

      transactionCommit();
    }

    return this;
  }
}