<cfset local.processTime = getTickCount() - rc.startTime />
<cfoutput>
  <cfif rc.debug and rc.config.showDebug>
    <div class="whitespace"></div>
    <div class="well footnotes">
      <h4>DEBUG INFO</h4>
      <small>
        Powered by FW/1 version #variables.framework.version#.<br />
        <a href="/admin">Admin</a>
        | <a href="#buildURL( 'home:main.docs?x=' & randRange( 1000, 9999 ))#">Docs</a>
        | <a href="#buildURL( 'admin:main.loc' )#">LoC</a>
        | <a href="#buildURL( 'home:main.diagram' )#">Diagram</a>
        <cfif isFrameworkReloadRequest()>
          | <span class="label label-danger">Reloaded</span>
        <cfelse>
          | <a href="#buildURL(getfullyqualifiedaction(),'?reload=1')#">Reload</a>
        </cfif>
        <cfif variables.reset>
          | <span class="label label-danger">Database Reloaded</span>
        <cfelseif isFrameworkReloadRequest()>
          | <span class="label label-success">Database Updated</span>
        </cfif>
        <br />Current FQA: <strong>#getfullyqualifiedaction()#</strong>
        <br />Sites:
        <cfloop array="#entityLoad( 'website' )#" index="local.website">
          <a href="http://#local.website.getHostname()#" class="label label-#local.website.getHostname() eq cgi.server_name?'info':'default'#">#local.website.getName()#</a>
        </cfloop>
        <br />Language:
        <cfloop array="#entityLoad( 'language' )#" index="language">
          <a class="label label-#rc.currentlanguageid eq language.getID()?'info':'default'#" href="#buildURL(getfullyqualifiedaction(),'?languageid=#language.getID()#')#">#language.getName()#</a>
        </cfloop>
        <br /><a href="#buildURL( 'admin:translation' )#">Edit translations</a>
        <br />Is logged in: #rc.auth.isLoggedIn#
      </small>
    </div>
    <hr />
  </cfif>
  <div id="timer">#local.processTime#ms</div>
</cfoutput>