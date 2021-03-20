/*
 * Copyright (c) 2021 by Andrew Binstock. All rights reserved.
 * This code is licensed under the Mozilla 2.0 license. For
 * additional information about this project, go to jacobin.org.
 */

library jacobin.JarProcessor;

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

import 'file_content.dart';
import 'globals.dart' as env;
import 'loaded_jar.dart';
import 'notification_handler.dart';

// import 'package:archive/archive.dart';
// import 'package:archive/archive_io.dart';

/**
 * Processes JAR files. It first reads them into memory, unzips them,
 * looks for the manifest and goes to the Main-Class if specified and
 * begins execution there.
 */

class JarProcessor {

  var bytes;
  LoadedJar jarLoader;

  ///Accepts name of a JAR file and loads its classes into the appropriate classloader
  void process(String jarName ) {
    try {
      // read the JAR's bytes into memory
      bytes = File( jarName ).readAsBytesSync();
      env.Globals.logger.log( "[load:jar][opened $jarName]", CLASS );
    }
    on FileSystemException {
      stderr.write("File $jarName not found or accessing it caused an error. Exiting.");
      return;
    }

    // decocde the zip file
    final archive = ZipDecoder().decodeBytes(bytes);
    if( archive.length > 0 ) {
      jarLoader = new LoadedJar( jarName );
    }
    else {
      env.Globals.logger.log( "Error reading JAR file: $jarName Skipping JAR.", WARNING );
    }

    //read through the uncompressed JAR file (which is a .zip container),
    // and process the files in it
    for( ArchiveFile file in archive ) {
      String filename = file.name;
      file.decompress();
      if (file.isFile && !file.isCompressed) {
        Uint8List fileContents = file.content as Uint8List;

        // JARs can contain documentation files in the META directory. Skip these.
        if( ! filename.endsWith( ".class" ) && ! filename.endsWith( ".MF "))
          continue;

        if ( env.Globals.mainClassName == null &&
             filename.endsWith( "MANIFEST.MF" )) { //Find the main class
          String mainClassName = getMainClassName( fileContents );
          env.Globals.mainClassName = mainClassName;
          env.Globals.logger.log( "Main Class: $mainClassName", CLASS );
        }
        else {
          env.Globals.userLoader.loadClass( file.name, fileContents );
        }
      }
    }
  }

  ///Extracts the main class's name from the manifest file (MANIFEST.MF)
  String getMainClassName( Uint8List manifestData ) {
    String s = Utf8Decoder().convert( manifestData );
    int i = s.indexOf( "Main-Class: " );
    if( i == -1 ) // manifest does not have a main class
      return null;
    i += "Main-Class: ".length; //get class name that comes after this literal
    return( s.substring(i).trimRight() );
  }
}
