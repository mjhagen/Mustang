component
{
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public any function init( struct fw )
  {
    variables.fw = fw;
    return this;
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public void function login( struct rc )
  {
    param name="rc.username" default="";
    param name="rc.password" default="";
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public void function doLogin( struct rc )
  {
    param name="rc.username" default="";
    param name="rc.password" default="";
    param name="rc.authhash" default="";
    param name="rc.origin" default=fw.getSubsystem();

    lock name="login_#rc.username#" type="exclusive" timeout="5"
    {
      var dontRedirect = false;

      session.alert = {
        "class" = "danger",
        "text"  = "login-error"
      };

      if( structKeyExists( rc, "authhash" ) and len( trim( rc.authhash )))
      {
        rc.util.createSession();

        local.contactID = decrypt( toString( toBinary( rc.authhash )), request.encryptKey );
        local.user = entityLoadByPK( "contact", local.contactID );

        if( isNull( local.user ))
        {
          session.alert = {
            "class" = "danger",
            "text"  = "user-not-found"
          };
          fw.redirect( "#rc.origin#:security.login" );
        }

        dontRedirect = true;
      }
      else
      {
        // CHECK USERNAME:
        var findusers = entityLoad( "contact", { "username" = rc.username, "deleted" = false });

        if( not isDefined( "findusers" ) or arrayLen( findusers ) neq 1 )
        {
          fw.redirect( "#rc.origin#:security.login", "all" );
        }
        // / CHECK USERNAME:

        local.user = findusers[1];

        // CHECK PASSWORD:
        var loginValidated = rc.util.comparePassword( password = rc.password, storedPW = local.user.getPassword());

        if( not loginValidated )
        {
          fw.redirect( "#rc.origin#:security.login" );
        }
        // / CHECK PASSWORD:
      }

      if( local.user.getDeleted() eq true )
      {
        session.alert = {
          "class" = "danger",
          "text"  = "user-was-deleted"
        };
        fw.redirect( "#rc.origin#:security.login" );
      }

      transaction
      {
        local.user.setLastLoginDate( now());
        if( isInstanceOf( local.user, 'logged' ))
        {
          local.securityLogAction = entityLoad( "logaction", { "name" = "security" }, true );
          local.loginEvent = entityNew( "logentry", {
            "logaction"     = local.securityLogAction,
            "note"          = "Logged in",
            "createContact" = local.user,
            "createDate"    = now(),
            "createIP"      = cgi.remote_addr,
            "updateContact" = local.user,
            "updateDate"    = now(),
            "updateIP"      = cgi.remote_addr,
            "deleted"       = false
          });
          entitySave( local.loginEvent );
        }
      }

      rc.util.refreshSession( userid = local.user.getID());

      if( not structKeyExists( session.auth, "role" ))
      {
        rc.util.createSession();
        session.alert = {
          "class" = "danger",
          "text"  = "user-has-no-role"
        };
        fw.redirect( "#rc.origin#:security.login" );
      }

      structDelete( session, "alert" );
    }

    if( not dontRedirect )
    {
      if( local.user.getUsername() eq "admin" )
      {
        fw.redirect( "admin:" );
      }

      fw.redirect( "home:" );
    }
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public void function doLogout( struct rc )
  {
    lock scope="session" type="exclusive" timeout="5"
    {
      rc.util.createSession();

      if( isDefined( "rc.auth.isLoggedIn" ) and rc.auth.isLoggedIn )
      {
        session.alert = {
          "class" = "success",
          "text"  = "logout-success"
        };
      }

      if( isDefined( "rc.auth.userid" ))
      {
        local.user = entityLoadByPK( "contact", rc.auth.userid );
        if( not isNull( local.user ))
        {
          local.securityLogAction = entityLoad( "logaction", { "name" = "security" }, true );
          local.loginEvent = entityNew( "logentry", {
            "logaction"     = local.securityLogAction,
            "note"          = "Logged out",
            "createContact" = local.user,
            "createDate"    = now(),
            "createIP"      = cgi.remote_addr,
            "updateContact" = local.user,
            "updateDate"    = now(),
            "updateIP"      = cgi.remote_addr,
            "entity"        = local.user,
            "deleted"       = false
          });
          entitySave( local.loginEvent );
        }
      }

      fw.redirect( "home:security.login" );
    }
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public void function authorize( struct rc )
  {
    lock scope="session" type="exclusive" timeout="5"
    {
      // Always allow access to common:security and api:css
      if( listFind( 'security,css', fw.getSection()))
      {
        rc.auth.isLoggedIn = false;
        if( structKeyExists( session, "auth" ) and
                      structKeyExists( session.auth, "isLoggedIn" ))
        {
          rc.auth.isLoggedIn = session.auth.isLoggedIn;
        }
        return;
      }

      // Auto login
      if( structKeyExists( rc, 'authhash' ))
      {
        doLogin( rc = rc );
      }

      if( not structKeyExists( session, "auth" ))
      {
        session.alert = {
          "class" = "danger",
          "text"  = "no-auth-in-session"
        };
        doLogout( rc = rc );
      }

      rc.auth = session.auth;

      if( not rc.util.authIsValid( rc.auth ))
      {
        session.alert = {
          "class" = "danger",
          "text"  = "invalid-auth-struct"
        };
        doLogout( rc = rc );
      }

      if( fw.getSubSystem() neq "home" and not rc.auth.isLoggedIn )
      {
        session.alert = {};
        fw.redirect( 'security.login' );
      }

      if( fw.getSubSystem() eq "admin" and not rc.auth.canAccessAdmin )
      {
        session.alert = {
          "class" = "danger",
          "text"  = "no-access-to-admin"
        };
        doLogout( rc = rc );
      }
    }
  }

  public void function doRetrieve( struct rc )
  {
    if( structKeyExists( rc, 'email' ) and len( trim( rc.email )))
    {
      rc.data = entityLoad( 'contact',{ email = rc.email, deleted = false }, true );
    }

    if( isDefined( 'rc.data' ))
    {
      local.authhash = toBase64( encrypt( rc.data.getID(), request.encryptKey ));
      local.link = '<a href="http://#cgi.server_name##fw.buildURL( action = 'home:profile.password', queryString = { authhash = local.authhash })#">Klik hier</a>';
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
      fw.redirect( "home:security.login" );
    }
    else
    {
      session.alert = {
        "class" = "danger",
        "text"  = "email-not-found"
      };
      fw.redirect( "home:security.retrieve" );
    }
  }
}