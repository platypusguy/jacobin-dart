/*
 * Copyright (c) 2021 by Andrew Binstock. All rights reserved.
 * This code is licensed under the Mozilla 2.0 license. For
 * additional information about this project, go to jacobin.org.
 */

///Jacobin VM -- runs Java bytecode
library jacobin;

import 'dart:io';
import 'dart:typed_data';

import 'classloader.dart';
import 'custom_errors.dart';
import 'globals.dart' as env;
import 'jar_processor.dart' as jarprocess;
import 'notification_handler.dart';

void showUsage(IOSink stream) {
  stream.write( "Helpful info goes here." );
}

/* ===== main line begins here ===== */

void main( List<String> args ) {
  try {
    // Before anything else set up the logger and start the elapsed timer
    env.Globals.logger = new NotificationHandler() //TODO: consider passing in the args
      ..start();
    if (args.contains( "-vverbose" )) {
      env.Globals.logger.setLogLevel( FINEST );
    }

    env.Globals.logger.log( "Starting Jacobin VM", INFO );

    //---- various start-up routines ----//
    env.Globals.bootstrap  = new Classloader();
    env.Globals.userLoader = new Classloader();

    env.Globals.args = args;

    // remove formatting from command line, then add it to globals
    var commandLine = new StringBuffer();
    for( String arg in args ) {
      commandLine.write( arg + " " );
    }
    env.Globals.commandLine = commandLine.toString().trimRight();
    env.Globals.logger.log( "Command line: ${env.Globals.commandLine}", INFO );

    String jarName = null;
    String className;
    Set<String> appParams = new Set<String>();

    for( int i = 0; i < args.length; i++ ) {
      if ( args[i] == "-jar" ) {
        i += 1;
        jarName = args[i++];
        while ( i < args.length )
          appParams.add( args[i++] );

        env.Globals.logger.log( "JAR: $jarName APP PARAMS: $appParams", CLASS );
        break;
      }
      else if( ! args[i].startsWith( "-") && args[i].endsWith( ".class" )) {
        className = args[i];
        while ( i < args.length )
          appParams.add( args[i++] );
      }
      else {
        switch ( args[i] ) {
          case "--help":
            showUsage( stdout );
            exit( 0 );
            break;
          case "-?":
          case "-h":
          case "-help":
            showUsage( stderr );
            exit( 0 );
            break;
          case "--show-version":
            stderr.write( env.Globals.jacobinVer );
            break;
          case "-showversion":
            print( env.Globals.jacobinVer );
            break;
          case "-verbose:class":
            env.Globals.logger.setLogLevel( CLASS );
            break;
          case "-vverbose": //unique to Jacobin, not part of the JDK
            env.Globals.logger.setLogLevel( FINEST );
            break;
          case "--version":
            print(env.Globals.jacobinVer);
            exit(0);
            break;
          case "-version":
            stderr.write(env.Globals.jacobinVer);
            exit(0);
            break;
          default:
            stderr.write( "Invalid parameter ${args[i]} ignored." );
            break;
        }
      }
    }

    if( jarName != null ) {
      var handleJar = new jarprocess.JarProcessor();
      handleJar.process( jarName );
    }
    else if( className != null ){
      Uint8List bytes;
      try {
        // read the class's bytes into memory
        bytes = File( className ).readAsBytesSync();
        env.Globals.logger.log( "[load:class][opened $className]", CLASS );
      }
      on FileSystemException {
        stderr.write("File $className not found or accessing it caused an error. Exiting.");
        return;
      }
      env.Globals.mainClassName = className;
      env.Globals.logger.log( "Main Class: $className", CLASS );
      env.Globals.userLoader.loadClass( className, bytes );
    }
  } on ClassFormatError {
      shutdown( true );
    }
    on UnsupportedClassVersionError {
    shutdown( true );
  }
  shutdown( false );
}

//shutdown the VM. Pass it a flag, which is true if an error caused the shutdown, false otherwise.
void shutdown( bool dueToError ) {
  if( dueToError ) {
    stderr.write( "Shutting down due to previous error." );
    exit( -1 );
  }
  else exit( 0 );
}
  // ArgParser argParser = new ArgParser();
  //   argParser.addOption('classpath', abbr: 'c', defaultsTo: '.', help:
  //               'class search path of directories and zip/jar files' );
  //   // ..addFlag('enableassertions', abbr: 'ea', help: 'enable assertions',
  //   //            defaultsTo: false )
  //   // ..addFlag( "disableassertions", abbr: 'da', help: 'diable assertions',
  //   //            defaultsTo: true );
  //


