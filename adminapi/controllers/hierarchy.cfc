component extends="apibase"
{
  public function load( rc )
  {
    param name="rc.entity";
    param name="rc.id" default="null";

    var selection = {
      "parent" = entityLoadByPK( rc.entity, rc.id )
    };

    var items = entityLoad( rc.entity, selection );

    var result = {
      "data" = []
    };

    for( var item in items )
    {
      arrayAppend( result.data, {
        "text" = item.getName(),
        "type" = "folder",
        "attr" = {
          "id" = item.getID(),
          "hasChildren" = item.hasChild(),
          "data-editurl" = fw.buildURL( "admin:#rc.entity#.edit?#rc.entity#id=#item.getID()#" ),
          "data-addurl" = fw.buildURL( "admin:#rc.entity#.new?parent=#item.getID()#" )
        }
      });
    }

    returnAsJSON( result );
  }
}