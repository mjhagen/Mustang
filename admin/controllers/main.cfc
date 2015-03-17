<cfcomponent extends="crud" output="false">
  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="loc">
    <cfset var q = directoryList( fw.root, true, 'query' ) />
    <cfset var ext = "" />
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
        AND     name <> '.DS_Store'
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
</cfcomponent>