component output="false"
{
  public i18n function init( fw )
  {
    variables.fw = fw;
    return this;
  }

  public void function setLanguage( rc )
  {
    var defaultLanguage = rc.config.defaultLanguage;
    var languageid = createUUID();
    var reload = false;

    lock scope="session" timeout=5
    {
      if(
          not structKeyExists( cookie, "languageid" ) or
          not structKeyExists( session, "languageid" ) or
          not structKeyExists( session, "language" ) or
          structKeyExists( url, "languageid" ) or
          structKeyExists( url, "reload" )
        )
      {
        reload = true;
      }
    }

    if( reload )
    {
      if( structKeyExists( rc, "languageid" ) and len( trim( rc.languageid )))
      {
        languageid = rc.languageid;
      }

      if( not len( trim( languageid )) and structKeyExists( cookie, "languageid" ) and len( trim( cookie.languageid )))
      {
        languageid = cookie.languageid;
      }

      if( not len( trim( languageid )))
      {
        lock scope="session" timeout=5
        {
          if( structKeyExists( session, "languageid" ) and len( trim( session.languageid )))
          {
            languageid = session.languageid;
          }
        }
      }

      var language = entityLoadByPK( "language", languageid );

      if( isNull( language ) and len( trim( defaultLanguage )))
      {
        language = entityLoad( "language", { "code" = defaultLanguage }, true );
      }

      if( isNull( language ))
      {
        language = entityNew( "language" );
        language.setID( languageid );
        language.setCode( defaultLanguage );
      }

      languageid = language.getID();

      if( not isSimpleValue( language ) and
          not isNull( language.getCode()) and
          len( trim( language.getCode())))
      {
        setLocale( language.getCode());
      }

      lock scope="session" timeout=5
      {
        cookie.languageid = languageid;
        session.languageid = languageid;
        session.language = language;
        rc.currentlanguageid = languageid;
        rc.currentlanguage = language;
      }
    }

    lock scope="session" timeout=5
    {
      rc.currentlanguageid = session.languageid;
      rc.currentlanguage = session.language;
    }
  }
}