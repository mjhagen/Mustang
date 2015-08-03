component accessors=true
{
  property name="name" default="Administrator";
  property name="firstname" default="John";
  property name="lastname" default="Doe";

  public any function init()
  {
    return this;
  }
}