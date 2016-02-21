<cfoutput>
  #view("elements/html-header")#
  <div class="container">
    <cfif rc.auth.isLoggedIn>
      <div class="row">#view("elements/topnav")#</div>
      <div class="row main">#view( "elements/standard", { body = body } )#</div>
      <div class="row">#view("elements/footer")#</div>
    <cfelse>
      #body#
    </cfif>
  </div>
  #view("elements/html-footer")#
</cfoutput>