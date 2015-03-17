component persistent="true"
          extends="logged"
          discriminatorValue="website"
          joinColumn="id"
          hint="(for future development) helper object containing websites"
          hideDelete="true"
{
  property name="logo"     fieldType="column"                                orderinform="2" inform="true" editable="true" ORMType="string" length="128" formfield="file";
  property name="hostname" fieldType="column" inlist="true" orderinlist="3"  orderinform="3" inform="true" editable="true" ORMType="string" length="128";
  property name="menulist" fieldType="column"                                orderinform="4" inform="true" editable="true" ORMType="string" length="128";

  property name="fontfamily"     fieldType="column" ORMType="string" length="32";
  property name="fontsize"       fieldType="column" ORMType="string" length="32";
  property name="fontcolor"      fieldType="column" ORMType="string" length="32";

  property name="color1"         fieldType="column" ORMType="string" length="32";
  property name="color2"         fieldType="column" ORMType="string" length="32";
  property name="color3"         fieldType="column" ORMType="string" length="32";
  property name="color4"         fieldType="column" ORMType="string" length="32";
  property name="color5"         fieldType="column" ORMType="string" length="32";

  // property name="texts" fieldType="many-to-many" inverse="true" singularName="text" FKColumn="websiteid" cfc="text" linkTable="websitetext" inverseJoinColumn="textid";
  // property name="customdata" singularName="logentry" fieldType="one-to-many" cfc="logentry" FKColumn="logactionid";

  property name="name" inlist=true inform=true editable=true;
}