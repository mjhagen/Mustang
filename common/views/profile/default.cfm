<cfset local.iconTrue = '<i class="fa fa-check-circle-o" style="color:green;"></i>' />
<cfset local.iconFalse = '<i class="fa fa-circle-o" style="color:red;"></i>' />

<cfoutput>

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

  <form action="#buildURL( '.save' )#" method="post" class="form-horizontal">
    <div class="form-group">
      <label class="col-lg-3 control-label">#i18n.translate('username')#</label>
      <div class="col-lg-9">
        <input class="form-control" type="text" disabled="disabled"
          value="#rc.data.getUsername()#" />
      </div>
    </div>
    <hr />

    <div class="form-group">
      <label for="firstname" class="col-lg-3 control-label">#i18n.translate('firstname')#</label>
      <div class="col-lg-9">
        <input tabindex="2" class="form-control" id="firstname" placeholder="#i18n.translate('placeholder-firstname')#" name="firstname" type="text"
          value="#rc.data.getFirstname()#" />
      </div>
    </div>
    <div class="form-group">
      <label for="infix" class="col-lg-3 control-label">#i18n.translate('infix')#</label>
      <div class="col-lg-9">
        <input tabindex="3" class="form-control" id="infix" placeholder="#i18n.translate('placeholder-infix')#" name="infix" type="text"
          value="#rc.data.getinfix()#" />
      </div>
    </div>
    <div class="form-group">
      <label for="lastname" class="col-lg-3 control-label">#i18n.translate('lastname')#</label>
      <div class="col-lg-9">
        <input tabindex="4" class="form-control" id="lastname" placeholder="#i18n.translate('placeholder-lastname')#" name="lastname" type="text"
          value="#rc.data.getlastname()#" />
      </div>
    </div>
    <div class="form-group">
      <label for="email" class="col-lg-3 control-label">#i18n.translate('email')#</label>
      <div class="col-lg-9">
        <input tabindex="5" class="form-control" id="email" placeholder="#i18n.translate('placeholder-email')#" name="email" type="text"
          value="#rc.data.getemail()#" />
      </div>
    </div>
    <div class="form-group">
      <label for="phone_mobile" class="col-lg-3 control-label">#i18n.translate('phone_mobile')#</label>
      <div class="col-lg-9">
        <input tabindex="6" class="form-control" id="phone_mobile" placeholder="#i18n.translate('placeholder-phone_mobile')#" name="phone_mobile" type="text"
          value="#rc.data.getphone_mobile()#" />
      </div>
    </div>
    <div class="form-group">
      <label for="phone_direct" class="col-lg-3 control-label">#i18n.translate('phone_direct')#</label>
      <div class="col-lg-9">
        <input tabindex="7" class="form-control" id="phone_direct" placeholder="#i18n.translate('placeholder-phone_direct')#" name="phone_direct" type="text"
          value="#rc.data.getphone_direct()#" />
      </div>
    </div>

		<div class="form-group">
	    <label for="photo" class="col-lg-3 control-label">#i18n.translate('photo')#</label>
	    <div class="col-lg-9">
				<div class="fileinput">

		      <cfset local.showUploadButton = true />
		      <input type="hidden" name="photo" value="" />

		      <span role="button" class="btn btn-primary fileinput-button"#local.showUploadButton?'':' style="display:none;"'#>
		        <i class="fa fa-plus"></i>
		        <span>#i18n.translate( "select-file" )#</span>
		        <input type="file" data-name="photo" />
		      </span>

		      <div class="progress" style="margin-top:5px; display:none;">
		        <div class="progress-bar progress-bar-success" role="progressbar" aria-valuemin="0" aria-valuemax="100" style="width: 0%"></div>
		      </div>

		      <div#local.showUploadButton?' class="alert" style=" display:none;"':' class="alert alert-success"'#></div>
		    </div>
	    </div>
    </div>
    <hr />
    <div class="form-group">
      <div class="col-lg-offset-3 col-lg-9">
        <a href="javascript:history.go(-1)" class="btn btn-default btn-cancel">#i18n.translate( 'cancel' )#</a>
        <button type="submit" class="btn btn-primary">#i18n.translate( 'save' )#</button>
      </div>
    </div>
  </form>
</cfoutput>