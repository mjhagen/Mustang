<cfparam name="local.i" default="0" />
<cfparam name="local.namePrepend" default="" />
<cfparam name="local.idPrepend" default="#local.namePrepend#" />
<cfparam name="local.allowBlank" default="false" />
<cfparam name="local.chooseLabel" default="choose" />

<cfparam name="rc.modal" default="false" />

<cfset local.formElementName = local.namePrepend & local.column.name />
<cfset local.fieldAttributes = 'id="#local.idPrepend##local.column.name#"' />

<cfif structKeyExists( local.column, "entityName" )>
  <cfset local.columnEntityName = local.column.entityName />
</cfif>

<cfoutput>
  <cfif rc.modal and (
          (
            structKeyExists( local.column, "inlineedit" ) and
            (
              local.column.fieldtype eq "many-to-one" or
              local.column.fieldtype eq "many-to-many"
            )
          ) or
          local.column.fieldtype eq "one-to-many"
        )>
    <p class="form-control-static"><em class="text-muted">#i18n.translate('not-supported')#</em></p>
    <cfexit />
  </cfif>

  <cfif structKeyExists( local.column, "fieldtype" ) and
        local.column.fieldtype eq "many-to-one" and
        structKeyExists( local.column, "inlineedit" )>
    <cfset local.linkedEntityID = "" />
    <cfif isObject( local.column.saved )>
      <cfset local.linkedEntityID = local.column.saved.getID() />
    </cfif>

    <div class="load-inline" data-entity="#local.columnEntityName#" data-fieldname="#local.column.name#" data-id="#local.linkedEntityID#"></div>
  <cfelseif structKeyExists( local.column, "fieldtype" ) and local.column.fieldtype contains "many">
    <cfif structKeyExists( local.column, "inlineedit" )>
      <cfif structKeyExists( local.column, "saved" )>
        <cfset local.savedEntities = evaluate( "rc.data.get#local.column.name#()" ) />
        <cfif not isDefined( "local.savedEntities" )>
          <cfset local.savedEntities = [] />
        </cfif>
        <div class="inlineblock"#arrayLen( local.savedEntities )?'':' style="display:none;"'#>
          <table class="table table-condensed">
            <tbody id="saved-#structKeyExists( local.column, 'singularName' )?local.column.singularName:local.column.name#">
              <cfloop array="#local.savedEntities#" index="local.savedEntity">
                <cfset local.fieldsToDisplay = local.savedEntity.getFieldsToDisplay( "inlineedit-line" ) />
                <cfif not arrayLen( local.fieldsToDisplay )>
                  <cfset local.fieldsToDisplay = [local.savedEntity.getName()] />
                </cfif>
                <tr class="inline-item">
                  <cfloop array="#local.fieldsToDisplay#" index="local.fieldToDisplay">
                    <cfif not isSimpleValue( local.fieldToDisplay )>
                      <cfset local.fieldparameters = {
                        "val"     = local.savedEntity,
                        "data"    = local.savedEntity,
                        "column"  = {
                          "name" = local.column.name,
                          "orderNr" = 1,
                          "class" = "",
                          "data" = local.savedEntity
                        }
                      } />
                      <cfset local.fieldToDisplay = view( 'common:elements/fielddisplay', local.fieldparameters ) />
                    </cfif>
                    <td>#local.fieldToDisplay#</td>
                  </cfloop>
                  <td class="col-sm-3 text-right"><a href="##confirmremove" class="btn btn-xs btn-danger remove-button" data-entity="#local.column.name#" data-id="#local.savedEntity.getID()#">#i18n.translate( "remove" )#</a></td>
                </tr>
              </cfloop>
            </tbody>
          </table>
        </div>
      </cfif>

      <div id="#local.column.name#_inlineedit" class="inlineedit">
        <a class="btn btn-sm btn-primary inlineedit-modal-trigger" href="#buildURL( 'admin:' & local.columnEntityName & '.new?modal=1' & ( structKeyExists( rc, '#rc.entity#id' ) ? '&fk=#rc['#rc.entity#id']#' : '' ) & '&source=' & local.column.fkColumn )#" data-target="##modal-dialog" data-field="#structKeyExists( local.column, 'singularName' )?local.column.singularName:local.column.name#">#i18n.translate( 'add-#local.column.name#' )#</a>
      </div>
    <cfelseif structKeyExists( local.column, "autocomplete" )>
      #view( 'common:form/select', {
        "id"          = "#local.idPrepend##local.column.name#",
        "class"       = "autocomplete",
        "name"        = local.formElementName,
        "data"        = {
                          "entity"  = "#local.columnEntityName#"
                        },
        "placeholder" = i18n.translate('placeholder-#local.column.name#'),
        "selected"    = local.column.saved
      })#
    <cfelseif local.column.fieldtype contains "to-many">
      <cfset local.checkedOption = "" />
      <cfif structKeyExists( local.column, "saved" )>
        <cfif isSimpleValue( local.column.saved )>
          <cfset local.checkedOption = local.column.saved />
        <cfelseif isObject( local.column.saved )>
          <cfset local.checkedOption = local.column.saved.getID() />
        </cfif>
      </cfif>

      <input type="hidden" name="#local.formElementName#" value="" />

      <cfif structKeyExists( local.column, "hierarchical" )>
        <cfset local.checkboxes = ORMExecuteQuery( "FROM #local.columnEntityName# WHERE deleted=FALSE AND parent=NULL ORDER BY sortorder, name" ) />

        <div class="panel-group" id="accordion">
          <div class="panel panel-default">
            <div class="panel-heading">
              <h4 class="panel-title"><a data-toggle="collapse" data-parent="##accordion_#local.formElementName#" href="##collapse_#local.formElementName#"><span><i class="fa fa-caret-right"></i></span>#i18n.translate( 'view-change' )#</a></h4>
            </div>
            <div id="collapse_#local.formElementName#" class="panel-collapse collapse">
              <div class="panel-body">
                <cfloop array="#local.checkboxes#" index="local.checkbox">
                  <cfset local.viewOptions = {
                    name = local.formElementName,
                    boxes = local.checkbox.getChildren(),
                    checked = local.checkedOption
                  } />
                  <div class="#structKeyExists( local.column, 'affected' )?'affected #local.checkbox.getName()#':''#">#view( "common:elements/recursive-checkbox", local.viewOptions )#</div>
                </cfloop>
              </div>
            </div>
          </div>
        </div>
      <cfelse>
        <cfset local.checkboxes = ORMExecuteQuery( "FROM #local.columnEntityName# WHERE ( deleted IS NULL OR deleted = FALSE ) ORDER BY sortorder" ) />
        <cfset local.checkboxIndex = 0 />

        <cfloop array="#local.checkboxes#" index="local.option">
          <cfset local.checkboxIndex++ />
          <cfset local.required = ( local.checkboxIndex eq 1 and structKeyExists( local.column, 'required' )) ? ' data-bv-choice="true" data-bv-choice-min="1" data-bv-message="' & i18n.translate( '#local.column.name#-required-message' ) & '"' : '' />
          <cfset local.checked = listFind( local.checkedOption, local.option.getID()) ? ' checked="checked"' : '' />
          <div class="checkbox">
            <label>
              <input type="checkbox" name="#local.formElementName#" value="#local.option.getID()#"#local.checked##local.required#>#structKeyExists( local.column, "translateOptions" )?i18n.translate(local.option.getName()):local.option.getName()#
            </label>
          </div>
        </cfloop>
      </cfif>
    <cfelse>
      <cfset local.selectedOption = "" />

      <cfif structKeyExists( rc, "fk" ) and 
            structKeyExists( rc, "source" ) and 
            compareNoCase( rc.source, local.column.fkColumn ) eq 0>
        <cfset local.selectedOption = rc.fk />
      </cfif>

      <cfif structKeyExists( local.column, "saved" )>
        <cfif isSimpleValue( local.column.saved )>
          <cfif len( trim( local.column.saved ))>
            <cfset local.selectedOption = local.column.saved />
          </cfif>
        <cfelseif isObject( local.column.saved )>
          <cfset local.selectedOption = local.column.saved.getID() />
        </cfif>
      </cfif>

      <cfif structKeyExists( local.column, "hierarchical" )>
        <cfset local.selects = ORMExecuteQuery( "FROM #local.columnEntityName# WHERE deleted=FALSE AND parent=NULL ORDER BY sortorder" ) />
        <cfloop array="#local.selects#" index="local.select">
          <cfset local.viewOptions = { options = local.select.getChildren(), selected = local.selectedOption } />
          <cfset local.classNames = local.select.getName() />
          <cfif structKeyExists( local.column, "affectsform" )><cfset listAppend( local.classNames, affectsform, " " ) /></cfif>
          <cfif structKeyExists( local.column, "affected" )><cfset listAppend( local.classNames, affected, " " ) /></cfif>

          #view( 'common:form/select', {
            "id"        = "#local.idPrepend##local.column.name#",
            "name"      = local.formElementName,
            "class"     = local.classNames,
            "data"      = {
              "optionfilter" = local.select.getID()
            },
            "contents"  = view( "common:elements/recursive-option", local.viewOptions )
          })#
        </cfloop>
      <cfelse>
        <cfquery dbtype="hql" name="local.options" ormoptions="#{cacheable=true}#">
          FROM      #local.columnEntityName#
          WHERE     deleted != <cfqueryparam cfsqltype="cf_sql_tinyint" value="1" />

          <cfif structKeyExists( local.column, "where" )>
            <cfset local.whereClause = listToArray( replaceNoCase( local.column.where, ' AND ', chr( 0182 ), 'all' ), chr( 0182 )) />
            <cfloop array="#local.whereClause#" index="local.whereItem">
              <cfset local.whereKey = trim( listFirst( local.whereItem, '=' )) />
              <cfset local.whereValue = replace( trim( listRest( local.whereItem, '=' )), "'", "", "all" ) />
              <cfif right( local.whereKey, 2 ) eq "id">
                <cfset local.whereEntityName = mid( local.whereKey, 1, len( local.whereKey ) - 2 ) />
                <cfset local.whereEntity = entityLoadByPK( local.whereEntityName, local.whereValue ) />
                <cfif not isNull( local.whereEntity )>
                  AND #local.whereEntityName# = <cfqueryparam value="#local.whereEntity#" />
                </cfif>
              <cfelse>
                AND #replace( local.whereItem, "''", "'", "all" )#
              </cfif>
            </cfloop>
          </cfif>

          ORDER BY  sortorder
        </cfquery>

        #view( 'common:form/select', {
          "id"                = "#local.idPrepend##local.column.name#",
          "name"              = local.formElementName,
          "class"             = structKeyExists( local.column, "affectsform" ) ? " affectsform" : "",
          "options"           = local.options,
          "selected"          = local.selectedOption,
          "translateOptions"  = structKeyExists( local.column, "translateOptions" ),
          "affectsform"       = structKeyExists( local.column, "affectsform" ),
          "choose"            = (
                                  (
                                    local.column.fieldtype contains "to-one" and
                                    not structKeyExists( local.column, "required" )
                                  ) or
                                  local.allowBlank
                                ) ? local.chooseLabel : ""
        })#
      </cfif>
    </cfif>
  <cfelseif structKeyExists( local.column, "ORMType" ) and local.column.ORMType eq "Boolean">
    <cfif not isBoolean( local.column.saved )>
      <cfset local.column.saved = false />
    </cfif>
    <div class="checkbox"><label>
      <input
        type="checkbox"
        name="#local.formElementName#"
        id="#local.idPrepend##local.column.name#"
        value="1"
        #local.column.saved?'checked="checked"':''#
        #structKeyExists( local.column, 'required' )?('required data-bv-message="' & i18n.translate( local.column.name & '-required-message' ) & '" data-bv-notempty="true"'):''#
      /> #i18n.translate( local.column.name )#
    </label></div>
  <cfelse>
    <cfset local.fieldAttributes &= ' placeholder="#i18n.translate('placeholder-#local.column.name#')#"' />

    <cfif structKeyExists( local.column, "formfield" )>
      <cfswitch expression="#local.column.formfield#">
        <cfcase value="color">
          <cfset local.fieldAttributes &= ' class="form-control pick-a-color" name="#local.formElementName#"' />
          <input #local.fieldAttributes# type="text" value="#local.column.saved#" />
        </cfcase>
        <cfcase value="file">
          <div class="fileinput">
            <cfset local.showUploadButton = true />
            <cfif structKeyExists( local.column, "saved" ) and
                  isSimpleValue( local.column.saved ) and
                  len( trim( local.column.saved ))>
              <cfset local.showUploadButton = false />
              <input type="hidden" name="#local.formElementName#" value="#local.column.saved#" />
              <cfset local.column.saved = '<button type="button" class="close fileinput-remove">&times;</button><a href="' & buildURL( 'adminapi:crud.download?filename=#local.column.saved#' ) & '">#local.column.saved#</a>' />
            <cfelse>
              <input type="hidden" name="#local.formElementName#" value="" />
              <cfset local.column.saved = "" />
            </cfif>

            <span role="button" class="btn btn-primary fileinput-button"#local.showUploadButton?'':' style="display:none;"'#>
              <i class="fa fa-plus"></i>
              <span>#i18n.translate( "select-file" )#</span>
              <input #local.fieldAttributes# type="file" data-name="#local.formElementName#" />
            </span>

            <div class="progress" style="margin-top:5px; display:none;">
              <div class="progress-bar progress-bar-success" role="progressbar" aria-valuemin="0" aria-valuemax="100" style="width: 0%"></div>
            </div>

            <div#local.showUploadButton?' class="alert" style=" display:none;"':' class="alert alert-success"'#>#local.column.saved#</div>
          </div>
        </cfcase>
      </cfswitch>
    <cfelseif structKeyExists( local.column , 'editor' )>
      #view( 'common:form/#local.column.editor#', {
        "id"          = "#local.idPrepend##local.column.name#",
        "name"        = local.formElementName,
        "saved"       = local.column.saved
      })#
    <cfelseif (
      structKeyExists( local.column, "dataType" ) and
      local.column.dataType eq "json"
    )
    or
    (
      structKeyExists( local.column, "data" ) and
      isStruct( local.column.data ) and
      structKeyExists( local.column.data, "dataType" ) and
      local.column.data.dataType eq "json"
    )>
      <cfset local.saved = local.column.saved />
      <cfif not isSimpleValue( local.saved )>
        <cfset local.saved = serializeJSON( local.saved ) />
      </cfif>

      <div class="jsoneditorblock">
        <div class="jsoncontainer" data-value="#toBase64( local.saved )#"></div>
        <input type="hidden" name="#local.formElementName#" value="#htmlEditFormat( local.saved )#" />
      </div>

    <cfelse>
      <cfset local.fieldAttributes &= ' class="form-control" name="#local.formElementName#"' />
      <cfparam name="local.column.saved" default="" />
      <cfif isSimpleValue( local.column.saved )>
        <cfif ( structKeyExists( local.column, "sqltype" ) and local.column.sqltype contains "text" ) or
              ( structKeyExists( local.column, "ormtype" ) and local.column.ormtype contains "text" )>
          <textarea rows="15" #local.fieldAttributes#>#local.column.saved#</textarea>
        <cfelse>
          <cfif structKeyExists( local.column, "mask" )>
            <cfset local.fieldAttributes &= ' data-mask="#local.column.mask#"' />
          </cfif>

          <cfif listFindNoCase( "edit,new", getItem()) and structKeyExists( local.column, "required" )>
            <cfif structKeyExists( local.column, "regexp" )>
              <cfset local.fieldAttributes &= ' data-bv-regexp="true"' />
              <cfset local.fieldAttributes &= ' data-bv-regexp-regexp="^#local.column.regexp#$"' />
            </cfif>

            <cfset local.fieldAttributes &= ' data-bv-message="' & i18n.translate( local.column.name & '-required-message' ) & '"' />
            <cfif not structKeyExists( local.column, "allowempty" )>
              <cfset local.fieldAttributes &= ' required data-bv-notempty="true"' />
            </cfif>

            <cfif structKeyExists( local.column, "requirement" )>
              <cfswitch expression="#local.column.requirement#">
                <cfcase value="unique">
                  <cfset local.validationURLAttributes = {
                    "entityName" = rc.entity,
                    "propertyName" = local.column.name
                  } />

                  <cfif isDefined( "rc.data" ) and len( trim( rc.data.getID()))>
                    <cfset local.validationURLAttributes["entityID"] = rc.data.getID() />
                  </cfif>

                  <cfset local.fieldAttributes &= ' data-bv-remote="true" data-bv-remote-name="value" data-bv-remote-url="' & buildURL( action = 'adminapi:crud.validate', queryString = local.validationURLAttributes ) & '"' />
                </cfcase>
              </cfswitch>
            </cfif>
          </cfif>

          <input #local.fieldAttributes# type="text" value="#htmlEditFormat( local.column.saved )#" />
        </cfif>
      </cfif>
    </cfif>
  </cfif>
</cfoutput>