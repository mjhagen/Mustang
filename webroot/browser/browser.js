var runButtonDisabled = false;
var _webroot = uri.protocol + "://" + uri.hostname;
var _entity = "";
var form = {};
var useSEO = true;

$(function(){
  var activeURL, activeVerb;

  $( document ).on( "updateHTTPRequest", {}, function(){
    activeURL = useSEO ? "#seoURL" : "#nonSeoURL";
    activeVerb = $( "#verb-selector :selected" ).val();

    $( useSEO ? "#nonSeoURL" : "#seoURL" ).hide();
    $( activeURL ).show();

    $( "#run-call" ).attr( "href", $( activeURL ).text());
    $( "#request" ).html( '<pre></pre>' );
    $( "#request pre" ).html( activeVerb + " " + constructURL() + " HTTP/1.1\nHost: " + uri.hostname );

    var username = $( "#username" ).val();
    var password = $( "#password" ).val();

    if( username.length && password.length )
    {
      $( "#request pre" ).append( "\nAuthorization: Basic " + btoa( username + ":" + password ));
    }

    var docVars = {
      "apiBaseURL" : _webroot + "/" + uri.api,
      "entityName" : _entity,
      "GUID" : "{GUID}"
    }

    var afca = $.ajax( "./docs/" + activeVerb.toLowerCase() + ".html", {
      "success" : function( data, textStatus, jqHXR ){
        $( "#docs" ).html( data.replace( /#([^#]+)#/g, function(){
          return docVars[arguments[1]];
        }));
      }
    });
  });

  $( document ).on( "updateSeoUrl", {}, function(){
    $( "#seoURL hostname" ).text( $( "#nonSeoURL hostname" ).text());
    $( "#seoURL subsystem" ).text( $( "#nonSeoURL subsystem" ).text());
    $( "#seoURL section" ).text( $( "#nonSeoURL section" ).text().replace( ":", "/" ));
    $( "#seoURL item" ).text( $( "#nonSeoURL item" ).text());
  });

  $( document ).on( "change", "#verb-selector", function(){
    $( '.entities' ).hide();
    $( '.entities.' + $( this ).val()).show();
    $( document ).trigger( "updateHTTPRequest" );
  });

  $( document ).on( "click", ".nav-sidebar a", function(){
    var $this = $( this );
    $this.closest( "ul" ).find( "li" ).removeClass( 'active' );
    $this.closest( "li" ).addClass( 'active' );

    var $entity = $this.data( "entity" );
    var $call = $this.data( "call" );

    if( $call == undefined )
    {
      $call = "default";
    }

    _entity = $entity;

    $apicall = $( '#apicall' );
    $apicall.find( ".section" ).text( $entity );
    $apicall.find( ".item" ).text( $call );

    if( $call == 'default' )
    {
      $apicall.find( ".item" ).text( "" );
      $apicall.find( ".item" ).prev( ".delim" ).text( "" );
    }
    else
    {
      $apicall.find( ".item" ).prev( ".delim" ).text( useSEO ? "/" : "." );
    }

    $apicall.find( "a" ).attr( "href", _webroot + "/?action=api:" + $entity + '.' + $call );

    $( document ).trigger( "updateHTTPRequest" );

    $apicall.show();

    $( "#run-call" ).removeClass( "disabled" );
    runButtonDisabled = false;

    return false;
  });

  $( document ).on( "click", "#run-call", function(){
    if( runButtonDisabled )
    {
      return false;
    }

    var $this = $( this );
    $this.toggleClass( "disabled" );

    runButtonDisabled = true;

    $( "#response" ).html( '<img src="' + _webroot + '/inc/img/loading.gif" />' );

    var requestURL = _webroot + $( activeURL + " hostname" ).text() + constructURL();

    var afca = $.ajax( requestURL, {
      method : activeVerb,
      beforeSend : function( xhr ){
        var username = $( "#username" ).val();
        var password = $( "#password" ).val();
        if( username.length && password.length )
        {
          xhr.setRequestHeader( "Authorization", "Basic " + btoa( username + ":" + password ));
        }
      },
      complete : function( data, status, xhr ){
        $( "#response" ).html( '<pre class="prettyprint">' + JSON.stringify( data.responseJSON, undefined, 2 ) + '</pre>' );
        PR.prettyPrint();
        runButtonDisabled = false;
        $this.toggleClass( "disabled" );
      },
      data : form
    });

    return false;
  });

  $( document ).on( "click", ".keyValuePair i.add", function(){
    var $thisRow = $( this ).closest( ".keyValuePair" );

    var $newRow = $thisRow.clone();
    $newRow.find( "input" ).val( "" );
    $newRow.find( "i" ).toggleClass( "add remove fa-plus-circle fa-minus-circle" );

    $( "#props-form" ).append( $newRow );

    $( document ).trigger( "updateHTTPRequest" );
  });

  $( document ).on( "click", ".keyValuePair i.remove", function(){
    $( this ).closest( ".keyValuePair" ).remove();

    $( document ).trigger( "updateHTTPRequest" );
  });

  $( document ).on( "keyup click", "#username,#password,.keyValuePair input", function(){
    $( document ).trigger( "updateHTTPRequest" );
  });

  $( document ).on( "click", "#logged-in a", function(){
    var afca = $.ajax( "./?action=common:security.doLogout", {
      "complete" : function( data, status, xhr ){
        $( "#logged-in" ).hide();
        $( "#auth-form" ).show();
      }
    });

    return false;
  });

  $( "#verb-selector" ).trigger( "change" );
  $( ".nav-sidebar a" ).first().trigger( "click" );

  if( $( "#logged-in" ).length )
  {
    $( "#auth-form" ).hide();
  }
});

function constructURL()
{
  var requestURL = ( useSEO ? "/" : $( "#apicall .url .base" ).text());
  var fqa = $( "#apicall .url .fqa" ).text();

  activeVerb = $( "#verb-selector" ).val();
  requestURL += useSEO ? fqa.replace( ":", "/" ) : fqa;
  form = {};

  $( document ).trigger( "updateSeoUrl" );

  $( ".keyValuePair" ).each( function( index, item ){
    var $item = $( this );
    var key = $item.find( "input[name='key']" ).val();
    var val = $item.find( "input[name='value']" ).val();

    if( key.length && val.length )
    {
      if( useSEO && key == "id" )
      {
        var injectAt = requestURL.indexOf( "?" )-1;

        if( injectAt < 0 )
        {
          requestURL += "/" + val;
        }
        else
        {
          var firstPart = requestURL.slice( 0, injectAt );
          var lastPart = requestURL.slice( injectAt, requestURL.length );
          requestURL = firstPart + "/" + val + lastPart;
        }
      }
      else if( activeVerb == "GET" )
      {
        requestURL += ( requestURL.indexOf( "?" ) == -1 ? "/?" : "&" ) + key + "=" + val;
      }
      else
      {
        form[key] = val;
      }
    }
  });

  return requestURL;
}