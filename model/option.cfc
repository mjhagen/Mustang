component extends="basecfc.base"
          persistent=true
          table="option"
          schema="mustang"
          discriminatorColumn="type" {
  property persistent=false name="name" inlist=true;
  property persistent=false name="type" inlist=true;
  property persistent=false name="sourcecolumn" inlist=true;

  function getType() {
    return variables.instance.meta.discriminatorValue;
  }
}