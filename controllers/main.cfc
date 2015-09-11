component {
  public any function init( fw ) {
    variables.fw = fw;
    return this;
  }

  public void function default() {
    fw.redirect( 'admin:' );
  }
}