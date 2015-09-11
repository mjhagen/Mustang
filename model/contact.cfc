component extends="root.model.logged"
          persistent="true"
          table="contact"
          discriminatorvalue="contact"
{
  property name="username" fieldType="column" ORMType="string" length="64" inform=1 orderinform=1 editable=1 inlist=1;
  property name="password" fieldType="column" ORMType="string" length="144" type="string";

  property name="firstname" fieldType="column" ORMType="string" length="32" inform=1 orderinform=2 editable=1;
  property name="infix" fieldType="column" ORMType="string" length="16" inform=1 orderinform=3 editable=1;
  property name="lastname" fieldType="column" ORMType="string" length="64" inform=1 orderinform=4 editable=1;

  property name="email" fieldType="column" ORMType="string" length="128" inform=1 orderinform=5 editable=1;

  property name="phone" fieldType="column" ORMType="string" length="16" inform=1 orderinform=6 editable=1;
  property name="photo" fieldType="column" ORMType="string" length="128" inform=1 orderinform=7 editable=1 formfield="file";
  property name="lastLoginDate" fieldType="column" ORMType="timestamp" inlist=1;

  property name="name" persistent="false" inlist=1;

  property name="securityrole" fieldtype="many-to-one" cfc="root.model.securityrole" FKColumn="securityroleid" inform=1 editable=1;
  property name="createdObjects" singularName="createdObject" fieldtype="one-to-many" cfc="root.model.logged" FKColumn="createcontactid" lazy=1;
  property name="updatedObjects" singularName="updatedObject" fieldtype="one-to-many" cfc="root.model.logged" FKColumn="updatecontactid" lazy=1;

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public string function getFullname(){
    var result = getFirstname() & ' ' & trim( getInfix() & ' ' & getLastname());

    if( not len( trim( result ))){
      result = request.context.i18n.translate( 'noname' );
    }

    return result;
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public string function getName(){
    return getFullname();
  }
}