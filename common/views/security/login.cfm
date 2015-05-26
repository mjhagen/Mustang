<cfif not structKeyExists( rc, "content" )>
  <cfset rc.content = entityNew( "content" ) />
</cfif>

<cfoutput>
  <div class="row centercenter">
    <div class="col-lg-offset-3 col-lg-6">
      <div class="panel panel-default">
        <div class="panel-heading">
          <h3 class="panel-title">#rc.content.getTitle()#</h3>
        </div>
        <div class="panel-body">
          <cfif len( trim( rc.content.getBody()))>
            <p>#rc.content.getBody()#</p>
          </cfif>

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

          <form class="form-horizontal" action="#buildURL( 'common:security.dologin' )#" method="post">
            <input type="hidden" name="origin" value="#getSubsystem()#">

            <div class="form-group">
              <label for="username" class="col-lg-4 control-label">#i18n.translate('username')#</label>
              <div class="col-lg-8">
                <input type="text" class="form-control" name="username" id="username" placeholder="#i18n.translate('placeholder-username')#">
              </div>
            </div>
            <div class="form-group">
              <label for="password" class="col-lg-4 control-label">#i18n.translate('password')#</label>
              <div class="col-lg-8">
                <input type="password" class="form-control" name="password" id="password" placeholder="#i18n.translate('placeholder-password')#">
              </div>
            </div>
            <div class="form-group">
              <div class="col-lg-offset-4 col-lg-8">
                <button type="submit" class="btn btn-primary">#i18n.translate('log-in')#</button>
              </div>
            </div>
          </form>
        </div>
      </div>
    </div>
    <div class="clearfix"></div>
  </div>
</cfoutput>