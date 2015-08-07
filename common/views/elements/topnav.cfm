<cfprocessingdirective pageEncoding="utf-8" />

<cfif getSection() eq 'security' and
      getItem() eq 'login'>
  <cfexit />
</cfif>

<cfoutput>
  <nav class="navbar navbar-default navbar-fixed-top" role="navigation" style="margin-bottom: 0">
    <!-- Brand and toggle get grouped for better mobile display -->
    <div class="navbar-header">
      <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
        <span class="sr-only">#i18n.translate( 'toggle-nav' )#</span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
      </button>
      <a class="navbar-brand" href="#buildURL(':')#">#i18n.translate( framework.defaultsubsystem & '-home' )#</a>
    </div>

    <ul class="nav navbar-top-links navbar-left">
      <cfloop list="#rc.topnav#" index="local.section">
        <li#( getSubsystem() eq 'home' and getSection() eq local.section )?' class="active"':''#><a href="#buildURL('home:#local.section#.default')#">#i18n.translate( local.section )#</a></li>
      </cfloop>
    </ul>

    <cfif rc.auth.isLoggedIn and structKeyExists( rc.auth, "userID" )>
      <ul class="nav navbar-top-links navbar-right">
        <li><img id="loading" src="#request.webroot#/inc/img/loading-topnav.gif" /></li>

        <cfset local.contact = entityLoadByPK( "contact", rc.auth.userID ) />
        <cfset local.role = local.contact.getSecurityRole() />
        <cfif local.role.getCanAccessAdmin()>
          <li#( getSubsystem() eq 'admin' )?' class="active"':''#><a href="#buildURL('admin:')#"><i class="fa fa-home"></i> #i18n.translate('admin:main.default')#</a></li>
        </cfif>
        <li class="dropdown">
          <a href="##" class="dropdown-toggle" data-toggle="dropdown">
            <i class="fa fa-life-ring"></i>
            #i18n.translate( 'help' )#
            <i class="fa fa-caret-down"></i>
          </a>
          <ul class="dropdown-menu">
            <li><a href="#buildURL('help.faq')#"><i class="fa fa-question fa-fw"></i> #i18n.translate('help.faq')#</a></li>
            <li><a href="#buildURL('help.contact')#"><i class="fa fa-phone fa-fw"></i> #i18n.translate('help.contact')#</a></li>
            <li><a href="#buildURL('help.about')#" id="about-app"><i class="fa fa-info-circle fa-fw"></i> #i18n.translate('help.about')#</a></li>
          </ul>
        </li>
        <li class="dropdown">
          <a href="##" class="dropdown-toggle" data-toggle="dropdown">
            <i class="fa fa-user"></i>
            #rc.auth.user.getFirstname()#
            <i class="fa fa-caret-down"></i>
          </a>
          <ul class="dropdown-menu">
            <li><a href="#buildURL('profile.default')#"><i class="fa fa-user fa-fw"></i> #i18n.translate('profile.default')#</a></li>
            <!--- <li><a href="#buildURL('profile.settings')#"><i class="fa fa-cog fa-fw"></i> #i18n.translate('profile.settings')#</a></li> --->
            <li class="divider"></li>
            <li><a href="#buildURL('common:security.doLogout')#"><i class="fa fa-power-off fa-fw"></i> #i18n.translate('log-out')#</a></li>
          </ul>
        </li>
      </ul>
    </cfif>

    <div class="navbar-default sidebar" role="navigation">
      <div class="collapse sidebar-nav navbar-collapse">#view( "common:elements/subnav" )#</div>
    </div>
  </nav>
</cfoutput>