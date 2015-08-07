component extends="root.model.logged"
          persistent=true
          table="text"
          discriminatorcolumn="type"
          hide=true
{
  property name="title" fieldType="column" length=128 inlist=1;
  property name="body" fieldType="column" ORMType="text";
  property name="locale" fieldType="many-to-one" cfc="root.model.locale" FKColumn="localeid";

  public string function getName()
  {
    return getTitle();
  }
}