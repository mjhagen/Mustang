component extends="root.model.option"
          persistent=true
          table="option"
          discriminatorvalue="language"
          cacheuse="read-only"
          hide=true {
  property name="code" fieldType="column" type="string" length=2 inform=1 editable=1;
  property name="locales" singularName="locale" fieldType="one-to-many" cfc="root.model.locale" FKColumn="languageid";
}