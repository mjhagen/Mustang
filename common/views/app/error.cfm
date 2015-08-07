<cfset icons = ['frown-o','bomb','stethoscope','thumbs-down'] />

<cfoutput>
  <div class="container">
    <div class="jumbotron">
      <h1><i class="fa fa-#icons[randRange(1,4)]#"></i> Systeemfout</h1>
      <p>Deze melding is doorgegeven aan de ontwikkelaar van dit systeem en de fout zal zo snel mogelijk worden opgelost.</p>
      <p><a href="javascript:history.back();" class="btn btn-primary btn-lg" role="button">Terug</a></p>
    </div>

    <div class="well">
      <cftry>
        <h4>Message:</h4>
        <p class="text-muted">#request.exception.cause.message#</p>
        <cfcatch></cfcatch>
      </cftry>

      <cftry>
        <h4>Detail:</h4>
        <p class="text-muted">#request.exception.cause.detail#</p>
        <cfcatch></cfcatch>
      </cftry>

      <cftry>
        <h4>File:</h4>
        <p class="text-muted">#request.exception.TagContext[1].template# at line #request.exception.TagContext[1].line#</p>
        <cfcatch></cfcatch>
      </cftry>
    </div>

    <cfdump var="#request.exception#" expand="false" />
  </div>
</cfoutput>