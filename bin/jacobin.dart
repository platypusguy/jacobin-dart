/*
 * Copyright (c) 2021 by Andrew Binstock. All rights reserved.
 * This code is licensed under the Mozilla 2.0 license. For
 * additional information about this project, go to jacobin.org.
 */

///Jacobin VM -- runs Java bytecode
library jacobin;

import 'dart:isolate';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'argsProcessor.dart';
import 'classloader.dart';
import 'custom_exceptions.dart';
import 'globals.dart' as env;
import 'jar_processor.dart' as jarprocess;
import 'method.dart';
import 'notification_handler.dart';
import 'thread_frame.dart';

//SendPort loggerSendPort;

void showUsage(IOSink stream) {
  stream.write( "Helpful info goes here." );
}

/* ===== main line begins here ===== */

void main( List<String> args ) {

/* Attempted to create the logger as isolate.
  startLoggerIsolate();
  loggerSendPort.send( "*start*" );
  loggerSendPort.send( "Hello From Isolate! Rah!" );
*/
  try {
    // Before anything else set up the logger and start the elapsed timer
    env.Globals.logger = new NotificationHandler()
      ..start();
    if (args.contains( "-vverbose" )) {
      env.Globals.logger.setLogLevel( FINEST );
    }

    env.Globals.logger.log( "Starting Jacobin VM", INFO );

    //---- various start-up routines ----//
    env.Globals.bootstrap  = new Classloader();
    env.Globals.userLoader = new Classloader();

    env.Globals.args = args;
    new ArgsProcessor( args )..process();
    if( env.Globals.appArgs == null ) { //no class/JAR to execute was specified
      throw StartingClassNotSpecifiedException;
    }
    else {
      if( env.Globals.appArgs[0].endsWith( ".jar" )) {
        new jarprocess.JarProcessor(); // will insert main() class into globals
        if( env.Globals.mainClassName == null ) {
          throw StartingClassNotSpecifiedException;
        }
      }
      else { //if the first app arg is not a JAR file, it must be a class
        env.Globals.mainClassName = env.Globals.appArgs[0];
        if( ! env.Globals.mainClassName.endsWith( ".class" )) {
          env.Globals.mainClassName += ".class";
        }
      }
    }

    //we now have the name of the starting class and all the args. So, we begin execution.
    env.Globals.methodArea = new SplayTreeSet<Method>();
    env.Globals.threadFrames = <ThreadFrame>{};
    ///curr: get the starting class from the classloader and pass it to the new ThreadFrame below. ******
    env.Globals.threadFrames.add( new ThreadFrame() );

    Uint8List bytes;
    try {
      // read the class's bytes into memory
      bytes = File( env.Globals.mainClassName ).readAsBytesSync();
      env.Globals.logger.log( "[info] starting execution with: ${env.Globals.mainClassName}", CLASS );
    }
    on FileSystemException {
      stderr.write(
        "File ${env.Globals.mainClassName} not found or accessing it caused an error. Exiting." );
      return;
    }
    env.Globals.userLoader.loadClass( env.Globals.mainClassName, bytes );

  }
    on ClassFormatException {
    shutdown(true);
  }
    on StartingClassNotSpecifiedException {
      env.Globals.logger.log( "No starting class found. Aborting", SEVERE );
      showUsage( stdout );
      shutdown( true );
  }
    on UnsupportedClassVersionException {
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

/* *** Unsuccessful attempt to set up logger as isolate ***
void startLoggerIsolate() async {
  var isoReceive = ReceivePort( "logger receive port" );
  env.Globals.loggerIsolate = await Isolate.spawn( loggerAction, isoReceive.sendPort );
  loggerSendPort =  await isoReceive.first;
}

void loggerAction( SendPort sp ) async {
  var rp = new ReceivePort();
  sp.send(rp.sendPort);

  await for (String msg in rp) {
    if (msg == null) return;

    if (msg == "*start*") {
      env.Globals.logger = new NotificationHandler()
        ..start();
    }
    switch (msg) {
      case "*level=FINEST*":
        env.Globals.logger.setLogLevel(FINEST);
        break;
      default:
        env.Globals.logger.log(msg, SEVERE); //TODO: figure out how to send both msg and log level
        break;
    }
  }
} */



