import 'generic_platform.dart';

/// TikTok embed data
class TikTokEmbedData extends SocialMediaGenericEmbedData {
  /// TikTok video id (kept as a string to avoid JS integer precision loss)
  final String videoId;

  /// Creates an instance of the embed data
  /// Default iframe height; the WebView resizes to match after load.
  static const double embedHeight = 920;

  const TikTokEmbedData({required this.videoId}) : super(canChangeSize: true);

  /// Extracts a video id from blockquote, iframe, or TikTok URL markup.
  static String? extractVideoId(String embedHtml) {
    final dataVideoId =
        RegExp(r'data-video-id="(\d+)"').firstMatch(embedHtml);
    if (dataVideoId != null) return dataVideoId.group(1);

    final cite = RegExp(
      r'cite="https?://(?:www\.)?tiktok\.com/[^"]*?/video/(\d+)"',
    ).firstMatch(embedHtml);
    if (cite != null) return cite.group(1);

    final embedUrl =
        RegExp(r'tiktok\.com/embed(?:/v2)?/(\d+)').firstMatch(embedHtml);
    if (embedUrl != null) return embedUrl.group(1);

    final videoUrl =
        RegExp(r'tiktok\.com/@[^/]+/video/(\d+)').firstMatch(embedHtml);
    if (videoUrl != null) return videoUrl.group(1);

    return null;
  }

  @override
  String get htmlBaseUrl => 'https://www.tiktok.com/';

  @override
  String get htmlScriptUrl => '';

  @override
  String get htmlBody =>
      '<iframe src="https://www.tiktok.com/embed/v2/$videoId" '
      'style="width:100%;min-width:325px;max-width:605px;height:${embedHeight}px;border:0;" '
      'allow="encrypted-media; fullscreen; picture-in-picture" '
      'referrerpolicy="strict-origin-when-cross-origin"></iframe>';
}
