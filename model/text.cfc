component extends="base"
          table="text"
          discriminatorColumn="type"

          persistent="true"
          hide=true
{
  property name="title" length="128" inlist="true";
  property name="body" ORMType="text";
  property name="language" fieldType="many-to-one" cfc="language" FKColumn="languageid";

  public string function getName()
  {
    return getTitle();
  }
}