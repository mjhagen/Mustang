$(function() {
  $( document ).on( 'click' , '#button-bk' , function(e) {
    window.history.back();
  });
	
  $( document ).on( 'click' , '.print' , function(e) {
    print();
  });


  $( 'input[type=file]' ).each(function(){
    setFileupload( $( this ) );
  }); 
	
	 $( document ).on( 'click' , '.open-ul' , function(e) {
    var $this = $( this );
    
    var $target = $( 'ul' , $this.parents( 'li' ) );
    
    if ( !$this.hasClass( 'active') ) {
      $this.addClass( 'active' );
      if( $( 'input.knob' , $this.parent() ).length )
        $( 'input.knob' , $this.parent() ).val(100).trigger('change');  
      if( $target.length ) 
       $target.removeClass( 'hide' );
      
    }else{
      $this.removeClass( 'active' );
      
      if( $( 'input.knob' , $this.parent() ).length )
        $( 'input.knob' , $this.parent() ).val(0).trigger('change');      
      if( $target.length ) 
       $target.addClass( 'hide' );  
    }
  });
});

function setFileupload( $input ){	
  $input.fileupload({
      url         : ajaxUrl( 'api:crud' , 'upload'),
      dataType    : 'json',
      add         : function( e, data ){
                      $( '.progress', $( this ).closest( 'div' )).show();
                      data.submit();
                    },
      done        : function( e, data ){
                      $( '.btn', $( this ).closest( 'div' )).hide();
                      $( '.progress', $( this ).closest( 'div' )).hide();
                      $( '.alert', $( this ).closest( 'div' )).addClass( 'alert-success' ).html( '<button type="button" class="close fileinput-remove">&times;</button>' + data.result.files[0].name ).show();

                      $( 'input[name='+$( this ).data('name')+']' ).val( data.result.files[0].name );
                      $( 'input[name='+$( this ).data('name')+'_uuid]' ).val( data.result.files[0].uuid );
                    },
      progressall : function( e, data ){
                      var progress = parseInt( data.loaded / data.total * 100, 10 );
                      $( '.progress .progress-bar', $( this ).closest( 'div' )).css(
                        'width',
                        progress + '%'
                      );
                    }
    });
}

function setValidator( $form, fields , validateoninit ){
  $form.bootstrapValidator({
    live: 'enabled',
		fields : fields
  }).on('success.form.bv', function(e) { this.submit() });
		
}

