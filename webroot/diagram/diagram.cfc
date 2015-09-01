component accessors=true {
  property name="reload" default="false";
  property name="format" default="svg";

  variables.jl = new javaloader.javaloader( loadColdFusionClassPath = true, loadPaths = [
    "#request.config.lmPath#/lib/oy-lm-1.4.jar"
  ] );

  public any function init() {
    return this;
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  remote any function get() {
    var cachedFile = replace( request.config.outputImage, '.', '-', 'all' ) & "." & getFormat();

    if( !fileExists( cachedFile ) || getReload()) {
      var conf = jl.create( "org.hibernate.cfg.Configuration" ).init();
      for( var hbmxmlFile in directoryList( request.config.modelPath, true, "path", "*.hbmxml" )) {
        conf.addXML( reReplace( fileRead( hbmxmlFile ), 'cfc:[^"]+\.', '', 'all' ));
      }
      conf.buildMappings();

      var opt = jl.create( "com.oy.shared.lm.ant.TaskOptions" ).init();
      opt.caption = "Diagram of ORM";

      return outputAsSVG( graph = jl.create( "com.oy.shared.lm.ext.HBMCtoGRAPH" ).load( opt, conf ));
    }

    return outputAsSVG( cachedFile = cachedFile );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  private any function outputAsSVG( any graph, string cachedFile="" ) {
    if( cachedFile == "" ) {
      cachedFile = replace( request.config.outputImage, '.', '-', 'all' ) & ".svg";

      var dotFile = replace( request.config.outputImage, '.', '-', 'all' ) & ".dot";
      var FileOutputStream = createObject( "java", "java.io.FileOutputStream" ).init( dotFile );

      var GRAPHtoDOT = jl.create( "com.oy.shared.lm.out.GRAPHtoDOT" );
          GRAPHtoDOT.transform( graph, FileOutputStream );

      FileOutputStream.close();

      lock scope="server" timeout="10" {
        var oRuntime = createObject("java", "java.lang.Runtime").getRuntime();
            oRuntime.exec( "#request.config.lmPath#/bin/graphviz-2.4/bin/dot.exe -Tsvg #dotFile# -o #cachedFile#" );

        removeFile( dotFile );
      }
    }

    var svgContent = fileRead( cachedFile, "utf-8" );
        svgContent = mid( svgContent, findNoCase( '<svg', svgContent ), len( svgContent ));
        svgContent = reReplaceNoCase( svgContent, '<a [^>]+>', '', 'all' );
        svgContent = replaceNoCase( svgContent, '</a>', '', 'all' );
        svgContent = trim( reReplace( svgContent, "\s{2,}|\n+|<!--(.*?)-->", " ", "all" ));
        svgContent = reReplaceNoCase( svgContent, '>\s+<', '><', 'all' );
        svgContent = reReplaceNoCase( svgContent, '\s?=\s?', '=', 'all' );

    return svgContent;
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  private void function outputAsImage( required any graph, string format = "gif" ) {
    var response = getPageContext().getFusionContext().getResponse();
        response.setContentType( "image/#format#" );

    var outputStream = response.getOutputStream();

    var GRAPHtoDOTtoGIF = jl.create( "com.oy.shared.lm.out.GRAPHtoDOTtoGIF" );
        GRAPHtoDOTtoGIF.transform( graph, "output.dot", request.config.outputImage, "#request.config.lmPath#/bin/graphviz-2.4/bin/dot.exe" );

    var byteArrayInputStream = createObject( "java", "java.io.ByteArrayInputStream" ).init( fileReadBinary( request.config.outputImage ));

    var imageIO = createObject( "java", "javax.imageio.ImageIO" );
        imageIO.write( imageIO.read( byteArrayInputStream ), format, outputStream );

    removeFile( request.config.outputImage );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  private void function removeFile( required string file ) {
    try {
      fileDelete( file );
    } catch( any e ) {

    }
  }
}