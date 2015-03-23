<cfcomponent output="false">
  <cfprocessingdirective pageEncoding="utf-8" />

  <cfset variables.languageFileName = "" />

  <cffunction name="init">
    <cfargument name="locale" default="nl-NL" />
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
    </cfif>

    <cfset result = parseStringVariables( translation, stringVariables ) />

    <cfreturn result />
  </cffunction>

  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="cacheRead" output="false">
    <cfargument name="label" default="" />
    <cfargument name="languageid" default="#session.languageid#" />
    <cfargument name="reload" default="false" />

    <cfset var result = "" />

    <!--- SEARCH CACHE FOR LABEL: --->
    <cflock name="fw1_#application.applicationName#_translations_#languageid#" type="exclusive" timeout="30">
      <cfif not reload and
            structKeyExists( application, "translations" ) and
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

      <cfif not structKeyExists( application.translations[languageid], label ) or
            reload>
        <cfset local.lanStruct = deserializeJSON( fileRead( '#request.root#/i18n/#languageFileName#', 'utf-8' )) />
        <cfif structKeyExists( local.lanStruct, label )>
          <cfset application.translations[languageid][label] = local.lanStruct[label] />
        </cfif>
      </cfif>

      <cfif structKeyExists( application.translations[languageid], label )>
        <cfset result = application.translations[languageid][label] />
      </cfif>
    </cflock>

    <!--- replace {label} with whatever comes out of translate( 'label' ) --->
    <cfloop array="#REMatchNoCase( "{[^}]+}", result )#" index="local.label">
      <cfset result = replaceNoCase( result, local.label, translate( mid( local.label, 2, len( local.label ) - 2 ))) />
    </cfloop>

    <cfreturn request.context.util.CapFirst( result ) />
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