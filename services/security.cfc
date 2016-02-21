component {
  public any function init() {
    variables.instance.bcrypt = getBCrypt();
  }

  public boolean function authIsValid( required struct auth ) {
    var requiredKeys = [ 'isLoggedIn', 'user', 'userid', 'role' ];

    for( var key in requiredKeys ) {
      if( !structKeyExists( auth, key )) {
        return false;
      }
    }

    if( !len( trim( auth.userid ))) { return false; }
    if( !isInstanceOf( auth.user, "root.model.contact" )) { return false; }
    if( !isInstanceOf( auth.role, "root.model.securityrole" )) { return false; }
    if( !isBoolean( auth.isLoggedIn )) { return false; }

    return true;
  }

  public void function createSession() {
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

    lock name="lock_#request.appName#_#cfid#_#cftoken#" type="exclusive" timeout="5" {
      structClear( session );
      structAppend( session, tmpSession );
    }
  }

  public void function refreshSession( required root.model.contact user ) {
    createSession();

    var securityRole = user.getSecurityrole();
    var tempAuth = {
      isLoggedIn = true,
      user = user,
      userid = user.getID(),
      role = securityRole,
      canAccessAdmin = securityRole.getCanAccessAdmin()
    };

    lock name="lock_#request.appName#_#cfid#_#cftoken#" type="exclusive" timeout="5" {
      structAppend( session.auth, tempAuth, true );
    }
  }

  public string function hashPassword( required string password ) {
    var t = 0;
    var cost = 4;

    while( t < 500 && cost <= 30 ) {
      var salt = variables.instance.bcrypt.gensalt( cost );
      var hashedPW = variables.instance.bcrypt.hashpw( password, salt );

      // test speed of decryption:
      var start = getTickCount();
      variables.instance.bcrypt.checkpw( password, hashedPW );
      t = getTickCount() - start;
      cost++;
    }

    return hashedPW;
  }

  public boolean function comparePassword( required string password, required string storedPW ) {
    try {
      // FIRST TRY BCRYPT:
      return variables.instance.bcrypt.checkpw( password, storedPW );
    } catch( Any e ) {
      try {
        // THEN TRY THE OLD SHA-512 WAY:
        var storedsalt = right( storedPW, 16 );

        return 0 == compare( storedPW, hash( password & storedsalt, 'SHA-512' ) & storedsalt );
      } catch( Any e ) {
        return false;
      }
    }
  }

  private any function getBCrypt() {
    var system = createObject( "java", "java.lang.System" );
    var javaVersion = listGetAt( system.getProperty( "java.version" ), 2, "." );
    var bCryptLocation = directoryList( "#request.root#/lib/java/#javaVersion#/", false, "path", "*.jar" );
    var jl = new javaloader.javaloader( bCryptLocation );

    return jl.create( "org.mindrot.jbcrypt.BCrypt" );
  }
}