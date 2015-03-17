<cfcomponent mappedSuperClass="true"

             cacheuse="transactional"
             defaultSort="sortorder"
             hide="true"
>
  <cfproperty name="id" fieldType="id" generator="uuid" />
  <cfproperty name="deleted" ORMType="boolean" default="false" />
  <cfproperty name="sortorder" ORMType="integer" />

  <!--- <cfproperty fieldType="many-to-one" name="createContact" FKColumn="createcontactid" cfc="contact" /> --->
  <cfproperty name="createDate" ORMType="timestamp" />
  <cfproperty name="createIP"  length="15" />

  <!--- <cfproperty fieldType="many-to-one" name="updateContact" FKColumn="updatecontactid" cfc="contact" /> --->
  <cfproperty name="updateDate" ORMType="timestamp" />
  <cfproperty name="updateIP"  length="15" />

  <!--- <cfproperty name="log" singularName="logentry" fieldType="one-to-many" cfc="logentry" FKColumn="loggedid" orderby="createDate desc" cascade="delete-orphan" /> --->

  <cfproperty name="name" length="128" />

  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="init" access="public">
    <cflock scope="application" timeout="5">
      <cfset variables.util = application.util />
    </cflock>

    <cfreturn this />
  </cffunction>

  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="getFieldsToDisplay" access="public" returnType="array">
    <cfargument name="type" required="true" />
    <cfargument name="formdata" required="false" default="#{}#" />

    <cfset var properties = getInheritedProperties() />
    <cfset var property = javaCast( "null", 0 ) />
    <cfset var key = "" />
    <cfset var result = [] />

    <cfswitch expression="#type#">
      <cfcase value="inlineedit-line">
        <cfset var propertiesInInline = structFindKey( properties, "ininline", "all" ) />
        <cfset var tempProperties = {} />

        <cfloop array="#propertiesInInline#" index="property">
          <cfset tempProperties[property.owner.name] = property.owner />
          <cfif not structKeyExists( tempProperties[property.owner.name], "orderininline" )>
            <cfset tempProperties[property.owner.name].orderininline = 9001 />
          </cfif>
        </cfloop>

        <cfset var sortKey = structSort( tempProperties, 'numeric', 'asc', '.orderininline' ) />
        <cfset var currentField = "" />

        <cfloop array="#sortKey#" index="key">
          <cfset currentField = tempProperties[key].name />

          <cfif structKeyExists( formData, currentField )>
            <cfset local.valueToDisplay = formData[currentField] />
          </cfif>

          <cfif not isDefined( "local.valueToDisplay" )>
            <cftry>
              <cfset local.valueToDisplay = evaluate( "get#currentField#()" ) />
              <cfcatch></cfcatch>
            </cftry>
          </cfif>

          <cfif isDefined( "local.valueToDisplay" ) and isObject( local.valueToDisplay )>
            <cfset local.valueToDisplay = local.valueToDisplay.getName() />
          </cfif>

          <cfif not isDefined( "local.valueToDisplay" )>
            <cfset local.valueToDisplay = "" />
          </cfif>

          <cfset arrayAppend( result, local.valueToDisplay ) />
          <cfset structDelete( local, "valueToDisplay" ) />
        </cfloop>
      </cfcase>
    </cfswitch>

    <cfreturn result />
  </cffunction>

  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="hasProperty" access="public" returnType="boolean">
    <cfargument name="propertyToCheck" required="true" />

    <cfreturn structKeyExists( getInheritedProperties(), propertyToCheck ) />
  </cffunction>

  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="getInheritedProperties" access="public" returnType="any">
    <cfargument name="result" default="#{}#" />

    <cfset var obj = getMetaData( this ) />

    <cfif structKeyExists( obj, "extends" ) and 
          not obj.extends.fullname eq 'WEB-INF.cftags.component' and 
          not obj.extends.fullname eq 'railo.Component' and 
          not obj.extends.fullname eq 'lucee.Component'>
      <cfset result = createObject( obj.extends.fullname ).getInheritedProperties( result ) />
    </cfif>

    <cfif structKeyExists( obj, "properties" )>
      <cfloop array="#obj.properties#" index="property">
        <cfloop collection="#property#" item="local.field">
          <cfset result[property.name][local.field] = property[local.field] />

          <cfif structKeyExists( property, "cfc" )>
            <cfset result[property.name]["entityName"] = createObject( property.cfc ).getEntityName() />
          </cfif>
        </cfloop>
      </cfloop>
    </cfif>

    <cfreturn result />
  </cffunction>

  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="getReverseField" access="public" output="true" returnType="any">
    <cfargument name="cfc" />
    <cfargument name="fkColumn" />
    <cfargument name="type" />
    <cfargument name="singular_or_plural" default="singular" />

    <cfset var properties = structFindKey( getInheritedProperties(), "cfc", "all" ) />
    <cfset var field = 0 />
    <cfset var fieldFound = false />

    <cfif not arrayLen( properties )>
      ERROR: not linked to any CFCs
      <cfdump var="#arguments#" />
      <cfabort />
    </cfif>

    <cfloop array="#properties#" index="property">
      <cfset field = property.owner />
      <cfif not ((
              structKeyExists( field, "fkcolumn" ) and
              field.fkColumn eq fkColumn
            ) or field.cfc eq cfc )>
        <cfcontinue />
      </cfif>

      <cfif field.cfc eq cfc>
        <cfset fieldFound = true />
        <cfbreak />
      </cfif>

      <cfset local.testCFC = createObject( "#cfc#" ) />

      <cfif isInstanceOf( local.testCFC, "#field.cfc#" )>
        <cfset fieldFound = true />
        <cfbreak />
      </cfif>
    </cfloop>

    <cfset propertyWithFK = structFindValue({ 'search' = properties }, fkColumn, 'all' ) />
    <cfif arrayLen( propertyWithFK ) eq 1>
      <cfset field = propertyWithFK[1].owner />
      <cfset fieldFound = true />
    </cfif>

    <cfif not fieldFound>
      <cfset local.meta = getMetaData( this ) />
      ERROR: no valid properties found in #listLast( local.meta.name, '.' )#

      <cfdump var="#arguments#" />
      <cfdump var="#local.meta#" />
      <cfdump var="#properties#" />

      <cfabort />
    </cfif>

    <cfset result = field.name />

    <cfif singular_or_plural eq "singular" and structKeyExists( field, 'singularName' )>
      <cfset result = field['singularName'] />
    </cfif>

    <cfreturn result />
  </cffunction>

  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="getEntityName">
    <cfreturn ORMGetSessionFactory().getClassMetadata( getClassName()).getEntityName() />
  </cffunction>

  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="getClassName">
    <cfreturn listLast( getMetaData( this ).fullname, "." ) />
  </cffunction>

  <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
  <cffunction name="save" access="public" output="true" returnType="any">
    <cfargument name="formData" default="#{}#" />
    <cfargument name="calledBy" default="#{entity='',id=''}#" />
    <cfargument name="depth" default="0" />

    <cfset var IDToSave           = 0 />
    <cfset var key                = 0 />
    <cfset var property           = 0 />
    <cfset var propertyEntityName = 0 />
    <cfset var objectToSave       = 0 />

    <cfset var tmpObject          = "" />
    <cfset var valueToLog         = "" />

    <cfset var objectsToSave      = [] />

    <cfset var objectsToAdd       = {} />
    <cfset var savedState         = {} />

    <cfset var meta               = getMetaData( this ) />
    <cfset var entityName         = this.getEntityName() />
    <cfset var CFCName            = meta.name />
    <cfset var properties         = getInheritedProperties() />
    <cfset var canBeLogged        = isInstanceOf( this, "base" ) />
    <cfset var uuid               = createUUID() />

    <cfparam name="request.ormActions" default="#{}#" />

    <cfif not structKeyExists( formData, "deleted" )>
      <cfset formData.deleted = 0 />
    </cfif>

    <cfif request.context.debug>
      <p>#depth# - #entityName#</p>
    </cfif>

    <cfif depth gt 6>
      <cfreturn />
    </cfif>

    <cfif canBeLogged>
      <cfif not len( trim( getCreateDate()))><cfset setCreateDate( now()) /></cfif>
      <cfif not len( trim( getCreateIP()))><cfset setCreateIP( cgi.remote_host ) /></cfif>

      <cfset setUpdateDate( now()) />
      <cfset setUpdateIP( cgi.remote_host ) />

      <cfif not request.context.config.disableSecurity>
        <cfif not hasCreateContact()><cfset setCreateContact( session.auth.user ) /></cfif>
        <cfset setUpdateContact( session.auth.user ) />
      </cfif>
    </cfif>

    <!--- typeahead --->
    <cfloop collection="#properties#" item="key">
      <cfset property = properties[key] />

      <cfif structKeyExists( property, "cfc" )>
        <cfset propertyEntityName = createObject( property.cfc ).getEntityName() />
      </cfif>

      <cfif structKeyExists( formData, '#property.name#_tagsinput' )>
        <cfset local.tagsField = formData['#property.name#_tagsinput'] />
        <cfif len( trim( local.tagsField ))>
          <cfset formData["set_" & property.name] = "" />
          <cfloop list="#local.tagsField#" index="local.tag">
            <cfset local.tagToLink = entityLoad( "#propertyEntityName#", { name = lCase( local.tag )}) />

            <cfif arrayLen( local.tagToLink ) eq 1>
              <cfset formData["set_" & property.name] = listAppend( formData["set_" & property.name], '{"id":"#local.tagToLink[1].getID()#"}' ) />
            <cfelse>
              <cfset formData["set_" & property.name] = listAppend( formData["set_" & property.name], '{"name":"#local.tag#"}' ) />
            </cfif>
          </cfloop>
        </cfif>
      </cfif>
    </cfloop>

    <cfif request.context.debug>
      <table cellpadding="5" cellspacing="0" border="1" width="100%">
        <tr>
          <th colspan="2" bgcolor="teal" style="cursor:pointer;" onclick="document.getElementById('#uuid#').style.display=(document.getElementById('#uuid#').style.display==''?'none':'');"><font color="white">#entityName# #getID()#</font></th>
        </tr>
        <tr>
          <td colspan="2">
            <table cellpadding="5" cellspacing="0" border="1" width="100%" id="#uuid#"#depth gt 0?' style="display:none;"':''#>
              <tr>
                <td colspan="2">#getName()#</td>
              </tr>
    </cfif>

    <!--- SAVE VALUES PASSED VIA FORM --->
    <cfloop collection="#properties#" item="key">
      <cfset property = properties[key] />

      <cfif listFindNoCase( "log,createDate,createIP,createContact,updateDate,updateIP,updateContact,id", key ) or
            not structKeyExists( property, "fieldtype" )>
        <cfcontinue />
      </cfif>

      <cfif structKeyExists( property, "cfc" )>
        <cfset propertyEntityName = createObject( property.cfc ).getEntityName() />
      </cfif>

      <cfsavecontent variable="local.debugoutput">

      <cfswitch expression="#property.fieldtype#">
        <cfcase value="one-to-many,many-to-many">
          <!---
           ______   ______        __    __     ______     __   __     __  __
          /\__  _\ /\  __ \      /\ "-./  \   /\  __ \   /\ "-.\ \   /\ \_\ \
          \/_/\ \/ \ \ \/\ \     \ \ \-./\ \  \ \  __ \  \ \ \-.  \  \ \____ \
             \ \_\  \ \_____\     \ \_\ \ \_\  \ \_\ \_\  \ \_\\"\_\  \/\_____\
              \/_/   \/_____/      \/_/  \/_/   \/_/\/_/   \/_/ \/_/   \/_____/

          --->
          <!--- OVERRIDE to SET --->
          <cfif structKeyExists( formdata, property.name )>
            <!--- Valid input: --->
            <cfset local.inputType = "invalid" />
            <!--- a JSON var --->
            <cfif isJSON( formdata[property.name] )>
              <cfset local.inputType = "json" />
            <cfelse>
              <!--- list of JSON structs --->
              <cfif isArray( formdata[property.name] )>
                <cfset formdata[property.name] = arrayToList( formdata[property.name] ) />
              </cfif>

              <cfset local.testForListOfStructs = "[#formdata[property.name]#]" />
              <cfif isJSON( local.testForListOfStructs )>
                <cfset local.inputType = "multiple-json" />
              <cfelse>
                <!--- list of UUIDs --->
                <cfset local.inputType = "uuid" />
              </cfif>
            </cfif>

            <cfset formdata["set_#property.name#"] = "" />
            <cfloop list="#formdata[property.name]#" index="local.dataToSave">
              <cfif local.inputType eq "uuid">
                <cfset local.dataToSave = '{"id":"#local.dataToSave#"}' />
              </cfif>
              <cfset formdata["set_#property.name#"] = listAppend( formdata["set_#property.name#"], local.dataToSave ) />
            </cfloop>

            <cfset local.workData = formdata[property.name] />
            <cfset structDelete( formdata, property.name ) />
          </cfif>

          <!--- REMOVE --->
          <cfif structKeyExists( formdata, "set_#property.name#" ) or
                structKeyExists( formdata, "remove_#property.name#" )>
            <cfquery dbtype="hql" name="local.objectsToOverride" ormoptions="#{cacheable=true}#">
              SELECT b
              FROM #entityName# a JOIN a.#property.name# b
              WHERE a.id = <cfqueryparam value="#getID()#" />
              <cfif structKeyExists( formdata, "remove_#property.name#" )>
                AND b.id IN ( <cfqueryparam value="#formdata['remove_'&property.name]#" list="true" /> )
              </cfif>
            </cfquery>
            <cfloop array="#local.objectsToOverride#" index="local.objectToOverride">
              <cfif property.fieldType eq "many-to-many">
                <cfset local.reverseField = local.objectToOverride.getReverseField( CFCName, property.inverseJoinColumn, property.fieldtype, 'singular' ) />
                <cfset evaluate( "local.objectToOverride.remove#local.reverseField#(this)" ) />
                <cfif request.context.debug><p>local.objectToOverride.remove#local.reverseField#(this)</p></cfif>
              <cfelse>
                <cfset local.reverseField = local.objectToOverride.getReverseField( CFCName, property.fkcolumn, property.fieldtype, 'plural' ) />
                <cfset evaluate( "local.objectToOverride.set#local.reverseField#(javaCast('null',0))" ) />
                <cfif request.context.debug><p>local.objectToOverride.set#local.reverseField#(javaCast('null',0))</p></cfif>
              </cfif>
              <cfset evaluate( "remove#property.singularName#(local.objectToOverride)" ) />
              <cfif request.context.debug><p>remove#property.singularName#(local.objectToOverride)</p></cfif>
            </cfloop>
          </cfif>

          <!--- SET --->
          <cfif structKeyExists( formdata, "set_#property.name#" )>
            <cfset local.workData = deSerializeJSON( '[' & formdata["set_#property.name#"] & ']' ) />

            <cfif arrayLen( local.workData )>
              <cfset formdata["add_#property.singularName#"] = "" />
            </cfif>
            <cfloop array="#local.workData#" index="local.toAdd">
              <cfif not isJSON( local.toAdd )>
                <cfset local.toAdd = serializeJSON( local.toAdd ) />
              </cfif>
              <cfset formdata["add_#property.singularName#"] = listAppend( formdata["add_#property.singularName#"], local.toAdd ) />
            </cfloop>

            <cfset structDelete( formdata, "set_#property.name#" ) />
          </cfif>

          <!--- ADD --->
          <cfif structKeyExists( formdata, "add_#property.singularName#" )>
              <cfset local.workData = deSerializeJSON( '[' & formdata["add_#property.singularName#"] & ']' ) />

            <cfloop array="#local.workData#" index="local.updatedStruct">
              <cfif isJSON( local.updatedStruct )>
                <cfset local.updatedStruct = deSerializeJSON( local.updatedStruct ) />
              </cfif>

              <cfif isStruct( local.updatedStruct ) and structKeyExists( local.updatedStruct, "id" )>
                <cfset local.objectToLink = entityLoadByPK( propertyEntityName, local.updatedStruct.id ) />
                <cfset structDelete( local.updatedStruct, "id" ) />
              </cfif>

              <cfif isNull( local.objectToLink )>
                <cfset local.objectToLink = entityNew( propertyEntityName ) />
                <cfset entitySave( local.objectToLink ) />
              </cfif>

              <cfset local.alreadyHasValue = evaluate( "has#property.singularName#(local.objectToLink)" ) />
              <cfif request.context.debug><p>this.has#property.singularName#( #local.objectToLink.getName()# #local.objectToLink.getID()# ) -> #local.alreadyHasValue#</p></cfif>

              <cfset local.ormAction = "#getID()#_#local.objectToLink.getID()#" />
              <cfif not local.alreadyHasValue and not structKeyExists( request.ormActions, local.ormAction )>
                <cfset evaluate( "add#property.singularName#(local.objectToLink)" ) />
                <cfif request.context.debug><p>add#property.singularName#(local.objectToLink)</p></cfif>
                <cfoutput>#local.ormAction#</cfoutput>
                <cfset local.reverseField = local.objectToLink.getReverseField( CFCName, property.fkcolumn, property.fieldtype, 'singular' ) />
                <cfif property.fieldtype eq "many-to-many">
                  <cfset local.updatedStruct['add_#local.reverseField#'] = '{"id":"#getID()#"}' />
                  <cfset request.ormActions[local.ormAction] = property.name />
                <cfelse>
                  <cfset local.updatedStruct[local.reverseField] = getID() />
                  <cfset request.ormActions[local.ormAction] = property.name />
                </cfif>
              </cfif>

              <!--- Go down the rabbit hole: --->
              <cfif structCount( local.updatedStruct )>
                <cfif request.context.debug><b>ADD .save()</b></cfif>
                <cfset local.objectToLink = local.objectToLink.save(
                  formData = local.updatedStruct,
                  depth= depth + 1,
                  calledBy = { entity = entityName, id = getID()}
                ) />
              </cfif>

              <!--- CLEANUP --->
              <cfset structDelete( local, "objectToLink" ) />
            </cfloop>
          </cfif>

          <!--- CLEANUP --->
          <cfif structKeyExists( local, "workData" )>
            <cfset structDelete( local, "workData" ) />
          </cfif>
        </cfcase>
        <cfdefaultcase>
          <!---
           ______   ______        ______     __   __     ______
          /\__  _\ /\  __ \      /\  __ \   /\ "-.\ \   /\  ___\
          \/_/\ \/ \ \ \/\ \     \ \ \/\ \  \ \ \-.  \  \ \  __\
             \ \_\  \ \_____\     \ \_____\  \ \_\\"\_\  \ \_____\
              \/_/   \/_____/      \/_____/   \/_/ \/_/   \/_____/

          --->
          <!--- inline forms --->
          <cfif structKeyExists( property, "inlineedit" ) and (
                  structKeyExists( formdata, property.name ) or
                  structKeyList( formdata ) contains '#property.name#_' or
                  structKeyExists( formdata, "#property.name#id" )
                )>
            <cfif propertyEntityName eq calledBy.entity>
              <!--- this prevents invinite loops --->
              <cfset local.inlineEntity = entityLoadByPK( "#calledBy.entity#", calledBy.id ) />
            <cfelse>
              <cfset local.inlineEntity = evaluate( "get#property.name#()" ) />

              <cfif request.context.debug><p>get#property.name#()</p></cfif>

              <cfif isNull( local.inlineEntity )>
                <cfif structKeyExists( formData, "#property.name#id" )>
                  <cfset local.inlineEntity = entityLoadByPK( propertyEntityName, formData["#property.name#id"] ) />
                </cfif>

                <cfif isNull( local.inlineEntity )>
                  <cfset local.inlineEntity = entityNew( propertyEntityName ) />
                  <cfset entitySave( local.inlineEntity ) />
                </cfif>
              </cfif>

              <cfset local.inlineEntityParameters = {} />

              <cfloop collection="#formData#" item="local.formField">
                <cfif listLen( local.formField, '_' ) gte 2 and listFirst( local.formField, "_" ) eq property.name>
                  <cfset local.inlineEntityParameters[listRest( local.formField, "_" )] = formData[local.formField] />
                </cfif>
              </cfloop>

              <cfif structKeyExists( formdata, property.name ) and
                    isJSON( formdata[property.name] ) and
                    not structCount( local.inlineEntityParameters )>
                <cfset local.inlineEntityParameters = deSerializeJSON( formdata[property.name] ) />
              </cfif>
            </cfif>

            <cfset formdata[property.name] = local.inlineEntity.getID() />
          </cfif>

          <!--- save value and link objects together --->
          <cfif structKeyExists( formdata, property.name )>
            <cfset local.value = formdata[property.name] />
            <cfset local.valueToLog = left( local.value, 255 ) />

            <cfif structKeyExists( property, "cfc" )>
              <!--- LINK TO OTHER OBJECT (USING PROVIDED ID) --->
              <cfif structKeyExists( local, "inlineEntity" )>
                <cfset local.obj = local.inlineEntity />
                <cfset structDelete( local, "inlineEntity" ) />
              <cfelseif len( trim( local.value ))>
                <cfset local.obj = entityLoadByPK( "#propertyEntityName#", local.value ) />
              </cfif>

              <cfif not isNull( local.obj )>
                <cfif not structKeyExists( local, "inlineEntityParameters" )>
                  <cfset local.inlineEntityParameters = {} />
                </cfif>

                <cfset local.inlineEntityParameters["#propertyEntityName#id"] = local.obj.getID() />
                <cfset local.reverseField = local.obj.getReverseField( CFCName, property.fkcolumn, property.fieldtype, 'singular' ) />

                <cfset local.alreadyHasValue = evaluate( "local.obj.has#local.reverseField#(this)" ) />

                <cfif request.context.debug><p>local.obj.has#local.reverseField#( #getID()# ) -> #local.alreadyHasValue#</p></cfif>

                <cfset local.ormAction = "#getID()#_#local.obj.getID()#" />
                <cfif not local.alreadyHasValue and
                      not structKeyExists( request.ormActions, local.ormAction )>
                  <cfoutput>#local.ormAction#</cfoutput>
                  <cfset local.inlineEntityParameters['add_#local.reverseField#'] = '{"id":"#getID()#"}' />
                  <cfset request.ormActions[local.ormAction] = property.name />
                </cfif>

                <cfif structCount( local.inlineEntityParameters )>
                  <cftry>
                    <cfif request.context.debug><b>SET .save()</b></cfif>
                    <cfset local.obj.save(
                      depth = ( depth + 1 ),
                      calledBy = {
                        entity = entityName,
                        id = getID()
                      },
                      formData = local.inlineEntityParameters
                    ) />

                    <cfcatch>
                      <cfdump var="#local.inlineEntityParameters#" />
                      <cfdump var="#cfcatch#" />
                      <cfabort />
                    </cfcatch>
                  </cftry>
                </cfif>

                <cfset local.valueToLog = local.obj.getName() />
                <cfset local.value = local.obj />

                <cfset structDelete( local, "obj" ) />
                <cfset structDelete( local, "inlineEntityParameters" ) />
              <cfelse>
                <cfset local.valueToLog = "removed" />
                <cfset structDelete( local, "value" ) />
              </cfif>
            <cfelse>
              <!--- SIMPLE VALUE --->
              <!--- make sure integers are saved as that: --->
              <cfif structKeyExists( property, "ORMType" )>
                <cfif property.ORMType eq "int" or property.ORMType eq "integer">
                  <cfset local.value = int( val( local.value )) />
                </cfif>
                <cfif property.ORMType eq "float">
                  <cfset local.value = val( local.value ) />
                </cfif>
              </cfif>
            </cfif>

            <cfif request.context.debug><font color="red">SET 3:</font></cfif>

            <cfif not isNull( local.value )>
              <cfset evaluate( "set#property.name#(local.value)" ) />
              <cfif request.context.debug><p>set#property.name#(local.value)</p></cfif>
            <cfelse>
              <cfset evaluate( "set#property.name#(javaCast('null',0))" ) />
              <cfif request.context.debug><p>set#property.name#(javaCast('null',0))</p></cfif>
            </cfif>
          </cfif>
        </cfdefaultcase>
      </cfswitch>

      </cfsavecontent>

      <cfif len( trim( local.debugoutput )) and request.context.debug>
        <tr>
          <th width="15%" valign="top" align="right">#key#</th>
          <td width="85%">#local.debugoutput#</td>
        </tr>
      </cfif>

      <cfif structKeyExists( local, "valueToLog" )>
        <cfset savedState[property.name] = local.valueToLog />
        <cfset structDelete( local, "valueToLog" ) />
      </cfif>
    </cfloop>

    <cfif request.context.debug>
            </td>
          </tr>
        </table>
      </table>
    </cfif>

    <cfif request.context.config.log and
          depth eq 0 and
          canBeLogged and
          entityName neq "logentry">
      <cfset var tempLogentry = { "entity" = this, "deleted" = false } />

      <cfif structKeyExists( form, "logentry_note"        )><cfset tempLogentry["note"]       = form.logentry_note       /></cfif>
      <cfif structKeyExists( form, "logentry_attachment"  )><cfset tempLogentry["attachment"] = form.logentry_attachment /></cfif>

      <cfset local.logentry = entityNew( "logentry", tempLogentry ) />
      <cfset entitySave( local.logentry ) />
      <cfset local.logaction = entityLoad( "logaction", { name = "changed" }, true ) />
      <cfset local.logentry.enterIntoLog( local.logaction, savedState ) />

      <cfset request.context.log = local.logentry />
    </cfif>

    <cfreturn this />
  </cffunction>
</cfcomponent>