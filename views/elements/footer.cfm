<cfset local.processTime = getTickCount() - rc.startTime />
<cfoutput>
  <cfif rc.debug and rc.config.showDebug>
    <div class="whitespace"></div>
    <div class="well footnotes">
      <h4>DEBUG INFO</h4>
      <small>
        Powered by FW/1 version #variables.framework.version#.<br />
        <a href="#buildURL( 'admin:' )#">Admin</a>
        | <a href="#buildURL( ':app.docs?x=' & randRange( 1000, 9999 ))#">Docs</a>
        | <a href="#buildURL( ':app.loc' )#">LoC</a>
        | <a href="#buildURL( ':app.diagram' )#">Diagram</a>
        <cfif isFrameworkReloadRequest()>
          | <span class="label label-danger">Reloaded</span>
        <cfelse>
          | <a href="#buildURL(getfullyqualifiedaction(),'?reload=1')#">Reload</a>
        </cfif>
        <cfif request.reset>
          | <span class="label label-danger">Database Reloaded</span>
        <cfelseif isFrameworkReloadRequest()>
          | <span class="label label-success">Database Updated</span>
        </cfif>
        <br />Current FQA: <strong>#getfullyqualifiedaction()#</strong>
        <br />Language:
        <cfloop array="#entityLoad( 'locale' )#" index="locale">
          <a class="label label-#rc.currentlocale.getID() eq locale.getID()?'info':'default'#" href="#buildURL( getfullyqualifiedaction(), '?localeid=#locale.getID()#' )#">#locale.getCode()#</a>
        </cfloop>
        <br />Is logged in: #rc.auth.isLoggedIn#
      </small>
    </div>
    <hr />
  </cfif>
  <div id="timer">#local.processTime#ms</div>
</cfoutput>