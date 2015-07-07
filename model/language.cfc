component extends="basecfc.base"
          persistent=true
          hint="helper object containing languages (used for translating labels and content based on location)"
          cacheuse="read-only"
          hide=true
{
  property name="code" fieldType="column" type="string" length=2 inform=1 editable=1;
  property name="text" singularName="text" fieldType="one-to-many" cfc="root.model.text" FKColumn="languageid" inlineedit=1 where="deleted!='1'";
}