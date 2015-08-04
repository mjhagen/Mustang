component extends="basecfc.base"
          persistent="true"
          table="contact"
          discriminatorvalue="contact"
{
  property name="username" fieldType="column" ORMType="string" length="64" inform=1 orderinform=1 editable=1 inlist=1;
  property name="password" fieldType="column" ORMType="string" length="144" type="string";

  property name="firstname" fieldType="column" ORMType="string" length="32" inform=1 orderinform=2 editable=1;
  property name="infix" fieldType="column" ORMType="string" length="16" inform=1 orderinform=3 editable=1;
  property name="lastname" fieldType="column" ORMType="string" length="64" inform=1 orderinform=4 editable=1;

  property name="email" fieldType="column" ORMType="string" length="128" inform=1 orderinform=5 editable=1;

  property name="phone" fieldType="column" ORMType="string" length="16" inform=1 orderinform=6 editable=1;
  property name="photo" fieldType="column" ORMType="string" length="128" inform=1 orderinform=7 editable=1;
  property name="lastLoginDate" fieldType="column" ORMType="timestamp" inlist=1;

  property name="name" persistent="false" inlist=1;

  property name="securityrole" fieldtype="many-to-one" cfc="root.model.securityrole" FKColumn="securityroleid" inform=1 editable=1;
  // property name="createdObjects" singularName="createdObject" fieldtype="one-to-many" cfc="root.model.logged" FKColumn="createcontactid";
  // property name="updatedObjects" singularName="updatedObject" fieldtype="one-to-many" cfc="root.model.logged" FKColumn="updatecontactid";

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public string function getFullname(){
    var result = getFirstname() & ' ' & trim( getInfix() & ' ' & getLastname());

    if( not len( trim( result ))){
      result = request.context.i18n.translate( 'noname' );
    }

    return result;
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public string function getName(){
    return getFullname();
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public boolean function authIsValid( required struct auth ){
    var requiredKeys = [ 'isLoggedIn', 'user', 'userid', 'role' ];

    for( var key in requiredKeys ){
      if( !structKeyExists( auth, key )){
        return false;
      }
    }

    if( !len( trim( auth.userid ))){ return false; }
    if( !isInstanceOf( auth.user, "root.model.contact" )){ return false; }
    if( !isInstanceOf( auth.role, "root.model.securityrole" )){ return false; }
    if( !isBoolean( auth.isLoggedIn )){ return false; }

    return true;
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public void function createSession(){
    var tmpSession = {
      "can" = {},
      "auth" = {
        "isLoggedIn" = false,
        "user" = 0,
        "role" = 0,
        "userid" = '',
        "canAccessAdmin" = false
      }
    };

    lock scope="session" type="exclusive" timeout="5" {
      structClear( session );
      structAppend( session, tmpSession );
    }
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public void function refreshSession(){
    createSession();

    var securityRole = getSecurityrole();
    var tempAuth = {
      isLoggedIn = true,
      user = this,
      userid = getID(),
      role = securityRole,
      canAccessAdmin = securityRole.getCanAccessAdmin()
    };

    lock scope="session" type="exclusive" timeout="5" {
      structAppend( session.auth, tempAuth, true );
    }
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  private Any function getBCrypt(){
    var javaVersion = listGetAt( createObject( "java", "java.lang.System" ).getProperty( "java.version" ), 2, "." );
    // path [,recurse] [,listInfo] [,filter] [,sort]
    var bCryptLocation = directoryList(
          "#request.root#/lib/java/#javaVersion#/",
          false,
          "path",
          "*.jar"
        );
    var jl = new javaloader.javaloader( bCryptLocation );

    return jl.create( "org.mindrot.jbcrypt.BCrypt" );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public String function hashPassword( required String password ){
    var bCrypt = getBCrypt();

    var t = 0;
    var cost = 10;

    while( t lt 400 ){
      var start = getTickCount();
      var hashedPW = bCrypt.hashpw( password, bCrypt.gensalt( cost ));
      t = getTickCount() - start;
      cost++;
    }

    return hashedPW;
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public Boolean function comparePassword( required string password, required string storedPW ){
    var bCrypt = getBCrypt();

    try{
      // FIRST TRY BCRYPT:
      return bCrypt.checkpw( password, storedPW );
    }
    catch( Any e ){
      try{
        // THEN TRY THE OLD SHA-512 WAY:
        var storedsalt = right( storedPW, 16 );

        return 0 == compare( storedPW, hash( password & storedsalt, 'SHA-512' ) & storedsalt );
      }
      catch( Any e ){
        return false;
      }
    }
  }
}