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
    <cfloop list="#rc.subnav#" index="fqa">
      <cfset subsystem = getSubsystem( fqa ) />
      <cfset section = getSection( fqa ) />
      <cfif section eq "-">
        <li style="border:0;">&nbsp;</li>
        <cfcontinue />
      </cfif>
      <li>
        <a#( getSection() eq section )?' class="active"':''# href="#buildURL( subsystem & ':' & section )#">#i18n.translate(getSubsystem() & ':' & section & '.default' )#</a>
        <cfif isDefined( "rc.subsubnav" ) and 
              (
                ( isSimpleValue( rc.subsubnav ) and len( trim( rc.subsubnav ))) or 
                ( isArray( rc.subsubnav ) and arrayLen( rc.subsubnav ))
              ) and getSection() eq section>
          <ul class="nav nav-second-level">
            <cfif isSimpleValue( rc.subsubnav )>
              <cfloop list="#rc.subsubnav#" index="subsubitem">
                <li><a#( getfullyqualifiedaction() eq '#getSubsystem()#:#section#.#subsubitem#' )?' class="active"':''# href="#buildURL('.#subsubitem#')#">#i18n.translate( '#getSubsystem()#:#section#.#subsubitem#' )#</a></li>
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