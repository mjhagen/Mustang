var field, target, $modal, textareaEl, l, _JSONeditor;
var th_last = '';

// Provide modal inline edit functionality:
// Used for one-to-many fields where you can add/remove unique items to a record
jQuery( document ).ready( function( e ){  
  
  initFormelements( $( document) );

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  $( "#mainform" ).validator();

	$( document ).on( 'click', '#confirmsend-contact-info a.btn-primary', function(){
		var name = $( this ).parents( '.modal' ).attr( 'data-name' );
		$( '#mainform button[data-name="' + name + '"]' ).click();
		return false;
	});

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  $( ".collapse" ).on( "hidden.bs.collapse", function( event ){
    var $parent = $( this ).closest( "div" ).prev();

    $parent.find( ".fa" ).removeClass( "fa-caret-down" );
    $parent.find( ".fa" ).addClass( "fa-caret-right" );

    event.stopPropagation();
  });

  $( ".collapse" ).on( "shown.bs.collapse", function( event ){
    var $parent = $( this ).closest( "div" ).prev();

    $parent.find( ".fa" ).removeClass( "fa-caret-right" );
    $parent.find( ".fa" ).addClass( "fa-caret-down" );

    event.stopPropagation();
  });

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  $( '.autocomplete' ).each(function(){
    var $this = $( this );

    $this.select2({
      ajax : {
        url : ajaxUrl( 'adminapi' + _subsystemDelimiter + 'autocomplete', 'search', { entity : $this.data( "entity" )})
      },
      dataType: 'json',
      results: function (data, page) {
        return { results: data.results };
      }
    });
  });


  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  $( document ).on( 'click', '.cancel-button', function(){
    history.back();
  });

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  $( document ).on( 'click', '.remove-button', function(){
    var entity = $( this ).data( 'entity' );
    var id = $( this ).data( 'id' );

    if( entity == 'ajax' )
    {
      $( '#' + id ).remove();
    }
    else
    {
      $( '#inlineedit-result' ).append( '<input type="hidden" name="remove_' + entity + '" value="' + id + '" />' );
    }

    $( this ).closest( '.inline-item' ).remove();
  });

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  $( document ).on( 'click', '.inlineedit-modal-trigger', function(){
    target = $( this ).data( 'target' );
    field = $( this ).data( 'field' );
    // $modal = $( '#modal-dialog-' + field );

    $( target ).attr( 'data-field', field );
    $( target ).modal({
      'show'  : true
    }).load( $( this ).attr( 'href' ), function( e ){
      initFormelements( $( this ) );      
      $( 'input[type=text],textarea', $( this )).first().focus();
    });

    return false;
  });

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  $( document ).on( 'click', '.inlineedit-modal-save', function(){
    var $modal = $( this ).closest( '.modal' );
    var $dialog = $( '.modal-dialog', $modal );
    var $form = $( 'form', $modal );
    var dataToSave = $form.serializeObject();
    dataToSave.uuid = generateUUID();
    var stringyfiedDataToSave = JSON.stringify( dataToSave );
    var field = $modal.data( 'field' );
    var entity = $dialog.data( 'entity' );

    // hidden field passed through to the save action of the main form
    $( '#inlineedit-result' ).append( '<input type="hidden" name="add_' + field + '" value=\'' + safe_tags_replace( stringyfiedDataToSave ) + '\' id="' + dataToSave.uuid + '" />' );

    // visual representation
    $.ajax( ajaxUrl( 'adminapi' + _subsystemDelimiter + 'crud' , 'displayInlineEditLine'), {
      data        : {
                      entityName : entity,
                      formdata : stringyfiedDataToSave
                    },
      dataType    : 'html',
      success     : function( data, textStatus, jqXHR )
                    {
                      $( '#saved-' + field ).append( data ).closest( 'div.inlineblock' ).show();
                    }
    });

    // close the dialog
    $modal.modal( 'hide' );
  });

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  $( document ).on( 'init change', '.affectsform', function(){
    var selected = $( this ).find( 'option:selected' );
    var fieldlist = selected.data( 'fieldlist' );

    $( '.affected' ).hide();

    $( '.' + selected.data( 'name' )).show();

    $.each( fieldlist.split(','), function( key, value ){
      if( value === "" ){return;}
      $( '.affected.' + value ).show();

    });

    $( '.affectedOption' ).hide();
  });

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  $( '.affectsform' ).trigger( 'init' );

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  $( '.selectedoption' ).each(function(){
    var selected = $( this );
    var fieldlist = selected.data( 'fieldlist' );

    if( fieldlist.length === 0 )
    {
      return;
    }

    $( '.affected' ).hide();

    $.each( fieldlist.split(','), function( key, value ){
      if( value === "" ){return;}
      $( '.affected.' + value ).show();
    });
  });

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  $( '.modal' ).on( 'hidden.bs.modal', function( event ){
    $(this).removeClass( 'fv-modal-stack' );
    $('body').data( 'fv_open_modals', $( 'body' ).data( 'fv_open_modals' ) - 1 );
  });

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  $( '.modal' ).on( 'shown.bs.modal', function( event ){
    // keep track of the number of open modals
    if( typeof( $( 'body' ).data( 'fv_open_modals' )) == 'undefined' )
    {
      $( 'body' ).data( 'fv_open_modals', 0 );
    }

    // if the z-index of this modal has been set, ignore.
    if( $( this ).hasClass( 'fv-modal-stack' ))
    {
      return;
    }

    $( this ).addClass( 'fv-modal-stack' );
    $( 'body' ).data( 'fv_open_modals', $('body').data( 'fv_open_modals' ) + 1 );
    $( this ).css( 'z-index', 1040 + ( 10 * $( 'body' ).data( 'fv_open_modals' )));
    $( '.modal-backdrop' ).not( '.fv-modal-stack' ).css( 'z-index', 1039 + (10 * $( 'body' ).data( 'fv_open_modals' )));
    $( '.modal-backdrop' ).not( 'fv-modal-stack' ).addClass( 'fv-modal-stack' );
  });

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  $( '.load-inline' ).each( function( index, element ){
    var $editblock = $( element );
    var entity = $editblock.data( 'entity' );
    var prepend = $editblock.data( 'fieldname' );
    var settings = {
      data: {
        modal       : 1,
        inline      : 1,
        entity      : entity,
        namePrepend : prepend + '_'
      },
      success: function( html ){
        $editblock.html( html );

        initFormelements( $editblock );
      },
      async: false
    };

    settings.data[entity + 'id'] = $editblock.data( 'id' );

    $.ajax( _webroot + '/index.cfm?action=admin:' + entity + '.edit', settings );
  });
	
	function initFormelements( $container ){
    $( 'textarea', $container ).each( function(){
      var editorID = $( this ).attr( "id" );
      var textareaEl = $( this );

      textareaEl.tinymce({
        statusbar : false,
        rel_list  : [{ title: 'Lightbox', value: 'lightbox' }],
        menubar   : false,
        plugins   : 'code,cfimage,image,link,paste',
        toolbar   : 'code | undo redo | bold italic underline | alignleft aligncenter alignright | bullist numlist outdent indent | link cfimage',
    
        //use absolute urls
        remove_script_host : false,
        relative_urls : false
      });
    });
    
    $( 'input[type=file]', $container ).fileupload({
	    pasteZone   : null,
	    url         : ajaxUrl( 'adminapi' + _subsystemDelimiter + 'crud' , 'upload'),
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
	  }).prop( 'disabled', !$.support.fileInput ).parent().addClass( $.support.fileInput ? undefined : 'disabled' );
		
		// JSON EDITOR:
	  var $jsoncontainer = $( '.jsoncontainer', $container );
	  if( $jsoncontainer.length )
	  {
	    _JSONeditor = new JSONEditor( $jsoncontainer[0], {
	      "modes"   : ["tree","text","form"],
	      "change"  : function()
	                  {
	                    // update hidden field, for saving:
	                    $jsoncontainer.next( "input" ).val( _JSONeditor.getText());
	                  }
	    });
	
	    // init with saved json:
	    var sourceJSON = $jsoncontainer.data( "value" );
	    if( sourceJSON.length )
	    {
	      var json = JSON.parse( window.atob( sourceJSON ));
	      _JSONeditor.set( json );
	    }
	  }
    
    
  };
});