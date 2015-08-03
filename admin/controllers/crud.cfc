component output="false"
{
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public any function init( fw )
  {
    param name="variables.listitems" default="";
    param name="variables.listactions" default=".new";
    param name="variables.lineactions" default=".view,.edit";
    param name="variables.submitButtons" default="#[]#" type="array";
    param name="variables.showNavbar" default="true";
    param name="variables.showSearch" default="false";
    param name="variables.showAlphabet" default="false";
    param name="variables.showPager" default="true";
    param name="variables.entity" default="#fw.getSection()#";

  	variables.fw = fw;

    return this;
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public void function before( rc )
  {
    if( not rc.auth.role.getCanAccessAdmin())
    {
      fw.redirect( "home:" );
    }

    if( fw.getItem() eq "edit" and not rc.auth.role.can( "change", fw.getSection()))
    {
      session.alert = {
        "class" = "danger",
        "text"  = "privileges-error-1"
      };
      fw.redirect( "admin:" );
    }

    session.alert = {
      "class" = "danger",
      "text"  = "privileges-error-2"
    };

    if( rc.auth.role.can( "view", fw.getSection()) or fw.getSection() eq "main" )
    {
      structDelete( session, "alert" );
    }

    if( fw.getSection() eq "api" )
    {
      session.alert = {
        "class" = "danger",
        "text"  = "privileges-error-3"
      };
      fw.redirect( "api:" );
    }

    if( structKeyExists( session, "alert" ))
    {
      fw.redirect( "admin:" );
    }

    variables.entity = fw.getSection();
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public void function default( rc )
  {
    param rc.columns      = [];
    param rc.offset       = 0;
    param rc.maxResults   = 30;
    param rc.d            = 0;// rc.d(escending) default false (ASC)
    param rc.orderby      = "";
    param rc.startsWith   = "";
    param rc.showdeleted  = 0;
    param rc.filters      = [];
    param rc.filterType   = "contains";
    param rc.classColumn  = "";

    // exit controller on non crud items
    switch( fw.getSection())
    {
      case "main":
        var dashboard = lCase( replace( rc.auth.role.getName(), ' ', '-', 'all' ));
        fw.setView( 'admin:main.dashboard-' & dashboard );
        return;
      break;

      case "profile":
        rc.data = entityLoadByPK( "contact", rc.auth.userid );
        fw.setView( 'common:profile.default' );
        return;
      break;
    }

    param rc.lineView     = "common:elements/line";
    param rc.tableView    = "common:elements/table";
    param rc.fallbackView = "common:elements/list";

    // default crud behaviour continues:
    rc.entity = variables.entity;

    // exit with error when trying to control a non-persisted entity
    if( not arrayFindNoCase( structKeyArray( ORMGetSessionFactory().getAllClassMetadata()), variables.entity ))
    {
      session.alert = {
        "class" = "danger",
        "text"  = "not-an-entity-error"
      };

      fw.redirect( "admin:main.default" );
    }

    var object = entityNew( variables.entity );
    var entityProperties = getMetaData( object );

    rc.defaultSort = "";

    if( structKeyExists( entityProperties, "defaultSort" ))
    {
      rc.defaultSort = entityProperties.defaultSort;
    }
    else if( structKeyExists( entityProperties.extends, "defaultSort" ))
    {
      rc.defaultSort = entityProperties.extends.defaultSort;
    }

    // exit out of controller if using a tree view (data retrieval goes through ajax calls instead)
    if( structKeyExists( entityProperties, "list" ))
    {
      rc.tableView  = "common:elements/" & entityProperties.list;

      if( entityProperties.list eq "hierarchy" )
      {
        rc.allColumns = {};
        rc.allData = [];
        rc.showAsTree = true;
        return;
      }
    }

    rc.properties     = object.getInheritedProperties();
    rc.recordCounter  = 0;
    rc.deleteddata    = 0;
    rc.lineactions    = variables.lineactions;
    rc.listactions    = variables.listactions;
    rc.showNavbar     = variables.showNavbar;
    rc.showSearch     = variables.showSearch;
    rc.showAlphabet   = variables.showAlphabet;
    rc.showPager      = variables.showPager;
    rc.showAsTree     = false;
    rc.allColumns     = {};

    if( not structKeyExists( rc, "alldata" )){
      var listArgs = {
        classColumn = rc.classColumn,
        columns     = rc.columns,
        d           = rc.d,
        filters     = rc.filters,
        filterType  = rc.filterType,
        maxResults  = rc.maxResults,
        offset      = rc.offset,
        orderby     = rc.orderby,
        showdeleted = rc.showdeleted,
        startsWith  = rc.startsWith
      };

      for( var key in rc )
      {
        if( not isSimpleValue( rc[key] ))
        {
          continue;
        }

        key = urlDecode( key );

        if( listFirst( key, "_" ) eq "filter" and len( trim( rc[key] )))
        {
          arrayAppend( listArgs.filters, { "field" = listRest( key, "_" ), "filterOn" = replace( rc[key], '''', '''''', 'all' ) });
        }
      }

      rc.alldata = object.list( argumentsCollection = listArgs );
    }

    if( not rc.auth.role.can( "change", variables.entity ))
    {
      var lineactionPointer = listFind( rc.lineactions, '.edit' );
      if( lineactionPointer )
      {
        rc.lineactions = listDeleteAt( rc.lineactions, lineactionPointer );
      }
    }

    if( structKeyExists( entityProperties, "classColumn" ) and len( trim( entityProperties.classColumn )))
    {
      classColumn = entityProperties.classColumn;
    }

    var columnsInList = [];
    var property = "";
    var indexNr = 0;
    var orderNr = 0;
    for( var key in rc.properties )
    {
      property = rc.properties[key];
      orderNr++;
      rc.allColumns[property.name] = property;
      rc.allColumns[property.name].columnIndex = orderNr;
      if( structKeyExists( property, "inlist" ))
      {
        indexNr++;
        columnsInList[indexNr] = property.name;
      }
    }

    if( len( trim( variables.listitems )))
    {
      columnsInList = [];
      for( var listItem in variables.listitems )
      {
        arrayAppend( columnsInList, listItem );
      }
    }

    if( variables.entity eq 'logged' )
    {
      arrayAppend( columnsInList, "entityName" );
      arrayAppend( columnsInList, "name" );
      arrayAppend( columnsInList, "createDate" );
      arrayAppend( columnsInList, "updateDate" );
    }

    var numberOfColumns = arrayLen( columnsInList );

    try
    {
      for( var columnName in columnsInList )
      {
        if( structKeyExists( rc.allColumns, columnName ))
        {
          var property = rc.allColumns[columnName];
          arrayAppend( rc.columns, {
            name        = columnName,
            orderNr     = structKeyExists( property, "cfc" )?0:property.columnIndex,
            orderInList = structKeyExists( property, "orderinlist" )?property.orderinlist:numberOfColumns++,
            class       = structKeyExists( property, "class" )?property.class:'',
            data        = property
          });
        }
      }
    }
    catch( any e )
    {
      writeDump( cfcatch );
      abort;
    }

    // sort the array based on the orderInList value in the structures:
    for( var i=1; i lte arrayLen( rc.columns ); i++ )
    {
      for( var j=(i-1)+1; j gt 1; j-- )
      {
        if( rc.columns[j].orderInList lt rc.columns[j-1].orderInList )
        {
          // swap values
          var temp = rc.columns[j];
          rc.columns[j] = rc.columns[j-1];
          rc.columns[j-1] = temp;
        }
      }
    }
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public void function new( rc )
  {
    if( not rc.auth.role.can( "change", fw.getSection()))
    {
      session.alert = {
        "class" = "danger",
        "text"  = "privileges-error"
      };
      fw.redirect( "admin:#fw.getSection()#.default" );
    }
    return edit( rc = rc );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public void function view( rc )
  {
    rc.editable = false;
    return edit( rc = rc );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public void function edit( rc )
  {
    param name="rc.modal" default="false";
    param name="rc.editable" default="true";
    param name="rc.inline" default="false";
    param name="rc.namePrepend" default="";

    rc.columns = [];
  	rc.entity = variables.entity;
    rc.submitButtons = variables.submitButtons;

  	if( rc.modal )
    {
  	  request.layout = false;
      rc.fallbackView = "common:elements/modaledit";

      if( rc.inline )
      {
        rc.fallbackView = "common:elements/inlineedit";
      }
    }
  	else
    {
      rc.fallbackView = "common:elements/edit";
  	}

    var property = "";
    var indexNr = 0;
    var columnsInForm = [];
    var propertyOwner = {};
    var object = entityNew( rc.entity );
    var propertiesInForm = [];

    rc.entityProperties = getMetaData( object );
    rc.canBeLogged = ( rc.config.log and isInstanceOf( object, "root.model.logged" ));

    if( rc.entity eq "logentry" )
    {
      rc.canBeLogged = false;
    }

    rc.properties = object.getInheritedProperties();

    for( key in rc.properties )
    {
      if( structKeyExists( rc.properties[key], "inform" ))
      {
        arrayAppend( propertiesInForm, rc.properties[key] );
      }
    }

    var numberOfPropertiesInForm = arrayLen( propertiesInForm ) + 10;

    rc.hideDelete = structKeyExists( rc.entityProperties, "hideDelete" );

    if( structKeyExists( rc, "#rc.entity#id" ) and not len( trim( rc["#rc.entity#id"] )))
    {
      structDelete( rc, "#rc.entity#id" );
    }

    if( structKeyExists( rc, "#rc.entity#id" ))
    {
      rc.data = entityLoadByPK( rc.entity, rc["#rc.entity#id"] );
      if( not isDefined( "rc.data" ))
      {
        fw.redirect( rc.entity );
      }
    }
    else
    {
      rc.data = entityNew( rc.entity );
    }

    if( not isDefined( "rc.data" ))
    {
      rc.data = entityNew( rc.entity );
    }

    for( property in propertiesInForm )
    {
      if( structKeyExists( property, "orderinform" ) and isNumeric( property.orderinform ))
      {
        indexNr = property.orderinform;
      }
      else
      {
        indexNr = numberOfPropertiesInForm++;
      }

      columnsInForm[indexNr] = property;
      local.savedValue = evaluate( "rc.data.get#property.name#()" );

      if( not isNull( local.savedValue ))
      {
        if( isArray( local.savedValue ))
        {
          local.savedValueList = "";
          for( local.individualValue in local.savedValue )
          {
            local.savedValueList = listAppend( local.savedValueList, local.individualValue.getID() );
          }
          local.savedValue = local.savedValueList;
        }

        columnsInForm[indexNr].saved = local.savedValue;
      }
      else if( structKeyExists( rc, property.name ))
      {
        columnsInForm[indexNr].saved = rc[property.name];
      }
      else
      {
        columnsInForm[indexNr].saved = "";
      }
    }

    for( columnInForm in columnsInForm )
    {
      if( not isNull( columnInForm ))
      {
        arrayAppend( rc.columns, columnInForm );
      }
    }
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public void function delete( rc )
  {
    if( not rc.auth.role.can( "delete", fw.getSection()))
    {
      session.alert = {
        "class" = "danger",
        "text"  = "privileges-error"
      };
      fw.redirect( "admin:#fw.getSection()#.default" );
    }

    var entityToDelete = entityLoadByPK( "#variables.entity#", rc["#variables.entity#id"] );

    if( not isNull( entityToDelete ))
    {
      entityToDelete.setDeleted( true );

      if( entityToDelete.hasProperty( "log" ))
      {
        local.logentry = entityNew( "logentry", { entity = entityToDelete } );
        local.logaction = entityLoad( "logaction", { name = "removed" }, true );
        rc.log = local.logentry.enterIntoLog( action = local.logaction );
      }
    }

    fw.redirect( ".default" );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public void function restore( rc )
  {
    var entityToRestore = entityLoadByPK( "#variables.entity#", rc["#variables.entity#id"] );

    if( not isNull( entityToRestore ))
    {
      entityToRestore.setDeleted( false );

      if( entityToRestore.hasProperty( "log" ))
      {
        local.logentry = entityNew( "logentry", { entity = entityToRestore } );
        local.logaction = entityLoad( "logaction", { name = "restored" }, true );
        rc.log = local.logentry.enterIntoLog( action = local.logaction );
      }
    }

    fw.redirect( ".view", "#variables.entity#id" );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public void function save( rc )
  {
    if( structCount( form ) eq 0 )
    {
      session.alert = {
        "class" = "danger",
        "text"  = "global-form-error"
      };
      fw.redirect( "admin:#fw.getSection()#.default" );
    }

    if( not rc.auth.role.can( "change", fw.getSection()))
    {
      session.alert = {
        "class" = "danger",
        "text"  = "privileges-error"
      };
      fw.redirect( "admin:#fw.getSection()#.default" );
    }

    // Load existing, or create a new entity
    if( structKeyExists( rc, "#variables.entity#id" ))
    {
      rc.data = entityLoadByPK( variables.entity, rc["#variables.entity#id"] );
    }
    else
    {
      rc.data = entityNew( variables.entity );
      entitySave( rc.data );
    }

    // Log create/update time and user if( object supprts it:
    rc.data = rc.data.save( formData = form );

    if( not ( structKeyExists( rc, "dontredirect" ) and rc.dontredirect ))
    {
      if( structKeyExists( rc, "returnto" ))
      {
        fw.redirect( rc.returnto );
      }
      else
      {
        fw.redirect( ".default" );
      }
    }
  }
}