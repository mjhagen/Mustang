component extends="root.model.option"
          persistent=true
          table="option"
          discriminatorvalue="country"
          cacheuse="read-only"
          hide=true {
  property name="code" fieldType="column" type="string" length=2 inform=1 editable=1;
  property name="locales" singularName="locale" fieldType="one-to-many" cfc="root.model.locale" FKColumn="countryid";
}