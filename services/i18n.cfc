<cfcomponent output="false">
  <cfprocessingdirective pageEncoding="utf-8" />

  <cfset variables.languageFileName = "" />

  <cffunction name="init">
    <cfargument name="locale" default="#request.context.config.defaultLanguage#" />
    <cfset variables.languageFileName = locale & ".json" />
    <cfreturn this />
  </cffunction>

  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="translate" returnType="string" access="public" output="false">
    <cfargument name="label" default="" />
    <cfargument name="languageid" default="" />
    <cfargument name="alternative" default="#label#" />
    <cfargument name="stringVariables" default="#{}#" required="false" type="struct" />
    <cfargument name="nospan" default="true" required="false" />
    <cfargument name="capFirst" default="true" required="false" />

    <cfif not structKeyExists( request, "infLoopGuard" )>
      <cfset request.infLoopGuard = 0 />
    </cfif>

    <cfset request.infLoopGuard++ />

    <cfif request.infLoopGuard gt 4>
      <cfreturn alternative />
    </cfif>

    <cfset var result = "" />
    <cfset var usecache = request.context.config.appIsLive />
    <cfset var translation = "" />

    <cfif structKeyExists( url, "reload" )>
      <cfset usecache = false />
    </cfif>

    <cfif label eq "" and alternative eq "">
      <cfset translation = "Please provide a label to translate." />
    <cfelse>
      <cfset translation = cacheRead( label, languageid, !usecache ) />
    </cfif>

    <cfif not len( trim( translation ))>
      <cfset translation = alternative />

      <!--- Try some default translation options on FQAs --->
      <cfif listLen( label, ":" ) eq 2 and listLen( label, "." ) eq 2>
        <cfset var subsystem  = listFirst( label, ":" ) />
        <cfset var section    = listFirst( listRest( label, ":" ), "." ) />
        <cfset var item       = listRest( listRest( label, ":" ), "." ) />

        <cfif label eq "#subsystem#:#section#.default">
          <cfset translation = "{#subsystem#:#section#}" />
        </cfif>

        <cfif label eq "#subsystem#:#section#.view">
          <cfset translation = "{#section#}" />
        </cfif>

        <cfif label eq "#subsystem#:#section#.edit">
          <cfset translation = "{btn-edit} {#section#}" />
        </cfif>

        <cfif label eq "#subsystem#:#section#.new">
          <cfset translation = "{btn-new} {#section#}" />
        </cfif>

        <cfif listFirst( label, "-" ) eq "btn">
          <cfset translation = "{btn-#item#} {#section#}" />
        </cfif>
      <cfelseif listLen( label, ":" ) eq 2>
        <cfset translation = "{#listLast( label, ':' )#s}" />
      <cfelseif listLen( label, "-" ) gte 2 and listFirst( label, "-" ) eq "placeholder">
        <cfset translation = "{placeholder} {#listRest( label, '-' )#}" />
      </cfif>
    </cfif>

    <cfset result = parseStringVariables( translation, stringVariables ) />

    <!--- replace {label} with whatever comes out of translate( 'label' ) --->
    <cfloop array="#REMatchNoCase( '{[^}]+}', result )#" index="local.label">
      <cfset result = replaceNoCase( result, local.label, translate( mid( local.label, 2, len( local.label ) - 2 ))) />
    </cfloop>

    <cfset structDelete( request, "infLoopGuard" ) />

    <cfreturn capFirst ? request.context.util.capFirst( result ) : result  />
  </cffunction>

  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="cacheRead" output="false">
    <cfargument name="label" default="" />
    <cfargument name="languageid" default="#session.languageid#" />
    <cfargument name="reload" default="false" />

    <cfset var result = "" />

    <!--- SEARCH CACHE FOR LABEL: --->
    <cflock name="fw1_#application.applicationName#_translations_#languageid#" type="exclusive" timeout="30">
      <cfif reload>
        <cfset structDelete( application, "translations" ) />
      </cfif>

      <cfif structKeyExists( application, "translations" ) and
            structKeyExists( application.translations, languageid ) and
            structKeyExists( application.translations[languageid], label )>
        <cfreturn application.translations[languageid][label] />
      </cfif>

      <cfif not structKeyExists( application, "translations" )>
        <cfset application.translations = {} />
      </cfif>

      <cfif not structKeyExists( application.translations, languageid )>
        <cfset application.translations[languageid] = {} />
      </cfif>

      <cfif not structKeyExists( application.translations[languageid], label )>
        <cfset local.lanStruct = deserializeJSON( fileRead( '#request.root#/i18n/#languageFileName#', 'utf-8' )) />
        <cfif structKeyExists( local.lanStruct, label )>
          <cfset application.translations[languageid][label] = local.lanStruct[label] />
        </cfif>
      </cfif>

      <cfif structKeyExists( application.translations[languageid], label )>
        <cfset result = application.translations[languageid][label] />
      </cfif>
    </cflock>

    <cfreturn result />
  </cffunction>

  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="parseStringVariables" output="false">
    <cfargument name="stringToParse" type="string" required="true" />
    <cfargument name="stringVariables" type="struct" default="#{}#" required="false" />

    <cfif not isDefined( "stringVariables" ) or not structCount( stringVariables )>
      <cfreturn stringToParse />
    </cfif>

    <cfloop collection="#stringVariables#" item="local.key">
      <cfset stringToParse = replaceNoCase( stringToParse, '###local.key###', stringVariables[local.key] ) />
    </cfloop>

    <cfreturn stringToParse />
  </cffunction>
</cfcomponent>