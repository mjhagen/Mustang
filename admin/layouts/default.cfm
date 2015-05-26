<cfoutput><!DOCTYPE html>
<html lang="#rc.currentlanguage.getCode()#">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge">

    <cfset local.title = rc.displaytitle />

    <cfif isDefined( "rc.content" )>
      <cfif len( trim( rc.content.getHTMLTitle()))>
        <cfset local.title = rc.content.getHTMLTitle() />
      <cfelseif len( trim( rc.content.getTitle()))>
        <cfset local.title = rc.content.getTitle() />
      </cfif>
    </cfif>

    <title>#local.title#</title>



    <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css" />
    <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap-theme.min.css" />
    <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css" />

    <link rel="stylesheet" href="//www.fuelcdn.com/fuelux/3.6.3/css/fuelux.min.css" />

    <link rel="stylesheet" href="#getBaseURL()#/inc/plugins/bootstrap/theme/sb-admin-2.css" />
    <link rel="stylesheet" href="#getBaseURL()#/inc/plugins/metisMenu/metisMenu.min.css" />

    <link rel="stylesheet" href="#getBaseURL()#/inc/plugins/ladda/ladda.min.css" />
    <link rel="stylesheet" href="#getBaseURL()#/inc/plugins/fileupload/jquery.fileupload.css" />
    <link rel="stylesheet" href="#getBaseURL()#/inc/plugins/jsoneditor/jsoneditor.min.css" />

    <link rel="stylesheet" href="#getBaseURL()#/inc/css/default.css" />
    <link rel="stylesheet" href="#getBaseURL()#/inc/css/admin.css" />

    <cfif cachedFileExists( 'inc/css/#getSubSystem()#.#getSection()#.css' )><link href="#getBaseURL()#/inc/css/#getSubSystem()#.#getSection()#.css" rel="stylesheet"></cfif>

    <script>
      var _webroot = '#getBaseURL()#';
      var _subsystemDelimiter = ':';

      <cfif structKeyExists( rc, "entity" )>
        var _entity = "#rc.entity#";
      </cfif>

      <cfif listFindNoCase( 'new,edit,view', getItem()) and getSection() neq 'logentry' and structKeyExists( rc, "canBeLogged" )>
        var _loggable = #rc.canBeLogged?'true':'false'#;
      <cfelsE>
        var _loggable = false;
      </cfif>
    </script>


    <script src="//code.jquery.com/jquery-2.1.3.min.js"></script>
    <script src="//code.jquery.com/ui/1.11.4/jquery-ui.min.js"></script>
    <script src="//maxcdn.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js"></script>

    <script src="//www.fuelcdn.com/fuelux/3.6.3/js/fuelux.min.js"></script>

    <script src="#getBaseURL()#/inc/plugins/bootstrap/theme/sb-admin-2.js"></script>
    <script src="#getBaseURL()#/inc/plugins/metisMenu/metisMenu.min.js"></script>

    <script src="#getBaseURL()#/inc/plugins/jquery/jquery.cookie.js"></script>
    <script src="#getBaseURL()#/inc/plugins/jquery/jquery.sortElements.js"></script>
    <script src="#getBaseURL()#/inc/plugins/jquery/jquery.mask.js"></script>
    <script src="#getBaseURL()#/inc/plugins/jquery/jquery.slimscroll.min.js"></script>
    <script src="#getBaseURL()#/inc/plugins/tinymce/tinymce.min.js"></script>
    <script src="#getBaseURL()#/inc/plugins/tinymce/jquery.tinymce.min.js"></script>
    <script src="#getBaseURL()#/inc/plugins/fileupload/jquery.ui.widget.js"></script>
    <script src="#getBaseURL()#/inc/plugins/fileupload/jquery.iframe-transport.js"></script>
    <script src="#getBaseURL()#/inc/plugins/fileupload/jquery.fileupload.js"></script>
    <script src="#getBaseURL()#/inc/plugins/validator/validator.min.js"></script>
    <script src="#getBaseURL()#/inc/plugins/ladda/spin.min.js"></script>
    <script src="#getBaseURL()#/inc/plugins/ladda/ladda.min.js"></script>
    <script src="#getBaseURL()#/inc/plugins/ladda/ladda.jquery.min.js"></script>
    <script src="#getBaseURL()#/inc/plugins/jsoneditor/jsoneditor.min.js"></script>

    <script src="#getBaseURL()#/inc/js/util.js"></script>
    <script src="#getBaseURL()#/inc/js/default.js"></script>
    <script src="#getBaseURL()#/inc/js/admin.js"></script>

    <cfset local.jsIncludeItem = getItem() />
    <cfif listFindNoCase( "new,edit", local.jsIncludeItem )>
      <cfset local.jsIncludeItem = 'view' />
    </cfif>

    <cfif cachedFileExists( 'inc/js/#getSubSystem()#.#getSection()#.js' )><script src="#getBaseURL()#/inc/js/#getSubSystem()#.#getSection()#.js"></script></cfif>
    <cfif cachedFileExists( 'inc/js/#getSubSystem()#.global.#local.jsIncludeItem#.js' )><script src="#getBaseURL()#/inc/js/#getSubSystem()#.global.#local.jsIncludeItem#.js"></script></cfif>
    <cfif cachedFileExists( 'inc/js/#getSubSystem()#.#getSection()#.#local.jsIncludeItem#.js' )><script src="#getBaseURL()#/inc/js/#getSubSystem()#.#getSection()#.#local.jsIncludeItem#.js"></script></cfif>

    <script src="//google-code-prettify.googlecode.com/svn/loader/run_prettify.js"></script>

    <!--[if lt IE 9]>
      <script src="//cdnjs.cloudflare.com/ajax/libs/html5shiv/3.7.2/html5shiv.min.js"></script>
      <script src="//cdnjs.cloudflare.com/ajax/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>
  <body data-spy="scroll" data-target="##side-nav">
    <div id="wrapper">
      #view("common:elements/topnav")#
      <div id="page-wrapper">
        <div class="container-fluid">
          <div id="contentblock">#view('common:elements/standard',{body=body})#</div>
          #view("common:elements/footer")#
        </div>
      </div>
    </div>
  </body>
</html></cfoutput>