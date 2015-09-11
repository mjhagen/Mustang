

$( function() {
  var $panzoom = $( '.panzoom' );
  // var $img = $panzoom.find( 'img' );

  // $img.load(function(){
    var $this = $( this );

    $panzoom.panzoom({
      minScale: .8,
      maxScale: 5
    });

    $( window ).on( 'resize', function() {
      $panzoom.panzoom( 'resetDimensions' );
    });

    $( window ).on( 'keydown', function( e ){
      var matrix = $panzoom.panzoom( "getMatrix" );
      var panX = parseInt( matrix[4] );
      var panY = parseInt( matrix[5] );

      switch( e.keyCode ) {
        case 37   : panX+=10; break; // left
        case 38   : panY+=10; break; // up
        case 39   : panX-=10; break; // right
        case 40   : panY-=10; break; // down

        case 187  : $panzoom.panzoom( 'zoom' ); break; // plus
        case 189  : $panzoom.panzoom( 'zoom', true ); break; // minus

        default   : return;
      }

      $panzoom.panzoom( 'pan', panX, panY );
      $panzoom.panzoom( 'resetDimensions' );
    });

    $panzoom.parent().on( 'mousewheel.focal', function( e ) {
      e.preventDefault();

      var delta = e.delta || e.originalEvent.wheelDelta;
      var zoomOut = delta ? delta < 0 : e.originalEvent.deltaY > 0;

      $panzoom.panzoom( 'zoom', zoomOut, {
        increment: 0.25,
        animate: false,
        focal: e
      });

      $panzoom.panzoom( 'resetDimensions' );
    });
  // });
});