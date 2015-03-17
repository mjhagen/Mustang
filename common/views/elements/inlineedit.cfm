<cfprocessingdirective pageEncoding="utf-8" />

<cfparam name="local.formappend" default="" />
<cfparam name="local.formprepend" default="" />
<cfparam name="local.fieldOverride" default="" />
<cfparam name="local.namePrepend" default="#rc.namePrepend#" />
<cfparam name="local.dialogName" default="#createUUID()#" />

<cfoutput>
  <div class="panel panel-default" id="#local.dialogName#">
    <div class="panel-body">#view( "common:elements/edit", local )#</div>
  </div>
</cfoutput>