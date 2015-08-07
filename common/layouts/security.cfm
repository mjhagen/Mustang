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

    <!--- layout: --->
    <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css" />
    <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap-theme.min.css" />
    <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css" />

    <!--- user css: --->
    <cfif cachedFileExists( 'inc/css/#getSubSystem()#.#getSection()#.css' )><link href="#getBaseURL()#/inc/css/#getSubSystem()#.#getSection()#.css" rel="stylesheet"></cfif>

    <script>
      var _webroot = '#getBaseURL()#';
      var _subsystemDelimiter = ':';
    </script>

    <!--- required for layout --->
    <script src="//code.jquery.com/jquery-2.1.3.min.js"></script>
    <script src="//code.jquery.com/ui/1.11.4/jquery-ui.min.js"></script>
    <script src="//maxcdn.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js"></script>

    <!--- user scripts: --->
    <script src="#getBaseURL()#/inc/js/util.js"></script>

    <cfset local.jsIncludeItem = getItem() />
    <cfif listFindNoCase( "new,edit", local.jsIncludeItem )>
      <cfset local.jsIncludeItem = 'view' />
    </cfif>

    <cfif cachedFileExists( 'inc/js/#getSubSystem()#.#getSection()#.js' )><script src="#getBaseURL()#/inc/js/#getSubSystem()#.#getSection()#.js"></script></cfif>
    <cfif cachedFileExists( 'inc/js/#getSubSystem()#.global.#local.jsIncludeItem#.js' )><script src="#getBaseURL()#/inc/js/#getSubSystem()#.global.#local.jsIncludeItem#.js"></script></cfif>
    <cfif cachedFileExists( 'inc/js/#getSubSystem()#.#getSection()#.#local.jsIncludeItem#.js' )><script src="#getBaseURL()#/inc/js/#getSubSystem()#.#getSection()#.#local.jsIncludeItem#.js"></script></cfif>

    <!--[if lt IE 9]>
      <script src="#getBaseURL()#/inc/plugins/bootstrap/compatibility/html5shiv.min.js"></script>
      <script src="#getBaseURL()#/inc/plugins/bootstrap/compatibility/respond.min.js"></script>
    <![endif]-->
  </head>
  <body data-spy="scroll" data-target="##side-nav">
    <div class="container">
      <div class="row">
        <div class="col-md-12">#body#</div>
      </div>
    </div>
  </body>
</html></cfoutput>