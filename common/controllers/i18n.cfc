component output="false" {
  public i18n function init( fw ) {
    variables.fw = fw;
    return this;
  }

  public void function setLanguage( rc ) {
    var defaultLanguage = rc.config.defaultLanguage;
    var localeID = createUUID();
    var reload = false;

    lock scope="session" timeout=5 {
      if( not structKeyExists( cookie, "localeID" ) or
          not structKeyExists( session, "localeID" ) or
          not structKeyExists( session, "locale" ) or
          structKeyExists( url, "localeID" ) or
          structKeyExists( url, "reload" )){
        reload = true;
      }
    }

    if( reload ) {
      if( structKeyExists( rc, "localeID" ) and len( trim( rc.localeID ))) {
        localeID = rc.localeID;
      }

      if( not len( trim( localeID )) and structKeyExists( cookie, "localeID" ) and len( trim( cookie.localeID ))) {
        localeID = cookie.localeID;
      }

      if( not len( trim( localeID ))) {
        lock scope="session" timeout=5 {
          if( structKeyExists( session, "localeID" ) and len( trim( session.localeID ))) {
            localeID = session.localeID;
          }
        }
      }

      var locale = entityLoadByPK( "locale", localeID );

      if( isNull( locale ) and len( trim( defaultLanguage ))) {
        var defaultLanguageCode = listGetAt( defaultLanguage, 1, "_" );
        var defaultCountryCode = listGetAt( defaultLanguage, 2, "_" );
        var language = entityLoad( "language", { "code" = defaultLanguageCode }, true );
        var country = entityLoad( "country", { "code" = defaultCountryCode }, true );
        
        if( not isNull( language ) and not isNull(country) ){
          var locale = entityLoad( "locale" , { country = country, language = language }, true );
        }
        
        if( isNull( locale )){
          var locale = entityNew( "locale" );

        if( isNull( language )) {
		          var language = entityNew( "language" );
		          language.setCode( defaultLanguageCode );
		      }
	
        if( isNull( country )) {
	          var country = entityNew( "country" );
	          country.setCode( defaultCountryCode );
	        }
	
	        locale.setID( localeID );
	        locale.setLanguage( language );
	        locale.setCountry( country );
	      }
      }

      localeID = locale.getID();

      var localeCode = locale.getCode();

      if( not isNull( localeCode ) and
          len( trim( localeCode ))) {
        setLocale( localeCode );
      }

      lock scope="session" timeout=5 type="exclusive" {
        cookie.localeID = localeID;
        session.localeID = localeID;
        session.locale = locale;
        rc.currentlocaleID = localeID;
        rc.currentlocale = locale;
      }
    }

    lock scope="session" timeout=5 {
      rc.currentlocaleID = session.localeID;
      rc.currentlocale = session.locale;
    }
  }
}