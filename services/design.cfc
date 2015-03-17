<cfcomponent>
  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="init">
    <cfreturn this />
  </cffunction>

  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="load">
    <cfset var tempColor = "" />
    <cfset var design = {
      "logo"    = "",
      "font"    = {
        "family" = "",
        "size" = "",
        "color" = ""
      },
      "colors"  = [
        "##052D57",
        "##5196E0",
        "##6781A4",
        "##D98876",
        "##DC3725"
      ]
    } />

    <cfif not structKeyExists( request, "context" ) or
          not structKeyExists( request.context, "currentWebsite" )>
      <cfreturn design />
    </cfif>

    <cfset var website = request.context.currentWebsite />

    <cfset design["logo"] = website.getLogo() />
    <cfif not structKeyExists( design, "logo" )>
      <cfset design["logo"] = "" />
    </cfif>

    <cfloop from="1" to="5" index="i">
      <cftry>
        <cfset tempColor = evaluate( "website.getColor#i#()" ) />
        <cfcatch>
          <cfset tempColor = design.colors[i] />
        </cfcatch>
      </cftry>
      <cfif not isNull( tempColor ) and len( trim( tempColor ))>
        <cfset design.colors[i] = tempColor />
      </cfif>
      <cfif len( trim( design.colors[i] )) eq 6>
        <cfset design.colors[i] = "##" & design.colors[i] />
      </cfif>
    </cfloop>

    <cfset local.fontCustomized = false />
    <cfif not isNull( website.getFontFamily()) and len( trim( website.getFontFamily()))><cfset design["font"]["family"] = website.getFontFamily() /><cfset local.fontCustomized = true /></cfif>
    <cfif not isNull( website.getFontSize()) and len( trim( website.getFontSize()))><cfset design["font"]["size"] = website.getFontSize() /><cfset local.fontCustomized = true /></cfif>
    <cfif not isNull( website.getFontColor()) and len( trim( website.getFontColor()))><cfset design["font"]["color"] = website.getFontColor() /><cfset local.fontCustomized = true /></cfif>

    <cfif not local.fontCustomized>
      <cfset structDelete( design, "font" ) />
    </cfif>

    <cfreturn design />
  </cffunction>
</cfcomponent>