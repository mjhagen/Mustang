<cfcontent type="text/html" reset="true" />
<cfoutput><!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>Error</title>

    <link rel="stylesheet" href="#getBaseURL()#/inc/plugins/bootstrap/bootstrap.min.css" />
    <link rel="stylesheet" href="#getBaseURL()#/inc/plugins/bootstrap/theme/bootstrap-theme.min.css" />
    <link rel="stylesheet" href="#getBaseURL()#/inc/plugins/bootstrap/theme/sb-admin-2.css" />
    <link rel="stylesheet" href="#getBaseURL()#/inc/plugins/font-awesome/css/font-awesome.min.css" />

    <script type="text/javascript">
      var _webroot = '#getBaseURL()#';
      var _subsystemDelimiter = ':';
    </script>

    <!--- required for layout --->
    <script src="#getBaseURL()#/inc/plugins/jquery/jquery-1.11.1.min.js"></script>
    <script src="#getBaseURL()#/inc/plugins/jquery/jquery-ui.min.js"></script>
    <script src="#getBaseURL()#/inc/plugins/bootstrap/bootstrap.min.js"></script>
    <script src="#getBaseURL()#/inc/plugins/bootstrap/theme/sb-admin-2.js"></script>

    <script src="#getBaseURL()#/inc/js/default.js"></script>
    <!--[if lt IE 9]>
      <script src="#getBaseURL()#/inc/plugins/bootstrap/compatibility/html5shiv.min.js"></script>
      <script src="#getBaseURL()#/inc/plugins/bootstrap/compatibility/respond.min.js"></script>
    <![endif]-->
  </head>
  <body>#body#</body>
</html></cfoutput>