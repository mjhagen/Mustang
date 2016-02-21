component accessors=true {
  property type="string" name="name" default="Administrator";
  property type="string" name="menuList" default="";

  public any function init() {
    return this;
  }

  public boolean function getCanAccessAdmin() {
    return true;
  }

  public boolean function can() {
    return true;
  }

  public boolean function isAdmin() {
    return true;
  }
}