component extends="apibase"
{
  public void function getTranslations()
  {
    var translations = fileRead( "#request.root#/i18n/nl_NL.json", "utf-8" );
    returnAsJSON( deSerializeJSON( translations ));
  }
}