component extends="basecfc.base"
          persistent=true
          table="metadata"
          schema="mustang" {
  property name="name" type="string" length=128;
  property name="deleted" type="boolean" ORMType="boolean" default=false inapi=false;
  property name="sortorder" type="numeric" ORMType="integer" default=0;

  property name="createContact" fieldType="many-to-one" FKColumn="createcontactid" cfc="root.model.contact";
  property name="createDate" ORMType="timestamp";
  property name="createIP"  length=15;

  property name="updateContact" fieldType="many-to-one" FKColumn="updatecontactid" cfc="root.model.contact";
  property name="updateDate" ORMType="timestamp";
  property name="updateIP" length=15;

  property name="logEntries" singularName="logEntry" fieldType="one-to-many" cfc="root.model.logentry" FKColumn="entityid" inapi=false;

}