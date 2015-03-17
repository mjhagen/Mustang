component persistent="true"
          extends="logged"
          discriminatorColumn="type"
          discriminatorValue="website"
          joinColumn="id"
          table="text"
          hide=true
{
  property fieldType="column"       name="title"  type="string" ORMType="string" length="128" inlist="true";
  property fieldType="column"       name="body"   type="string" ORMType="text";
  property fieldType="many-to-one"  name="language" cfc="language"  FKColumn="languageid";

  public string function getName()
  {
    return getTitle();
  }
}