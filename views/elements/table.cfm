<cfparam name="local.alldata" default="#[]#" />
<cfparam name="local.columns" default="#[]#" />
<cfparam name="local.lineview" default="elements/line" />
<cfparam name="local.lineactions" default="" />
<cfparam name="local.classColumn" default="" />
<cfparam name="local.queryString" default="#{}#" />

<cfoutput>
  <table class="table table-sm table-striped">
    <thead>
      <tr>
        <th width="45">&nbsp;</th>
        <cfset local.indexNr = 0 />
        <cfloop array="#local.columns#" index="local.column">
          <cfset local.indexNr++ />
          <cfset local.columnClass = "" />
          <cfif structKeyExists( local.column, "class" )>
            <cfset local.columnClass = local.column.class />
          </cfif>
          <th class="#local.columnClass#" nowrap="nowrap">
            <cfif structKeyExists( local.column.data, "fieldType" ) and (
              local.column.data.fieldType contains 'to-one' or
              local.column.data.fieldType eq 'column'
            )>
              <cfset local.qs = duplicate( local.queryString ) />
              <cfset local.qs["orderby"] = local.column.name />
              <cfif rc.orderby eq local.column.name and rc.d eq 0>
                <cfset local.qs["d"] = 1 />
              </cfif>
              <cfset local.sortLink = buildURL(
                action      = getFullyQualifiedAction(),
                queryString = local.qs
              ) />
              <a href="#local.sortLink#">#i18n.translate( local.column.name )#</a>&nbsp;<cfif listFindNoCase( rc.orderby, local.column.name )><i class="fa fa-sort-#rc.d?'desc':'asc'#"></i></cfif>
            <cfelse>
              #i18n.translate( local.column.name )#
            </cfif>
          </th>
        </cfloop>
        <cfif len( local.lineactions )>
          <th></th>
        </cfif>
      </tr>
    </thead>
    <tbody>
      <cfif structKeyExists( local.queryString, 'offset' )>
        <cfset local.rowNr = local.queryString.offset + 1 />
      <cfelse>
        <cfset local.rowNr = 1 />
      </cfif>
      <cfloop array="#local.alldata#" index="local.data">
        <cfset local.params = {
          "data" = local.data,
          "columns" = local.columns,
          "lineactions" = local.lineactions,
          "class" = "#( local.data.getDeleted() eq true ? 'deleted' : '' )#",
          "classColumn" = local.classColumn,
          "rowNr" = local.rowNr++
        } />
        #view( local.lineview, local.params )#
      </cfloop>
    </tbody>
  </table>
</cfoutput>