<cfcomponent extends="apibase">
  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="getTranslations">
    <cfset request.layout = false />

    <cfcontent file="#fw.root#/i18n/zz_en.txt" reset="true" type="application/json; charset=utf-8"  /><cfabort />
  </cffunction>
</cfcomponent>