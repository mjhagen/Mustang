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

    $( '.modal-content' , $modal ).load(ajaxUrl( 'adminapi:modal' , 'about'), function(){
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

function ajaxUrl( action, method, data )
{
  var seoAjax = false;
  var returnURL = _webroot + "/";

  if( seoAjax )
  {
    // return _webroot + "/" + action + "/" + method + "/" + data );
  }
  else
  {
    returnURL += "index.cfm?action=";

    if( action != undefined )
    {
      returnURL += action;
    }

    if( method != undefined )
    {
      returnURL += "." + method;
    }

    if( data != undefined )
    {
      var serializedData = $.param( data, true );

      if( serializedData != undefined && serializedData.length )
      {
        returnURL += "&" + serializedData;
      }
    }

    return returnURL;
  }
}

