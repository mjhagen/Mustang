<cfparam name="rc.subnav" default="" />

<cfset filesMenuItemPointer = listFindNoCase( rc.subnav, "files" ) />
<cfif filesMenuItemPointer>
  <cfset rc.subnav = listDeleteAt( rc.subnav, filesMenuItemPointer ) />
</cfif>

<cfoutput>
  <ul class="nav" id="side-menu">
    <cfif not rc.subnavHideHome>
      <li><a#( getSection() eq 'main' )?' class="active"':''# href="#buildURL( getSubsystem() & ':main' )#">#i18n.translate( getSubsystem() & ':main.default' )#</a></li>
    </cfif>
    <cfloop list="#rc.subnav#" index="local.fqa">
      <cfif listFirst( local.fqa, '=' ) eq "external">
        <cfset local.subsystem = "" />
        <cfset local.section = "" />
        <cfset local.href = listRest( local.fqa, '=' ) />
        <cfset local.active = false />
        <cfset local.label = i18n.translate( local.fqa ) />
      <cfelse>
        <cfset local.subsystem = getSubsystem( local.fqa ) />
        <cfset local.section = getSection( local.fqa ) />
        <cfif local.section eq "-">
          <li style="border:0;">&nbsp;</li>
          <cfcontinue />
        </cfif>
        <cfset local.href = buildURL( local.subsystem & ':' & local.section ) />
        <cfset local.active = ( local.subsystem eq getSubSystem() and local.section eq getSection() ) />
        <cfset local.label = i18n.translate( local.subsystem & ':' & local.section & '.default' ) />
      </cfif>

      <li>
        <a#local.active?' class="active"':''# href="#local.href#">#local.label#</a>
        <cfif isDefined( "rc.subsubnav" ) and
              (
                ( isSimpleValue( rc.subsubnav ) and len( trim( rc.subsubnav ))) or
                ( isArray( rc.subsubnav ) and arrayLen( rc.subsubnav ))
              ) and getSection() eq local.section>
          <ul class="nav nav-second-level">
            <cfif isSimpleValue( rc.subsubnav )>
              <cfloop list="#rc.subsubnav#" index="subsubitem">
                <li><a#( getfullyqualifiedaction() eq '#subsystem#:#section#.#subsubitem#' )?' class="active"':''# href="#buildURL('.#subsubitem#')#">#i18n.translate( '#subsystem#:#section#.#subsubitem#' )#</a></li>
              </cfloop>
            <cfelse>
              <cfloop array="#rc.subsubnav#" index="subsubitem">
                <cfset local.active = true />
                <cfloop collection="#subsubitem.querystring#" item="key">
                  <cfif not structKeyExists( rc, key ) or not rc[key] eq subsubitem.querystring[key]>
                    <cfset local.active = false />
                    <cfbreak />
                  </cfif>
                </cfloop>
                <li><a#local.active?' class="active"':''# href="#buildURL( action='.#subsubitem.action#', querystring=subsubitem.querystring)#">#subsubitem.label#</a></li>
              </cfloop>
            </cfif>
          </ul>
        </cfif>
      </li>
    </cfloop>
  </ul>

  <cfif structKeyExists( rc, "subnavwell" ) and len( trim( rc.subnavwell ))>
    <div class="well well-sm" style="margin:15px;">
      #rc.subnavwell#
    </div>
  </cfif>
</cfoutput>