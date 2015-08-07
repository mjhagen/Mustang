component extends="basecfc.base"
          persistent="true"
          cacheuse="read-only"
          hide="true"
{
  property fieldType="column" name="name" ORMType="string" length="128" inlist=1 inform=1 editable=1;
  property fieldType="column" name="class" ORMType="string" length="32" inlist=1 inform=1 editable=1;

  property name="logentries" singularName="logentry" fieldType="one-to-many" cfc="root.model.logentry" fkColumn="logactionid";
}