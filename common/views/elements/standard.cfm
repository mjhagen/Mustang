<cfif isDefined( "body" )>
  <cfset contentSettings = { generatedBody = duplicate( body ) } />
<cfelse>
  <cfset contentSettings = { generatedBody = "" } />
</cfif>

<cfoutput>
  #view( "common:elements/content", contentSettings )#
</cfoutput>