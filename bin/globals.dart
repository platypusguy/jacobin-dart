/*
 * Copyright (c) 2021 by Andrew Binstock. All rights reserved.
 * This code is licensed under the Mozilla 2.0 license. For
 * additional information about this project, go to jacobin.org.
 */

library jacobin.globals;

import 'dart:io' show Platform;
import 'package:file/memory.dart'; //for in-memory files

import 'classloader.dart';
import 'notification_handler.dart';

/* Data structures that need to be globally accessible
 * author: alb
 */

class Globals {
  /// Jacobin version #
  static String jacobinVer = "Jacobin version 0.1.0";

  /// Runtime environment
  static String os = Platform.operatingSystemVersion;
  static String pathSeparator = Platform.pathSeparator;
  static String javaHome = Platform.environment['JAVA_HOME'];
  static Map<String,String> runtimeEnv = Platform.environment;

  /// VM runtime parameters
  static List<String> args; // command-line args
  static String commandLine; // the command-line with spacing normalized

  /// Latest supported version of Java
  static int bytecodeVersion = 55; //55 = Java 11 bytecode

  /// class loaders
  static Classloader bootstrap;
  static Classloader userLoader;

  /// starting point
  static String mainClassName;

  ///Log system and handles notifications to user
  static NotificationHandler logger;

}


