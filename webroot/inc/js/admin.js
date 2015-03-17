$(function(){
  // Loading animation button
  Ladda.bind( '.ladda-button' );

  $(document).ajaxStart(function() {
    $( '#loading' ).show();
  });

  $(document).ajaxStop(function() {
    $( '#loading' ).hide();
  });

	/*
	$('.sidebar-nav').slimScroll({
    height: $('#side-menu').height() + 'px'
  });*/
});
