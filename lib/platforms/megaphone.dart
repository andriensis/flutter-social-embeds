import 'generic_platform.dart';

/// Megaphone playlist player embed data
class MegaphoneEmbedData extends SocialMediaGenericEmbedData {
  /// Megaphone player iframe URL
  final String embedUrl;

  /// Player height in logical pixels
  final double height;

  /// Default height when CMS markup does not specify one
  static const double defaultHeight = 200;

  /// Creates an instance of the embed data
  const MegaphoneEmbedData({
    required this.embedUrl,
    this.height = defaultHeight,
  }) : super(canChangeSize: true);

  /// Builds embed data from CMS markup or a plain Megaphone URL.
  static MegaphoneEmbedData? fromMarkup(String embedHtml) {
    final embedUrl = extractEmbedUrl(embedHtml);
    if (embedUrl == null) return null;
    return MegaphoneEmbedData(
      embedUrl: embedUrl,
      height: extractEmbedHeight(embedHtml),
    );
  }

  /// Extracts a Megaphone player URL from iframe markup or a plain link.
  static String? extractEmbedUrl(String embedHtml) {
    final iframeSrc = RegExp(
      r'''<iframe[^>]+src=["'](https?://playlist\.megaphone\.fm[^"']*)["']''',
      caseSensitive: false,
    ).firstMatch(embedHtml);
    if (iframeSrc != null) {
      return _normalizeUrl(iframeSrc.group(1)!);
    }

    final url = RegExp(
      r'https?://playlist\.megaphone\.fm[^\s"<>]*',
      caseSensitive: false,
    ).firstMatch(embedHtml);
    if (url != null) {
      return _normalizeUrl(url.group(0)!);
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

  static String _normalizeUrl(String url) {
    final uri = Uri.parse(url);
    return uri.replace(scheme: 'https').toString();
  }

  @override
  String get htmlBaseUrl => 'https://playlist.megaphone.fm/';

  @override
  String get htmlScriptUrl => '';

  String get _heightCss =>
      height == height.roundToDouble() ? '${height.toInt()}' : '$height';

  @override
  String get htmlBody =>
      '<div id="megaphone-player" style="left:0;width:100%;height:${_heightCss}px;position:relative;">'
      '<iframe src="$embedUrl" '
      'style="top:0;left:0;width:100%;height:100%;position:absolute;border:0;" '
      'allowfullscreen></iframe></div>';
}
