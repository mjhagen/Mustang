<cfif isDefined( "body" )>
  <cfset contentSettings = { generatedBody = duplicate( body ) } />
<cfelse>
  <cfset contentSettings = { generatedBody = "" } />
</cfif>

<cfoutput>
  #view( "elements/content", contentSettings )#
</cfoutput>