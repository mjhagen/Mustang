<cfoutput>
  <cfparam name="local.val" default="" />
  <cfparam name="local.column" default="#{}#" />
  <cfparam name="local.column.data" default="#{}#" />
  <cfparam name="local.column.data.link" default=false />
  <cfparam name="local.formElementName" default="" />

  <cfset local.fieldlist = "" />
  <cfset local.textvalue = local.val.getName() />

  <cfif isNull( local.textvalue )>
    <cfset local.textvalue = "noname" />
  </cfif>

  <cfif structKeyExists( local.column.data, "translateOptions" )>
    <cfset local.textvalue = i18n.translate( local.textvalue ) />
  </cfif>

  <cfif structKeyExists( local.column.data, 'affectsform' )>
    <cfset local.fieldlist = local.val.getFieldList() />
  </cfif>

  <cfif len( trim( local.val.getID())) and local.column.data.link>
    <cfset local.entityName = listLast( getMetaData( local.val ).name, '.' ) />
    <cfset local.fqa = local.entityName & '.view' />
    <cfset local.textvalue = '<a href="' & buildURL( local.fqa, '', { '#local.entityName#id' = local.val.getID()}) & '">' & local.textvalue & '</a>' />
    <!--- <input type="hidden" name="#local.formElementName#" value="#local.val.getID()#" /> --->
  </cfif>

  <span class="selectedoption" data-fieldlist="#local.fieldlist#">#local.textvalue#</span>
</cfoutput>