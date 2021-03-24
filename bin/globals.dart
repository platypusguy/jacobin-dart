/*
 * Copyright (c) 2021 by Andrew Binstock. All rights reserved.
 * This code is licensed under the Mozilla 2.0 license. For
 * additional information about this project, go to jacobin.org.
 */

library jacobin.globals;

import 'dart:collection';
import 'dart:io' show Platform;

import 'classloader.dart';
import 'method.dart';
import 'notification_handler.dart';
import 'thread_frame.dart';

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
  static String userCommandLine; // the command line as specified by the user
  static String fullCommandLine; // the command line when optional env args are added, if any.
  static Map<String, String> vmArgs; //the args that appear before the executable's name are VM args
  static List<String> appArgs; //the args to the app. appArgs[0] is the JAR or class to run

  /// Latest supported version of Java
  static int bytecodeVersion = 55; //55 = Java 11 bytecode

  /// class loaders
  static Classloader bootstrap;
  static Classloader userLoader;

  /// JVM-wide data structures
  static SplayTreeSet<Method> methodArea;  // JVM method area
  static Set<ThreadFrame> threadFrames;  // Array of running threads

  /// starting point
  static String mainClassName;

  ///Log system and handles notifications to user
  static NotificationHandler logger;

}


