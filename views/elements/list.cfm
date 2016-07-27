<cfparam name="local.tableview" default="#rc.tableView#" />

<cfset local.searchFields = [] />
<cfset local.nonSortedIndex = 1000 />
<cfloop collection="#rc.allColumns#" item="key">
  <cfif structKeyExists( rc.allColumns[key], "searchable" )>
    <cfset rc.showSearch = true />
    <cfif not structKeyExists( rc.allColumns[key], "orderinsearch" )>
      <cfset rc.allColumns[key]["orderinsearch"] = local.nonSortedIndex++ />
    </cfif>
    <cfset arrayAppend( local.searchFields, rc.allColumns[key] ) />
  </cfif>
</cfloop>
<cfset local.searchFields = util.arrayOfStructsSort( local.searchFields, 'orderinsearch' ) />

<cfoutput>
  <cfif rc.showAsTree>
    <cfset local.params = {
      alldata = rc.alldata,
      columns = rc.columns,
      lineactions = rc.lineactions,
      lineview = rc.lineview,
      classColumn = rc.classColumn
    } />

    #view( local.tableview, local.params )#
  <cfelse>
    <cfsavecontent variable="local.list_header">
      <cfif rc.showSearch>
        <cfif isDefined( "rc.content" )>
          <h3>#rc.content.getSearchbox()#</h3>
        </cfif>
        <form action="#buildURL( getfullyqualifiedaction())#" method="post" class="form-horizontal" role="form">
          <div class="row">
            <cfloop array="#local.searchFields#" index="local.searchField">
              <cfset key = local.searchField.name />
              <cfset local.searchField.saved = structKeyExists( rc, "filter_#key#" )?rc["filter_#key#"]:"" />
              <cfset param = { column = local.searchField, namePrepend = "filter_", allowBlank = true, chooseLabel = "all" } />
              <div class="form-group">
                <label for="search_#key#" class="col-sm-3 control-label">#i18n.translate( 'filter_' & key )#</label>
                <div class="col-sm-6">#view( "elements/fieldedit", param )#</div>
                <cfif structKeyExists( local.searchField, "filterType" ) and len( trim( local.searchField.filterType ))>
                  <div class="col-sm-3">
                    <cfloop list="#local.searchField.filterType#" index="local.filterType">
                      <div class="radio"><label><input name="filterType" value="#local.filterType#" type="radio"#rc.filterType eq local.filterType?' checked="checked"':''#> #i18n.translate( local.filterType )#</label></div>
                    </cfloop>
                  </div>
                </cfif>
              </div>
            </cfloop>

            <div class="form-group">
              <div class="col-sm-offset-3 col-sm-9">
                <div class="checkbox">
                  <label>
                    <input type="checkbox" name="showdeleted" value="1"#rc.showdeleted?' checked="checked"':''# /> #i18n.translate( 'include-deleted' )#
                  </label>
                </div>
              </div>
            </div>

            <div class="form-group">
              <div class="col-sm-offset-3 col-sm-6">
                <button type="submit" class="btn btn-primary ladda-button" data-style="zoom-in"><span class="ladda-label"><i class="fa fa-search"></i> #i18n.translate('search')#</span></button>
              </div>
            </div>
          </div>
        </form>
        <div class="whitespace"></div>
      </cfif>

      <cfif rc.showNavbar and len( trim( rc.listactions ))>
        <cfset local.allowedActions = "" />
        <cfloop list="#rc.listactions#" index="local.action">
          <cfif (
            listLast( local.action, "." ) eq "edit" or
            listLast( local.action, "." ) eq "new"
          ) and getBeanFactory().getBean( "securityService" ).can( "change", getSection())>
            <cfset local.allowedActions = listAppend( local.allowedActions, local.action ) />
          </cfif>
        </cfloop>

        <cfif len( trim( local.allowedActions ))>
          <cfif structKeyExists( rc, "content" )>
            <form action="javascript:void(0)" class="form-horizontal" role="form">
              <div class="row">
                <div class="form-group">
                  <label class="col-sm-3 control-label">#rc.content.getActionsbox()#</label>
                  <div class="col-sm-6">
          </cfif>

          <cfloop list="#local.allowedActions#" index="local.action">
            <cfif left( local.action, 1 ) eq '.'>
              <cfset local.action = "#getSubsystem()#:#getSection()##local.action#" />
            </cfif>
            <a class="btn btn-primary" href="#buildURL( local.action )#">#i18n.translate( 'btn-' & local.action )#</a>
          </cfloop>

          <cfif structKeyExists( rc, "content" )>
                  </div>
                </div>
              </div>
            </form>
          </cfif>
        </cfif>
      </cfif>
    </cfsavecontent>

    <cfif len( trim( local.list_header ))>
      <div class="well#rc.showSearch?'':' well-sm'#">#local.list_header#</div>
    </cfif>

    <cfif rc.showAlphabet>
      <ul class="pagination alphabet">
        <cfloop from="1" to="26" index="local.i">
          <cfset local.letter = chr( local.i + 64 ) />
          <li><a href="#buildURL(getfullyqualifiedaction(),'?startsWith='&local.letter)#">#local.letter#</a></li>
        </cfloop>
      </ul>
    </cfif>

    <cfif arrayLen( rc.alldata ) eq 0>
      <div class="alert alert-warning">
        <p>#i18n.translate( 'no-results' )#</p>
      </div>
    <cfelse>
      <cfset local.queryString = {} />

      <cfif val( rc.offset )>
        <cfset local.queryString["offset"] = rc.offset />
      </cfif>

      <cfif len( trim( rc.startsWith ))>
        <cfset local.queryString["startsWith"] = rc.startsWith />
      </cfif>

      <cfif rc.showdeleted neq 0>
        <cfset local.queryString["showdeleted"] = rc.showdeleted />
      </cfif>

      <cfif rc.filterType neq 'contains'>
        <cfset local.queryString["filterType"] = rc.filterType />
      </cfif>

      <cfloop collection="#rc#" item="key">
        <cfset key = urlDecode( key ) />
        <cfif listFirst( key, "_" ) eq "filter" and isSimpleValue( rc[key] ) and len( trim( rc[key] ))>
          <cfset local.queryString[lCase( key )] = lCase( rc[key] ) />
        </cfif>
      </cfloop>

      <cfset local.params = {
        alldata = rc.alldata,
        columns = rc.columns,
        lineactions = rc.lineactions,
        lineview = rc.lineview,
        classColumn = rc.classColumn,
        queryString = local.queryString
      } />

      #view( local.tableview, local.params )#

      <cfif rc.showPager>
        <cfif rc.orderby neq rc.defaultSort>
          <cfset local.queryString["orderby"] = rc.orderby />
        </cfif>

        <cfif structKeyExists( rc, "d" ) and rc.d eq 1>
          <cfset local.queryString["d"] = 1 />
        </cfif>

        <cfset local.prevOffset = rc.offset - rc.maxResults />
        <cfif local.prevOffset lt 0>
          <cfset local.prevOffset = 0 />
        </cfif>

        <cfset local.prevQS = duplicate( local.queryString ) />

        <cfif local.prevOffset neq 0>
          <cfset local.prevQS["offset"] = local.prevOffset />
        <cfelse>
          <cfset structDelete( local.prevQS, "offset" ) />
        </cfif>

        <cfset local.nextOffset = rc.offset + rc.maxResults />
        <cfif local.nextOffset gt rc.recordCounter>
          <cfset local.nextOffset = rc.recordCounter />
        </cfif>

        <cfset local.nextQS = duplicate( local.queryString ) />
        <cfset local.nextQS["offset"] = local.nextOffset />

        <ul class="pager">
          <cfif rc.offset lte 0>
            <li class="previous disabled"><a href="##">&larr; #i18n.translate( 'prev' )#</a></li>
          <cfelse>
            <li class="previous"><a href="#buildURL( action = getfullyqualifiedaction(), querystring = local.prevQS)#">&larr; #i18n.translate( 'prev' )#</a></li>
          </cfif>

          <li>#rc.recordCounter# #i18n.translate( 'record' & ( rc.recordCounter eq 1?'':'s' ))#</li>

          <cfif max( rc.offset, local.nextOffset ) gte rc.recordCounter>
            <li class="next disabled"><a href="##">#i18n.translate( 'next' )# &rarr;</a></li>
          <cfelse>
            <li class="next"><a href="#buildURL( action = getfullyqualifiedaction(), querystring = local.nextQS)#">#i18n.translate( 'next' )# &rarr;</a></li>
          </cfif>
        </ul>
      </cfif>
    </cfif>
  </cfif>
</cfoutput>