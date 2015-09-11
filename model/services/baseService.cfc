component accessors=true {
  property entityName;

  public any function init() {
    var meta = getMetaData( this );

    setEntityName( listLast( meta.name, '.' ));

    return this;
  }

  public any function get( required string id ) {
    return entityLoadByPK( getEntityName(), id );
  }

  public any function getAsStruct( required string id ) {
    var data = get( id );

    if( !isNull( data )) {
      return toStruct( data );
    }

    return nil();
  }

  private void function nil() {
  }

  // By Adam Tuttle (http://fusiongrokker.com/post/deorm).
  private struct function toStruct( obj=this ) hint="Returns a JSON representation of the object" {
    var deWormed = {};

    if( isSimpleValue( obj )){
      deWormed = obj;

    } else if( isObject( obj )){
      var md = getMetadata( obj );

      do {
        if( md.keyExists( 'properties' )){
          for( var prop in md.properties){
            if( structKeyExists( obj, 'get' & prop.name )){
              if( !prop.keyExists( 'fieldtype' ) || prop.fieldtype == "id" || ( prop.keyExists( 'fieldtype' ) && !( listFindNoCase( "one-to-many,many-to-one,one-to-one,many-to-many", prop.fieldtype )))){
                deWormed[ prop.name ] = evaluate( "obj.get#prop.name#()" );
              }
            }
          }
        }

        if( md.keyExists( 'extends' )){
          md = md.extends;
        }
      } while( md.keyExists( 'extends' ));

    } else if( isStruct( obj )){
      for( var key in obj ){
        deWormed[ key ] = toStruct( obj[key] );
      }

    } else if( isArray( obj )){
      var deWormed = [];
      for( var el in obj ){
        deWormed.append( toStruct( el ) );
      }

    } else {
      deWormed = getMetadata( obj );
    }

    return deWormed;

    // var jsonified = deserializeJSON( serializeJSON( this ));
    // structDelete( jsonified, "password" );
    // return serializeJSON( jsonified );
  }
}