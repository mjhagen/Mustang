component output="false"
{
  public i18n function init( fw )
  {
    variables.fw = fw;
    return this;
  }

  public void function setLanguage( rc )
  {
    var defaultLanguageID = "76ae31d3-42a7-4dbd-8853-65aa66e73561";
    var languageid = defaultLanguageID;
    var reload = false;

    lock scope="session" timeout=5
    {
      if( not structKeyExists( cookie, "languageid" ) or
          not structKeyExists( session, "languageid" ) or
          not structKeyExists( session, "language" ) or
          structKeyExists( url, "reload" ))
      {
        reload = true;
      }
    }

    if( reload )
    {
      if( not len( trim( languageid )) and structKeyExists( rc, "languageid" ) and len( trim( rc.languageid )))
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
    }

    var languages = entityLoad( "language", { "id" = languageid }, "", { cacheable = true });

    if( arrayLen( languages ))
    {
      language = languages[1];
    }

    if( isNull( language ))
    {
      language = entityNew( "language", { "id" = defaultLanguageID, "code" = "nl" });
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
}