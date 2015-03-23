<cfoutput>
  <div class="modal-header">
    <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">#rc.i18n.translate( 'close' )#</span></button>
    <h5 class="modal-title text-muted">#rc.modalContent.title#</h5>
  </div>
  <div class="modal-body">
    <div class="row">
      <div class="col-lg-5 text-center"><img width="200px" style="margin-top:30%;" src="#request.webroot#/cfimage/?src=logo-default.gif" /></div>
      <div class="col-lg-7 pull-right" style="border-left:1px solid silver;">#rc.util.parseStringVariables( rc.modalContent.body, { "version" = request.version })#</div>
    </div>
  </div>
  <div class="modal-footer">
    <cfloop array="#rc.modalContent.buttons#" index="button">
      <button type="button" class="btn #button.classes#">#rc.i18n.translate( button.title )#</button>
    </cfloop>
  </div>
</cfoutput>
