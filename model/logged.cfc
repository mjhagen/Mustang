component mappedSuperClass="true"
          extends="base"
          hide="true"
{

  // property fieldType="many-to-one" name="createContact" FKColumn="createcontactid" cfc="contact";
  property fieldType="column" name="createDate" ORMType="timestamp";
  property fieldType="column" name="createIP" ORMType="string" length="15";

  // property fieldType="many-to-one" name="updateContact" FKColumn="updatecontactid" cfc="contact";
  property fieldType="column" name="updateDate" ORMType="timestamp";
  property fieldType="column" name="updateIP" ORMType="string" length="15";

  // property name="log" singularName="logentry" fieldType="one-to-many" cfc="logentry" FKColumn="loggedid" orderby="createDate desc" cascade="delete-orphan";
  property name="entityName" persistent="false";

}