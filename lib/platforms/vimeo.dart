import 'generic_platform.dart';

/// Vimeo player embed data
class VimeoEmbedData extends SocialMediaGenericEmbedData {
  /// Vimeo player iframe URL (`player.vimeo.com/video/{id}`)
  final String embedUrl;

  /// Creates an instance of the embed data
  const VimeoEmbedData({required this.embedUrl})
      : super(
          aspectRatio: 16 / 9,
          canChangeSize: false,
        );

  /// Builds embed data from CMS markup or a plain Vimeo URL.
  static VimeoEmbedData? fromMarkup(String embedHtml) {
    final embedUrl = extractEmbedUrl(embedHtml);
    if (embedUrl == null) return null;
    return VimeoEmbedData(embedUrl: toEmbedUrl(embedUrl));
  }

  /// Extracts a Vimeo player or permalink URL from markup.
  static String? extractEmbedUrl(String embedHtml) {
    final iframeSrc = RegExp(
      r'''<iframe[^>]+src=["'](https?://player\.vimeo\.com/[^"']+)["']''',
      caseSensitive: false,
    ).firstMatch(embedHtml);
    if (iframeSrc != null) {
      return _normalizeUrl(iframeSrc.group(1)!);
    }

    final playerUrl = RegExp(
      r'https?://player\.vimeo\.com/[^\s"<>]+',
      caseSensitive: false,
    ).firstMatch(embedHtml);
    if (playerUrl != null) {
      return _normalizeUrl(playerUrl.group(0)!);
    }

    final permalink = RegExp(
      r'https?://(?:www\.)?vimeo\.com/[^\s"<>]+',
      caseSensitive: false,
    ).firstMatch(embedHtml);
    if (permalink != null) {
      return _normalizeUrl(permalink.group(0)!);
    }

    return null;
  }

  /// Converts permalinks to `player.vimeo.com` URLs; preserves query params.
  static String toEmbedUrl(String url) {
    final uri = Uri.parse(_normalizeUrl(url));
    if (uri.host == 'player.vimeo.com') {
      return uri.toString();
    }

    final videoId = _videoIdFromUri(uri);
    if (videoId != null) {
      return Uri(
        scheme: 'https',
        host: 'player.vimeo.com',
        path: '/video/$videoId',
        queryParameters:
            uri.queryParameters.isEmpty ? null : uri.queryParameters,
      ).toString();
    }

    return uri.toString();
  }

  static String? _videoIdFromUri(Uri uri) {
    final segments =
        uri.pathSegments.where((segment) => segment.isNotEmpty).toList();
    if (segments.isEmpty) return null;

    if (segments.first == 'video' && segments.length >= 2) {
      return segments[1];
    }

    if (RegExp(r'^\d+$').hasMatch(segments.first)) {
      return segments.first;
    }

    return null;
  }

  static String _normalizeUrl(String url) {
    final uri = Uri.parse(url);
    return uri.replace(scheme: 'https').toString();
  }

  @override
  String get htmlBaseUrl => 'https://player.vimeo.com/';

  @override
  String get htmlScriptUrl => '';

  @override
  String get htmlBody =>
      '<div style="left:0;width:100%;height:0;position:relative;padding-bottom:56.25%;">'
      '<iframe src="$embedUrl" '
      'style="top:0;left:0;width:100%;height:100%;position:absolute;border:0;" '
      'allowfullscreen scrolling="no" allow="encrypted-media *;"></iframe>'
      '</div>';
}
