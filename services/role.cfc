component accessors=true
{
  property name="name" default="Administrator";
  property name="menuList" default="test";

  public any function init()
  {
    return this;
  }

  public boolean function can()
  {
    return true;
  }
}