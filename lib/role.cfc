component accessors=true
{
  property name="name" default="Administrator";
  property name="menuList" default="";

  public boolean function getCanAccessAdmin(){
    return true;
  }

  public any function init()
  {
    return this;
  }

  public boolean function can()
  {
    return true;
  }
}