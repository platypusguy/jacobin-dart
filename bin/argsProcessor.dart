/*
 * Copyright (c) 2021 by Andrew Binstock. All rights reserved.
 * This code is licensed under the Mozilla 2.0 license. For
 * additional information about this project, go to jacobin.org.
 */

import 'dart:io' show Platform;

import 'globals.dart' as env;
import 'notification_handler.dart';

///Processes all the args to the running program

class ArgsProcessor {
  List<String> cliArgs; // strings passed on the command line when Jacobin invoked
  var argTable = new Map<String, String>(); // holds the parameters and their arguments, if any

  ArgsProcessor( List<String> args ) {
    cliArgs = args;
  }
  
  ///the main function. It gathers all the CLI parameters and puts then into a table,
  ///which holds each param and its value (if any). The talbe is then stored in the globals.
  void process() {
    String commandLine = gatherArgs();
    
    //copy the unparsed command line to globals for future reference and log it.
    env.Globals.commandLine = commandLine;
    env.Globals.logger.log( "Command line: ${env.Globals.commandLine}", INFO );

    //parse the command line into parameters and put them into a table/map.
    parseCommandLine( commandLine, argTable );
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
  
  //takes a string that is part or all of the command line and 
  // parses it into parameters/switches and their values and places them into a table/map
  parseCommandLine( String commandLine, Map<String,String> argsTable ) {
      List<String> args = commandLine.split( " " );
      for( String arg in args ) {
        //CURR resume here. e.g., check for -XX: and see if they have any associated numeric values
      }
  }

  ///several environment variables contains arg to be added to the command-line.
  ///this function fetches them
  String getArgsFromEnvironment( String envVariable ) {
    String javaToolOptions = Platform.environment[envVariable];
    return( javaToolOptions == null ? "" : javaToolOptions );
  }
}

