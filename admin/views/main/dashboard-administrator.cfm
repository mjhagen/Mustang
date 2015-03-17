<!--- cfloop from="1" to="1000" index="n">
  <cfset product = entityNew( "product" ) />
  <cfset entitySave( product ) />
  <cfset product.setPrice( randRange( 10, 1000 )) />
</cfloop --->

<cfquery name="test" result="r">
  SELECT  *
  FROM    product
  WHERE   (data::json->>'price')::float
            BETWEEN <cfqueryparam cfsqltype="cf_sql_float" value="#randRange( 10, 500 )#" />
                AND <cfqueryparam cfsqltype="cf_sql_float" value="#randRange( 500, 1000 )#" />
</cfquery>

<cfdump var="#r.recordCount#" />

<cfdump var="#r#" />
