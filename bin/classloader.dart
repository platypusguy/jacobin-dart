/*
 * Copyright (c) 2021 by Andrew Binstock. All rights reserved.
 * This code is licensed under the Mozilla 2.0 license. For
 * additional information about this project, go to jacobin.org.
 */

import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'custom_exceptions.dart';
import 'globals.dart' as env;
import 'notification_handler.dart';

///Loads classes from files into memory and makes them accessible to the JVM
class Classloader {
  ///directory holding the contents of the classloader
  SplayTreeMap<String, Uint8List> dir;

  ///simple constructor creates an empty directory to hold classes
  Classloader() {
    dir = new SplayTreeMap<String, Uint8List>();
  }

  ///loading a class means entering its name and contents into the class loader's directory
  ///throw custom errors: ClassFormatError and UnsupportedClassVersionError--which are both fatal
  void loadClass( String name, Uint8List contents ) {
    if( validateClass( contents )) {
      if( validateSupportedJavaVersion( contents )) {
        dir.putIfAbsent( name, () => contents );
        env.Globals.logger.log( "[class,load] $name", CLASS );
      }
      else {
        env.Globals.logger.log( "This JVM does not support the bytecode version in: $name", SEVERE );
        throw UnsupportedClassVersionException();
      }
    }
    else {
      env.Globals.logger.log( "Invalid Class: $name", SEVERE );
      throw ClassFormatException();
    }
  }

  ///validates whether the class contains the required magic value
  bool validateClass( Uint8List classBytes ) {
    if( classBytes == null ) return false;
    if( classBytes[0] == 0xCA && classBytes [1] == 0xFE &&
        classBytes[2] == 0xBA && classBytes [3] == 0xBE )
      return( true );
    else
      return( false );
  }

  ///validates that the class bytecode version is valid on this VM (55 = Java 11)
  bool validateSupportedJavaVersion( Uint8List classBytes ){
    return( classBytes[7] <= env.Globals.bytecodeVersion ? true : false );
  }

  ///looks up the class by name and returns the contents, or null if it hasn't been loaded
  getClass( name ) {
    return( dir.containsKey( name ) ? dir[name] : null );
  }

  ///prints the contents of a classloader to stderr. Used only for diagnostic purposes
  print() {
    for( String name in dir.keys ) {
      int classSize = dir[name].length;
      stderr.write( "class: $name size: ${classSize}\n" );
    }
  }
}
