component accessors=true {
  property utilityService;
  property numeric recordCount;
  property string query;
  property struct debugInfo;
  property struct params;
  property struct querySettings;

  public component function init() {
    return this;
  }

  public array function onMissingMethod( string missingMethodName, struct missingMethodArguments ) {
    // defaults
    var cacheable = false;
    var maxResults = 25;
    var offset = 0;
    var basicsOnly = false;
    var customArgs = duplicate( local );

    structDelete( customArgs, "this" );
    structDelete( customArgs, "arguments" );

    structAppend( customArgs, missingMethodArguments, true );

    variables.querySettings = {
      "cacheable" = customArgs.cacheable,
      "maxResults" = customArgs.maxResults,
      "offset" = customArgs.offset
    };

    utilityService.cfinvoke( this, "__#missingMethodName#", customArgs );

    var result = ormExecuteQuery( variables.query, variables.params, false, variables.querySettings );

    return result;
  }

  public struct function getDebugInfo() {
    return {
      "hql" = variables.query,
      "settings" = variables.querySettings,
      "where" = variables.params
    };
  }
}