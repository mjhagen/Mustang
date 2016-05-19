<cfcontent type="text/html" reset="true" /><cfoutput><!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title><cfif structKeyExists( rc, 'displaytitle' )>#rc.displaytitle# - </cfif>#request.appName# #request.version#</title>

    <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/4.0.0-alpha.2/css/bootstrap.min.css" />
    <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/font-awesome/4.6.3/css/font-awesome.min.css" />
    <link rel="stylesheet" href="#request.webroot#/inc/css/admin.css" />
  </head>
  <body>
    <div class="container-fluid">
      <cfif rc.auth.isLoggedIn>
        <div class="row">#view("elements/topnav")#</div>
        <div class="row main">#view("elements/standard",{body=body})#</div>
        <div class="row">#view("elements/footer")#</div>
      <cfelse>
        #body#
      </cfif>
    </div>

    <script src="//code.jquery.com/jquery-2.2.3.min.js"></script>
    <script src="//maxcdn.bootstrapcdn.com/bootstrap/4.0.0-alpha.2/js/bootstrap.min.js"></script>
    <script type="text/javascript">
      var _webroot = "#request.webroot#";
    </script>
    <script src="#request.webroot#/inc/js/admin.js"></script>
    <!--[if lt IE 9]>
      <script src="#request.webroot#/inc/plugins/bootstrap/compatibility/html5shiv.min.js"></script>
      <script src="#request.webroot#/inc/plugins/bootstrap/compatibility/respond.min.js"></script>
    <![endif]-->
  </body>
</html></cfoutput>