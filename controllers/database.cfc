component extends=crud accessors=true {
  property framework;
  property contactService;
  property vendorService;
  property syncService;
  property vendorgroupService;

  variables.fields = [
    "ACCNLCC",
    "ACCNLCODE",
    "ACCNLDEPT",
    "ACFLAG",
    "ACTIVE",
    "ALLOCTRANSREV",
    "ALLOWRW",
    "ALTCHRG",
    "ALTITEMNO",
    "ANLCODE",
    "AVCOST",
    "BARCODE",
    "BUDGET1",
    "BUDGET10",
    "BUDGET11",
    "BUDGET12",
    "BUDGET2",
    "BUDGET3",
    "BUDGET4",
    "BUDGET5",
    "BUDGET6",
    "BUDGET7",
    "BUDGET8",
    "BUDGET9",
    "BUYPRICE",
    "CALCODE",
    "CALPER",
    "CAPACITY",
    "CAPTYPE",
    "CEMARK",
    "CHARGEHANDLING",
    "CNTORIGIN",
    "COMCODE",
    "CONDITIONCOST",
    "CONDITIONHOURS",
    "CONSTOCK",
    "COSNLCC",
    "COSNLCODE",
    "COSNLDEPT",
    "CURRDEPOT",
    "CUSTOM",
    "CUSTOMER",
    "DAMAGEWAVER",
    "DATEPURCH",
    "DATESOLD",
    "DATEUSED",
    "DAYSUNAV",
    "DEFCOSTGRP",
    "DEFDEP",
    "DEFRATE",
    "DEPOSIT",
    "DEPOTORIGTYPE",
    "DEPOTPLCODE",
    "DEPOTPOSTED",
    "DEPOTSLCODE",
    "DEPRMETH",
    "DEPTH",
    "DESC1",
    "DESC2",
    "DESC3",
    "DLYCOST",
    "DRIVER",
    "EAN",
    "EXTMEMO",
    "EXTXH",
    "FIREANDTHEFT",
    "FWDORDER",
    "GROSSPRICE",
    "GRPACTIVE",
    "GRPCODE",
    "HANDLINGPERC",
    "HEIGHT",
    "HIDEWP",
    "HPNLCC",
    "HPNLCODE",
    "HPNLDEPT",
    "INSVALUE",
    "INVOHO",
    "ITEMNO",
    "JCCODE",
    "JCCODEXH",
    "JIRECID",
    "JOINACCESS",
    "KITFLAG",
    "LABITEM",
    "LASTHIRE",
    "LASTSER1",
    "LASTSER2",
    "LASTSER3",
    "LASTSER4",
    "LASTSER5",
    "LASTSER6",
    "LIFECOSTS",
    "LIFEDEPR",
    "LIFEREV",
    "LMTDREV",
    "LOCATION",
    "LYTDREV",
    "MANUF",
    "MASTREC",
    "MAXSTK",
    "MEMTYPE",
    "METER",
    "METERED",
    "METERTOTAL",
    "MINSTK",
    "MSTCODE",
    "MTDCOSTS",
    "MTDREV",
    "NLCC",
    "NLCODE",
    "NLDEPT",
    "NODISC",
    "NOFAR",
    "NONSTOCK",
    "NORESALE",
    "NOSUSP",
    "NOTES",
    "OHSTATUS",
    "ONORDER",
    "PACK",
    "PACKPURC",
    "PACKSELL",
    "PALOAD",
    "PALOADUN",
    "PATLASTPERIOD",
    "PATLASTSER",
    "PATPERIOD",
    "PATPERIODTYPE",
    "PATTEST",
    "PERIOD1",
    "PERIOD2",
    "PERIOD3",
    "PERIOD4",
    "PERIOD5",
    "PERIOD6",
    "PERLAST1",
    "PERLAST2",
    "PERLAST3",
    "PERLAST4",
    "PERLAST5",
    "PERLAST6",
    "PERTYPE1",
    "PERTYPE2",
    "PERTYPE3",
    "PERTYPE4",
    "PERTYPE5",
    "PERTYPE6",
    "PGROUP",
    "PIRECID",
    "PRICE",
    "PRL",
    "PRLTYPE",
    "PURINV",
    "PURORD",
    "QTYALLOC",
    "QTYHIRE",
    "QTYIT",
    "QTYITJ",
    "QTYITJA",
    "QTYREP",
    "QTYSER",
    "QTYTBOM",
    "QTYTEMP",
    "QTYWIP",
    "READDATE",
    "RECID",
    "RECORDER",
    "REORDER",
    "RV",
    "SDEPT",
    "SDESC1",
    "SDESC2",
    "SDESC3",
    "SERNO",
    "SHOWTB",
    "SID",
    "SIRECID",
    "SNLCC",
    "SNLCODE",
    "SNLDEPT",
    "SOLD",
    "SOLDBY",
    "SPNLCC",
    "SPNLCODE",
    "SPNLDEPT",
    "SSPARRECID",
    "STARTFINYEARWDV",
    "STATUS",
    "STDCOST",
    "STERDEPT",
    "STKLEVEL",
    "SUPERSEDEDFROM",
    "SUPPDESC",
    "SUPPLIER",
    "SUPPREF",
    "SWL",
    "SWLOAD",
    "SWLOADUN",
    "SWLTYPE",
    "TCDATE",
    "TCNO",
    "TEMPHIRE",
    "TEST1",
    "TEST10",
    "TEST11",
    "TEST12",
    "TEST13",
    "TEST14",
    "TEST15",
    "TEST2",
    "TEST3",
    "TEST4",
    "TEST5",
    "TEST6",
    "TEST7",
    "TEST8",
    "TEST9",
    "THUMBNAIL",
    "TOTHIRE",
    "TOTHOURS",
    "TRUEUNQTY",
    "TYPE",
    "UNIQUE",
    "USAGEDAYS",
    "USEDFOR",
    "USEDPRICE",
    "USETEMPL1",
    "USETEMPL2",
    "USETEMPL3",
    "USETEMPL4",
    "USETEMPL5",
    "USETEMPL6",
    "USETEMPL7",
    "UTYPE",
    "VATCODE",
    "VATCODEPL",
    "VEHRENTAL",
    "WEIGHT",
    "WEIGHTING",
    "WIDTH",
    "WIPNLCC",
    "WIPNLCODE",
    "WIPNLDEPT",
    "XHIREALLOC",
    "XHIRELEVEL",
    "XHNLCC",
    "XHNLCODE",
    "XHNLDEPT",
    "XRNLCC",
    "XRNLCODE",
    "XRNLDEPT",
    "YTDCOSTS",
    "YTDDEPR",
    "YTDREV"
  ];

  public void function default( rc ) {
    var contact = contactService.get( rc.auth.user.getID());
    var vendor  = contact.getVendor();

    if( isNull( vendor )) {
      rc.groups = [];
    } else {
      if( structKeyExists( rc, "id" ) && len( trim( rc.id ))) {
        rc.group = vendorgroupService.get( rc.id );
      }

      try{
        if( !structKeyExists( rc, "group" )) {
          rc.group = entityLoad( 'vendorgroup', { deleted=false, vendor=vendor, parent=javaCast( "null", 0 )}, true );
        }
        rc.groups = entityLoad( 'vendorgroup', { deleted=false, vendor=vendor, parent=rc.group });
      } catch( any e ) {
        structDelete( rc, "group" );
        rc.groups = entityLoad( 'vendorgroup', { deleted=false, vendor=vendor, parent=javaCast( "null", 0 )});
      }
    }
  }

  public void function sync( required struct rc ) {
    if( structKeyExists( rc, "vendorID" )) {
      var vendor = vendorService.get( rc.vendorID );
    }

    if( isNull( vendor )) {
      var contact = contactService.get( rc.auth.userID );
      var vendor = contact.getVendor();
    }

    rc.alert = { "class" = "danger", "text"  = "missing-vendor" };

    if( !isNull( vendor )) {
      syncService.setVendor( vendor );
      rc.result = syncService.sync();
      structDelete( rc, "alert" );
    }

    if( structKeyExists( rc, "alert" )) {
      framework.redirect( ".default", "alert" );
    }
  }

  public void function importSource( rc ) {
    rc.util.setCFSetting( "requesttimeout", 600 );
    createObject( "java", "coldfusion.tagext.lang.SettingTag" ).setRequestTimeout( 600 );
    // setting requesttimeout=600;

    lock scope="session" timeout="30" {
      if( not structKeyExists( session, "src" ) or structKeyExists( url, "reload")) {
        session.src = excelToQuery( request.fileUploads & "/VerhuurlijstV2.xls" );
      }    // src.sort( src.findColumn( "PGROUP" ), TRUE );

      var src = session.src;
    }

    var maxRows = src.recordCount;

    ORMExecuteQuery( "DELETE FROM product" );
    ORMExecuteQuery( "DELETE FROM group" );

    var importStruct = {};
    var importedProducts = {};

    // convert query to struct
    for( var row=1; row lte maxRows; row++ ) {
      local.groupID = src["ANLCODE"][row];
      local.subgroupID = src["PGROUP"][row];
      local.pgroupID = src["GRPCODE"][row];

      if(
          val( local.groupID ) eq 0 or
          val( local.subgroupID ) eq 0 or
          val( local.pgroupID ) eq 0 or
          structKeyExists( importedProducts, local.pgroupID )
        ) {
        continue;
      }

      if( not structKeyExists( importStruct, local.groupID )) {
        importStruct[local.groupID] = {};
      }

      if( not structKeyExists( importStruct[local.groupID], local.subgroupID )) {
        importStruct[local.groupID][local.subgroupID] = [];
      }

      local.fullRecord = {
        "name" = src["DESC1"][row]
      };

      for( local.field in variables.fields ) {
        local.value = src[local.field][row];

        if(
            isNull( local.value ) or
            ( isNumeric( local.value ) and val( local.value ) eq 0 ) or
            local.value eq ""
          ) {
          continue;
        }

        local.fullRecord[local.field] = local.value;
      }

      arrayAppend( importStruct[local.groupID][local.subgroupID], local.fullRecord );
      importedProducts[local.pgroupID] = 1;
    }

    var errors = [];

    var rootGroup = entityNew( "vendorgroup" );
    entitySave( rootGroup );
    rootGroup.setName( "ROOT" );

    // import struct into ORM database
    for( var groupID in importStruct ) {
      local.group = entityNew( "vendorgroup" );
      entitySave( local.group );
      local.group.setName( groupID );
      local.group.setParent( rootGroup );

      for( var subGroupID in importStruct[groupID] ) {
        local.subGroup = entityNew( "vendorgroup" );
        entitySave( local.subGroup );
        local.subGroup.setName( subGroupID );
        local.subGroup.setParent( local.group );
        local.group.addChild( local.subGroup );

        for( var productStruct in importStruct[groupID][subGroupID] ) {
          local.data = serializeJSON( productStruct );

          if( len( local.data ) gt 4000 ) {
            arrayAppend( errors, productStruct );
            continue;
          }

          local.defaultproduct = entityNew( "defaultproduct" );
          entitySave( local.defaultproduct );
          local.defaultproduct.setData( local.data );
          local.defaultproduct.setGroup( local.subGroup );
          local.subGroup.addProduct( local.defaultproduct );
        }
      }
    }

    writeOutput( 'Done.' );

    writeDump( errors );

    abort;
  }

  public query function excelToQuery( required string fileNameStr ) {
    var xlsObj = SpreadsheetRead( fileNameStr );

    /* Extract the workbook object from the spreadsheet */
    var workbookObj = xlsObj.getWorkBook();
    var sheetIndex = workbookObj.getActiveSheetIndex();

    /* Extract the sheet */
    var sheetObj = workbookObj.getSheetAt( sheetIndex );

    /* Extract column names (values in the first row in Excel sheet) */
    var rowObj = sheetObj.getRow(0);
    var columnList = "";

    for( headerCellIdx=0; headerCellIdx < rowObj.getLastCellNum(); headerCellIdx++ ) {
      var headerCellObj = rowObj.getCell(headerCellIdx);
      var headerCellValue = reReplaceNoCase( headerCellObj.getRichStringCellValue().getString(), '[^a-z0-9]', '', 'all' );
      columnList = ListAppend( columnList, headerCellValue );
    }

    /* Create new query object */
    var outputQry = QueryNew( columnList );

    /* Fetch the DateUtil object (POI), we'll need it later */
    var DateUtilObj = createObject("java","org.apache.poi.hssf.usermodel.HSSFDateUtil");

    /* Loop through the sheet. Mind that the iterator starts with 0 as we are using a Java method
    but we ignore the data from the first row as it contains column labels!  */
    for( rowIdx=1; rowIdx < sheetObj.getLastRowNum(); rowIdx++ ) {
      /* Extract row */
      var rowObj = sheetObj.getRow(rowIdx);

      /* Add a new row to the query */
      QueryAddRow(outputQry);

      /* Extract cell and pass it to the query */
      for( cellIdx=0; cellIdx < rowObj.getLastCellNum(); cellIdx++ ) {
        var cellObj = rowObj.getCell( cellIdx );

        if( isNull( cellObj )) {
          continue;
        }

        var cellValue = "";

        /* Please note that I ignore cellTypes CELL_TYPE_ERROR, CELL_TYPE_FORMULA and CELL_TYPE_BLANK as they are not relevant to me. Add your own handlers if you need them */
        if( cellObj.getCellType() eq cellObj.CELL_TYPE_STRING ) {
          cellValue = cellObj.getStringCellValue().toString();
        }
        else if( cellObj.getCellType() eq cellObj.CELL_TYPE_BOOLEAN ) {
          cellValue = cellObj.getBooleanCellValue();
        }
        else if( cellObj.getCellType() eq cellObj.CELL_TYPE_NUMERIC ) {
          if( DateUtilObj.isCellDateFormatted( cellObj )) {
            cellValue = cellObj.getDateCellValue();
          }
          else {
            cellValue = cellObj.getNumericCellValue();
          }
        }

        /* Set query cell to the spreadsheet cell value. Mind the iterators! Coldfusion starts with 1 */
        QuerySetCell( outputQry, ListGetAt( columnList, cellIdx+1 ), cellValue,rowIdx );
      }
    }

    return outputQry;
  }

  function saveProduct() {
  	if( structKeyExists( rc, 'id' )) {
  		var vendorproduct   = entityLoadByPK( 'vendorproduct' , rc.id );

  		if( not isDefined( 'vendorproduct' )) {
	      var contact         = entityLoadByPK( 'contact' , rc.auth.user.getID());
	      var vendor          = contact.getVendor();
		  	var defaultproduct  = entityLoadByPK( 'defaultproduct' , rc.id );
		  	var vendorproduct   = entityLoad( 'vendorproduct' , { vendor = vendor , defaultproduct = defaultproduct } , true );
		  	var group           = defaultproduct.getGroup();


		  	if( not isDefined( 'vendorproduct' )) {
		  		var vendorproduct = entityNew( 'vendorproduct' );
	        entitySave( vendorproduct );

	        vendorproduct.setVendor( vendor );
	        vendorproduct.setDefaultproduct( defaultproduct );
	        vendorproduct.setGroup( group );
	      }
      }

	  	if( isDefined( 'vendorproduct')) {
		  	saveStruct = {};

		  	for( fieldname in listToArray( rc.fieldnames )) {

		  		if( not listFindNoCase( 'id' , fieldname )) {
			  		if( len( fieldname ) gt 5 && left( fieldname , 5 ) eq 'file_' ) {
			  			//file
			  			dbfieldname = replaceNoCase( fieldname , 'file_' , '' , 'ONCE' );

			  			if( not structKeyExists( saveStruct, dbfieldname )) {
				        saveStruct[ dbfieldname ] = [];
				        for( filename in rc[ fieldname ] ) {
				          saveStruct[ dbfieldname ][ arrayLen( saveStruct[ dbfieldname ] )+1 ] = filename;
				        }

			  			}

			  		} else {
			  			//default
			  			if( not structKeyExists( saveStruct, fieldname ))
	              saveStruct[ fieldname ] = rc[ fieldname ];
			  		}
		  		}
			  }

		    vendorproduct.setData( serializeJSON( saveStruct ));
      }
  	}

    rc.alert = {
      "class" = "success",
      "text"  = "product-saved"
    };
    framework.redirect( "database", "alert" );
  }
}