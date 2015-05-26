<cfcomponent output="false">
  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="init" returntype="any" access="public" output="false">
  	<cfargument name="fw" type="component" required="true" />
  	<cfset variables.fw = fw />
    <cfreturn this />
  </cffunction>

  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="getContent">
    <cfset rc.displaytitle = rc.i18n.translate( fw.getfullyqualifiedaction()) />

    <cfquery dbtype="HQL" name="rc.content" ormoptions="#{cacheable=true}#">
      SELECT  c

      FROM    content c

      WHERE c.fullyqualifiedaction = <cfqueryparam value="#fw.getfullyqualifiedaction()#" />
        AND c.language.id = <cfqueryparam value="#rc.currentlanguage.getID()#" />
        AND c.deleted != <cfqueryparam cfsqltype="cf_sql_tinyint" value="1" />
    </cfquery>

    <cfif arrayLen( rc.content )>
      <cfset rc.content = rc.content[1] />
    <cfelse>
      <cfset structDelete( rc, "content" ) />
    </cfif>

    <cfif not isDefined( "rc.topnav" )>
      <cfset rc.topnav = "" />
    </cfif>

    <cfset rc.subnavHideHome = false />

    <cfif fw.getSubsystem() eq 'admin'>
      <cfset local.reload = true />

      <cflock scope="session" timeout="5">
        <cfif structKeyExists( session, "subnav" )>
          <cfset rc.subnav = session.subnav />
          <cfset local.reload = false />
        </cfif>
      </cflock>

      <cfif not rc.config.appIsLive or structKeyExists( rc, "reload" )>
        <cfset local.reload = true />
      </cfif>

      <cfif local.reload>
        <cfset rc.subnav = "" />

        <cfif structKeyExists( rc.auth, "role" ) and isObject( rc.auth.role )>
          <cfif rc.auth.role.getName() eq "Administrator">
            <cfset local.roleSubnav = "" />
          <cfelseif rc.auth.isLoggedIn>
            <cfset local.roleSubnav = rc.auth.role.getMenuList() />
          </cfif>
        </cfif>

        <cfif not isDefined( "local.roleSubnav" )>
          <cfset local.roleSubnav = "" />
        </cfif>

        <cfif len( trim( local.roleSubnav ))>
          <cfloop list="#local.roleSubnav#" index="local.navItem">
            <cfif local.navItem eq "-" or rc.auth.role.can( "view", local.navItem )>
              <cfset rc.subnav = listAppend( rc.subnav, local.navItem ) />
            </cfif>
          </cfloop>
        <cfelse>
          <cfset local.hiddenMenuitems = "base" />
          <cfloop array="#directoryList( fw.mappings['/root'] & '/model', true, 'name', '*.cfc' )#" index="local.entityPath">
            <cfset local.entityName = reverse( listRest( reverse( getFileFromPath( local.entityPath )), "." )) />
            <cfset local.hide = false />

            <cfif fileExists( "#fw.mappings['/root']#/model/#local.entityName#.cfc" )>
              <cfset local.entity = getMetaData( createObject( "root.model." & local.entityName )) />
              <cfset local.hide = structKeyExists( local.entity, "hide" ) />
            </cfif>

            <cfif listFindNoCase( local.hiddenMenuitems, local.entityName )>
              <cfset local.hide = true />
            </cfif>

            <cfif rc.auth.isLoggedIn and rc.auth.role.can( "view", local.entityName ) and not local.hide>
              <cfset rc.subnav = listAppend( rc.subnav, local.entityName ) />
            </cfif>
          </cfloop>
        </cfif>
      </cfif>

      <cflock scope="session" timeout="5">
        <cfset session.subnav = rc.subnav />
      </cflock>
    </cfif>

    <cfset rc.design = createObject( "root.services.design" ).load() />
  </cffunction>
</cfcomponent>