<cfsilent>
  <cfsetting showdebugoutput="false" />
  <cfscript>
    verbs = listToArray( "GET,PUT,POST,DELETE" );
    entities = directoryList( expandPath( "../../model" ), true, "name", "*.cfc", "name asc" );
    hideEntities = "jsonEntity";
    uri = {
        "protocol"  = "http",
        "hostname"  = cgi.server_name,
        "api"       = "api"
      };
    baseURL = "#uri.protocol#://#uri.hostname#";
  </cfscript>
</cfsilent><cfoutput><!DOCTYPE html>
  <html>
    <head>
      <title>API Browser</title>
    </head>
    <body>
      <div class="container-fluid">
        <div class="row">
          <div class="col-sm-3 col-md-2 sidebar">
            <p><a class="btn btn-sm btn-default" href="../"><i class="fa fa-arrow-left"></i> Back to Admin</a></p>

            <hr /><h4>HTTP Verb</h4>
            <form>
              <div class="form-group">
                <select class="form-control" id="verb-selector" name="verb">
                  <option></option>
                  <cfloop array="#verbs#" index="verb">
                    <option#url.verb eq verb ? ' selected="selected"' : ''#>#verb#</option>
                  </cfloop>
                </select>
              </div>
            </form>

            <hr /><h4>Entities</h4>
            <cfloop array="#verbs#" index="verb">
              <ul class="nav nav-sidebar entities #verb#">
                <cfloop array="#entities#" index="entity">
                  <cfset entity = replaceNoCase( entity, ".cfc", "" ) />
                  <cfif listFindNoCase( hideEntities, entity )>
                    <cfcontinue />
                  </cfif>
                  <li><a href="javascript:void(0)" data-entity="#entity#">#entity#</a></li>
                </cfloop>
              </ul>
            </cfloop>
          </div>

          <div class="col-sm-9 col-sm-offset-3 col-md-10 col-md-offset-2 main">
            <h1 class="page-header">API Browser</h1>

            <div id="apicall">
              <div class="well well-sm lead url">
                <p id="nonSeoURL"><span
                  class="hostname text-muted">#baseURL#</span><span class="delim text-muted">/</span><span
                  class="base text-muted">index.cfm?action=</span><span
                  class="fqa"><span
                  class="subsystem text-success">#uri.api#</span><span class="delim text-muted">:</span><span
                  class="section text-primary"></span><span class="delim text-muted">.</span><span
                  class="item text-info"></span></span></p>
                <p id="seoURL"><span class="hostname text-muted">#baseURL#</span><span class="delim text-muted">/</span><span
                  class="subsystem text-success">#uri.api#</span><span class="delim text-muted">/</span><span
                  class="section text-primary"></span><span class="delim text-muted">/</span><span
                  class="item text-info"></span></span></p>
              </div>

              <form class="form-inline" id="props-form">
                <h4>Parameters</h4>
                <div class="keyValuePair">
                  <input type="text" name="key" class="form-control input-sm" /> = <input type="text" name="value" class="form-control input-sm" /> <i class="fa fa-plus-circle add"></i>
                </div>
              </form>

              <hr />

              <form class="form-inline" id="auth-form">
                <div class="form-group">
                  <label for="username">Authorization</label>
                  <select class="form-control input-sm"><option>Basic</option></select>
                </div>
                <div class="form-group">
                  <label for="username">Username</label>
                  <input type="text" class="form-control input-sm" id="username" placeholder="placeholder-username">
                </div>
                <div class="form-group">
                  <label for="password">Password</label>
                  <input type="password" class="form-control input-sm" id="password" placeholder="placeholder-password">
                </div>
              </form>

              <div class="row">
                <div class="col-md-6">
                  <div class="panel panel-default">
                    <div class="panel-heading">
                      <a id="run-call" href="" class="btn btn-xs btn-primary pull-right">Run</a>
                      <h3 class="panel-title">
                        Request
                      </h3>
                    </div>
                    <div class="panel-body" id="request"></div>
                  </div>

                  <div class="panel panel-default">
                    <div class="panel-heading">
                      <h3 class="panel-title">
                        Documentation
                      </h3>
                    </div>
                    <div class="panel-body" id="docs"></div>
                  </div>
                </div>

                <div class="col-md-6">
                  <div class="panel panel-default">
                    <div class="panel-heading">
                      <h3 class="panel-title">Response</h3>
                    </div>
                    <div class="panel-body" id="response"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!--- Third party stylesheets and scripts: --->
      <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css" />
      <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap-theme.min.css" />
      <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css">
      <script src="//code.jquery.com/jquery-2.1.3.min.js"></script>
      <script src="//maxcdn.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js"></script>
      <script src="//google-code-prettify.googlecode.com/svn/loader/run_prettify.js"></script>

      <!--- API Browser stylesheets and scripts: --->
      <script>var uri = #serializeJSON( uri )#;</script>
      <script src="browser.js"></script>
      <link rel="stylesheet" href="browser.css" />
    </body>
  </html>
</cfoutput>