<cfoutput>
  <cfparam name="local.val" default="#[]#" />
  <cfparam name="local.column" default="#{}#" />
  <cfparam name="local.column.data" default="#{}#" />
  <cfparam name="local.inlist" default=false />

  <cfset local.listedIDs = [] />

  <cfif not local.inlist><ul class="list-group"></cfif>

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
      <cfset local.linkTo = buildURL( action = local.linkSection & '.view', queryString = { '#local.linkSection#id' = local.valID }) />
      <cfset local.valString = '<a href="#linkTo#"#local.inlist?' class="tag tag-pill tag-info"':''#>#local.valString#</a>' />
    </cfif>

    <cfif not local.inlist><li class="list-group-item"></cfif>

    #local.valString#

    <cfif not local.inlist></li></cfif>
  </cfloop>

  <cfif not local.inlist></ul></cfif>
</cfoutput>