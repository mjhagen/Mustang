component persistent="true"
          extends="basecfc.base"
          hint="(for future development) helper object containing websites"
          hideDelete="true"
{
  property name="logo" length="128" orderinform="2" inform="true" editable="true" formfield="file";
  property name="hostname" length="128" inlist="true" orderinlist="3" orderinform="3" inform="true" editable="true";
  property name="menulist" length="128" orderinform="4" inform="true" editable="true";

  property name="fontfamily" length="32";
  property name="fontsize" length="32";
  property name="fontcolor" length="32";

  property name="color1" length="32";
  property name="color2" length="32";
  property name="color3" length="32";
  property name="color4" length="32";
  property name="color5" length="32";

  // property name="texts" fieldType="many-to-many" inverse="true" singularName="text" FKColumn="websiteid" cfc="text" linkTable="websitetext" inverseJoinColumn="textid";
  // property name="customdata" singularName="logentry" fieldType="one-to-many" cfc="logentry" FKColumn="logactionid";

  property name="name" inlist=true inform=true editable=true;
}