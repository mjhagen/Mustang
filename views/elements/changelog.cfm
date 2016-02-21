<cfparam name="local.notesInline" default="false" />
<cfparam name="local.linkToEntity" default="true" />
<cfparam name="local.activity" default="#[]#" />

<cfoutput>
  <ul class="list-group">
    <cfloop array="#local.activity#" index="local.logEntry">
      <cfset local.by = local.logEntry.getby() />
      <cfif not isDefined( "local.by" )>
        <cfset local.by = entityNew( "contact" ) />
      </cfif>
      <cfset local.dd = local.logEntry.getdd() />
      <cfset local.logaction = local.logEntry.getLogaction() />
      <cfif not isDefined( "local.logaction" )>
        <cfset local.logaction = entityLoad( "logaction", { name = "changed" }, true ) />
      </cfif>
      <cfset local.cssClass = local.logaction.getCSSClass() />
      <cfif not isDefined( "local.cssClass" )>
        <cfset local.cssClass = "default" />
      </cfif>

      <cfset local.loggedEntity = local.logEntry.getRelatedEntity() />
      <cfif isDefined( "local.loggedEntity" )>
        <cfset local.loggedEntityName = listLast( getMetaData( local.loggedEntity ).name, '.' ) />
        <cfset local.loggedEntityID = local.loggedEntity.getID() />
      <cfelse>
        <cfset local.loggedEntityName = "unknown" />
        <cfset local.loggedEntityID = "" />
      </cfif>

      <li class="list-group-item list-group-item-#local.cssClass#">
        <!--- log entry actions: --->
        <cfif local.linkToEntity and len( trim( local.loggedEntityID ))>
          <a class="btn btn-xs btn-primary pull-right" style="margin-left:5px;" href="#buildURL( '' & local.loggedEntityName & '.view?#local.loggedEntityName#id=#local.loggedEntityID#' )#">#i18n.translate( 'view-item' )#</a>
        </cfif>
        <a class="btn btn-xs btn-primary pull-right" style="margin-left:5px;" href="#buildURL( 'logentry.view?logentryID=#local.logEntry.getID()#' )#">#i18n.translate( 'view-logentry' )#</a>

        <!--- log entry output: --->
        <cfif not isNull( local.dd )>
          <span class="text-muted">#i18n.translate( 'on' )#</span> #lsDateFormat( local.dd, i18n.translate( 'defaults-dateformat-small' ))#
          <span class="text-muted">#i18n.translate( 'at' )#</span> #lsTimeFormat( local.dd, 'HH:mm:ss' )#
        </cfif>
        #local.by.getName()#
        <strong>#i18n.translate( local.logaction.getName())#</strong>
        #i18n.translate( local.loggedEntityName )#
        <cfset local.loggedEntity = local.logEntry.getRelatedEntity() />
        <cfif isDefined( "local.loggedEntity" )>
          #local.loggedEntity.getName()#
        </cfif>

        <!--- notes and attachments: --->
        <cfif local.notesInline>
          <p>
            <cfif len( trim( local.logentry.getNote()))>
              <strong>#i18n.translate( 'note' )#:</strong> #local.logentry.getNote()#<br />
            </cfif>
            <cfif len( trim( local.logentry.getAttachment()))>
              <strong>#i18n.translate( 'attachment' )#:</strong> <a href="#buildURL( 'adminapi:crud.download?filename=' & local.logentry.getAttachment() )#">#local.logentry.getAttachment()#</a><br />
            </cfif>
          </p>
        </cfif>
      </li>
    </cfloop>
  </ul>
</cfoutput>