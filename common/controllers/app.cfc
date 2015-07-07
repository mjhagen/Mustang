<cfcomponent>
  <cffunction name="init" output="false">
    <cfargument name="fw" type="component" required="true" />
    <cfset variables.fw = fw />
    <cfreturn this />
  </cffunction>

  <cffunction name="error">
    <cfargument name="rc" />

    <cfif rc.debug>
      <cfcontent reset="true" />
      <cfdump var="#cgi#" expand="false" />
      <cfdump var="#request.exception#" />
      <cfabort />
    </cfif>

    <cfheader statuscode="500" statustext="Internal Server Error" />
    <cfset rc.dontredirect = true />

    <cfset var mailSubject = "Error #cgi.server_name#" />

    <cfif isDefined( "request.exception.cause.message" )>
      <cfset mailSubject &= " - " & request.exception.cause.message />
    </cfif>

    <cfmail from="#rc.config.debugEmail#" to="#rc.config.debugEmail#" subject="#mailSubject#" type="html">
      <cfdump var="#cgi#" />
      <cfdump var="#request.exception#" />
    </cfmail>
  </cffunction>

  <cffunction name="loc">
    <cfset var q = directoryList( request.root, true, 'query' ) />
    <cfset var ext = "" />
    <cfset var cont = false />
    <cfset var files = {} />
    <cfset var filecontents = "" />
    <cfset var countFile = true />
    <cfset var sep = server.os.name contains 'windows' ? '\' : '/' />
    <cfset var filter = {
      hidedirs = [
        '.svn',
        '.DS_Store',
        '__MACOSX',
        'WEB-INF',
        'CFIDE',
        'plugins',
        'docs',
        'stats',
        'diagram',
        'org'
      ],
      exts = "js,txt,cfg,cfm,cfc,css,sql,ini,json,config,hbmxml",
      filecontains = ""
    } />

    <cfquery name="rc.lastmod" dbtype="query" maxRows="10">
      SELECT    *
      FROM      q
      WHERE     [type] = 'File'

      <cfloop array="#filter.hidedirs#" index="local.dir">
        AND NOT directory LIKE '%#sep##local.dir#'
        AND NOT directory LIKE '%#sep##local.dir##sep#'
        AND NOT directory LIKE '%#sep##local.dir##sep#%'
      </cfloop>

      ORDER BY  datelastmodified DESC
    </cfquery>

    <cfloop query="q">
      <cfif type eq "dir" or
            left( name, 1 ) eq '.' or
            not listFind( filter.exts, listLast( name, '.' ))>
        <cfcontinue />
      </cfif>

      <cfset cont = false />
      <cfloop array="#filter.hidedirs#" index="local.dir">
        <cfif directory eq local.dir or
              directory contains "#sep##local.dir##sep#" or
              name eq local.dir>
          <cfset cont = true />
          <cfbreak />
        </cfif>
      </cfloop>

      <cfif cont>
        <cfcontinue />
      </cfif>

      <cfif type eq "file">
        <cfset ext = listLast( name, '.' ) />
        <cfif not structKeyExists( files, ext )>
          <cfset files[ext] = 0 />
        </cfif>
        <cfset filecontents = fileRead( directory & sep & name ) />
        <cfif len( trim( filter.filecontains ))>
          <cfset countFile = false />
          <cfloop list="#filter.filecontains#" index="word">
            <cfif findNoCase( word, filecontents )>
              <cfset countFile = true />
              <cfbreak />
            </cfif>
          </cfloop>
        </cfif>
        <cfif countFile>
          <cfset files[ext] += listLen( filecontents, chr( 10 )) />
        </cfif>
      </cfif>
    </cfloop>

    <cfset rc.files = files />
  </cffunction>

  <cffunction name="docs">
    <cfset rc.docsPath = "#rc.config.fileUploads#/docs" />

    <cfset var coldDocService = new colddoc.ColdDoc() />
    <cfset var strategy = new colddoc.strategy.api.HTMLAPIStrategy( rc.docsPath, "ColdDoc 1.0 Alpha" ) />

    <cfset coldDocService.setStrategy( strategy ) />
    <cfset coldDocService.generate( request.root, "" ) />
  </cffunction>
</cfcomponent>