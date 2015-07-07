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
    param name="rc.columns" default="#[]#";
    param name="rc.offset" default="0";
    param name="rc.maxResults" default="30";
    param name="rc.d" default="0";// rc.d(escending) default false (ASC)
    param name="rc.orderby" default="";
    param name="rc.startsWith" default="";
    param name="rc.showdeleted" default="0";
    param name="rc.filters" default="#[]#";
    param name="rc.filterType" default="contains";
    param name="rc.classColumn" default="";

    // exit controller on non crud items
    switch( fw.getSection())
    {
      case "main":
        var dashboard = lCase( replace( rc.auth.role.getName(), ' ', '-', 'all' ));
        fw.setView( 'admin:main.dashboard-' & dashboard );
        return;
      break;

      case "profile":
        fw.setView( 'common:profile.default' );
        return;
      break;
    }

    param name="rc.lineView" default="common:elements/line";
    param name="rc.tableView" default="common:elements/table";
    param name="rc.fallbackView" default="common:elements/list";

    // default crud behaviour continues:
    rc.entity = variables.entity;

    if( not structKeyExists( ORMGetSessionFactory().getAllClassMetadata(), rc.entity ))
    {
      // exit with error when trying to control a non-persisted entity
      session.alert = {
        "class" = "danger",
        "text"  = "not-an-entity-error"
      };
      fw.redirect( "admin:main.default" );
    }

    var object = entityNew( rc.entity );
    var entityProperties = getMetaData( object );
    var property = "";
    var indexNr = 0;
    var orderNr = 0;
    var columnName = "";
    var columnsInList = [];
    var orderByString = "";
    var queryOptions = { ignorecase = true, maxResults = rc.maxResults, offset = rc.offset };

    rc.recordCounter = 0;
    rc.deleteddata   = 0;
    rc.properties    = object.getInheritedProperties();
    rc.lineactions   = variables.lineactions;
    rc.listactions   = variables.listactions;
    rc.showNavbar    = variables.showNavbar;
    rc.showSearch    = variables.showSearch;
    rc.showAlphabet  = variables.showAlphabet;
    rc.showPager     = variables.showPager;
    rc.showAsTree    = false;

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

    if( not rc.auth.role.can( "change", rc.entity ))
    {
      local.lineactionPointer = listFind( rc.lineactions, '.edit' );
      if( local.lineactionPointer )
      {
        rc.lineactions = listDeleteAt( rc.lineactions, local.lineactionPointer );
      }
    }

    if( structKeyExists( entityProperties, "classColumn" ) and len( trim( entityProperties.classColumn )))
    {
      rc.classColumn = entityProperties.classColumn;
    }

    if( structKeyExists( entityProperties, "defaultSort" ))
    {
      rc.defaultSort = entityProperties.defaultSort;
    }
    else if( structKeyExists( entityProperties.extends, "defaultSort" ))
    {
      rc.defaultSort = entityProperties.extends.defaultSort;
    }
    else
    {
      rc.defaultSort = "";
    }

    if( len( trim( rc.orderby )))
    {
      local.vettedOrderByString = "";

      for( var orderField in listToArray( rc.orderby ))
      {
        if( orderField contains ';' )
        {
          continue;
        }

        if( orderField contains ' ASC' or orderField contains ' DESC' )
        {
          orderField = listFirst( orderField, ' ' );
        }

        if( structKeyExists( rc.properties, orderField ))
        {
          local.vettedOrderByString = listAppend( local.vettedOrderByString, orderField );
        }
      }

      rc.orderby = local.vettedOrderByString;

      if( len( trim( rc.orderby )))
      {
        rc.defaultSort = rc.orderby & ( rc.d ? ' DESC' : '' );
      }
    }

    rc.orderby = replaceNoCase( rc.defaultSort, ' ASC', '', 'all' );
    rc.orderby = replaceNoCase( rc.orderby, ' DESC', '', 'all' );

    if( rc.defaultSort contains ' DESC' )
    {
      rc.d = 1;
    }
    else if( rc.defaultSort contains ' ASC' )
    {
      rc.d = 0;
    }

    for( orderByPart in listToArray( rc.defaultSort ))
    {
      orderByString = listAppend( orderByString, "mainEntity.#orderByPart#" );
    }

    if( len( trim( rc.startsWith )))
    {
      rc.filters = [{
        "field" = "name",
        "filterOn" = replace( rc.startsWith, '''', '''''', 'all' )
      }];
      rc.filterType = "starts-with";
    }

    for( key in rc )
    {
      if( not isSimpleValue( rc[key] ))
      {
        continue;
      }

      key = urlDecode( key );

      if( listFirst( key, "_" ) eq "filter" and len( trim( rc[key] )))
      {
        arrayAppend( rc.filters, { "field" = listRest( key, "_" ), "filterOn" = replace( rc[key], '''', '''''', 'all' ) });
      }
    }

    if( not structKeyExists( rc, "alldata" ))
    {
      if( arrayLen( rc.filters ))
      {
        var alsoFilterKeys = structFindKey( rc.properties, 'alsoFilter' );
        var alsoFilterEntity = "";
        var whereBlock = " WHERE 0 = 0 ";
        var whereParameters = {};
        var counter = 0;

        if( rc.showdeleted eq 0 )
        {
          whereBlock &= " AND ( mainEntity.deleted IS NULL OR mainEntity.deleted = false ) ";
        }

        for( filter in rc.filters )
        {
          if( len( filter.field ) gt 2 and right( filter.field, 2 ) eq "id" )
          {
            whereBlock &= "AND mainEntity.#left( filter.field, len( filter.field ) - 2 )# = ( FROM #left( filter.field, len( filter.field ) - 2 )# WHERE id = :where_id )";
            whereParameters["where_id"] = filter.filterOn;
          }
          else
          {
            if( filter.filterOn eq "NULL" )
            {
              whereBlock &= " AND ( ";
              whereBlock &= " mainEntity.#lCase( filter.field )# IS NULL ";
            }
            else if( structKeyExists( rc.properties[filter.field], "cfc" ))
            {
              whereBlock &= " AND ( ";
              whereBlock &= " mainEntity.#lCase( filter.field )#.id = :where_#lCase( filter.field )# ";
              whereParameters["where_#lCase( filter.field )#"] = filter.filterOn;
            }
            else
            {
              if( rc.filterType eq "contains" )
              {
                filter.filterOn = "%#filter.filterOn#";
              }

              filter.filterOn = "#filter.filterOn#%";

              whereBlock &= " AND ( ";
              whereBlock &= " mainEntity.#lCase( filter.field )# LIKE :where_#lCase( filter.field )# ";
              whereParameters["where_#lCase( filter.field )#"] = filter.filterOn;
            }

            for( alsoFilterKey in alsoFilterKeys )
            {
              if( alsoFilterKey.owner.name neq filter.field )
              {
                continue;
              }

              counter++;
              alsoFilterEntity &= " LEFT JOIN mainEntity.#listFirst( alsoFilterKey.owner.alsoFilter, '.' )# AS entity_#counter# ";
              whereBlock &= " OR entity_#counter#.#listLast( alsoFilterKey.owner.alsoFilter, '.' )# LIKE '#filter.filterOn#' ";
              whereParameters["where_#listLast( alsoFilterKey.owner.alsoFilter, '.' )#"] = filter.filterOn;
            }
            whereBlock &= " ) ";
          }
        }

        if( structKeyExists( entityProperties, "where" ) and len( trim( entityProperties.where )))
        {
          whereBlock &= entityProperties.where;
        }

        var HQLcounter  = " SELECT COUNT( mainEntity ) AS total ";
        var HQLselector  = " SELECT mainEntity ";

        HQL = "";
        HQL &= " FROM #lCase( rc.entity )# mainEntity ";
        HQL &= alsoFilterEntity;
        HQL &= whereBlock;

        HQLcounter = HQLcounter & HQL;
        HQLselector = HQLselector & HQL;

        if( len( trim( orderByString )))
        {
          HQLselector &= " ORDER BY #orderByString# ";
        }

        rc.alldata = ORMExecuteQuery( HQLselector, whereParameters, queryOptions );

        if( arrayLen( rc.alldata ) gt 0 )
        {
          rc.recordCounter = ORMExecuteQuery( HQLcounter, whereParameters, { ignorecase = true })[1];
        }
      }
      else
      {
        HQL = " FROM #lCase( rc.entity )# mainEntity ";

        if( rc.showDeleted )
        {
          HQL &= " WHERE mainEntity.deleted = TRUE ";
        }
        else
        {
          HQL &= " WHERE ( mainEntity.deleted IS NULL OR mainEntity.deleted = FALSE ) ";
        }

        if( len( trim( orderByString )))
        {
          HQL &= " ORDER BY #orderByString# ";
        }

        try
        {
          rc.alldata = ORMExecuteQuery( HQL, {}, queryOptions );
        }
        catch( any e )
        {
          writeDump( e );
          abort;
          rc.alldata = [];
        }

        if( arrayLen( rc.alldata ) gt 0 )
        {
          rc.recordCounter = ORMExecuteQuery( "SELECT COUNT( e ) AS total FROM #lCase( rc.entity )# AS e WHERE e.deleted != :deleted", { "deleted" = true }, { ignorecase = true })[1];
          rc.deleteddata = ORMExecuteQuery( "SELECT COUNT( mainEntity.id ) AS total FROM #lCase( rc.entity )# AS mainEntity WHERE mainEntity.deleted = :deleted", { "deleted" = true } )[1];

          if( rc.showdeleted )
          {
            rc.recordCounter = rc.deleteddata;
          }
        }
      }
    }

    rc.allColumns = {};

    indexNr = 0;

    for( key in rc.properties )
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
      for( local.listItem in variables.listitems )
      {
        arrayAppend( columnsInList, local.listItem );
      }
    }

    numberOfColumns = arrayLen( columnsInList );

    for( columnName in columnsInList )
    {
      try
      {
        if( structKeyExists( rc.allColumns, columnName ))
        {
          property = rc.allColumns[columnName];
          arrayAppend( rc.columns, {
            name = columnName,
            orderNr = structKeyExists( property, "cfc" )?0:property.columnIndex,
            orderInList = structKeyExists( property, "orderinlist" )?property.orderinlist:numberOfColumns++,
            class = structKeyExists( property, "class" )?property.class:'',
            data = property
          });
        }
      }
      catch( any e )
      {
        writeDump( cfcatch );
        abort;
      }
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
    rc.canBeLogged = rc.config.log;

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