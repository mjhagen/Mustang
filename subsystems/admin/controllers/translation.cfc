component
{
  public any function init( fw )
  {
    variables.fw = fw;

    return this;
  }

  public void function default()
  {
    rc.allLanguages = directoryList( request.root & '/i18n', false, "name" );
  }
}