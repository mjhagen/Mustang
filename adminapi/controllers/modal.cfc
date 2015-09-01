component extends="apibase"
{
  public void function before( rc )
  {
    if( structKeyExists( rc, "modalContentAsJSON" ) and len( trim( rc.modalContentAsJSON )) and isJSON( rc.modalContentAsJSON ))
    {
      rc.modalContent = deserializeJSON( rc.modalContentAsJSON );
    }

    param name = "rc.modalContent" default = {
      title = '',
      body = '',
      buttons = [
        {
          title = 'close',
          classes = 'btn-primary btn-modal-close'
        }
      ]
    };

    if( structKeyExists( rc, "content" ))
    {
      rc.modalContent.title = rc.content.getTitle();
      rc.modalContent.body = rc.content.getBody();
    }
  }

  public void function open( rc )
  {
    // switch( rc.type )
    // {
    //   default: break;
    // }
  }
}