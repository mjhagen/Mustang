component extends="root.model.option"
          persistent=true
          table="option"
          discriminatorvalue="logaction"
          cacheuse="read-only"
          hide=true
{
  property name="class" fieldType="column" length=32 inlist=1 inform=1 editable=1;
  property name="logentries" singularName="logentry" fieldType="one-to-many" cfc="root.model.logentry" fkColumn="logactionid";

  property persistent=0 name="name" inlist=1 inform=1 editable=1;
}