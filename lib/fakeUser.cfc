component accessors=true {
  property type="string" name="name" default="Administrator";
  property type="string" name="firstname" default="John";
  property type="string" name="lastname" default="Doe";

  public any function init() {
    return this;
  }
}