component extends="base" persistent="true" hide="true"
{
  property name="section" fieldType="column" ORMType="string" type="string" length="32" inform="true" orderinform="1" editable="true" inlist="true" ininline="true" orderininline="1";
  property name="create" fieldType="column" ORMType="boolean" default="FALSE" inform="true" orderinform="2" editable="true" ininline="true" orderininline="2";
  property name="view" fieldType="column" ORMType="boolean" default="FALSE" inform="true" orderinform="3" editable="true" ininline="true" orderininline="3";
  property name="change" fieldType="column" ORMType="boolean" default="FALSE" inform="true" orderinform="4" editable="true" ininline="true" orderininline="4";
  property name="delete" fieldType="column" ORMType="boolean" default="FALSE" inform="true" orderinform="5" editable="true" ininline="true" orderininline="5";
  property name="approve" fieldType="column" ORMType="boolean" default="FALSE" inform="true" orderinform="6" editable="true" ininline="true" orderininline="6";

  property name="securityrole" fieldtype="many-to-one" cfc="securityrole" FKColumn="securityroleid";

  function getName()
  {
    return getSection();
  }
}