part of '../social_embed_webview.dart';

Uri _htmlToURI(String code) {
  return Uri.dataFromString(code,
      mimeType: 'text/html', encoding: Encoding.getByName('utf-8'));
}

String _colorToHtmlRGBA(Color c) {
  return 'rgba(${c.red},${c.green},${c.blue},${c.alpha / 255})';
}

SocialMediaGenericEmbedData? _htmlToEmbedData(String embedHtml) {
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
  } else if (embedHtml.contains('blockquote class="twitter-tweet"')) {
    return XTwitterEmbedData(embedHtml: embedHtml);
  }
  return null;
}
