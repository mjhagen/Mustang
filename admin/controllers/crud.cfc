<cfcomponent output="false">
  <cfprocessingdirective pageEncoding="utf-8" />

  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="init" returntype="any" access="public" output="false">
    <cfargument name="fw" />

    <cfparam name="variables.listitems" default="" />
    <cfparam name="variables.listactions" default=".new" />
    <cfparam name="variables.lineactions" default=".view,.edit" />
    <cfparam name="variables.submitButtons" default="#[]#" type="array" />
    <cfparam name="variables.showNavbar" default="true" />
    <cfparam name="variables.showSearch" default="false" />
    <cfparam name="variables.showAlphabet" default="false" />
    <cfparam name="variables.showPager" default="true" />
    <cfparam name="variables.entity" default="#fw.getSection()#" />

  	<cfset variables.fw = fw />

    <cfreturn this />
  </cffunction>

  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="before">
    <cfif fw.getItem() eq "edit" and
          not rc.auth.role.can( "change", fw.getSection())>
      <cfset session.alert = {
        "class" = "danger",
        "text"  = "privileges-error"
      } />
      <cfset fw.redirect( "admin:" ) />
    </cfif>

    <cfset session.alert = {
      "class" = "danger",
      "text"  = "privileges-error"
    } />

    <cfif rc.auth.role.can( "view", fw.getSection())>
      <cfset structDelete( session, "alert" ) />
    </cfif>

    <cfif structKeyExists( session, "alert" )>
      <cfset fw.redirect( "admin:" ) />
    </cfif>

    <cfset variables.entity = fw.getSection() />
  </cffunction>

  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="default">
    <cfparam name="rc.columns" default="#[]#" />
    <cfparam name="rc.offset" default="0" />
    <cfparam name="rc.maxResults" default="30" />
    <cfparam name="rc.d" default="0" /><!--- rc.d(escending) default false (ASC) --->
    <cfparam name="rc.orderby" default="" />
    <cfparam name="rc.startsWith" default="" />
    <cfparam name="rc.showdeleted" default="0" />
    <cfparam name="rc.filters" default="#[]#" />
    <cfparam name="rc.filterType" default="contains" />
    <cfparam name="rc.lineview" default="common:elements/line" />
    <cfparam name="rc.classColumn" default="" />

    <cfset rc.fallbackView  = "common:elements/list" />
  	<cfset rc.entity = variables.entity />

    <cfif fw.getSection() eq "main">
      <cfset var dashboard = lCase( replace( rc.auth.role.getName(), ' ', '-', 'all' )) />
      <cfset fw.setView( 'admin:main.dashboard-' & dashboard )>
      <cfreturn />
    </cfif>

    <cfif fw.getSection() eq "profile">
      <cfset fw.setView( 'common:profile.default' )>
      <cfreturn />
    </cfif>

    <cfif not structKeyExists( ORMGetSessionFactory().getAllClassMetadata(), rc.entity )>
      <cfset session.alert = {
        "class" = "danger",
        "text"  = "not-an-entity-error"
      } />
      <cfset fw.redirect( "admin:main.default" ) />
    </cfif>

    <cfset var object = entityNew( rc.entity ) />
    <cfset var entityProperties = getMetaData( object ) />
    <cfset var property = "" />
    <cfset var indexNr = 0 />
    <cfset var orderNr = 0 />
    <cfset var columnName = "" />
    <cfset var columnsinlist = [] />
    <cfset var orderByString = "" />
    <cfset var queryOptions = { ignorecase = true, maxResults = rc.maxResults, offset = rc.offset } />

    <cfset rc.recordCounter = 0 />
    <cfset rc.deleteddata   = 0 />
    <cfset rc.properties    = object.getInheritedProperties() />
    <cfset rc.lineactions   = variables.lineactions />
    <cfset rc.listactions   = variables.listactions />
    <cfset rc.showNavbar    = variables.showNavbar />
    <cfset rc.showSearch    = variables.showSearch />
    <cfset rc.showAlphabet  = variables.showAlphabet />
    <cfset rc.showPager     = variables.showPager />

    <cfif not rc.auth.role.can( "change", rc.entity )>
      <cfset local.lineactionPointer = listFind( rc.lineactions, '.edit' ) />
      <cfif local.lineactionPointer>
        <cfset rc.lineactions = listDeleteAt( rc.lineactions, local.lineactionPointer ) />
      </cfif>
    </cfif>

    <cfif structKeyExists( entityProperties, "classColumn" ) and len( trim( entityProperties.classColumn ))>
      <cfset rc.classColumn = entityProperties.classColumn />
    </cfif>

    <cfset var defaultSort = ( structKeyExists( entityProperties.extends, "defaultSort" ) ? entityProperties.extends.defaultSort : "" ) />
    <cfset defaultSort = ( structKeyExists( entityProperties, "defaultSort" ) ? entityProperties.defaultSort : defaultSort ) />

    <cfset rc.defaultSort = defaultSort />

    <cfif len( trim( rc.orderby ))>
      <cfset defaultSort = rc.orderby & ( rc.d ? ' DESC' : '' ) />
    </cfif>

    <cfset rc.orderby = replaceNoCase( defaultSort, ' ASC', '', 'all' ) />
    <cfset rc.orderby = replaceNoCase( rc.orderby, ' DESC', '', 'all' ) />

    <cfif defaultSort contains 'DESC'>
      <cfset rc.d = 1 />
    <cfelseif defaultSort contains 'ASC'>
      <cfset rc.d = 0 />
    </cfif>

    <cfloop list="#defaultSort#" index="orderByPart">
      <cfset orderByString = listAppend( orderByString, "mainEntity.#orderByPart#" ) />
    </cfloop>

    <cfif len( trim( rc.startsWith ))>
      <cfset rc.filters = [{
        "field" = "name",
        "filterOn" = replace( rc.startsWith, '''', '''''', 'all' )
      }] />
      <cfset rc.filterType = "starts-with" />
    </cfif>

    <cfloop collection="#rc#" item="key">
      <cfif not isSimpleValue( rc[key] )>
        <cfcontinue />
      </cfif>
      <cfset key = urlDecode( key ) />
      <cfif listFirst( key, "_" ) eq "filter" and len( trim( rc[key] ))>
        <cfset arrayAppend( rc.filters, { "field" = listRest( key, "_" ), "filterOn" = replace( rc[key], '''', '''''', 'all' ) }) />
      </cfif>
    </cfloop>

    <cfif not structKeyExists( rc, "alldata" )>
      <cfif arrayLen( rc.filters )>
        <cfset var alsoFilterKeys = structFindKey( rc.properties, 'alsoFilter' ) />
        <cfset var alsoFilterEntity = "" />
        <cfset var whereBlock = " WHERE 0 = 0 " />
        <cfset var counter = 0 />

        <cfif rc.showdeleted eq 0>
          <cfset whereBlock &= " AND ( mainEntity.deleted IS NULL OR mainEntity.deleted = false ) " />
        </cfif>

        <cfloop from="1" to="#arrayLen( rc.filters )#" index="local.filterIndex">
          <cfif len( rc.filters[local.filterIndex].field ) gt 2 and right( rc.filters[local.filterIndex].field, 2 ) eq "id">
            <cfset whereBlock &= "AND mainEntity.#left( rc.filters[local.filterIndex].field, len( rc.filters[local.filterIndex].field ) - 2 )# = ( FROM #left( rc.filters[local.filterIndex].field, len( rc.filters[local.filterIndex].field ) - 2 )# WHERE id = '#rc.filters[local.filterIndex].filterOn#' )" />
          <cfelse>
            <cfif rc.filterType eq "contains">
              <cfset rc.filters[local.filterIndex].filterOn = "%#rc.filters[local.filterIndex].filterOn#" />
            </cfif>
            <cfset rc.filters[local.filterIndex].filterOn = "#rc.filters[local.filterIndex].filterOn#%" />

            <cfset whereBlock &= " AND ( " />
            <cfset whereBlock &= " mainEntity.#lCase( rc.filters[local.filterIndex].field )# LIKE '#rc.filters[local.filterIndex].filterOn#' " />

            <cfloop array="#alsoFilterKeys#" index="alsoFilterKey">
              <cfif alsoFilterKey.owner.name neq rc.filters[local.filterIndex].field>
                <cfcontinue />
              </cfif>
              <cfset counter++ />
              <cfset alsoFilterEntity &= " LEFT JOIN mainEntity.#listFirst( alsoFilterKey.owner.alsoFilter, '.' )# AS entity_#counter# " />
              <cfset whereBlock &= " OR entity_#counter#.#listLast( alsoFilterKey.owner.alsoFilter, '.' )# LIKE '#rc.filters[local.filterIndex].filterOn#' " />
            </cfloop>
            <cfset whereBlock &= " ) " />
          </cfif>
        </cfloop>

        <cfif structKeyExists( entityProperties, "where" ) and len( trim( entityProperties.where ))>
          <cfset whereBlock &= entityProperties.where />
        </cfif>

        <cfset var HQLcounter  = " SELECT COUNT( mainEntity ) AS total " />
        <cfset var HQLselector  = " SELECT mainEntity " />

        <cfset HQL = "" />
        <cfset HQL &= " FROM #lCase( rc.entity )# mainEntity " />
        <cfset HQL &= alsoFilterEntity />
        <cfset HQL &= whereBlock />

        <cfset HQLcounter = HQLcounter & HQL />
        <cfset HQLselector = HQLselector & HQL />

        <cfif len( trim( orderByString ))>
          <cfset HQLselector &= " ORDER BY #orderByString# " />
        </cfif>

        <cfset rc.alldata = ORMExecuteQuery( HQLselector, [], queryOptions ) />
        <cfif arrayLen( rc.alldata ) gt 0>
          <cfset rc.recordCounter = ORMExecuteQuery( HQLcounter, [], { ignorecase = true })[1] />
        </cfif>
      <cfelse>
        <cfset HQL = " FROM #lCase( rc.entity )# mainEntity " />

        <cfif rc.showDeleted>
          <cfset HQL &= " WHERE mainEntity.deleted = TRUE " />
        <cfelse>
          <cfset HQL &= " WHERE ( mainEntity.deleted IS NULL OR mainEntity.deleted = FALSE ) " />
        </cfif>

        <cfif len( trim( orderByString ))>
          <cfset HQL &= " ORDER BY #orderByString# " />
        </cfif>

        <cftry>
          <cfset rc.alldata = ORMExecuteQuery( HQL, {}, queryOptions ) />
          <cfcatch>
            <cfcontent reset=true /><cfsetting enableCFoutputOnly="false" />
            <cfdump var="#cfcatch#" />
            <cfabort />
            <cfset rc.alldata = [] />
          </cfcatch>
        </cftry>

        <cfif arrayLen( rc.alldata ) gt 0>
          <cfset rc.recordCounter = ORMExecuteQuery( "SELECT COUNT( e ) AS total FROM #lCase( rc.entity )# AS e WHERE e.deleted != :deleted", { "deleted" = true }, { ignorecase = true })[1] />
          <cfset rc.deleteddata = ORMExecuteQuery( "SELECT COUNT( mainEntity.id ) AS total FROM #lCase( rc.entity )# AS mainEntity WHERE mainEntity.deleted = :deleted", { "deleted" = true } )[1] />
          <cfif rc.showdeleted>
            <cfset rc.recordCounter = rc.deleteddata />
          </cfif>
        </cfif>
      </cfif>
    </cfif>

    <cfset rc.allColumns = {} />

    <cfset indexNr = 0 />
    <cfloop collection="#rc.properties#" item="key">
      <cfset property = rc.properties[key] />
      <cfset orderNr++ />
      <cfset rc.allColumns[property.name] = property />
      <cfset rc.allColumns[property.name].columnIndex = orderNr />
      <cfif structKeyExists( property, "inlist" )>
        <cfset indexNr++ />
        <cfset columnsinlist[indexNr] = property.name />
      </cfif>
    </cfloop>

    <cfif len( trim( variables.listitems ))>
      <cfset columnsinlist = [] />
      <cfloop list="#variables.listitems#" index="local.listItem">
        <cfset arrayAppend( columnsinlist, local.listItem ) />
      </cfloop>
    </cfif>

    <cfset numberOfColumns = arrayLen( columnsinlist ) />
    <cfloop array="#columnsinlist#" index="columnName">
      <cftry>
        <cfif structKeyExists( rc.allColumns, columnName )>
          <cfset property = rc.allColumns[columnName] />
          <cfset arrayAppend( rc.columns, {
            name = columnName,
            orderNr = structKeyExists( property, "cfc" )?0:property.columnIndex,
            orderInList = structKeyExists( property, "orderinlist" )?property.orderinlist:numberOfColumns++,
            class = structKeyExists( property, "class" )?property.class:'',
            data = property
          }) />
        </cfif>
        <cfcatch>
          <cfdump var="#cfcatch#" />
          <cfabort />
        </cfcatch>
      </cftry>
    </cfloop>

    <cfscript>
      // sort the array based on the orderInList value in the structures:
      for( var i=1; i lte arrayLen( rc.columns ); i++ )
      {
        for( var j=(i-1)+1; j gt 1; j-- )
        {
          if( rc.columns[j].orderInList lt rc.columns[j-1].orderInList )
          {
            // swap values
            var temp = rc.columns[j];
            rc.columns[j] = rc.columns[j-1];
            rc.columns[j-1] = temp;
          }
        }
      }
    </cfscript>
  </cffunction>

  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="import">
    <cfset rc.fallbackView = "common:elements/import" />
  </cffunction>

  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="new">
    <cfif not rc.auth.role.can( "change", fw.getSection())>
      <cfset session.alert = {
        "class" = "danger",
        "text"  = "privileges-error"
      } />
      <cfset fw.redirect( "admin:#fw.getSection()#.default" ) />
    </cfif>
    <cfreturn edit( rc = rc ) />
  </cffunction>

  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="view">
    <cfset rc.editable = false />
    <cfreturn edit( rc = rc ) />
  </cffunction>

  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="edit">
    <cfparam name="rc.modal" default="false" />
    <cfparam name="rc.editable" default="true" />
    <cfparam name="rc.inline" default="false" />
    <cfparam name="rc.namePrepend" default="" />

    <cfset rc.columns = [] />
  	<cfset rc.entity = variables.entity />

    <cfset rc.submitButtons = variables.submitButtons />

  	<cfif rc.modal>
  	  <cfset request.layout = false />
      <cfset rc.fallbackView = "common:elements/modaledit" />
      <cfif rc.inline>
        <cfset rc.fallbackView = "common:elements/inlineedit" />
      </cfif>
  	<cfelse>
      <cfset rc.fallbackView = "common:elements/edit" />
  	</cfif>

    <cfset var property = "" />
    <cfset var indexNr = 0 />
    <cfset var columnsinform = [] />
    <cfset var propertyOwner = {} />
    <cfset var object = entityNew( "#rc.entity#" ) />
    <cfset var propertiesInForm = [] />

    <cfset rc.entityProperties = getMetaData( object ) />

    <cfset rc.canBeLogged = isInstanceOf( object, 'logged' ) />

    <cfif rc.entity eq "logentry">
      <cfset rc.canBeLogged = false />
    </cfif>

    <cfset rc.properties = object.getInheritedProperties() />

    <cfloop collection="#rc.properties#" item="key">
      <cfif structKeyExists( rc.properties[key], "inform" )>
        <!--- cfset rc.properties[key].editable = true / --->
        <cfset arrayAppend( propertiesInForm, rc.properties[key] ) />
      </cfif>
    </cfloop>

    <cfset var numberOfPropertiesInForm = arrayLen( propertiesInForm ) + 10 />

    <cfset rc.hideDelete = structKeyExists( rc.entityProperties, "hideDelete" ) />

    <cfif structKeyExists( rc, "#rc.entity#id" ) and not len( trim( rc["#rc.entity#id"] ))>
      <cfset structDelete( rc, "#rc.entity#id" ) />
    </cfif>

    <cfif structKeyExists( rc, "#rc.entity#id" )>
      <cfset rc.data = entityLoadByPK( "#rc.entity#", rc["#rc.entity#id"] ) />
      <cfif not isDefined( "rc.data" )>
        <cfset fw.redirect( rc.entity ) />
      </cfif>
    <cfelse>
      <cfset rc.data = entityNew( "#rc.entity#" ) />
    </cfif>

    <cfif not isDefined( "rc.data" )>
      <cfset rc.data = entityNew( "#rc.entity#" ) />
    </cfif>

    <cfloop array="#propertiesInForm#" index="property">
      <cfif structKeyExists( property, "orderinform" ) and isNumeric( property.orderinform )>
        <cfset indexNr = property.orderinform />
      <cfelse>
        <cfset indexNr = numberOfPropertiesInForm++ />
      </cfif>

      <cfset columnsinform[indexNr] = property />
      <cfset local.savedValue = evaluate( "rc.data.get#property.name#()" ) />

      <cfif isDefined( "local.savedValue" )>
        <cfif isArray( local.savedValue )>
          <cfset local.savedValueList = "" />
          <cfloop array="#local.savedValue#" index="local.individualValue">
            <cfset local.savedValueList = listAppend( local.savedValueList, local.individualValue.getID() ) />
          </cfloop>
          <cfset local.savedValue = local.savedValueList />
        </cfif>
        <cfset columnsinform[indexNr].saved = local.savedValue />
      <cfelse>
        <cfset columnsinform[indexNr].saved = "" />
      </cfif>
    </cfloop>

    <cfloop array="#columnsinform#" index="columnInForm">
      <cfif not isNull( columnInForm )>
        <cfset arrayAppend( rc.columns, columnInForm ) />
      </cfif>
    </cfloop>
  </cffunction>

  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="delete">
    <cfif not rc.auth.role.can( "delete", fw.getSection())>
      <cfset session.alert = {
        "class" = "danger",
        "text"  = "privileges-error"
      } />
      <cfset fw.redirect( "admin:#fw.getSection()#.default" ) />
    </cfif>

    <cfset var entityToDelete = entityLoadByPK( "#variables.entity#", rc["#variables.entity#id"] ) />
    <cfif isDefined( "entityToDelete" )>
      <cfset entityToDelete.setDeleted( true ) />

      <cfif entityToDelete.hasProperty( "log" )>
        <cfset local.logentry = entityNew( "logentry", { entity = entityToDelete } ) />
        <cfset local.logaction = entityLoad( "logaction", { name = "removed" }, true ) />
        <cfset rc.log = local.logentry.enterIntoLog( action = local.logaction ) />
      </cfif>
    </cfif>

    <cfset fw.redirect( ".default" ) />
  </cffunction>

  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="restore">
    <cfset var entityToRestore = entityLoadByPK( "#variables.entity#", rc["#variables.entity#id"] ) />
    <cfif isDefined( "entityToRestore" )>
      <cfset entityToRestore.setDeleted( false ) />

      <cfif entityToRestore.hasProperty( "log" )>
        <cfset local.logentry = entityNew( "logentry", { entity = entityToRestore } ) />
        <cfset local.logaction = entityLoad( "logaction", { name = "restored" }, true ) />
        <cfset rc.log = local.logentry.enterIntoLog( action = local.logaction ) />
      </cfif>
    </cfif>

    <cfset fw.redirect( ".view", "#variables.entity#id" ) />
  </cffunction>

  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="save">
    <cfargument name="rc" />

    <cfif structCount( form ) eq 0>
      <cfset session.alert = {
        "class" = "danger",
        "text"  = "global-form-error"
      } />
      <cfset fw.redirect( "admin:#fw.getSection()#.default" ) />
    </cfif>

    <cfif not rc.auth.role.can( "change", fw.getSection())>
      <cfset session.alert = {
        "class" = "danger",
        "text"  = "privileges-error"
      } />
      <cfset fw.redirect( "admin:#fw.getSection()#.default" ) />
    </cfif>

    <!--- Load existing, or create a new entity --->
    <cfif structKeyExists( rc, "#variables.entity#id" )>
      <cfset rc.data = entityLoadByPK( variables.entity, rc["#variables.entity#id"] ) />
    <cfelse>
      <cfset rc.data = entityNew( variables.entity ) />
      <cfset entitySave( rc.data ) />
    </cfif>

    <!--- Log create/update time and user if object supprts it: --->
    <cfset rc.data = rc.data.save( formData = form ) />

    <cfif not ( structKeyExists( rc, "dontredirect" ) and rc.dontredirect )>
      <cfif structKeyExists( rc, "returnto" )>
        <cfset fw.redirect( rc.returnto ) />
      <cfelse>
        <cfset fw.redirect( ".default" ) />
      </cfif>
    </cfif>
  </cffunction>

  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="upload">
    <cfset var recordToImport = "" />
    <cfset var importedCSVFile = "" />
    <cfset var i = 0 />
    <cfset var field = "" />
    <cfset var newRecord = "" />

    <cffile action="upload" fileField="form.upload" nameConflict="MakeUnique" destination="#getTempDirectory()#" />
    <cffile action="read" file="#getTempDirectory()#/#cffile.serverFile#" variable="importedCSVFile" />

    <cfset var arrData = rc.util.csvToArray( importedCSVFile ) />

    <cfif arrayLen( arrData ) lte 1>
      No Records in CSV file.
    <cfelse>
      <cfset var fieldsToImportTo = duplicate( arrData[1] ) />
      <cfset arrayDeleteAt( arrData, 1 ) />


        <cfset local.prevRecords = entityLoad( "#variables.entity#" ) />
        <cfloop array="#local.prevRecords#" index="local.prevRecord">
          <cfset entityDelete( local.prevRecord ) />
        </cfloop>

        <cfset ORMFlush() />

        <cfloop array="#arrData#" index="recordToImport">
          <cfif arrayLen( recordToImport ) neq arrayLen( fieldsToImportTo )>
            <cfcontinue />
          </cfif>

          <cfset newRecord = entityNew( "#variables.entity#" ) />
          <cfset entitySave( newRecord ) />

          <cfset i = 0 />
          <cfloop array="#fieldsToImportTo#" index="field">
            <cfset i++ />
            <cftry>
              <cfset evaluate( "rc.data.set#field#(recordToImport[i])" ) />
              <cfcatch></cfcatch>
            </cftry>
          </cfloop>
        </cfloop>

    </cfif>

    <br />DONE.
    <cfabort />
  </cffunction>
</cfcomponent>