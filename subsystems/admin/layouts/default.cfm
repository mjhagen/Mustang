<cfoutput>
  <div class="wrapper">
    #view( "elements/topnav" )#
    <div class="content-wrapper">
      #view( "elements/standard", { body = body })#
    </div>
    <footer class="main-footer">
      #view( "elements/footer" )#
    </footer>
  </div>
</cfoutput>