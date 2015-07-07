component extends="basecfc.base"
          persistent=true
          table="text"
          discriminatorcolumn="type"
          hide=true
{
  property name="title" fieldType="column" length=128 inlist=1;
  property name="body" fieldType="column" ORMType="text";
  property name="language" fieldType="many-to-one" cfc="root.model.language" FKColumn="languageid";

  public string function getName()
  {
    return getTitle();
  }
}