component extends="root.model.logged"
          persistent=true
          joinColumn="id"
          schema="mustang" {
  property name="username" length="64" inform=true orderinform=1 editable=true;
  property name="password" length="144" type="string";
  property name="firstname" length="32" inform=true orderinform=2 editable=true;
  property name="infix" length="16" inform=true orderinform=3 editable=true;
  property name="lastname" length="64" inform=true orderinform=4 editable=true;
  property name="email" length="128" inform=true orderinform=5 editable=true inlist=true orderinlist=2;
  property name="lastLoginDate" ORMType="timestamp" inlist=true;
  property name="phone" length="16" inform=1 orderinform=6 editable=1;
  property name="photo" length="128" inform=true1 orderinform=7 editable=1 formfield="file";
  property name="securityrole" fieldtype="many-to-one" cfc="root.model.securityrole" FKColumn="securityroleid" inform=true editable=true;
  property name="createdObjects" singularName="createdObject" fieldtype="one-to-many" cfc="root.model.logged" FKColumn="createcontactid";
  property name="updatedObjects" singularName="updatedObject" fieldtype="one-to-many" cfc="root.model.logged" FKColumn="updatecontactid";
  property name="contactLogEntries" singularName="contactLogEntry" fieldtype="one-to-many" cfc="root.model.logentry" FKColumn="contactid" inapi=false;

  property name="name" persistent="false" inlist=true orderinlist=1;

  property translationService;

  public string function getFullname(){
    var result = getFirstname() & ' ' & trim( getInfix() & ' ' & getLastname());

    if( not len( trim( result ))){
      result = translationService.translate( 'noname' );
    }

    return result;
  }

  public string function getName(){
    return getFullname();
  }
}