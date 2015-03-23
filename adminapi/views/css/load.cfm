<cfoutput>
<cfif structKeyExists( rc.design, "font" )>
  body{
    <cfif len( trim( rc.design["font"]["family"] ))>font-family : #rc.design["font"]["family"]#;</cfif>
    <cfif len( trim( rc.design["font"]["size"] ))>font-size : #rc.design["font"]["size"]#;</cfif>
    <cfif len( trim( rc.design["font"]["color"] ))>color : #rc.design["font"]["color"]#;</cfif>
  }
<cfelse>
  body{
    font-family: Helvetica Neue, Helvetica, Arial, sans-serif;
    font-size:16px;
  }
</cfif>

<cfloop from="1" to="#arrayLen(rc.design.colors)#" index="local.i">
  .color#local.i#{ color: #rc.design.colors[local.i]# !important }
  .bgcolor#local.i#{ background-color: #rc.design.colors[local.i]# !important }
</cfloop>
.btn-default{
  background-color:#rc.design.colors[1]#;
  border-color:#rc.design.colors[2]#;
  color:white;
}
.btn-default .caret{
  border-top-color:white;
}
.btn-default:hover,.btn-default:active,.btn-default:visited{
  background-color:#rc.design.colors[2]#;
  border-color:#rc.design.colors[1]#;
  color:white;
}
.tooltip-inner{
  background-color:#rc.design.colors[1]#;
  max-width:250px;
}
.tooltip.bottom .tooltip-arrow{
  border-bottom-color:#rc.design.colors[1]#;
}
a:hover{
  color:#rc.design.colors[1]#
}
</cfoutput>