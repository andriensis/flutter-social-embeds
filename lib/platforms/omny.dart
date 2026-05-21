import 'generic_platform.dart';

/// Omny.fm audio embed data
class OmnyEmbedData extends SocialMediaGenericEmbedData {
  /// Player iframe URL (always the `/embed` player endpoint)
  final String embedUrl;

  /// Player height in logical pixels
  final double height;

  /// Default height when CMS markup does not specify one
  static const double defaultHeight = 180;

  /// Creates an instance of the embed data
  const OmnyEmbedData({
    required this.embedUrl,
    this.height = defaultHeight,
  }) : super(canChangeSize: true);

  /// Builds embed data from CMS markup or a plain Omny URL.
  static OmnyEmbedData? fromMarkup(String embedHtml) {
    final rawUrl = extractEmbedUrl(embedHtml);
    if (rawUrl == null) return null;
    return OmnyEmbedData(
      embedUrl: toPlayerEmbedUrl(rawUrl),
      height: extractEmbedHeight(embedHtml),
    );
  }

  /// Extracts an Omny URL from iframe markup or a plain link.
  static String? extractEmbedUrl(String embedHtml) {
    final iframeSrc = RegExp(
      r'''<iframe[^>]+src=["'](https?://(?:www\.)?omny\.fm/[^"']+)["']''',
      caseSensitive: false,
    ).firstMatch(embedHtml);
    if (iframeSrc != null) {
      return _normalizeUrl(iframeSrc.group(1)!);
    }

    final url = RegExp(
      r'https?://(?:www\.)?omny\.fm/[^\s"<>]+',
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

  /// Omny episode pages must use the `/embed` player URL inside an iframe.
  static String toPlayerEmbedUrl(String url) {
    final uri = Uri.parse(_normalizeUrl(url));
    if (uri.path.endsWith('/embed')) {
      return uri.toString();
    }
    final path = uri.path.endsWith('/') ? uri.path : '${uri.path}/';
    return uri.replace(path: '${path}embed').toString();
  }

  static String _normalizeUrl(String url) {
    final uri = Uri.parse(url);
    return uri.replace(scheme: 'https').toString();
  }

  @override
  String get htmlBaseUrl => 'https://omny.fm/';

  @override
  String get htmlScriptUrl => '';

  String get _heightCss =>
      height == height.roundToDouble() ? '${height.toInt()}' : '$height';

  @override
  String get htmlBody =>
      '<div id="omny-player" style="left:0;width:100%;height:${_heightCss}px;position:relative;">'
      '<iframe src="$embedUrl" '
      'style="top:0;left:0;width:100%;height:100%;position:absolute;border:0;" '
      'allow="autoplay" allowfullscreen></iframe></div>';
}
