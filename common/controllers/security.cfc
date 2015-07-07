component
{
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public any function init( struct fw )
  {
    variables.fw = fw;
    variables.frameworkConfig = fw.getConfig();

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
    param name="rc.dontRedirect" default=false;

    lock name="login_#rc.username#" type="exclusive" timeout="5"
    {
      session.alert = {
        "class" = "danger",
        "text"  = "login-error"
      };

      if( structKeyExists( rc, "authhash" ) and len( trim( rc.authhash )))
      {
        rc.util.createSession();

        local.contactID = decrypt( toString( toBinary( rc.authhash )), request.context.config.encryptKey );
        local.user = entityLoadByPK( "contact", local.contactID );

        if( isNull( local.user ))
        {
          session.alert = {
            "class" = "danger",
            "text"  = "user-not-found"
          };
          doLogout( rc=rc );
        }

        rc.dontRedirect = true;
      }
      else
      {
        var loginValidated = true;

        // CHECK USERNAME:
        var findusers = entityLoad( "contact", { "username" = rc.username, "deleted" = false });

        if( isNull( findusers ) or arrayLen( findusers ) neq 1 )
        {
          loginValidated = false;
        }

        if( loginValidated )
        {
          local.user = findusers[1];

          // CHECK PASSWORD:
          loginValidated = rc.util.comparePassword( password = rc.password, storedPW = local.user.getPassword());
        }

        if( not loginValidated )
        {
          doLogout( rc=rc );
        }
        // / CHECK PASSWORD:
      }

      if( local.user.getDeleted() eq true )
      {
        session.alert = {
          "class" = "danger",
          "text"  = "user-was-deleted"
        };
        doLogout( rc=rc );
      }

      local.user.setLastLoginDate( now());

      if( rc.config.log )
      {
        local.securityLogAction = entityLoad( "logaction", { "name" = "security" }, true );

        local.loginEvent = entityNew( "logentry" );
        entitySave( local.loginEvent );

        local.loginEvent.save( {
          "logaction"     = local.securityLogAction.getID(),
          "note"          = "Logged in",
          "createContact" = local.user.getID(),
          "createDate"    = now(),
          "createIP"      = cgi.remote_addr,
          "updateContact" = local.user.getID(),
          "updateDate"    = now(),
          "updateIP"      = cgi.remote_addr,
          "deleted"       = false
        });
      }

      rc.util.refreshSession( userid = local.user.getID());

      if( not structKeyExists( session.auth, "role" ))
      {
        rc.util.createSession();
        session.alert = {
          "class" = "danger",
          "text"  = "user-has-no-role"
        };
        doLogout( rc=rc );
      }

      structDelete( session, "alert" );
    }

    if( not rc.dontRedirect )
    {
      var role = local.user.getSecurityRole();
      if( not isNull( role ))
      {
        var loginscript = role.getLoginScript();
      }

      if( isNull( loginscript ) or not len( trim( loginscript )))
      {
        loginscript = "#variables.frameworkConfig["defaultSubsystem"]#:";
      }

      fw.redirect( loginscript );
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
        if( rc.config.log and not isNull( local.user ))
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

      if( fw.getSubsystem() eq "api" or listFirst( cgi.PATH_INFO, "/" ) eq "api" or ( fw.getSubsystem() eq "admin" and fw.getSection() eq "api" ))
      {
        var pageContext = getPageContext();
        var response = pageContext.getFusionContext().getResponse();
            response.setStatus( 401 );
            response.setHeader( "Content-Type", "application/json" );

        request.context.util.setCFSetting( "showdebugoutput", false );
        pageContext.getCfoutput().clearAll();
        writeOutput( serializeJSON( {"status"="error","detail"="Unauthorized"} ));
        abort;
      }

      fw.redirect( "common:security.login" );
    }
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public void function authorize( struct rc )
  {
    lock scope="session" type="exclusive" timeout="5"
    {
      // Always allow access to common:security and api:css
      if(
          listFind( 'security,css', fw.getSection()) or
          (
            len( trim( rc.config.securedSubsystems )) and
            not listFindNoCase( rc.config.securedSubsystems, fw.getSubSystem())
          )
        )
      {
        rc.auth.isLoggedIn = false;
        if(
            structKeyExists( session, "auth" ) and
            structKeyExists( session.auth, "isLoggedIn" )
          )
        {
          rc.auth = session.auth;
        }
        return;
      }

      // Auto login
      if( structKeyExists( rc, 'authhash' ))
      {
        doLogin( rc = rc );
      }

      var HTTPRequestData = GetHTTPRequestData();

      if(
          isStruct( HTTPRequestData ) and
          structKeyExists( HTTPRequestData, "headers" ) and
          isStruct( HTTPRequestData.headers ) and
          structKeyExists( HTTPRequestData.headers, "authorization" ) and
          len( trim( HTTPRequestData.headers.authorization ))
        )
      {
        var basicAuth = toString( toBinary( listLast( HTTPRequestData.headers.authorization, " " )));
        rc.username = listFirst( basicAuth, ":" );
        rc.password = listRest( basicAuth, ":" );
        rc.dontRedirect = true;

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

      if( not rc.util.authIsValid( rc.auth ) or not rc.auth.isLoggedIn )
      {
        session.alert = {
          "class" = "danger",
          "text"  = "invalid-auth-struct"
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
      fw.redirect( "common:security.login" );
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