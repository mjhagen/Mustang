<!doctype html>
<html>
  <head>
    <title>Entity Relationship</title>
  </head>
  <body>
    <cfscript>
      jl = new javaloader.javaloader( loadColdFusionClassPath = true, loadPaths = [
        "#request.lmPath#\lib\oy-lm-1.4.jar",
        "#request.lmPath#\bin\junit-3.8.1.jar"
      ] );

      Configuration = jl.create( "org.hibernate.cfg.Configuration" );
      HBMCtoGRAPH = jl.create( "com.oy.shared.lm.ext.HBMCtoGRAPH" );
      TaskOptions = jl.create( "com.oy.shared.lm.ant.TaskOptions" );
      GRAPHtoDOTtoGIF = jl.create( "com.oy.shared.lm.out.GRAPHtoDOTtoGIF" );

      conf = Configuration.init();

      for( hbmxmlFile in directoryList( request.modelpath, false, "path", "*.hbmxml" ))
      {
        conf.addXML( replace( fileRead( hbmxmlFile ), 'cfc:root.model.', '', 'all' ));
      }

      conf.buildMappings();

      opt = TaskOptions.init();
      opt.caption = "Diagram of ORM";
      opt.colors = "##FCE08B, black, blue";

      graph = HBMCtoGRAPH.load( opt, conf );

      GRAPHtoDOTtoGIF.transform(
        graph,
        "output.dot", expandPath( "./output.gif" ), "#request.lmPath#\bin\graphviz-2.4\bin\dot.exe"
      );
    </cfscript>
    <img src="output.gif" />
  </body>
</html>
<cfsetting showdebugoutput=false />