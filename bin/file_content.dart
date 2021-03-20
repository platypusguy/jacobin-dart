/*
 * Copyright (c) 2021 by Andrew Binstock. All rights reserved.
 * This code is licensed under the Mozilla 2.0 license. For
 * additional information about this project, go to jacobin.org.
 */

import 'dart:typed_data';

class FileContent {
  Uint8List content;

  FileContent( Uint8List contents ) {
    content = contents;
  }

  int length() => content.length;
}

