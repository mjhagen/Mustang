component extends="basecfc.base"
          persistent=true
          table="locale"
          cacheuse="read-only"
          hide=true {
  property name="language" fieldType="many-to-one" cfc="root.model.language" FKColumn="languageid" inform=1 editable=1;
  property name="country" fieldType="many-to-one" cfc="root.model.country" FKColumn="countryid" inform=1 editable=1;
  property name="texts" fieldType="one-to-many" cfc="root.model.text" FKColumn="localeid" singularName="text" where="deleted!='1'";
  property name="name" persistent=false inlist=1;

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public string function getName(){
    if( isNull( variables.language )){
      var language = new Language();
      language.setName( "English" );
    }

    if( isNull( variables.country )){
      var country = new Country();
      country.setName( "US" );
    }

    return country.getName() & "/" & language.getName();
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public string function getCode( string delimiter="_" ){
    if( isNull( variables.language )){
      var language = new Language();
      language.setCode( "en" );
    }

    if( isNull( variables.country )){
      var country = new Country();
      country.setCode( "US" );
    }

    return language.getCode() & delimiter & country.getCode();
  }
}