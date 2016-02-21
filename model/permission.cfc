component extends="basecfc.base"
          persistent=true
          schema="mustang" {
  property name="section" type="string" length="32" inform="true" orderinform="1" editable="true" inlist="true" ininline="true" orderininline="1";
  property name="create" ORMType="boolean" default="FALSE" inform="true" orderinform="2" editable="true" ininline="true" orderininline="2";
  property name="view" ORMType="boolean" default="FALSE" inform="true" orderinform="3" editable="true" ininline="true" orderininline="3";
  property name="change" ORMType="boolean" default="FALSE" inform="true" orderinform="4" editable="true" ininline="true" orderininline="4";
  property name="delete" ORMType="boolean" default="FALSE" inform="true" orderinform="5" editable="true" ininline="true" orderininline="5";
  property name="approve" ORMType="boolean" default="FALSE" inform="true" orderinform="6" editable="true" ininline="true" orderininline="6";

  property name="securityrole" fieldtype="many-to-one" cfc="root.model.securityrole" FKColumn="securityroleid";

  function getName() {
    return getSection();
  }
}