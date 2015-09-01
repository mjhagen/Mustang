component{
  public any function init( fw ){
    variables.fw = fw;
    return this;
  }

  public void function get( rc ){
    var fqa = fw.getfullyqualifiedaction();
    rc.displaytitle = rc.i18n.translate( fqa );

    // fetch content
    var hql = "FROM content c WHERE c.fullyqualifiedaction = :fqa AND c.locale.id = :locale AND c.deleted != true";
    var params = {
          fqa = fqa,
          locale = rc.currentlocaleID
        };
    var options = {
          cacheable = true
        };
    var content = ormExecuteQuery( hql, params, options );
        
    if( arrayLen( content )){
      rc.content = content[1];
    }

    // setup navigation
    if( !structKeyExists( rc, "topnav" )){
      rc.topnav = "";
    }
    
    rc.subnavHideHome = false;

    if( fw.getSubsystem() == 'admin' ){
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

          for( var entityPath in directoryList( fw.mappings['/root'] & '/model', true, 'name', '*.cfc' )){
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
      }

      lock scope="session" timeout="5" type="exclusive" {
        session.subnav = rc.subnav;
      }
    }

    // load design
    rc.design = createObject( "root.lib.design" ).load();
  }
}