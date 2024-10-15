import 'dart:convert';

import 'package:flutter/material.dart';

Uri htmlToURI(String code) {
  return Uri.dataFromString(code,
      mimeType: 'text/html', encoding: Encoding.getByName('utf-8'));
}

String colorToHtmlRGBA(Color c) {
  return 'rgba(${c.red},${c.green},${c.blue},${c.alpha / 255})';
}
