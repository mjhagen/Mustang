<cfparam name="local.generatedBody" default="" />

<cfif not isDefined( "rc.content" )>
  <cfset rc.content = entityNew( "content" ) />
  <cfset rc.content.setTitle( rc.displaytitle ) />
</cfif>

<cfoutput>
  <div class="row">
    <div class="col-lg-12">
      <cfif getSubsystem() eq "admin">
        <h1 class="page-header">
          <cfif getSection() eq "main">
            #rc.i18n.translate( 'welcome' )# #rc.auth.user.getFirstname()#
          <cfelse>
            <cfif len( trim( rc.content.getTitle()))>#rc.content.getTitle()#</cfif>
          </cfif>
          <cfif len( trim( rc.content.getSubTitle()))><small>#rc.content.getSubTitle()#</small></cfif>
          <cfif rc.auth.isLoggedIn and rc.auth.role.can( "change", "content" )>
            <cfset local.editContentLink = buildURL(
              action = "admin:content.edit",
              querystring = {
                "returnTo" = getFullyQualifiedAction()
              }
            ) />
            <a class="btn btn-default pull-right text-muted" href="#local.editContentLink#" title="#i18n.translate('edit-content')#"><i class="fa fa-pencil"></i></a>
          </cfif>
        </h1>

        <div class="hidden-xs">#view( "common:elements/breadcrumbs" )#</div>
      </cfif>

      <cfif isDefined( "rc.content" ) and len( trim( rc.content.getBody()))>
        <p>#rc.content.getBody()#</p>
      </cfif>
    </div>
  </div>

  <cfif structKeyExists( rc, "alert" ) and isStruct( rc.alert ) and
        structKeyExists( rc.alert, 'class' ) and
        structKeyExists( rc.alert, 'text' )>
    <div class="row">
      <div class="col-lg-12">
        <div class="alert alert-dismissable alert-#rc.alert.class#">
          <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
          #i18n.translate( label = rc.alert.text, stringVariables = rc.alert.stringVariables )#
        </div>
      </div>
    </div>
  </cfif>

  #local.generatedBody#
</cfoutput>