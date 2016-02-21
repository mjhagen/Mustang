<cfoutput>
  <div class="modal-header">
    <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">#request.i18n.translate( 'close' )#</span></button>
    <h3 class="modal-title">#rc.modalContent.title#</h3>
  </div>
  <div class="modal-body">
    #rc.modalContent.body#
  </div>
  <div class="modal-footer">
    <cfloop array="#rc.modalContent.buttons#" index="button">
      <button type="button" class="btn #button.classes#">#request.i18n.translate( button.title )#</button>
    </cfloop>
  </div>
</cfoutput>