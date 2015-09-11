component extends="crud" accessors=true {
  property contactService;

  public void function default( required struct rc ) {
    if( structKeyExists( rc, "orderby" ) && listFindNoCase( rc.orderby, "fullname" )) {
      rc.orderby = replaceNoCase( rc.orderby, "fullname", "lastname,firstname" );
    }

    super.default( rc = rc );
  }

  public void function save( required struct rc ) {
    rc.dontredirect = true;

    if( structKeyExists( rc, "password" ) && !len( trim( rc.password ))) {
      structDelete( rc, "password" );
      if( structKeyExists( form, "password" )) {
        structDelete( form, "password" );
      }
    }

    super.save( rc = rc ); // sets rc.data to the saved entity

    if( structKeyExists( rc, "password" ) && len( trim( rc.password ))) {
      if( len( trim( rc.password )) lt 2 ) {
        lock scope="session" timeout="5" type="exclusive" {
        session.alert = {
          "class" = "danger",
          "text"  = "password-too-short"
        };
        }
      } else {
        rc.data.setPassword( contactService.hashPassword( rc.password ));
      }
    }

    fw.redirect( ".default" );
  }
}