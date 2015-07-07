component extends="root.model.text"
          persistent=true
          table="text"
          discriminatorvalue="content"
          hint="admin texts (like pages) are stored in here"
          defaultSort = "fullyqualifiedaction"
{
  property name="fullyqualifiedaction"  fieldType="column" length=128  orderinform=1   inform=1 editable=1 listmask='<a href="/{val}">{val}</a>' inlist=1 orderinlist=2;
  property name="subtitle"              fieldType="column" length=256  orderinform=3   inform=1 editable=1;
  property name="excerpt"               fieldType="column" length=1024 orderinform=4   inform=1 editable=1;
  property name="searchbox"             fieldType="column" length=256;
  property name="actionsbox"            fieldType="column" length=256;
  property name="htmltitle"             fieldType="column" length=64   orderinform=8   inform=1 editable=1;
  property name="htmlkeywords"          fieldType="column" length=128  orderinform=9   inform=1 editable=1;
  property name="htmldescription"       fieldType="column" length=128  orderinform=10  inform=1 editable=1;

  property persistent=false name="title"     inform=1 editable=1 orderinform=2 inlist=1 orderinlist=1;
  property persistent=false name="body"      inform=1 editable=1 orderinform=5;
  property persistent=false name="language"  inform=1 editable=1 orderinform=7;
}