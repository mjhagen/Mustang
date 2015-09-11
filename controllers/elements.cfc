component {
  public any function init( fw ) {
    variables.fw = fw;
    return this;
  }

  public void function before( rc ) {
    param rc.tableview = "";
    param rc.allColumns = {};
    param rc.showAsTree = false;
    param rc.showSearch = false;
    param rc.showNavBar = false;
    param rc.showAlphabet = false;
    param rc.returnURL = "";
    param rc.allData = [];
    param rc.data = 0;
    param rc.entity = "";
    param rc.columns = [];
    param rc.editable = false;
    param rc.hideDelete = true;
    param rc.namePrepend = "";
    param rc.modal = false;
    param rc.inline = false;
    param rc.canBeLogged = false;
    param rc.properties = {};
  }
}