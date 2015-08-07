component extends="root.model.logged"
          persistent=true
          discriminatorValue="logentry"
          joinColumn="id"
          defaultSort="createDate DESC"
          classColumn="logaction"
{
  property name="note"       fieldType="column" ORMType="string" length=1024 inform=1 orderinform=6 editable=1 required=1;
  property name="attachment" fieldType="column" ORMType="string" length=128 inform=1 orderinform=7 editable=1 formfield="file";
  property name="logaction"  fieldType="many-to-one" cfc="root.model.logaction" FKColumn="logactionid" inform=1 orderinform=3 inlist=1;
  property name="entity"     fieldType="many-to-one" cfc="root.model.logged" FKColumn="entityid" inlist=1;
  property name="savedState" fieldType="column" ORMType="string" length=4000 dataType="json" inform=1;

  property persistent="false" name="createContact" inform=1 orderinform=1 inlist=1;
  property persistent="false" name="createDate" inform=1 orderinform=2 inlist=1;

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  function init()
  {
    return this;
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  function getName()
  {
    var entity = getEntity();
    if( !isNull( entity ))
    {
      return entity.getName() & " log";
    }

    return "no entity found";
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  function enterIntoLog( action, Struct newState={} )
  {
    var newStateAsJSON = "";
    var tempEntity = this.getEntity();
    var prevLogEntry = entityLoad( "logentry", { entity = this.getEntity()}, "createDate DESC", { maxResults = 1 } );

    if( isDefined( "action" ) and isSimpleValue( action ))
    {
      if( len( trim( action )))
      {
        action = entityLoad( "logaction", { name = action }, true );
      }
      else
      {
        structDelete( arguments, "action" );
      }
    }

    if( not isDefined( "action" ))
    {
      action = entityLoad( "logaction", { name = "Init" }, true );
    }

    if( structCount( newState ) eq 0 )
    {
      newState = {
        "init" = true,
        "name" = this.getEntity().getName()
      };
    }

    newStateAsJSON = serializeJSON( newState );

    setCreateDate( now());
    setCreateIP( cgi.remote_host );
    setSavedState( newStateAsJSON );
    setLogaction( action );

    if( isDefined( "request.context.auth.user" ))
    {
      setCreateContact( request.context.auth.user );
    }

    this.getEntity().addLogentry( this );

    entitySave( this );

    return this;
  }
}