component persistent=true
          extends="basecfc.base"
          table="option"
          discriminatorcolumn="type"
{
  property name="importkey" fieldType="column";
  property persistent=0 name="name" inlist=1;
  property persistent=0 name="type" inlist=1;
}