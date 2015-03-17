component persistent="true"
          extends="base"
          cacheuse="read-only"
          hint="helper object containing languages (used for translating labels and content based on location)"
          hide="true"
{
  property fieldType="column" name="code" ORMType="string" length="2";
  // property fieldType="many-to-many" name="countries" singularName="country" FKColumn="languageid" linkTable="languagecountry" inverseJoinColumn="countryid" cfc="country";
  // property name="content" singularName="content" fieldType="one-to-many" cfc="content" FKColumn="languageid" inlineedit="true" where="deleted!='1'";
}