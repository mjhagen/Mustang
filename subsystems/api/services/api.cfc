component accessors=true {
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

    var customArgs = duplicate( local );

    structDelete( customArgs, "this" );
    structDelete( customArgs, "arguments" );

    structAppend( customArgs, missingMethodArguments, true );

    setQuerySettings({
      "cacheable" = customArgs.cacheable,
      "maxResults" = customArgs.maxResults,
      "offset" = customArgs.offset
    });

    evaluate( "__#missingMethodName#(argumentCollection=customArgs)" );

    var result = ormExecuteQuery( getQuery(), getParams(), false, getQuerySettings());

    return result;
  }

  public struct function getDebugInfo() {
    return {
      "hql" = getQuery(),
      "settings" = getQuerySettings(),
      "where" = getParams()
    };
  }
}