<cfparam name="local.formprepend" default="" />
<cfparam name="local.fieldOverride" default="" />

<cfoutput>
  <cfif not rc.modal and rc.entity eq "logentry">
    <cfif structKeyExists( rc, "prevEntry" ) or structKeyExists( rc, "nextEntry" )>
      <cfsavecontent variable="local.formprepend">
        <div class="pull-right">
          <cfif structKeyExists( rc, "prevEntry" )>
            <a href="#buildURL( '.view?logentryID=' & rc.prevEntry.getID())#" class="btn btn-default">#i18n.translate( 'prev-logentry' )#</a>
          </cfif>
          <cfif structKeyExists( rc, "nextEntry" )>
            <a href="#buildURL( '.view?logentryID=' & rc.nextEntry.getID())#" class="btn btn-default">#i18n.translate( 'next-logentry' )#</a>
          </cfif>
        </div>
        <div class="clearfix"></div>
      </cfsavecontent>
    </cfif>
    #view('common:elements/edit',local)#
  <cfelse>
    <cfset local.formprepend = "<p>#i18n.translate( 'enter-a-note' )#</p>" />
    #view('common:elements/modaledit',local)#
  </cfif>

</cfoutput>