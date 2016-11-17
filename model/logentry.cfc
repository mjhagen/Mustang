component extends="basecfc.base"
          persistent=true
          table="log"
          schema="mustang"
          defaultSort="dd DESC"
          classColumn="logaction" {
  property name="name" type="string" length=128;
  property name="deleted" type="boolean" ORMType="boolean" default=false inapi=false;
  property name="sortorder" type="numeric" ORMType="integer" default=0;

  property name="relatedEntity" fieldType="many-to-one" cfc="root.model.logged" FKColumn="entityid" inform=true orderinform=1 inlist=1 link=true;
  property name="logaction" fieldType="many-to-one" cfc="root.model.logaction" FKColumn="logactionid" inform=true orderinform=2 inlist=1;
  property name="savedState" length=4000 dataType="json" inform=true orderinform=5;
  property name="note" length=1024 inform=true orderinform=6 editable=true required=1 inlist=1;
  property name="attachment" length=128 inform=true orderinform=7 editable=true formfield="file";

  property name="by" fieldType="many-to-one" FKColumn="contactid" cfc="root.model.contact";
  property name="dd" ORMType="timestamp" inlist=true;
  property name="ip" length=15;

  public string function getName() {
    return "";
    var entity = getRelatedEntity();

    if( !isNull( entity )) {
      return entity.getName() & " log";
    }

    throw( "no entity found" );
  }

  public any function enterIntoLog( string action="init", struct newState={}, component entityToLog=getRelatedEntity()) {
    if( isNull( entityToLog )) {
      return this;
    }

    writeLog( text = "Logging entry for #entityToLog.getId( )#", file = request.appName );
    var formData = {
      "dd" = now(),
      "ip" = cgi.remote_addr,
      "relatedEntity" = entityToLog.getId()
    };

    if( isDefined( "request.context.auth.userID" )) {
      var contact = entityLoadByPK( "contact", request.context.auth.userID );

      if( !isNull( contact )) {
        formData["by"] = contact;
      }
    }

    if( len( trim( action ))) {
      var logaction = entityLoad( "logaction", { name = action }, true );

      if( isNull( logaction )) {
        var logaction = entityLoad( "logaction", { name = "init" }, true );
      }

      formData["logaction"] = logaction;
    }

    if( structCount( newState ) == 0 ) {
      newState = {
        "init" = true,
        "name" = entityToLog.getName()
      };
    }

    formData[ "savedState" ] = deORM( newState );

    transaction {
      var result = save( formData );
    }

    var e = result.getRelatedEntity( );

    if ( !isNull( e ) ) {
      writeLog( text = "Entry logged for #e.getId( )#", file = request.appName );
    }

    return result;
  }
}