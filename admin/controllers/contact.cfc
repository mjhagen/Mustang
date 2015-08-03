<cfcomponent extends="crud">
  <cfset variables.submitButtons = [
    {
      "value" = "save",
      "modal" = ""
    }
  ]>

  <cffunction name="default">
    <cfargument name="rc" />

    <cfif structKeyExists( rc, "orderby" ) and listFindNoCase( rc.orderby, "fullname" )>
      <cfset rc.orderby = replaceNoCase( rc.orderby, "fullname", "lastname,firstname" ) />
    </cfif>

    <cfset super.default( rc = rc ) />
  </cffunction>

  <cffunction name="save">
    <cfargument name="rc" />

    <cfset rc.dontredirect = true />

    <cfif structKeyExists( rc, "password" ) and not len( trim( rc.password ))>
      <cfset structDelete( rc, "password" ) />
      <cfif structKeyExists( form, "password" )>
        <cfset structDelete( form, "password" ) />
      </cfif>
    </cfif>

    <cfset super.save( rc = rc ) /> <!--- sets rc.data to the saved entity --->

    <cfif structKeyExists( rc, "password" ) and len( trim( rc.password ))>
      <cfif len( trim( rc.password )) lt 2>
        <cfset session.alert = {
          "class" = "danger",
          "text"  = "password-too-short"
        } />
      <cfelse>
        <cfset rc.data.setPassword( rc.util.hashPassword( rc.password )) />
      </cfif>
    </cfif>

    <cfset fw.redirect( ".default" ) />
  </cffunction>
</cfcomponent>