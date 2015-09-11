<cfparam name="local.namePrepend" default="" />
<cfparam name="local.column" default="#{}#" />
<cfparam name="local.column.name" default="" />

<cfset local.formElementName = local.namePrepend & local.column.name />

<cfif isNull( local.column )><cfexit /></cfif>

<cfif isNull( local.val )>
  <cfif isNull( local.data )><cfexit /></cfif>
  <cfset local.val = evaluate( 'local.data.get#local.column.name#()' ) />

  <cfif structKeyExists( local.data, "displayName" )>
    <cfset local.val = local.data.getDisplayName() />
  </cfif>

  <cfif structKeyExists( local.column, "data" ) and
        isStruct( local.column.data ) and
        structKeyExists( local.column.data, "fieldType" ) and
        structKeyExists( local.column.data, "saved" ) and
        structKeyExists( local.column.data, "entityName" ) and
        isSimpleValue( local.column.data.fieldType ) and
        isSimpleValue( local.column.data.saved ) and
        isSimpleValue( local.column.data.entityName ) and
        len( trim( local.column.data.fieldType )) and
        len( trim( local.column.data.saved )) and
        len( trim( local.column.data.entityName ))
  >
    <cfswitch expression="#local.column.data.fieldType#">
      <cfcase value="many-to-one">
        <cfset local.val = entityLoadByPK( local.column.data.entityName, local.column.data.saved ) />
      </cfcase>
    </cfswitch>
  </cfif>
</cfif>

<cfoutput>
  <cfif not isNull( local.val )>
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
        <cfelseif structKeyExists( local.column.data, "formfield" ) and
                  local.column.data.formfield eq "file">
          <a href="#buildURL( 'adminapi:crud.download?filename=' & local.val )#">#local.val#</a>
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

          <cfif not isNull( local.valID ) and len( trim( local.valID ))>
              <cfset local.valString = '<a href="#buildURL( action = local.linkSection & '.view', queryString = { '#local.linkSection#id' = local.valID })#">#local.valString#</a>' />
            </cfif>

            <li>#local.valString#</li>
          </cfloop>
        </ul>
      </div>
    <cfelseif isObject( local.val )>
      <cfsetting requestTimeout="5" />

      <cfset local.fieldlist = "" />
      <cfset local.obj = local.val />
      <cfset local.textvalue = local.obj.getName() />

      <cfif isNull( local.textvalue )>
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
        <input type="hidden" name="#local.formElementName#" value="#local.obj.getID()#" />
      </cfif>

      <p class="form-control-static">
        <span class="selectedoption" data-fieldlist="#local.fieldlist#">#local.textvalue#</span>
      </p>
    </cfif>
  </cfif>
</cfoutput>