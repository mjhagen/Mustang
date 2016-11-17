<cfprocessingdirective pageEncoding="utf-8" />

<cfif getSection() eq 'security' and
      getItem() eq 'login'>
  <cfexit />
</cfif>

<cfoutput>
  <nav class="navbar navbar-light bg-faded" style="margin-bottom: 15px;">
    <button class="navbar-toggler hidden-sm-up" type="button" data-toggle="collapse" data-target="##navbar-header" aria-controls="navbar-header">&##9776;</button>
    <div class="collapse navbar-toggleable-xs" id="navbar-header">
      <a class="navbar-brand" href="#buildURL(':')#">#i18n.translate( request.appName )#</a>

      <ul class="nav navbar-nav">
        <cfloop list="#rc.topnav#" index="local.section">
          <li class="nav-item#( getSection() eq local.section )?' active':''#">
            <a href="#buildURL(':#local.section#.default')#">#i18n.translate( local.section )#</a>
          </li>
        </cfloop>
      </ul>

      <cfif rc.auth.isLoggedIn and structKeyExists( rc.auth, "userID" )>
        <ul class="nav navbar-nav pull-xs-right">
          <li class="nav-item"><img id="loading" src="#request.webroot#/inc/img/loading-topnav.gif" /></li>
          <cfif rc.auth.role.canAccessAdmin>
            <li class="nav-item active">
              <a href="#buildURL(':')#"><i class="fa fa-home"></i> #i18n.translate(':main.default')#</a>
            </li>
          </cfif>
          <li class="nav-item dropdown">
            <a href="##" class="dropdown-toggle" data-toggle="dropdown">
              <i class="fa fa-life-ring"></i>
              #i18n.translate( 'help' )#
            </a>
            <ul class="dropdown-menu">
              <li><a href="#buildURL(':help.faq')#"><i class="fa fa-question fa-fw"></i> #i18n.translate('help.faq')#</a></li>
              <li><a href="#buildURL(':help.contact')#"><i class="fa fa-phone fa-fw"></i> #i18n.translate('help.contact')#</a></li>
              <li><a href="#buildURL(':help.about')#" id="about-app"><i class="fa fa-info-circle fa-fw"></i> #i18n.translate('help.about')#</a></li>
            </ul>
          </li>
          <li class="nav-item dropdown">
            <a href="##" class="dropdown-toggle" data-toggle="dropdown">
              <i class="fa fa-user"></i>
              <cfif structKeyExists( rc.auth.user, "firstname" )>#rc.auth.user.firstname#</cfif>
            </a>
            <ul class="dropdown-menu">
              <li><a href="#buildURL(':profile.default')#"><i class="fa fa-user fa-fw"></i> #i18n.translate('profile.default')#</a></li>
              <!--- <li><a href="#buildURL(':profile.settings')#"><i class="fa fa-cog fa-fw"></i> #i18n.translate('profile.settings')#</a></li> --->
              <li class="divider"></li>
              <li><a href="#buildURL(':security.doLogout')#"><i class="fa fa-power-off fa-fw"></i> #i18n.translate('log-out')#</a></li>
            </ul>
          </li>
        </ul>
      </cfif>
    </div>
  </nav>
</cfoutput>