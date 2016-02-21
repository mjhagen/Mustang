component accessors=true {
  property framework;
  property localeService;
  property contentService;
  property designService;

  public void function load( rc ) {
    var locale = localeService.get( rc.currentlocaleID );
    var fqa = framework.getfullyqualifiedaction();
    rc.displaytitle = rc.i18n.translate( fqa );

    if( structKeyExists( rc, "alert" )) {
      param struct rc.alert.stringVariables={};
    }

    // fetch content
    if( !isNull( locale )) {
      var content = contentService.getByFQA( fqa, locale );

      if( arrayLen( content )) {
        rc.content = content;
      }
    }

    // setup navigation
    if( !structKeyExists( rc, "topnav" )){
      rc.topnav = "";
    }

    rc.subnavHideHome = false;

    var reload = true;

    lock scope="session" timeout="5" type="readonly" {
      if( structKeyExists( session, "subnav" )){
        rc.subnav = session.subnav;
        reload = false;
      }
    }

    if( !rc.config.appIsLive || structKeyExists( rc, "reload" )){
      reload = true;
    }

    if( reload ){
      rc.subnav = "";

      if( rc.auth.isLoggedIn && structKeyExists( rc.auth, "role" ) && isObject( rc.auth.role )){
        var roleSubnav = rc.auth.role.getMenuList();
      }

      if( isNull( roleSubnav )){
        var roleSubnav = "";
      }

      if( len( trim( roleSubnav ))){
        for( var navItem in listToArray( roleSubnav )){
          if( navItem == "-" || rc.auth.role.can( "view", navItem )){
            rc.subnav = listAppend( rc.subnav, navItem );
          }
        }
      } else {
        var hiddenMenuitems = "base";
        var subnav = [];
        var tempSortOrder = 9001;

        for( var entityPath in directoryList( framework.mappings['/root'] & '/model', false, 'name', '*.cfc' )){
          var entityName = reverse( listRest( reverse( getFileFromPath( entityPath )), "." ));
          var sortOrder = tempSortOrder++;
          var entity = getMetaData( createObject( "root.model." & entityName ));

          if( structKeyExists( entity, "hide" ) ||
              listFindNoCase( hiddenMenuitems, entityName ) ||
              ( rc.auth.isLoggedIn && !rc.auth.role.can( "view", entityName ))) {
            continue;
          }

          if( structKeyExists( entity, "sortOrder" )){
            sortOrder = entity["sortOrder"];
          }

          subnav[sortOrder] = entityName;
        }

        rc.subnav = arrayToList( subnav );
      }

      lock scope="session" timeout="5" type="exclusive" {
        session.subnav = rc.subnav;
      }
    }

    // load design
    rc.design = designService.load();
  }
}