/*
 * Copyright (c) 2021 by Andrew Binstock. All rights reserved.
 * This code is licensed under the Mozilla 2.0 license. For
 * additional information about this project, go to jacobin.org.
 */

import 'dart:io' show IOSink, Platform, stderr, stdout;

import 'globals.dart' as env;
import 'jacobin.dart';
import 'notification_handler.dart';

///Processes all the args for the running program



class ArgsProcessor {
  List<String> cliArgs; // strings passed on the command line when Jacobin invoked

  ArgsProcessor( List<String> args ) {
    cliArgs = args;
    env.Globals.vmArgs = new Map<String, String>(); //holds the VM parameters
    env.Globals.appArgs= []; //holds the app args. appArgs[0] is the name of the JAR or class to run
  }
  
  ///the main function. It gathers all the CLI parameters and puts then into a table,
  ///which holds each param and its value (if any). The talbe is then stored in the globals.
  void process() {
    String commandLine = gatherArgs();
    
    //copy the unparsed command line to globals for future reference and log it.
    env.Globals.commandLine = commandLine;
    env.Globals.logger.log( "Command line: ${env.Globals.commandLine}", INFO );

    //parse the command line into parameters and put them into a table/map.
    parseCommandLine( commandLine );
  }

  //gathers all the switches and CLI params from all the various sources and 
  //creates a full command line.
  String gatherArgs() {
    String envArgs = getEnvArgs(); //first get the args stored in environmental variables
    var sb = new StringBuffer( envArgs );
    if( sb.isNotEmpty ) sb.write( " " );

    //now add the args that were on the command-line when the program was run
    sb.writeAll( cliArgs, " " );
    String completeCommandLine = sb.toString().trimRight();
    return completeCommandLine;
  }

  ///get args from the many places that the JVM supports beyond just the command line. Then,
  ///mash them together with the args on the command line and come up with a complete command line.
  ///Note that the order in which these locations are checked is prescribed in the JVM spec
  String getEnvArgs() {
    var evolvingCommandLine = new StringBuffer();

    String newArgs = getArgsFromEnvironment( "JAVA_TOOL_OPTIONS" );
    if( newArgs.isNotEmpty ) evolvingCommandLine.write( "$newArgs " );

    newArgs = getArgsFromEnvironment( "_JAVA_OPTIONS" );
    if( newArgs.isNotEmpty ) evolvingCommandLine.write( "$newArgs " );

    newArgs = getArgsFromEnvironment( "JDK_JAVA_OPTIONS" );
    if( newArgs.isNotEmpty ) evolvingCommandLine.write( "$newArgs" );

    return( evolvingCommandLine.toString().trimRight() );
  }
  
  ///takes the command line and parses it into parameters/switches.
  ///once the JAR or class we're running is specified, we gather all the remaining args
  ///into the List<String> appArgs, which starts with the name of the JAR or class, so
  ///in most cases, appArgs.length will be >= 1. The exception being if the command line
  ///executes something else such as "-help" or show the version number, etc.
  parseCommandLine( String commandLine ) {
    bool inAppArgs = false; // will be true once we know the name of the JAR or class that
                            // will be executed

    //split the command line into args and then parse each arg successively
    List<String> args = commandLine.split( " " );
    for( String arg in args ) {
      if( inAppArgs ) { //we know the JAR or class to be run, remaining args are all for the app
        env.Globals.appArgs.add( arg );
        continue;
      }

      if( arg.startsWith( "-XX:" )) { //experimental features, none currently supported
        env.Globals.logger.log( "$arg is not supported. Ignored.", WARNING );
        continue;
      }

      if( arg.startsWith( "-X" )) { //lesser-used options, some supported
        switch( arg ) {
          case( "-X"):              // =print info on -X switches that are supporte. TODO
          case( "-Xint" ):          // =interpret-only, no JITing, which is our only run mode
            env.Globals.vmArgs.putIfAbsent( arg, () => null );
            break;
          default:
            env.Globals.logger.log( "$arg is not supported. Ignored.", WARNING );
            break;
        }
        continue;
      }

      if( arg == '-jar' || ! arg.startsWith( "-" )) {
        inAppArgs = true;
        if( arg != '-jar') //we're executing a class, add its name to the appArgs List
          env.Globals.appArgs.add( arg );
        continue;
      }

      switch( arg ) {
        case "--help":
          showUsage( stdout );
          shutdown( false );
          break;
        case "-?":
        case "-h":
        case "-help":
          showUsage( stderr );
          shutdown( false );
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
        case "-vverbose": // =very verbose; unique to Jacobin, not part of the JDK
          env.Globals.logger.setLogLevel( FINEST );
          break;
        case "--version":
          print( env.Globals.jacobinVer );
          shutdown( false );
          break;
        case "-version":
          stderr.write( env.Globals.jacobinVer );
          shutdown( false );
          break;
        default:
          stderr.write( "Invalid parameter ${arg} ignored." );
          break;
      }
    }
  }

  ///several environment variables contains arg to be added to the command-line.
  ///this function fetches them
  String getArgsFromEnvironment( String envVariable ) {
    String javaToolOptions = Platform.environment[envVariable];
    return( javaToolOptions == null ? "" : javaToolOptions );
  }

  ///the usage screen that's shown the user in the case of an error in the command-line or
  ///the a request to show usage via -help and related command-line parameters
  void showUsage( IOSink stream ) {
    stream.write( "Helpful info goes here." ); //will eventually contain the full info.
  }
}

