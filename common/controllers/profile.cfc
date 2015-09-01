<cfcomponent output="false">
  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="init" returntype="any" access="public" output="false">
  	<cfargument name="fw" type="component" required="true" />
  	<cfset variables.fw = fw />
    <cfreturn this />
  </cffunction>

  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="before">
    <cfargument name="rc" />

    <cfset rc.subnav = "profile" />
    <cfset rc.subsubnav = "password" />
  </cffunction>

  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="default">
    <cfset rc.data = entityLoadByPK( "contact", rc.auth.userid ) />
  </cffunction>

  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="save">
    <cftransaction>
    <cfset var currentUser = entityLoadByPK( "contact", rc.auth.userid ) />

    <cfparam name="rc.firstname" default="" />
    <cfparam name="rc.infix" default="" />
    <cfparam name="rc.lastname" default="" />
    <cfparam name="rc.email" default="" />
    <cfparam name="rc.phone" default="" />
    <cfparam name="rc.photo" default="" />

    <cfset formFields = {
      "firstname"     = rc.firstname,
      "infix"         = rc.infix,
      "lastname"      = rc.lastname,
      "email"         = rc.email,
      "phone"         = rc.phone,
      "contactID"     = currentUser.getID()
	  }>

		<cfif len( trim( rc.photo ) )>
      <cfset formFields["photo"] = rc.photo>
		</cfif>

    <cfset currentUser.save( formFields )>
      <cftransaction action="commit" />
    </cftransaction>

    <cfset session.auth.user = entityLoadByPK( "contact", rc.auth.userID ) />
    <cfset session.alert = {
      class = 'success',
      text  = rc.i18n.translate('saved-text')
	  }>

    <cfset fw.redirect( '.default' ) />
  </cffunction>

  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="newpassword">
    <cfargument name="rc" />

    <cfparam name="rc.newPassword" default="#rc.util.generatePassword( 8 )#" />

    <cfif len( trim( rc.newPassword )) lt 8>
      <cflock scope="session" timeout="5">
        <cfset session.alert = {
          "class" = "danger",
          "text"  = "password-change-fail-tooshort"
        } />
      </cflock>
      <cfset fw.redirect( '.password' ) />
    </cfif>

    <cfset var currentUser = entityLoadByPK( "contact", rc.auth.userid ) />
    <cfif isDefined( "currentUser" )>
      <cfset currentUser.setPassword( currentUser.hashPassword( rc.newPassword )) />
      <cflock scope="session" timeout="5">
        <cfset session.alert = {
          "class"           = "success",
          "text"            = "password-changed",
          "stringVariables" = { "newPassword" = rc.newPassword }
        } />
      </cflock>
    <cfelse>
      <cflock scope="session" timeout="5">
        <cfset session.alert = {
          "class"           = "danger",
          "text"            = "password-change-failed"
        } />
      </cflock>
    </cfif>

    <cfset fw.redirect( '.password' ) />
  </cffunction>
</cfcomponent>