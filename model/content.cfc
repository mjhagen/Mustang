component persistent="true"
          extends="text"
          discriminatorValue="content"
          joinColumn="id"
          table="text"
          hint="admin texts (like pages) are stored in here"
          defaultSort = "fullyqualifiedaction"
{
  property name="fullyqualifiedaction" fieldType="column" ORMType="string" length="128"  type="string" orderinform=1  inform=true editable=true listmask='<a href="/{val}">{val}</a>' inlist=true orderinlist=2;
  property name="subtitle"             fieldType="column" ORMType="string" length="256"  type="string" orderinform=3  inform=true editable=true;
  property name="excerpt"              fieldType="column" ORMType="string" length="1024" type="string" orderinform=4  inform=true editable=true;
  property name="searchbox"            fieldType="column" ORMType="string" length="256"  type="string";
  property name="actionsbox"           fieldType="column" ORMType="string" length="256"  type="string";
  property name="htmltitle"            fieldType="column" ORMType="string" length="64"   type="string" orderinform=8  inform=true editable=true;
  property name="htmlkeywords"         fieldType="column" ORMType="string" length="128"  type="string" orderinform=9  inform=true editable=true;
  property name="htmldescription"      fieldType="column" ORMType="string" length="128"  type="string" orderinform=10  inform=true editable=true;

  property persistent=false name="title"    inform=true editable=true orderinform=2 inlist=true orderinlist=1;
  property persistent=false name="body"     inform=true editable=true orderinform=5;
  property persistent=false name="language" inform=true editable=true orderinform=7;
}