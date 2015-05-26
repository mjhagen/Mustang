component extends="root.model.text"
          persistent=true
          table="text"
          discriminatorvalue="content"
          hint="admin texts (like pages) are stored in here"
          defaultSort = "fullyqualifiedaction"
          hide="true"
{
  property name="fullyqualifiedaction"  fieldType="column" length="128"  orderinform=1   inform=true editable=true listmask='<a href="/{val}">{val}</a>' inlist=true orderinlist=2;
  property name="subtitle"              fieldType="column" length="256"  orderinform=3   inform=true editable=true;
  property name="excerpt"               fieldType="column" length="1024" orderinform=4   inform=true editable=true;
  property name="searchbox"             fieldType="column" length="256";
  property name="actionsbox"            fieldType="column" length="256";
  property name="htmltitle"             fieldType="column" length="64"   orderinform=8   inform=true editable=true;
  property name="htmlkeywords"          fieldType="column" length="128"  orderinform=9   inform=true editable=true;
  property name="htmldescription"       fieldType="column" length="128"  orderinform=10  inform=true editable=true;

  property persistent=false name="title"     inform=true editable=true orderinform=2 inlist=true orderinlist=1;
  property persistent=false name="body"      inform=true editable=true orderinform=5;
  property persistent=false name="language"  inform=true editable=true orderinform=7;
}