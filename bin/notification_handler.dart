/*
 * Copyright (c) 2021 by Andrew Binstock. All rights reserved.
 * This code is licensed under the Mozilla 2.0 license. For
 * additional information about this project, go to jacobin.org.
 */

import 'dart:io';
import 'package:intl/intl.dart'; //for formatting numbers

final watch = new Stopwatch();

const int SEVERE  = 0, // the various logging levels. Can't use enums due to arithmetic comparisons
          WARNING = 1,
          CLASS   = 2,
          INFO    = 3,
          FINE    = 4,
          FINEST  = 5;


/* Sets up a minimal logging system.
 * TODO: see if this can be put in its own isolate.
 *
 * author alb
 */
class NotificationHandler {
  int logLevel;

  void start() {
    watch.start();
    setLogLevel( WARNING );
  }

  void setLogLevel( int level ) {
    if( level >= SEVERE && level <= FINEST )
      logLevel = level;
    else {
      logLevel = FINEST;
    }
  }

  void log( String msg, int level ) {
    if( msg != null && ! msg.isEmpty && logLevel >= level ) {
      var f = NumberFormat("00000", "en_US");
      if( level >= CLASS ) {
        stderr.write("[${f.format(watch.elapsedMilliseconds)}ms]" );
      }

      if( level == SEVERE ) {
        stderr.write( "SEVERE: $msg\n" );
      }
      else if( level == WARNING ) {
        stderr.write( "WARNING: $msg\n" );
      }
      else {
        stderr.write("$msg\n");
      }
    }
  }
}