<cfcomponent>
  <cffunction name="init" output="false">
    <cfargument name="fw" type="component" required="true" />
    <cfset variables.fw = fw />
    <cfreturn this />
  </cffunction>

  <cffunction name="error">
    <cfheader statuscode="500" statustext="Internal Server Error" />
    <cfset rc.dontredirect = true />

    <cfset var mailSubject = "Error #cgi.server_name#" />

    <cfif isDefined( "request.exception.cause.message" )>
      <cfset mailSubject &= " - " & request.exception.cause.message />
    </cfif>

    <cfmail from="#rc.config.debugEmail#" to="#rc.config.debugEmail#" subject="#mailSubject#" type="html">
      <cfdump var="#cgi#" />
      <cfdump var="#request.exception#" />
    </cfmail>
  </cffunction>
</cfcomponent>