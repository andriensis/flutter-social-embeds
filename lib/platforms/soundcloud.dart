import 'generic_platform.dart';

/// SoundCloud player embed data
class SoundCloudEmbedData extends SocialMediaGenericEmbedData {
  /// SoundCloud widget iframe URL (`w.soundcloud.com/player/`)
  final String embedUrl;

  /// Player height in logical pixels
  final double height;

  /// Default height when CMS markup does not specify one
  static const double defaultHeight = 166;

  /// Creates an instance of the embed data
  const SoundCloudEmbedData({
    required this.embedUrl,
    this.height = defaultHeight,
  }) : super(canChangeSize: true);

  /// Builds embed data from CMS markup or a plain SoundCloud URL.
  static SoundCloudEmbedData? fromMarkup(String embedHtml) {
    final rawUrl = extractEmbedUrl(embedHtml);
    if (rawUrl == null) return null;
    return SoundCloudEmbedData(
      embedUrl: toEmbedUrl(rawUrl),
      height: extractEmbedHeight(embedHtml),
    );
  }

  /// Extracts a SoundCloud or widget player URL from markup.
  static String? extractEmbedUrl(String embedHtml) {
    final iframeSrc = RegExp(
      r'''<iframe[^>]+src=["'](https?://w\.soundcloud\.com/[^"']+)["']''',
      caseSensitive: false,
    ).firstMatch(embedHtml);
    if (iframeSrc != null) {
      return _normalizeUrl(iframeSrc.group(1)!);
    }

    final trackUrl = RegExp(
      r'https?://(?:www\.)?soundcloud\.com/[^\s"<>]+',
      caseSensitive: false,
    ).firstMatch(embedHtml);
    if (trackUrl != null) {
      return _normalizeUrl(trackUrl.group(0)!);
    }

    return null;
  }

  /// Reads `height: …px` from wrapper styles, else [defaultHeight].
  static double extractEmbedHeight(String embedHtml) {
    final styleHeight = RegExp(
      r'height:\s*(\d+(?:\.\d+)?)\s*px',
      caseSensitive: false,
    ).firstMatch(embedHtml);
    if (styleHeight != null) {
      return double.parse(styleHeight.group(1)!);
    }

    final attrHeight = RegExp(
      r'''height=["'](\d+(?:\.\d+)?)''',
      caseSensitive: false,
    ).firstMatch(embedHtml);
    if (attrHeight != null) {
      return double.parse(attrHeight.group(1)!);
    }

    return defaultHeight;
  }

  /// Converts track permalinks to the `w.soundcloud.com/player` widget URL.
  ///
  /// Widget options (`visual`, `show_artwork`, `show_comments`, etc.) are taken
  /// from the source URL query string. CMS iframe URLs are returned unchanged.
  static String toEmbedUrl(String url) {
    final uri = Uri.parse(_normalizeUrl(url));
    if (uri.host == 'w.soundcloud.com') {
      return uri.toString();
    }

    if (uri.host.contains('soundcloud.com')) {
      final trackUri = uri.replace(query: null, fragment: '');
      final params = Map<String, String>.from(uri.queryParameters);
      params['url'] = trackUri.toString();
      return Uri(
        scheme: 'https',
        host: 'w.soundcloud.com',
        path: '/player/',
        queryParameters: params,
      ).toString();
    }

    return uri.toString();
  }

  static String _normalizeUrl(String url) {
    final uri = Uri.parse(url);
    return uri.replace(scheme: 'https').toString();
  }

  @override
  String get htmlBaseUrl => 'https://w.soundcloud.com/';

  @override
  String get htmlScriptUrl => '';

  String get _heightCss =>
      height == height.roundToDouble() ? '${height.toInt()}' : '$height';

  @override
  String get htmlBody =>
      '<div id="soundcloud-player" style="left:0;width:100%;height:${_heightCss}px;position:relative;">'
      '<iframe src="$embedUrl" '
      'style="top:0;left:0;width:100%;height:100%;position:absolute;border:0;" '
      'allowfullscreen></iframe></div>';
}
