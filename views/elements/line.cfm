<cfparam name="local.columns" default="#[]#" />
<cfparam name="local.lineactions" default="" />
<cfparam name="local.entity" default="#getSection()#" />
<cfparam name="local.class" default="" />
<cfparam name="local.classColumn" default="" />
<cfparam name="local.data" default="#createObject( 'basecfc.base' ).init()#" />

<cfset local.entityProperties = getMetaData( local.data ) />
<cfset local.lineTitle = "" />

<cfif local.data.hasProperty( "updateDate" )>
  <cfset local.updated = local.data.getUpdateDate() />
  <cfif not isDefined( "local.updated" ) or not isDate( local.updated )>
    <cfset local.updated = local.data.getCreateDate() />
  </cfif>
  <cfif isDefined( "local.updated" ) and isDate( local.updated )>
    <cfset local.lineTitle = "#i18n.translate( 'last-updated' )#: #lsDateFormat( local.updated, i18n.translate( 'defaults-dateformat-small' ))# #lsTimeFormat( local.updated, 'HH:mm:ss' )#" />
  </cfif>
</cfif>

<cfif len( trim( local.classColumn )) and local.data.hasProperty( local.classColumn )>
  <cfset local.classColumn = evaluate( "local.data.get#local.classColumn#()" ) />
  <cfif isDefined( "local.classColumn" )>
    <cfset local.class = local.classColumn.getClass() />
  </cfif>
  <cfif not isDefined( "local.class" )>
    <cfset local.class = "" />
  </cfif>
</cfif>

<cfoutput>
  <tr title="#local.lineTitle#"#len( trim( local.class ))?' class="#local.class#"':''#>
    <cfif structKeyExists( local, "rowNr" )>
      <th class="rowNr">#local.rowNr#</th>
    </cfif>

    <cfloop array="#local.columns#" index="local.column">
      <cfif isDefined( "local.column" )>
        <td>#trim( view( "elements/fielddisplay", { data = local.data, column = local.column }))#</td>
      <cfelse>
        <td></td>
      </cfif>
    </cfloop>

    <cfif len( trim( local.lineactions ))>
      <td><div class="pull-right">
        <cfloop list="#local.lineactions#" index="local.action">
          <cfif structKeyExists( local.entityProperties, "fullname" )>
            <cfset local.entity = listLast( local.entityProperties.fullname, '.' ) />
          </cfif>
          <cfset local.actionLink = buildURL( action = local.entity & local.action, queryString = { "#local.entity#id" = evaluate( 'local.data.getID()' )}) />
          <div class="btn-group"><a class="btn btn-xs btn-primary" href="#local.actionLink#">#i18n.translate( local.action )#</a></div>
        </cfloop>
      </div></td>
    </cfif>
  </tr>
</cfoutput>