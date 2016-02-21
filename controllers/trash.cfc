component extends=crud {
  variables.entity = "base";
  variables.listitems = "name,entityName,updateDate";
  variables.listactions = "";

  public void function default( required struct rc ) {
    rc.showdeleted = true;
    super.default( rc );
  }
}