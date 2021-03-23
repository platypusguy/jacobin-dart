/*
 * Copyright (c) 2021 by Andrew Binstock. All rights reserved.
 * This code is licensed under the Mozilla 2.0 license. For
 * additional information about this project, go to jacobin.org.
 */

///the following exceptions mirror the terminology used in the JDK--except they're called errors in
///Java. They are renamed to exceptions here to conform to Dart naming conventions
class ClassFormatException implements Exception{}
class UnsupportedClassVersionException implements Exception {}

///the following exceptions are used by Jacobin and don't necessarily have counterparts in the JDK
class ClassNotSpecified implements Exception{}


