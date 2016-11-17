<cfoutput>
  <div class="row">
    <div class="col-lg-5 text-center"><img width="200px" style="margin-top:30%;" src="#request.webroot#/inc/img/logo-default.gif" /></div>
    <div class="col-lg-7 pull-right" style="border-left:1px solid silver;">#rc.util.parseStringVariables( rc.modalContent.body, { "version" = request.version })#</div>
  </div>
</cfoutput>
