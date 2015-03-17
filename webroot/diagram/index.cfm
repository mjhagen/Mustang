<cfsetting enableCFoutputOnly="yes">

<cfset root = expandPath( request.modelpath ) />

<cfdirectory action="list" directory="#root#" name="ls" recurse="yes" />
<cfquery dbtype="query" name="ls">
  SELECT    directory, type, name, '' AS cfc, '' AS package
  FROM      ls
  WHERE     name LIKE '%.cfc'
</cfquery>

<cfloop query="ls">
  <cfset querySetCell( ls, "package", "model" & replaceList( replaceNoCase( directory, root, "", "one" ), "/,\", ".,." ), currentRow ) />

  <cfif type eq "File">
    <cfset querySetCell( ls, "cfc", package & "." & listFirst( name, "." ), currentRow ) />
  <cfelse>
    <cfset querySetCell( ls, "package", package & "." & name, currentRow ) />
  </cfif>
</cfloop>

<cfquery dbtype="query" name="ls">
  SELECT    package, cfc
  FROM      ls
  ORDER BY  package
</cfquery>

<cfsavecontent variable="body">
  <cfoutput query="ls" group="package">
    <fieldset id="_#hash( package )#" class="wrap">
      <legend>#package#</legend>

      <cfoutput>
        <cfset class = createObject( "component", cfc ) />
        <cfset classInfo = getMetaData( class ) />

        <div class="box col1">
          <a name="#cfc#"></a>
          <h2 style="text-align:center;">#listLast( cfc, '.' )#</h2>
          <cfif structKeyExists( classInfo, "hint" ) and len( trim( classInfo.hint ))>
            <h4>#classInfo.hint#</h4>
          </cfif>
          <cfif structKeyExists( classInfo, "extends" ) and
                structKeyExists( classInfo.extends, "name" ) and
                classInfo.extends.name neq "WEB-INF.cftags.component">
            <em>&rarr; <a href="###classInfo.extends.name#">#listLast( classInfo.extends.name, '.' )#</a></em>
          </cfif>
          <cfif structKeyExists( classInfo, "properties" ) and arrayLen( classInfo.properties )>
            <dl class="properties">
              <cfloop array="#classInfo.properties#" index="property">
                <dt><cfif structKeyExists( property, "access" ) and property.access eq "private">-<cfelse>+</cfif> #property.name#<cfif structKeyExists( property, "type" )><span class="type">:<cfif property.type contains ""><a href="###property.type#">#property.type#</a><cfelse>#property.type#</cfif></span></cfif></dt>
                <dd><cfif structKeyExists( property, "hint" ) and len( trim( property.hint ))>#property.hint#</cfif></dd>
              </cfloop>
            </dl>
          </cfif>

          <cfif structKeyExists( classInfo, "functions" ) and arrayLen( classInfo.functions )>
            <div class="methods">
              <cfloop array="#classInfo.functions#" index="method">
                <cfif structKeyExists( method, "access" ) and method.access eq "private">-<cfelse>+</cfif> #lCase( method.name )#()<cfif structKeyExists( method, "returntype" )>:<span class="type"><cfif method.returntype contains ""><a href="###method.returntype#">#method.returntype#</a><cfelse>#method.returntype#</cfif></span></cfif><br />
              </cfloop>
            </div>
          </cfif>
        </div>
      </cfoutput>
    </fieldset>

    <br style="page-break-after:always" />
  </cfoutput>
</cfsavecontent>

<cfset body = REreplace( body, "[\s]+", " ", "all" ) />

<cfsetting enableCFoutputOnly="no"><!DOCTYPE html>

<html>
  <head>
    <title><cfoutput>#request.title#</cfoutput></title>
    <style>
      *{ font-family: Helvetica; font-size: 11px; }

      a,a:visited,a:active,a:hover{ color : #ff0069 }

      h2, legend{ font-size: 24px; margin: 5px 0; }
      h4{ font-size: 13px; margin: 0 10px; }

      legend{ color: red; }

      .wrap
      {
        padding-bottom : 35px;
      }

      em{ margin-left: 10px; }

      dd{ margin: 0 0 0px 20px; color: blue; font-size: 12px; }

      .box{
        float: left;
        width: 320px;
        margin: 5px;

        -webkit-box-shadow: 0px 2px 3px #333333;
        -webkit-border-radius: 5px;
        border-radius: 5px;

        background: -webkit-gradient(
            linear,
            left bottom,
            left top,
            color-stop(0.66, rgb(242,242,242)),
            color-stop(0.95, rgb(200,200,200))
        );

        text-shadow: 0px 2px 8px #fff;
        filter: dropshadow(color=#fff, offx=0, offy=2);
      }

      .properties, .methods
      {
        border:1px solid silver;
        padding: 5px;
        background-color: whitesmoke;
        margin: 5px;
      }

      .type
      {
        color: gray;
      }
    </style>
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js"></script>
    <script src="masonry.js"></script>
  </head>
  <body>
    <cfoutput>#body#</cfoutput>
    <script type="text/javascript">
      $('.wrap').masonry({
          singleMode: true,
          itemSelector: '.box'
      });
    </script>
  </body>
</html>

<cfsetting showDebugoutput="false" />