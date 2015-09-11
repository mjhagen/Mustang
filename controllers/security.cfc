component accessors=true {
  property securityService;
  property contactService;
  property contentService;
  property mailService;

  public any function init( required struct fw ) {
    variables.fw = fw;
    variables.frameworkConfig = fw.getConfig();

    return this;
  }

  public void function login( required struct rc ) {
    param rc.username = "";
    param rc.password = "";
  }

  public void function doLogin( required struct rc ) {
    param rc.username = "";
    param rc.password = "";
    param rc.authhash = "";
    param rc.dontRedirect = false;

    lock name = "login_#rc.username#"
         type = "exclusive"
         timeout = "5" {
      // Check credentials:
      if( structKeyExists( rc, "authhash" ) && len( trim( rc.authhash ))) {
        var contactID = decrypt( rc.util.base64urlDecode( rc.authhash ), request.context.config.encryptKey );
        var user = contactService.get( contactID );

        if( isNull( user )) {
          rc.alert = {
            "class" = "danger",
            "text"  = "user-not-found"
          };
          writeLog( text = "authhash failed", type = "warning", file = request.appName );
          doLogout( rc = rc );
        }

        rc.dontRedirect = true;
        writeLog( text = "authhash success", type = "information", file = request.appName );
      } else {
        // CHECK USERNAME:
        var user = contactService.getByUsername( rc.username );

        if( isNull( user )) {
          rc.alert = {
            "class" = "danger",
            "text"  = "user-not-found"
          };
          writeLog( text = "login failed: wrong username", type = "warning", file = request.appName );
          doLogout( rc = rc );
        }

        // CHECK PASSWORD:
        if( !securityService.comparePassword( password = rc.password, storedPW = user.getPassword())) {
          rc.alert = {
            "class" = "danger",
            "text"  = "password-incorrect"
          };
          writeLog( text = "user #user.getUsername()# login failed: wrong password ", type = "warning", file = request.appName );
          doLogout( rc = rc );
        }
      }

      // Set auth struct:
      user.save({ LastLoginDate = now()});
      securityService.refreshSession( user );

      writeLog( text = "user #user.getUsername()# logged in.", type = "information", file = request.appName );

      // Log login action:
      if( rc.config.log ) {
        transaction {
          var logentry = entityNew( "logentry" );
          entitySave( logentry );
          logentry
            .save({ note = "Logged in", entity = user.getID()})
            .enterIntoLog( "security" );
          transactionCommit();
        }
      }
    }

    if( !rc.dontRedirect ) {
      var loginscript = session.auth.role.getLoginScript();

      if( structKeyExists( rc , 'returnpage') ) {
      	loginscript = rc.returnpage;
      }
      else if( isNull( loginscript ) || !len( trim( loginscript ))) {
        loginscript = "admin:";
      }

      fw.redirect( loginscript );
    }
  }

  public void function doLogout( required struct rc ) {
    // reset session
    securityService.createSession();

    if( isDefined( "rc.auth.isLoggedIn" ) && rc.auth.isLoggedIn ) {
      rc.alert = {
        "class" = "success",
        "text"  = "logout-success"
      };
    }

    var logMessage = "user logged out.";

    if( rc.config.log && isDefined( "rc.auth.userid" ) && len( trim( rc.auth.userid ))) {
      var user = contactService.get( rc.auth.userid );

      if( !isNull( user )) {
        logMessage = user.getUsername() & " logged out.";
      }

      transaction {
        var logentry = entityNew( "logentry" );
        entitySave( logentry );
        logentry
          .save({ note = "Logged out", entity = rc.auth.userid })
          .enterIntoLog( "security" );
        transactionCommit();
      }
    }

    writeLog( text = logMessage, type = "information", file = request.appName );

    if( fw.getSubsystem() == "api" || listFirst( cgi.PATH_INFO, "/" ) == "api" || ( fw.getSubsystem() == "admin" && fw.getSection() == "api" )) {
      var pageContext = getPageContext();
      var response = pageContext.getFusionContext().getResponse();
          response.setStatus( 401 );
          response.setHeader( "Content-Type", "application/json" );

      rc.util.setCFSetting( "showdebugoutput", false );
      pageContext.getCfoutput().clearAll();
      writeOutput( serializeJSON( {"status"="error","detail"="Unauthorized"} ));
      abort;
    }

    if( structKeyExists( rc, "alert" )) {
      lock scope = "session"
           type = "exclusive"
           timeout = "5" {
        session.alert = rc.alert;
      }
    }

    fw.redirect( ":security.login" );
  }

  public void function authorize( required struct rc ) {
    lock scope = "session"
         type = "exclusive"
         timeout = "5" {

      // Auto login:
      if( structKeyExists( rc, 'authhash' )) {
        writeLog( text = "trying authhash", type = "information", file = request.appName );
        doLogin( rc = rc );
      }

      // Always allow access to security && api:css
      if(( fw.getSubsystem() == "" && !rc.config.secureDefaultSubsystem ) ||
         ( fw.getSubsystem() == "" && fw.getSection() == "security" ) ||
         ( fw.getSubsystem() == "adminapi" && fw.getSection() == "css" )) {
        rc.auth.isLoggedIn = false;

        if( structKeyExists( session, "auth" ) && structKeyExists( session.auth, "isLoggedIn" )) {
          rc.auth = session.auth;
        }

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
        doLogin( rc = rc );
      }

      // no auth in session, user is not logged in:
      if( !structKeyExists( session, "auth" )) {
        rc.alert = {
          "class" = "danger",
          "text"  = "no-auth-in-session"
        };
        doLogout( rc = rc );
      }

      // store session info in the request context scope:
      rc.auth = session.auth;

      if(
          !rc.auth.isLoggedIn ||
          !structKeyExists( rc.auth, "user" ) ||
          !securityService.authIsValid( rc.auth )
      ) {
        // something is wrong with the session:
        rc.alert = {
          "class" = "danger",
          "text"  = "invalid-auth-struct"
        };
        doLogout( rc = rc );
      }
    }
  }

  public void function doRetrieve( required struct rc ) {
    if( structKeyExists( rc, 'email' ) && len( trim( rc.email ))) {
      var user = contactService.getByEmail( rc.email );

      if( !isNull( user )) {
        var authhash = toBase64( encrypt( user.getID(), request.context.config.encryptKey ));
        var activationEmails = contentService.getByFQA( "mail.activation" );

        if( arrayLen( activationEmails ) gt 0 ) {
          var emailText = activationEmails[1];
        }

        if( isNull( emailText )) {
          var logMessage = "missing activation email text, add text with fqa: 'mail.activation'";
          writeLog( text = logMessage, type = "warning", file = request.appName );
          throw( logMessage );
        }

        mailService.send(
          rc.config.ownerEmail,
          user,
          emailText.getTitle(),
          rc.util.parseStringVariables(
            emailText.getBody(),
            {
              link = fw.buildURL( action = 'profile.password', queryString = { "authhash" = authhash })
            }
          )
        );

        session.alert = {
          "class" = "success",
          "text"  = "email-sent"
        };
        writeLog( text = "retrieve password email sent", type = "information", file = request.appName );
        fw.redirect( ":security.login", "all" );
      } else {
        session.alert = {
          "class" = "danger",
          "text"  = "email-not-found"
        };
        writeLog( text = "retrieve password email not found", type = "warning", file = request.appName );
        fw.redirect( ":security.retrieve" );
      }
    }
  }
}