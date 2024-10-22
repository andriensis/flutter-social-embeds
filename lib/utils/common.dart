import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_social_embeds/platforms/generic_platform.dart';
import 'package:flutter_social_embeds/platforms/instagram.dart';
import 'package:flutter_social_embeds/platforms/tiktok.dart';
import 'package:flutter_social_embeds/platforms/x_twitter.dart';
import 'package:flutter_social_embeds/platforms/youtube.dart';

Uri htmlToURI(String code) {
  return Uri.dataFromString(code,
      mimeType: 'text/html', encoding: Encoding.getByName('utf-8'));
}

String colorToHtmlRGBA(Color c) {
  return 'rgba(${c.red},${c.green},${c.blue},${c.alpha / 255})';
}

SocialMediaGenericEmbedData? htmlToEmbedData(String embedHtml) {
  if (embedHtml.contains('blockquote class="instagram-media"')) {
    return InstagramEmbedData(embedHtml: embedHtml);
  } else if (embedHtml.contains('blockquote class="tiktok-embed"')) {
    return TikTokEmbedData(embedHtml: embedHtml);
  } else if (embedHtml.contains('youtube.com/embed/')) {
    RegExp regex = RegExp(r'youtube\.com\/embed\/([a-zA-Z0-9_-]+)');
    Match? match = regex.firstMatch(embedHtml);

    if (match != null) {
      String videoId = match.group(1)!;
      return YoutubeEmbedData(videoId: videoId);
    }
  } else {
    return XTwitterEmbedData(embedHtml: embedHtml);
  }
  return null;
}
