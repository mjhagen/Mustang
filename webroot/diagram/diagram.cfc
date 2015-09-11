component accessors=true {
  property name="reload" default=false;
  property name="format" default="svg";

  variables.jl = new javaloader.javaloader( loadColdFusionClassPath = true, loadPaths = [
    "#request.config.lmPath#/lib/oy-lm-1.4.jar"
  ] );

  public any function init() {
    return this;
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  remote string function get() {
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
  private string function outputAsSVG( any graph, string cachedFile="" ) {
    if( cachedFile != "" && fileExists( cachedFile )) {
      return fileRead( cachedFile, "utf-8" );
    }

    var svgFile = replace( request.config.outputImage, '.', '-', 'all' ) & ".svg";
    var dotFile = replace( request.config.outputImage, '.', '-', 'all' ) & ".dot";
    var FileOutputStream = createObject( "java", "java.io.FileOutputStream" ).init( dotFile );
    var GRAPHtoDOT = jl.create( "com.oy.shared.lm.out.GRAPHtoDOT" );

    GRAPHtoDOT.transform( graph, FileOutputStream );

    FileOutputStream.close();

    lock scope="server" timeout="10" {
      var Runtime = createObject("java", "java.lang.Runtime").getRuntime();

      Runtime.exec( "#request.config.lmPath#/bin/graphviz-2.4/bin/dot.exe -Tsvg #dotFile# -o #svgFile#" );
      Runtime.gc();

      removeFile( dotFile );
    }

    var svgContent = fileRead( svgFile, "utf-8" );

    svgContent = mid( svgContent, findNoCase( '<svg', svgContent ), len( svgContent ));
    svgContent = reReplaceNoCase( svgContent, '<a [^>]+>', '', 'all' );
    svgContent = replaceNoCase( svgContent, '</a>', '', 'all' );
    svgContent = trim( reReplace( svgContent, "\s{2,}|\n+|<!--(.*?)-->", " ", "all" ));
    svgContent = reReplaceNoCase( svgContent, '>\s+<', '><', 'all' );
    svgContent = reReplaceNoCase( svgContent, '\s?=\s?', '=', 'all' );
    svgContent = reReplaceNoCase( svgContent, '<title>[^<]+</title>', '', 'all' );

    fileWrite( svgFile, svgContent, "utf-8" );

    return fileRead( svgFile, "utf-8" );;
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  private void function removeFile( required string file ) {
    try {
      fileDelete( file );
    } catch( any e ) {

    }
  }
}