<cfcomponent output="false">
<cfscript>
  this.name = "diagram";
  this.title = "Database Diagram";
  this.modelpath = "../../model";
  this.mappings["/model"] = expandPath( this.modelpath );
</cfscript>

  <cffunction name="onRequestStart">
    <cfset request.title = this.title />
    <cfset request.modelpath = this.modelpath />
  </cffunction>
</cfcomponent>