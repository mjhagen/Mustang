<cfcomponent extends="apibase">
  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="before">
    <cfargument name="rc">

    <cfset super.before( rc=rc ) />

    <cfparam name="rc.modalContent" default="#{title='',body='',buttons=[{title='close',classes='btn-primary btn-modal-close'}]}#" />

    <cfif structKeyExists( rc, "content" )>
      <cfset rc.modalContent.title = rc.content.getTitle() />
      <cfset rc.modalContent.body = rc.content.getBody() />
    </cfif>
  </cffunction>

  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="open">
    <cfargument name="rc">

    <cfswitch expression="#rc.type#">
      <cfdefaultcase></cfdefaultcase>
    </cfswitch>
  </cffunction>
</cfcomponent>