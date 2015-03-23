<cfcomponent output="false">
  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="deleteLabel" access="remote" output="false">
    <cfargument name="labelid" />

    <cfset var label = entityLoadByPK( "label", arguments.labelid ) />

    <cftry>
      <cfset entityDelete( label ) />
      <cfcatch></cfcatch>
    </cftry>

    <cfset ORMFlush() />

    <cfset util.updatePopulateFile() />
    <cfset application["translations"] = {} />
  </cffunction>

  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="saveTranslations" access="remote" output="false" returnType="struct" returnFormat="json">
    <cfargument name="translations" />

    <cfset var languages = entityLoad( "language" ) />
    <cfset var newTranslation = "" />

    <cfset translations = deserializeJSON( arguments.translations ) />

    <cfif structKeyExists( translations, "label" )>
      <cfset var newLabel = entityNew( "label" ) />
      <cfset newLabel.setName( translations.label ) />
      <cfset entitySave( newLabel ) />
    <cfelseif structKeyExists( translations, "labelid" )>
      <cfset var oldLabel = entityLoadByPK( "label", translations.labelid ) />
      <cfset var newLabel = entityNew( "label" ) />
      <cfset newLabel.setName( oldLabel.getName()) />
      <cfset entityDelete( oldLabel ) />
      <cfset ORMFlush() />
      <cfset entitySave( newLabel ) />
    <cfelse>
      <cfreturn />
    </cfif>

    <cfloop array="#translations.translations#" index="translation">
      <cfif not len( trim( translation.translated ))>
        <cfcontinue />
      </cfif>
      <cfset newTranslation = entityNew( "translation" ) />
      <cfset entitySave( newTranslation ) />

      <cfset newTranslation.setLanguage( entityLoadByPK( "language", translation.languageid )) />
      <cfset newTranslation.setLabel( newLabel ) />
      <cfset newTranslation.setTranslated( translation.translated ) />
    </cfloop>

    <cfset ORMFlush() />
    <cfset application["translations"] = {} />

    <cfset util.updatePopulateFile() />

    <cfreturn { "labelid" = newLabel.getID(), "name" = newLabel.getName()} />
  </cffunction>
</cfcomponent>