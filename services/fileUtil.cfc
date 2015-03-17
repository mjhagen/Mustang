<cfcomponent>
  <cffunction name="init">
    <cfreturn this />
  </cffunction>

  <cffunction name="download">
    <cfargument name="filePath" required="true" />
    <cfargument name="deleteFile" default="false" />
    <cfargument name="fileName" />
    <cfargument name="disposition" default="attachment" />

    <cfif isNull( fileName )>
      <cfset fileName = listLast( filePath, "/" ) />
    </cfif>

    <cfheader name="Content-Disposition" value="#disposition#; filename=#fileName#" /><cfcontent type="application/pdf" file="#filePath#" reset="true" deletefile="#deleteFile#" /><cfabort />
  </cffunction>
</cfcomponent>