component extends="root.model.logged"
          persistent=true
          joinColumn="id"
          schema="mustang" {
  property name="title" length=128 inlist=1;
  property name="body" ORMType="text";
  property name="locale" fieldType="many-to-one" cfc="root.model.locale" FKColumn="localeid";

  public string function getName() {
    return getTitle();
  }
}