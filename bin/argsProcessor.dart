/*
 * Copyright (c) 2021 by Andrew Binstock. All rights reserved.
 * This code is licensed under the Mozilla 2.0 license. For
 * additional information about this project, go to jacobin.org.
 */

import 'dart:io' show Platform;

///Processes all the args to the running program

class ArgsProcessor {
  List<String> cliArgs; // strings passed on the command line when Jacobin invoked
  String envArgs;       // strings passed to the JDK via environmental variables

  ArgsProcessor( List<String> args ) {
    cliArgs = args;
  }

  void gatherArgs() {
    envArgs = getEnvArgs();
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

  ///several environment variables contains arg to be added to the command-line. this fetches them
  String getArgsFromEnvironment( String envVariable ) {
    String javaToolOptions = Platform.environment[envVariable];
    return( javaToolOptions == null ? "" : javaToolOptions );
  }
}

