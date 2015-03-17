<cfcomponent output="false">
  <cfscript>
    this.name = "images";
    sizes = {
      'large'   = [1000,1000],
      'medium'  = [250,250],
      'small'   = [100,100],
      'logo'    = [200,100],
      'pdflogo' = [500,300]
    };
  </cfscript>
  <cffunction name="onRequest" output="false">
    <cfset url.src = trim( url.src ) />

    <cfset basePath   = "../../../files_vgn/temp/" />
	  <cfset baseImage  = expandPath( "#basePath##listFirst( url.src, '/' )#" ) />

    <cfif not fileExists( baseImage )>
      <cffile action="readBinary" file="#expandPath( '../inc/img/noimg.png' )#" variable="fallback_image" />
      <cfcontent type="image/gif" variable="#fallback_image#" reset="true" /><cfabort />
    </cfif>

    <cfif structKeyExists( url , 'size' )>
		  <cfset imageName  = "#url.size#-#listFirst( url.src, '/' )#">
    <cfelse>
      <cfset imageName = "#listFirst( url.src, '/' )#" />
    </cfif>

    <cfset imageFile = expandPath( "#basePath##imageName#" ) />

    <cfif not fileExists( imageFile ) and ( structKeyExists( url , 'size' ) && structKeyExists( sizes , url.size ))>
      <cfset original = imageRead( baseImage )>
      <cfset imageScaleToFit( original, sizes[url.size][1], sizes[url.size][2] )>
      <cfset imageWrite( original, imageFile)>
    </cfif>

    <cfset mimeType = getPageContext().getServletContext().getMimeType( imageFile ) />

    <cfcontent file="#imageFile#" type="#mimeType#" reset="true" /><cfabort />
  </cffunction>
</cfcomponent>