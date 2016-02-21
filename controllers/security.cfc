component accessors=true {
  property framework;
  property securityService;
  property contactService;
  property contentService;
  property mailService;
  property optionService;
  property utilityService;
  property dataService;

  public void function login( required struct rc ) {
    framework.setLayout( "security" );

    param rc.username="";
    param rc.password="";
  }

  public void function doLogin( required struct rc ) {
    param rc.username="";
    param rc.password="";
    param rc.authhash="";
    param rc.dontRedirect=false;

    lock name="login_#rc.username#" type="exclusive" timeout=5 {
      var updateUserWith = {
        lastLoginDate = now()
      };

      // Check credentials:
      if( structKeyExists( rc, "authhash" ) && len( trim( rc.authhash ))) {
        writeLog( text="trying authhash", type="information", file=request.appName );

        var contactID=decrypt( rc.util.base64urlDecode( rc.authhash ), rc.config.encryptKey );
        var user = contactService.get( contactID );

        if( isNull( user )) {
          rc.alert = {
            "class" = "danger",
            "text" = "user-not-found"
          };
          writeLog( text = "authhash failed", type = "warning", file = request.appName );
          doLogout( rc );
        }

        rc.dontRedirect = true;
        writeLog( text = "authhash success", type = "information", file = request.appName );
      } else {
        // CHECK USERNAME:
        var user = contactService.getByUsername( rc.username );

        if( isNull( user )) {
          rc.alert = {
            "class" = "danger",
            "text" = "user-not-found"
          };
          writeLog( text = "login failed: wrong username (#rc.username#)", type = "warning", file = request.appName );
          doLogout( rc );
        }

        // CHECK PASSWORD:
        var decryptSpeed = getTickCount();
        var passwordIsCorrect = securityService.comparePassword( password = rc.password, storedPW = user.getPassword());
        decryptSpeed = getTickCount() - decryptSpeed;

        if( !passwordIsCorrect ) {
          rc.alert = {
            "class" = "danger",
            "text" = "password-incorrect"
          };
          writeLog( text = "user #user.getUsername()# login failed: wrong password", type = "warning", file = request.appName );
          doLogout( rc );
        }

        if( passwordIsCorrect && ( decryptSpeed < 250 || decryptSpeed > 1000 )) {
          // re-encrypt if decryption is too slow, or too fast:
          updateUserWith.password = securityService.hashPassword( rc.password );
        }
      }

      // Set auth struct:
      securityService.refreshSession( user );

      updateUserWith.contactID=user.getID();

      if( rc.config.log ) {
        structAppend( updateUserWith, {
          add_contactLogEntry={
            relatedEntity=user,
            by=user,
            dd=now(),
            ip=cgi.remote_addr,
            logaction=optionService.getOptionByName( "logaction", "security" ),
            note="Logged in"
          }
        });
      }

      var originalLogSetting=rc.config.log;
      request.context.config.log=false;

      user.save( updateUserWith );

      request.context.config.log=originalLogSetting;

      writeLog( text="user #user.getUsername()# logged in.", type="information", file=request.appName );
    }

    if( !rc.dontRedirect ) {
      var loginscript=session.auth.role.getLoginScript();

      if( structKeyExists( rc , 'returnpage') ) {
      	loginscript=rc.returnpage;
      } else if( isNull( loginscript ) || !len( trim( loginscript ))) {
        loginscript=":";
      }

      framework.redirect( loginscript );
    }
  }

  public void function doLogout( required struct rc ) {
    // reset session
    securityService.createSession();

    if( isDefined( "rc.auth.isLoggedIn" ) && isBoolean( rc.auth.isLoggedIn ) && rc.auth.isLoggedIn && !structKeyExists( rc, "alert" )) {
      rc.alert={
        "class"="success",
        "text"="logout-success"
      };
    }

    var logMessage="user logged out.";

    if( rc.config.log && isDefined( "rc.auth.userid" ) && dataService.isGUID( rc.auth.userid )) {
      var user=contactService.get( rc.auth.userid );

      if( !isNull( user )) {
        logMessage=user.getUsername() & " logged out.";
      }

      var updateUserLog={
        contactID=user.getID(),
        add_contactLogEntry={
          relatedEntity=user,
          logaction=optionService.getOptionByName( "logaction", "security" ),
          note=logMessage,
          by=user,
          dd=now(),
          ip=cgi.remote_addr
        }
      };

      var originalLogSetting=rc.config.log;
      request.context.config.log=false;

      user.save( updateUserLog );

      request.context.config.log=originalLogSetting;
    }

    writeLog( text=logMessage, type="information", file=request.appName );

    if( framework.getSubsystem() == "api" || listFirst( cgi.PATH_INFO, "/" ) == "api" ) {
      var isLucee = listFindNoCase( "lucee,railo", server.ColdFusion.ProductName );
      var pageContext=getPageContext();
      var response = isLucee ? pageContext.getResponse() : pageContext.getFusionContext().getResponse();

      response.setHeader( "WWW-Authenticate", "Basic realm=""#request.appName#-API""" );

      framework.renderData( "rawjson", '{"status":"error","detail":"Unauthorized"}', 401 );
      framework.abortController();
    }

    framework.redirect( ":security.login", "alert" );
  }

  public void function authorize( required struct rc ) {
    rc.auth = { isLoggedIn = false };

    lock name="lock_#request.appName#_#session.urltoken#" type="exclusive" timeout="5" {
      if( structKeyExists( session, "auth" ) && structKeyExists( session.auth, "isLoggedIn" )) {
        structAppend( rc.auth, session.auth );
      }

      if( rc.auth.isLoggedIn ) {
        return;
      }

      // Auto login:
      if( structKeyExists( rc, 'authhash' )) {
        writeLog( text = "trying authhash", type = "information", file = request.appName );
        doLogin( rc = rc );
      }

      // Always allow access to security && api:css
      if(( framework.getSubsystem() == framework.getDefaultSubsystem() && !rc.config.secureDefaultSubsystem ) ||
         ( framework.getSection() == "security" ) ||
         ( framework.getSubsystem() == "adminapi" && framework.getSection() == "css" )) {
        return;
      }

      // API basic auth login:
      var HTTPRequestData = GetHTTPRequestData();

      if( isStruct( HTTPRequestData ) &&
          structKeyExists( HTTPRequestData, "headers" ) &&
          isStruct( HTTPRequestData.headers ) &&
          structKeyExists( HTTPRequestData.headers, "authorization" ) &&
          len( trim( HTTPRequestData.headers.authorization ))) {
        writeLog( text = "trying API basic auth", type = "information", file = request.appName );
        var basicAuth = toString( toBinary( listLast( HTTPRequestData.headers.authorization, " " )));

        rc.username = listFirst( basicAuth, ":" );
        rc.password = listRest( basicAuth, ":" );
        rc.dontRedirect = true;

        doLogin( rc );
      }

      // no auth in session, user is not logged in:
      if( !structKeyExists( session, "auth" )) {
        rc.alert = {
          "class" = "danger",
          "text" = "no-auth-in-session"
        };
        doLogout( rc );
      }

      // store session info in the request context scope:
      structAppend( rc.auth, session.auth );

      if( !securityService.authIsValid( rc.auth )) {
        // something is wrong with the session:
        rc.alert = {
          "class" = "danger",
          "text" = "invalid-auth-struct"
        };
        doLogout( rc );
      }

      if( !rc.auth.isLoggedIn ||
          !structKeyExists( rc.auth, "user" )) {
        // something is wrong with the session:
        rc.alert = {
          "class" = "danger",
          "text" = "user-not-logged-in"
        };
        doLogout( rc );
      }
    }
  }

  public void function doRetrieve( required struct rc ) {
    if( structKeyExists( rc, 'email' ) && len( trim( rc.email ))) {
      var user=contactService.getByEmail( rc.email );

      if( !isNull( user )) {
        var authhash=toBase64( encrypt( user.getID(), rc.config.encryptKey ));
        var activationEmails=contentService.getByFQA( "mail.activation" );

        if( arrayLen( activationEmails ) gt 0 ) {
          var emailText=activationEmails[1];
        }

        if( isNull( emailText )) {
          var logMessage="missing activation email text, add text with fqa: 'mail.activation'";
          writeLog( text=logMessage, type="warning", file=request.appName );
          throw( logMessage );
        }

        mailService.send(
          rc.config.ownerEmail,
          user,
          emailText.getTitle(),
          rc.util.parseStringVariables(
            emailText.getBody(),
            {
              link=framework.buildURL( action='profile.password', queryString={ "authhash"=authhash })
            }
          )
        );

        rc.alert = {
          "class"="success",
          "text"="email-sent"
        };
        writeLog( text="retrieve password email sent", type="information", file=request.appName );
        framework.redirect( ":security.login", "alert" );
      } else {
        rc.alert = {
          "class"="danger",
          "text"="email-not-found"
        };
        writeLog( text="retrieve password email not found", type="warning", file=request.appName );
        framework.redirect( ":security.retrieve", "alert" );
      }
    }
  }
}
