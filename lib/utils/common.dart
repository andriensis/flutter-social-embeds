import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_social_embeds/platforms/generic_platform.dart';
import 'package:flutter_social_embeds/platforms/instagram.dart';

Uri htmlToURI(String code) {
  return Uri.dataFromString(code,
      mimeType: 'text/html', encoding: Encoding.getByName('utf-8'));
}

String colorToHtmlRGBA(Color c) {
  return 'rgba(${c.red},${c.green},${c.blue},${c.alpha / 255})';
}

SocialMediaGenericEmbedData htmlToEmbedData(String embedHtml) {
  return InstagramEmbedData(embedHtml: embedHtml);
}
