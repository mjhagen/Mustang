$(function(){
  // TODO: Hierarchy, tree display:
  $( "#hierarchy" ).tree({
    dataSource  : function( options, callback )
                  {
                    var parent = "null";

                    if( "attr" in options )
                    {
                      parent = options.attr["id"];
                    }

                    var afca = $.ajax({
                      url       : ajaxUrl( "adminapi:hierarchy", "load", {
                                    entity  : _entity,
                                    id      : parent
                                  }),
                      success   : function( response )
                                  {
                                    callback( response )

                                    if( parent == "null" )
                                    {
                                      $( "#hierarchy" ).tree( 'discloseVisible' );
                                    }
                                  }
                    });
                  },
    cacheItems: true,
    folderSelect: false
  });

  $( document ).on( "click", ".hierarchy-add", function(){
    $this = $( this );
    self.location = $this.closest( ".tree-branch" ).data( "addurl" );
  });

  $( document ).on( "click", ".hierarchy-edit", function(){
    $this = $( this );
    self.location = $this.closest( ".tree-branch" ).data( "editurl" );
  });

  $( document ).on( "click", ".expand-all", function(){
    $( "#hierarchy" ).tree( "discloseAll" );
  });

  $( document ).on( "click", ".collapse-all", function(){
    $( "#hierarchy" ).tree( "closeAll" );
  });
});