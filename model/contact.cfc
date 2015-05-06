component extends="basecfc.base"
          persistent="true"
{
  property name="username" fieldType="column" ORMType="string" length="64" inform=true orderinform=1 editable=true inlist=true;
  property name="password" fieldType="column" ORMType="string" length="144" type="string";

  property name="firstname" fieldType="column" ORMType="string" length="32" inform=true orderinform=2 editable=true;
  property name="infix" fieldType="column" ORMType="string" length="16" inform=true orderinform=3 editable=true;
  property name="lastname" fieldType="column" ORMType="string" length="64" inform=true orderinform=4 editable=true;

  property name="email" fieldType="column" ORMType="string" length="128" inform=true orderinform=5 editable=true;

  property name="lastLoginDate" fieldType="column" ORMType="timestamp" inlist=true;

  property name="name" persistent="false" inlist=true;

  property name="securityrole" fieldtype="many-to-one" cfc="securityrole" FKColumn="securityroleid" inform=true editable=true;

  function getFullname()
  {
    var result = getFirstname() & ' ' & trim( getInfix() & ' ' & getLastname());

    if( not len( trim( result )))
    {
      result = request.context.i18n.translate( 'noname' );
    }

    return result;
  }

  function getName()
  {
    return getFullname();
  }
}