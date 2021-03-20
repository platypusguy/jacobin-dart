/*
 * Copyright (c) 2021 by Andrew Binstock. All rights reserved.
 * This code is licensed under the Mozilla 2.0 license. For
 * additional information about this project, go to jacobin.org.
 */
import 'dart:collection';
import 'dart:typed_data';

import 'package:file/memory.dart';
import 'package:file/file.dart';

import 'file_content.dart';
import 'globals.dart' as env;


class LoadedJar {
  SplayTreeMap<String, File> files;
  Directory thisJar;
  String jarName;

  LoadedJar( String name ) {
    jarName = name;
    // thisJar = env.Globals.userfs.systemTempDirectory.createTempSync( name );
  }
  
  void addFile( String name, Uint8List content ){
    File f = thisJar.childFile( name );
    f.writeAsBytesSync( content );
    files.putIfAbsent( name, () => f );
    // files.putIfAbsent( name, () => content );
  }

  void printAll() {
    for( String s in files.keys ) {
      File actualFile = files[s];
      print( "JAR: ${jarName}, Filename: $s, actualFilename: ${actualFile}");
    }
  }

  getLength( String name ) => files[name].length();

  bool isLoaded( String name ) => files.containsKey( name );

  dynamic getFile( String name ) => name == null ? "" : files[name];
}

