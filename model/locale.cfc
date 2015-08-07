component extends="basecfc.base"
          persistent=true
          table="locale"
          cacheuse="read-only"
          hide=true
{
  property name="language" fieldType="many-to-one" cfc="root.model.language" FKColumn="languageid";
  property name="country" fieldType="many-to-one" cfc="root.model.country" FKColumn="countryid";
  property name="texts" singularName="text" fieldType="one-to-many" cfc="root.model.text" FKColumn="localeid" inlineedit=1 where="deleted!='1'";

  public String function getCode( String delimiter="_" )
  {
    if( isNull( variables.language ))
    {
      var language = new Language();
      language.setCode( "en" );
    }

    if( isNull( variables.country ))
    {
      var country = new Country();
      country.setCode( "US" );
    }

    return language.getCode() & delimiter & country.getCode();
  }
}