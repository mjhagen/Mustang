component{
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public any function init( struct fw ){
    variables.fw = fw;
    variables.frameworkConfig = fw.getConfig();

    return this;
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public void function login( struct rc ){
    param rc.username = "";
    param rc.password = "";
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public void function doLogin( struct rc ){
    param rc.username = "";
    param rc.password = "";
    param rc.authhash = "";
    param rc.dontRedirect = false;

    lock name = "login_#rc.username#"
         type = "exclusive"
         timeout = "5" {
      // Check credentials:
      if( structKeyExists( rc, "authhash" ) && len( trim( rc.authhash ))){
        var contactID = decrypt( toString( toBinary( rc.authhash )), request.context.config.encryptKey );
        var user = entityLoadByPK( "contact", contactID );

        if( isNull( user )){
          rc.alert = {
            "class" = "danger",
            "text"  = "user-not-found"
          };
          doLogout( rc = rc );
        }

        rc.dontRedirect = true;
      } else {
        // CHECK USERNAME:
        var user = entityLoad( "contact", { "username" = rc.username, "deleted" = false }, true );

        if( isNull( user )){
          rc.alert = {
            "class" = "danger",
            "text"  = "user-not-found"
          };
          doLogout( rc = rc );
        }

        // CHECK PASSWORD:
        if( !user.comparePassword( password = rc.password, storedPW = user.getPassword())){
          rc.alert = {
            "class" = "danger",
            "text"  = "password-incorrect"
          };
          doLogout( rc = rc );
        }
      }

      // Set auth struct:
      user.setLastLoginDate( now());
      user.refreshSession();

      // Log login action:
      if( rc.config.log ){
        var securityLogAction = entityLoad( "logaction", { "name" = "security" }, true );
        var loginEvent = entityNew( "logentry" );
        entitySave( loginEvent );
        loginEvent.save( {
          "logaction"     = securityLogAction.getID(),
          "note"          = "Logged in",
          "createContact" = user.getID(),
          "createDate"    = now(),
          "createIP"      = cgi.remote_addr,
          "updateContact" = user.getID(),
          "updateDate"    = now(),
          "updateIP"      = cgi.remote_addr,
          "deleted"       = false
        });
      }
    }

    if( !rc.dontRedirect ){
      var loginscript = session.auth.role.getLoginScript();

      if( isNull( loginscript ) || !len( trim( loginscript ))){
        loginscript = "#variables.frameworkConfig["defaultSubsystem"]#:";
      }

      fw.redirect( loginscript );
    }
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public void function doLogout( struct rc ){
    // reset session
    var tmpUser = entityNew( "contact" );
    tmpUser.createSession();

    if( isDefined( "rc.auth.isLoggedIn" ) && rc.auth.isLoggedIn ){
      rc.alert = {
        "class" = "success",
        "text"  = "logout-success"
      };
    }

    if( rc.config.log and isDefined( "rc.auth.userid" ) ){
      var user = entityLoadByPK( "contact", rc.auth.userid );
      var securityLogAction = entityLoad( "logaction", { "name" = "security" }, true );
      var logoutEvent = entityNew( "logentry" );
      entitySave( logoutEvent );
      logoutEvent.save( {
        "logaction"     = securityLogAction.getID(),
        "note"          = "Logged out",
        "createContact" = user.getID(),
        "createDate"    = now(),
        "createIP"      = cgi.remote_addr,
        "updateContact" = user.getID(),
        "updateDate"    = now(),
        "updateIP"      = cgi.remote_addr,
        "deleted"       = false
      });
    }

    if( fw.getSubsystem() == "api" || listFirst( cgi.PATH_INFO, "/" ) == "api" || ( fw.getSubsystem() == "admin" && fw.getSection() == "api" )){
      var pageContext = getPageContext();
      var response = pageContext.getFusionContext().getResponse();
          response.setStatus( 401 );
          response.setHeader( "Content-Type", "application/json" );

      rc.util.setCFSetting( "showdebugoutput", false );
      pageContext.getCfoutput().clearAll();
      writeOutput( serializeJSON( {"status"="error","detail"="Unauthorized"} ));
      abort;
    }

    if( structKeyExists( rc, "alert" )){
      lock scope = "session"
           type = "exclusive"
           timeout = "5" {
        session.alert = rc.alert;
      }
    }

    fw.redirect( "common:security.login", "all" );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public void function authorize( struct rc ){
    lock scope = "session"
         type = "exclusive"
         timeout = "5" {
      // Always allow access to common:security && api:css
      if(
          ( fw.getSubsystem() == "common" && fw.getSection() == "security" ) ||
          ( fw.getSubsystem() == "adminapi" && fw.getSection() == "css" ) ||
          ( len( trim( rc.config.securedSubsystems )) && !listFindNoCase( rc.config.securedSubsystems, fw.getSubSystem()))
      ){
        rc.auth.isLoggedIn = false;

        if( structKeyExists( session, "auth" ) && structKeyExists( session.auth, "isLoggedIn" )){
          rc.auth = session.auth;
        }

        return;
      }

      // Auto login:
      if( structKeyExists( rc, 'authhash' )){
        doLogin( rc = rc );
      }

      // API basic auth login:
      var HTTPRequestData = GetHTTPRequestData();

      if(
          isStruct( HTTPRequestData ) &&
          structKeyExists( HTTPRequestData, "headers" ) &&
          isStruct( HTTPRequestData.headers ) &&
          structKeyExists( HTTPRequestData.headers, "authorization" ) &&
          len( trim( HTTPRequestData.headers.authorization ))
      ){
        var basicAuth = toString( toBinary( listLast( HTTPRequestData.headers.authorization, " " )));
        rc.username = listFirst( basicAuth, ":" );
        rc.password = listRest( basicAuth, ":" );
        rc.dontRedirect = true;
        doLogin( rc = rc );
      }

      // no auth in session, user is not logged in:
      if( !structKeyExists( session, "auth" )){
        rc.alert = {
          "class" = "danger",
          "text"  = "no-auth-in-session"
        };
        doLogout( rc = rc );
      }

      // store session info in the request context scope:
      rc.auth = session.auth;

      var tempUser = new root.model.contact();

      if(
          !rc.auth.isLoggedIn ||
          !structKeyExists( rc.auth, "user" ) ||
          !tempUser.authIsValid( rc.auth )
      ){
        // something is wrong with the session:
        rc.alert = {
          "class" = "danger",
          "text"  = "invalid-auth-struct"
        };
        doLogout( rc = rc );
      }
    }
  }

  public void function doRetrieve( struct rc ){
    if( structKeyExists( rc, 'email' ) && len( trim( rc.email )))
    {
      rc.data = entityLoad( 'contact',{ email = rc.email, deleted = false }, true );
    }

    if( isDefined( 'rc.data' ))
    {
      local.authhash = toBase64( encrypt( rc.data.getID(), request.context.config.encryptKey ));
      local.link = '<a href="http://#cgi.server_name##fw.buildURL( action = 'admin:profile.password', queryString = { authhash = local.authhash })#">Klik hier</a>';
      local.email = entityLoad( 'content', { fullyQualifiedAction = 'common:mail.activation' }, true );
      local.mailTo = rc.debug ? rc.config.ownerEmail : rc.data.getEmail();

      retrievePasswordMail = new mail();

      retrievePasswordMail.setFrom( rc.config.ownerEmail );
      retrievePasswordMail.setTo( local.mailTo );
      retrievePasswordMail.setSubject( local.email.getTitle());
      retrievePasswordMail.setHTML( true );
      retrievePasswordMail.setBody( rc.util.parseStringVariables( local.email.getBody(), { 'link' = local.link }));

      retrievePasswordMail.send();

      session.alert = {
        "class" = "success",
        "text"  = "email-send"
      };
      fw.redirect( "common:security.login", "all" );
    }
    else
    {
      session.alert = {
        "class" = "danger",
        "text"  = "email-not-found"
      };
      fw.redirect( "common:security.retrieve" );
    }
  }
}