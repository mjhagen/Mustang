var translations = {};
var tagsToReplace = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;'
};

$(function(){
  // Auto hide certain alerts:
  $( '.alert-dismissable' ).delay( 30000 ).fadeOut();

  // JSON prettyfier:
  $( '.prettyprint' ).each(function( i, el ){
    jsonObj = JSON.parse( $( el ).html());
    $( el ).html( JSON.stringify( jsonObj, undefined, 2 ));
  });

  $( document ).on( "click", "#about-app", function(){
    var $modal = $(createModal(''));

    $( 'body' ).append( $modal );

    $( '.modal-content' , $modal ).load(ajaxUrl( 'api:modal' , 'about'), function(){
      $( 'button.btn-modal-close' , $modal ).click( function(){
        var $parent = $( this ).parents( '.modal' );
        removeModal( $parent );
      });

      $modal.modal();
    });

    return false;
  });

	$( document ).on( "click", ".fileinput-remove", function(){
    $( ".fileinput-button", $( this ).closest( ".fileinput" )).show();
    $( "input[type=hidden]", $( this ).closest( ".fileinput" )).val( "" );
    $( this ).closest( ".alert" ).html( '' ).hide();
  });
});

function createModal( id, size ){
  if( size == undefined )
  {
    size = '';
  }

  return '<div class="modal fade" data-id="'+id+'">'
  + '<div class="modal-dialog ' + size + '">'
  +   '<div class="modal-content">'
  +   '</div>'
  + '</div>';
};

function removeModal($modal){
  $modal.modal('hide');
  $modal.on('hidden.bs.modal', function () {
     $( this ).remove();
  })
};

var seoAjax = false;

function ajaxUrl( action , method , data ){
  var attributes = "";

  if( seoAjax ){
    if( data && data.length ){
      for (var i = 0; i < data.length; i++) {
        attributes += data[i][0] + "/" + data[i][1] + "/";
      }
    }
    return _webroot + "/" + action + "/" + method + "/" + attributes;
  }
  else{
    if( data && data.length ){
      for (var i = 0; i < data.length; i++) {
        attributes += "&" + data[i][0] + "=" + data[i][1];
      }
    }
    return _webroot + "/index.cfm?action=" + action + "." + method + attributes;
  }
}

