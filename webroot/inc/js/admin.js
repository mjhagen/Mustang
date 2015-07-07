$(function(){
  // Loading animation button
  Ladda.bind( '.ladda-button' );

  $(document).ajaxStart(function() {
    $( '#loading' ).show();
  });

  $(document).ajaxStop(function() {
    $( '#loading' ).hide();
  });
});
