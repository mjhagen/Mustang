<cfcomponent extends="apibase">
  <cffunction name="save">
    <cfargument name="rc" />

    <cftry>
      <cfset var languageFileName = "nl-NL.json" />

      <cfset request.layout = false />

      <cffile charset="UTF-8" action="read" file="#request.root#/i18n/#languageFileName#" variable="local.languageFile" />

      <cfset local.translations = deserializeJSON( local.languageFile ) />
      <cfset local.translations[rc.label] = rc.translation />

      <cfif not structKeyExists( application, "jl" )>
        <cfset application.jl = new javaloader.javaLoader(['#request.root#/thirdparty/json/thirdparty.json.jar']) />
      </cfif>

      <cfset local.jl = application.jl />
      <cfset local.JSONObject = local.jl.create( "thirdparty.json.JSONObject" ).init( serializeJSON( local.translations )) />

      <cffile charset="UTF-8" action="write" file="#request.root#/i18n/#languageFileName#" output="#local.JSONObject.toString( 2 )#" fixnewline="true" />

      <cfreturn true />

      <cfcatch>
        <cfreturn false />
      </cfcatch>
    </cftry>
  </cffunction>
</cfcomponent>