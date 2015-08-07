component extends="basecfc.base"
          persistent="true"
          discriminatorColumn="entityName"
          hide=true
{
  property name="createContact" fieldType="many-to-one" FKColumn="createcontactid" cfc="root.model.contact";
  property name="createDate" fieldType="column" ORMType="timestamp";
  property name="createIP" fieldType="column"  length=15;
  property name="updateContact" fieldType="many-to-one" FKColumn="updatecontactid" cfc="root.model.contact";
  property name="updateDate" fieldType="column" ORMType="timestamp";
  property name="updateIP" fieldType="column" length=15;

  property name="logEntries" singularName="logEntry" fieldType="one-to-many" cfc="root.model.logentry" FKColumn="loggedid";
}