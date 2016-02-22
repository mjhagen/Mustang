component extends="basecfc.base"
          persistent=true
          schema="mustang" {
  property name="language" fieldType="many-to-one" cfc="root.model.language" FKColumn="languageid" inform=true editable=true;
  property name="country" fieldType="many-to-one" cfc="root.model.country" FKColumn="countryid" inform=true editable=true;
  property name="texts" fieldType="one-to-many" cfc="root.model.text" FKColumn="localeid" singularName="text";
  property name="name" persistent=false inlist=true;
  property name="code" persistent=false inlist=true;

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

  public string function getCode( string delimiter="_" ){
    if( isNull( variables.language )){
      var language = new Language();
      language.setISO2( "en" );
    }

    if( isNull( variables.country )){
      var country = new Country();
      country.setISO2( "US" );
    }

    return language.getISO2() & delimiter & country.getISO2();
  }
}