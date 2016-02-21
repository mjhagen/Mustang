<cfoutput>
  <cfparam name="local.val" default="#[]#" />
  <cfparam name="local.column" default="#{}#" />
  <cfparam name="local.column.data" default="#{}#" />

  <cfset local.listedIDs = [] />

  <ul class="list-group">
    <cfloop array="#local.val#" index="local.singleVal">
      <cfset local.valID        = local.singleVal.getID() />
      <cfset local.valString    = local.singleVal.getName() />
      <cfset local.linkSection  = local.singleVal.getEntityName() />

      <cfif arrayFind( local.listedIDs, local.valID )>
        <cfcontinue />
      </cfif>
      <cfset arrayAppend( local.listedIDs, local.valID ) />

      <cfif isNull( local.valString )>
        <cfset local.valString = i18n.translate( 'no-name' ) />
      <cfelse>
        <cfif structKeyExists( local.column.data, "translateOptions" )>
          <cfset local.valString = i18n.translate( local.valString ) />
        </cfif>
      </cfif>

      <cfif not isNull( local.valID ) and len( trim( local.valID ))>
        <cfset local.valString = '<a href="#buildURL( action = local.linkSection & '.view', queryString = { '#local.linkSection#id' = local.valID })#">#local.valString#</a>' />
      </cfif>

      <li class="list-group-item">#local.valString#</li>
    </cfloop>
  </ul>
</cfoutput>