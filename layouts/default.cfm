<cfoutput><!DOCTYPE html>
<html lang="#rc.currentlocale.getCode()#">
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
    <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css" />
    <link rel="stylesheet" href="//www.fuelcdn.com/fuelux/3.6.3/css/fuelux.min.css" />
    <link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/bootstrap-table/1.8.1/bootstrap-table.min.css" />
    <link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/x-editable/1.5.0/bootstrap3-editable/css/bootstrap-editable.css" />
    <link rel="stylesheet" href="#getBaseURL()#/inc/plugins/bootstrap/theme/AdminLTE.css" />
    <link rel="stylesheet" href="#getBaseURL()#/inc/plugins/bootstrap/theme/skins/_all-skins.min.css" />
    <link rel="stylesheet" href="#getBaseURL()#/inc/plugins/bootstrap/icheck/all.css" />
    <link rel="stylesheet" href="#getBaseURL()#/inc/plugins/jvectormap/jquery-jvectormap-1.2.2.css"  />
    <link rel="stylesheet" href="#getBaseURL()#/inc/plugins/datatables/jquery.dataTables.min.css"  />
    <link rel="stylesheet" href="#getBaseURL()#/inc/plugins/metisMenu/metisMenu.min.css" />
    <link rel="stylesheet" href="#getBaseURL()#/inc/plugins/uploadify/uploadify.css" />
    <link rel="stylesheet" href="#getBaseURL()#/inc/plugins/ladda/ladda.min.css" />
    <link rel="stylesheet" href="#getBaseURL()#/inc/plugins/fileupload/jquery.fileupload.css" />
    <link rel="stylesheet" href="#getBaseURL()#/inc/plugins/jsoneditor/jsoneditor.min.css" />
    <link rel="stylesheet" href="#getBaseURL()#/inc/plugins/typeahead/typeahead.js-bootstrap.css" />		
    <link rel="stylesheet" href="#getBaseURL()#/inc/css/default.css" />
    <link rel="stylesheet" href="#getBaseURL()#/inc/css/admin.css" />

    <cfif cachedFileExists( 'inc/css/#getSubSystem()#.#getSection()#.css' )><link href="#getBaseURL()#/inc/css/#getSubSystem()#.#getSection()#.css?v=#request.version#" rel="stylesheet"></cfif>

    <script>
      var _webroot = '#getBaseURL()#';
      var _subsystemDelimiter = ':';

      <cfif structKeyExists( rc, "entity" )>
        var _entity = "#rc.entity#";
      </cfif>

      <cfif listFindNoCase( 'new,edit,view', getItem()) and getSection() neq 'logentry' and structKeyExists( rc, "canBeLogged" )>
        var _loggable = #rc.canBeLogged?'true':'false'#;
      <cfelse>
        var _loggable = false;
      </cfif>

      var seoAjax = false;
    </script>

    <script src="//code.jquery.com/jquery-2.1.3.min.js"></script>
    <script src="//code.jquery.com/ui/1.11.4/jquery-ui.min.js"></script>
    <script src="//maxcdn.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js"></script>
    <script src="//www.fuelcdn.com/fuelux/3.6.3/js/fuelux.min.js"></script>
    <script src="//cdnjs.cloudflare.com/ajax/libs/bootstrap-table/1.8.1/bootstrap-table.min.js"></script>
    <script src="//cdnjs.cloudflare.com/ajax/libs/bootstrap-table/1.8.1/locale/bootstrap-table-nl-NL.js"></script>
    <script src="//cdnjs.cloudflare.com/ajax/libs/bootstrap-table/1.8.1/extensions/editable/bootstrap-table-editable.js"></script>
    <script src="//cdnjs.cloudflare.com/ajax/libs/x-editable/1.5.0/bootstrap3-editable/js/bootstrap-editable.min.js"></script>
    <script src="#getBaseURL()#/inc/plugins/bootstrap/theme/app.js"></script>
    <script src="#getBaseURL()#/inc/plugins/bootstrap/iCheck/icheck.min.js"></script>
    <script src="#getBaseURL()#/inc/plugins/jvectormap/jquery-jvectormap-1.2.2.min.js" type="text/javascript"></script>
    <script src="#getBaseURL()#/inc/plugins/jvectormap/jquery-jvectormap-world-mill-en.js" type="text/javascript"></script>
    <script src="#getBaseURL()#/inc/plugins/sparkline/jquery.sparkline.min.js" type="text/javascript"></script>
    <script src="#getBaseURL()#/inc/plugins/chartjs/chart.min.js" type="text/javascript"></script>
    <script src="#getBaseURL()#/inc/plugins/datatables/jquery.datatables.min.js" type="text/javascript"></script>
    <script src="#getBaseURL()#/inc/plugins/metisMenu/metisMenu.min.js"></script>
    <script src="#getBaseURL()#/inc/plugins/uploadify/jquery.uploadify.min.js"></script>
    <script src="#getBaseURL()#/inc/plugins/jquery/jquery.cookie.js"></script>
    <script src="#getBaseURL()#/inc/plugins/jquery/jquery.sortElements.js"></script>
    <script src="#getBaseURL()#/inc/plugins/jquery/jquery.mask.js"></script>
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
    <script src="#getBaseURL()#/inc/plugins/typeahead/typeahead.bundle.min.js"></script>
    <script src="#getBaseURL()#/inc/js/util.js"></script>
    <script src="#getBaseURL()#/inc/js/default.js"></script>
    <script src="#getBaseURL()#/inc/js/admin.js"></script>

    <cfset local.jsIncludeItem = getItem() />
    <cfif listFindNoCase( "new,edit", local.jsIncludeItem )>
      <cfset local.jsIncludeItem = 'view' />
    </cfif>
    <cfif cachedFileExists( 'inc/js/#getSubSystem()#.#getSection()#.js' )><script src="#getBaseURL()#/inc/js/#getSubSystem()#.#getSection()#.js?v=#request.version#"></script></cfif>
    <cfif cachedFileExists( 'inc/js/#getSubSystem()#.global.#local.jsIncludeItem#.js' )><script src="#getBaseURL()#/inc/js/#getSubSystem()#.global.#local.jsIncludeItem#.js?v=#request.version#"></script></cfif>
    <cfif cachedFileExists( 'inc/js/#getSubSystem()#.#getSection()#.#local.jsIncludeItem#.js' )><script src="#getBaseURL()#/inc/js/#getSubSystem()#.#getSection()#.#local.jsIncludeItem#.js?v=#request.version#"></script></cfif>

    <script src="//google-code-prettify.googlecode.com/svn/loader/run_prettify.js"></script>

    <!--[if lt IE 9]>
      <script src="//cdnjs.cloudflare.com/ajax/libs/html5shiv/3.7.2/html5shiv.min.js"></script>
      <script src="//cdnjs.cloudflare.com/ajax/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>
  <body class="skin-blue sidebar-mini">#body#</body>
</html></cfoutput>