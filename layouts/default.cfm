<cfcontent type="text/html; charset=utf-8" /><cfoutput><!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title><cfif structKeyExists( rc, 'displaytitle' )>#rc.displaytitle# - </cfif>#request.appName# #request.version#</title>

    <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/4.0.0-alpha.4/css/bootstrap.min.css" />
    <!--- <link rel="stylesheet" href="#request.webroot#/inc/plugins/material/css/material.min.css" /> --->

    <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/font-awesome/4.6.3/css/font-awesome.min.css" />
    <link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/bootstrap-table/1.11.0/bootstrap-table.min.css" />
    <link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/x-editable/1.5.0/bootstrap3-editable/css/bootstrap-editable.css" />
    <link rel="stylesheet" href="#request.webroot#/inc/plugins/ladda/ladda.min.css" />
    <link rel="stylesheet" href="#request.webroot#/inc/plugins/jsoneditor/jsoneditor.min.css" />
    <link rel="stylesheet" href="#request.webroot#/inc/plugins/datetimepicker/bootstrap-datetimepicker.min.css" />
    <link rel="stylesheet" href="#request.webroot#/inc/css/admin.css" />
    <cfif rc.util.fileExistsUsingCache( request.root & "/webroot/inc/css/" & getSection() & "." & getItem() & ".css" )>
      <link rel="stylesheet" href="#request.webroot#/inc/css/#getSection()#.#getItem()#.css" />
    </cfif>
  </head>
  <body>
    <div class="container">
      <cfif rc.auth.isLoggedIn>
        <div class="row">#view( ":elements/topnav" )#</div>
        <div class="row">
          <div class="sidebar-nav collapse navbar-toggleable-xs col-sm-2">#view( ":elements/subnav" )#</div>
          <div class="main col-sm-10">#view( ":elements/standard", { body = body } )#</div>
        </div>
        <div class="row">#view( ":elements/footer" )#</div>
      <cfelse>
        <div class="login-page">#body#</div>
      </cfif>
    </div>
    <script src="//code.jquery.com/jquery-2.2.4.min.js"></script>
    <script src="//cdnjs.cloudflare.com/ajax/libs/tether/1.3.1/js/tether.min.js"></script>
    <!--[if lt IE 9]>
      <script src="//cdnjs.cloudflare.com/ajax/libs/html5shiv/3.7.3/html5shiv.min.js"></script>
      <script src="//cdnjs.cloudflare.com/ajax/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->

    <script src="//maxcdn.bootstrapcdn.com/bootstrap/4.0.0-alpha.4/js/bootstrap.min.js"></script>
    <!--- <script src="#request.webroot#/inc/plugins/material/js/material.min.js"></script> --->

    <script src="//cdnjs.cloudflare.com/ajax/libs/bootstrap-table/1.11.0/bootstrap-table.min.js"></script>
    <script src="//cdnjs.cloudflare.com/ajax/libs/bootstrap-table/1.11.0/locale/bootstrap-table-nl-NL.js"></script>
    <script src="//cdnjs.cloudflare.com/ajax/libs/bootstrap-table/1.11.0/extensions/editable/bootstrap-table-editable.js"></script>
    <script src="//cdnjs.cloudflare.com/ajax/libs/x-editable/1.5.0/bootstrap3-editable/js/bootstrap-editable.min.js"></script>
    <script src="#request.webroot#/inc/plugins/ladda/ladda.min.js"></script>
    <script src="#request.webroot#/inc/plugins/tinymce/jquery.tinymce.min.js"></script>
    <script src="#request.webroot#/inc/plugins/tinymce/tinymce.min.js"></script>
    <script src="#request.webroot#/inc/plugins/validator/validator.min.js"></script>
    <script src="#request.webroot#/inc/plugins/fileupload/jquery.ui.widget.js"></script>
    <script src="#request.webroot#/inc/plugins/fileupload/jquery.fileupload.js"></script>
    <script src="#request.webroot#/inc/plugins/jsoneditor/jsoneditor.min.js"></script>
    <script src="#request.webroot#/inc/plugins/datetimepicker/bootstrap-datetimepicker.min.js"></script>
    <script type="text/javascript">
      var _webroot = "#request.webroot#";
      var _subsystemDelimiter = "#framework.subsystemDelimiter#";
      var seoAjax = true;
    </script>
    <script src="#request.webroot#/inc/js/util.js"></script>
    <script src="#request.webroot#/inc/js/admin.js"></script>
    <cfset local.jsIncludeItem = getItem() />
    <cfif listFindNoCase( "new,edit", jsIncludeItem )>
      <cfset local.jsIncludeItem = 'view' />
    </cfif>
    <cfif rc.util.fileExistsUsingCache( request.root & "/webroot/inc/js/global.#jsIncludeItem#.js" )>
      <script src="#request.webroot#/inc/js/global.#jsIncludeItem#.js"></script>
    </cfif>
    <cfif rc.util.fileExistsUsingCache( request.root & "/webroot/inc/js/#getSection()#.#jsIncludeItem#.js" )>
      <script src="#request.webroot#/inc/js/#getSection()#.#jsIncludeItem#.js"></script>
    </cfif>
  </body>
</html></cfoutput>