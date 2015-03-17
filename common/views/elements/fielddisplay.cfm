<cfif not isDefined( "local.column" )><cfexit /></cfif>

<cfif not isDefined( "local.val" )>
  <cfif not isDefined( "local.data" )><cfexit /></cfif>
  <cfset local.val = evaluate( 'local.data.get#local.column.name#()' ) />

  <cfif structKeyExists( local.data, "displayName" )>
    <cfset local.val = local.data.getDisplayName() />
  </cfif>
</cfif>

<cfoutput>
  <cfif isDefined( "local.val" )>
    <cfif isSimpleValue( local.val )>
      <p class="form-control-static">
        <cfif structKeyExists( local.column.data, "listmask" )>
          <cfset local.val = replaceNoCase( local.column.data.listmask, '{val}', local.val, 'all' ) />
        </cfif>

        <cfif structKeyExists( local.column.data, "translateOptions" )>
          <cfset local.val = i18n.translate( local.val ) />
        </cfif>

        <cfif (
                structKeyExists( local.column, "dataType" ) and
                local.column.dataType eq "json"
              )
              or
              (
                structKeyExists( local.column, "data" ) and
                isStruct( local.column.data ) and
                structKeyExists( local.column.data, "dataType" ) and
                local.column.data.dataType eq "json"
              )>
          <pre class="prettyprint">#htmlEditFormat( local.val )#</pre>
        <cfelseif
          structKeyExists( local.column, "data" ) and
          isStruct( local.column.data ) and
          structKeyExists( local.column.data, "ORMType" ) and
          local.column.data.ORMType eq "boolean"
        >
          #i18n.translate( local.val & '-' & local.column.name )#
        <cfelseif
          structKeyExists( local.column, "data" ) and
          isStruct( local.column.data ) and (
            ( structKeyExists( local.column.data, "ORMType" ) and local.column.data.ORMType eq "float" ) or
            ( structKeyExists( local.column.data, "type" ) and local.column.data.type eq "numeric" )
          )
        >
          #lsNumberFormat( local.val, ',.00' )#
        <cfelseif
          structKeyExists( local.column, "data" ) and
          isStruct( local.column.data ) and
          structKeyExists( local.column.data, "ORMType" ) and
          local.column.data.ORMType eq "string"
        >
          <cfif structKeyExists( local.column.data, "translateOptions" )>
            <cfset local.val = i18n.translate( local.val ) />
          </cfif>
          #local.val#
        <cfelseif isDate( local.val ) and
          structKeyExists( local.column.data, "ORMType" ) and
          local.column.data.ORMType eq "timestamp">
          #lsDateFormat( local.val, i18n.translate( 'defaults-dateformat-small' ))#<br />
          #lsTimeFormat( local.val, 'HH:mm:ss' )#
        <cfelseif structKeyExists( local.column, "formfield" ) and
                  local.column.formfield eq "file">
          <a href="#buildURL( 'api:crud.download?filename=' & local.val )#">#local.val#</a>
        <cfelse>
          #replace( local.val, '#chr( 13 )##chr( 10 )#', '<br />', 'all' )#
        </cfif>
      </p>
    <cfelseif isArray( local.val ) and arrayLen( local.val )>
      <cfset local.listedIDs = [] />
      <div class="form-control-static">
        <ul class="nobullets">
          <cfloop array="#local.val#" index="local.singleVal">
            <cfset local.valID        = local.singleVal.getID() />
            <cfset local.valString    = local.singleVal.getName() />
            <cfset local.linkSection  = local.singleVal.getEntityName() />

            <cfif arrayFind( local.listedIDs, local.valID )>
              <cfcontinue />
            </cfif>
            <cfset arrayAppend( local.listedIDs, local.valID ) />

            <cfif isNull( local.valString )>
              <li>#i18n.translate( 'no-name' )#</li>
              <cfcontinue />
            </cfif>

            <cfif structKeyExists( local.column.data, "translateOptions" )>
              <cfset local.valString = i18n.translate( local.valString ) />
            </cfif>

          <cfif isDefined( "local.valID" ) and len( trim( local.valID ))>
              <cfset local.valString = '<a href="#buildURL( action = local.linkSection & '.view', queryString = { '#local.linkSection#id' = local.valID })#">#local.valString#</a>' />
            </cfif>

            <li>#local.valString#</li>
          </cfloop>
        </ul>
      </div>
    <cfelseif isObject( local.val )>
      <cftry>
        <cfsetting requestTimeout="5" />

        <cfset local.fieldlist = "" />
        <cfset local.obj = local.val />
        <cfset local.textvalue = local.obj.getName() />

        <cfif not isDefined( "local.textvalue" )>
          <cfset local.textvalue = "noname" />
        </cfif>

        <cfif structKeyExists( local.column.data, "translateOptions" )>
          <cfset local.textvalue = i18n.translate( local.textvalue ) />
        </cfif>

        <cfif structKeyExists( local.column.data, 'affectsform' )>
          <cfset local.fieldlist = local.obj.getFieldList() />
        </cfif>

        <cfif len( trim( local.obj.getID()))>
          <cfset local.entityName = listLast( getMetaData( local.obj ).name, '.' ) />
          <cfset local.fqa = local.entityName & '.view' />
          <cfset local.textvalue = '<a href="' & buildURL( local.fqa, '', { '#local.entityName#id' = local.obj.getID()}) & '">' & local.textvalue & '</a>' />
        </cfif>

        <p class="form-control-static">
          <span class="selectedoption" data-fieldlist="#local.fieldlist#">#local.textvalue#</span>
        </p>

        <cfcatch></cfcatch>
      </cftry>
    </cfif>
  </cfif>
</cfoutput>