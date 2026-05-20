import 'generic_platform.dart';

/// Spotify embed data
class SpotifyEmbedData extends SocialMediaGenericEmbedData {
  /// Spotify embed iframe URL (`/embed/{type}/{id}`)
  final String embedUrl;

  /// Player height in logical pixels
  final double height;

  /// Default height for playlist/album embeds
  static const double defaultHeight = 352;

  /// Supported Spotify content types in embed paths
  static const Set<String> _embedTypes = {
    'track',
    'album',
    'playlist',
    'episode',
    'show',
    'artist',
  };

  /// Creates an instance of the embed data
  const SpotifyEmbedData({
    required this.embedUrl,
    this.height = defaultHeight,
  }) : super(canChangeSize: true);

  /// Builds embed data from CMS markup or a plain Spotify URL.
  static SpotifyEmbedData? fromMarkup(String embedHtml) {
    final rawUrl = extractEmbedUrl(embedHtml);
    if (rawUrl == null) return null;
    final embedUrl = toEmbedUrl(rawUrl);
    return SpotifyEmbedData(
      embedUrl: embedUrl,
      height: extractEmbedHeight(embedHtml, embedUrl: embedUrl),
    );
  }

  /// Extracts a Spotify URL from iframe markup or a plain link.
  static String? extractEmbedUrl(String embedHtml) {
    final iframeSrc = RegExp(
      r'''<iframe[^>]+src=["'](https?://open\.spotify\.com/[^"']+)["']''',
      caseSensitive: false,
    ).firstMatch(embedHtml);
    if (iframeSrc != null) {
      return _normalizeUrl(iframeSrc.group(1)!);
    }

    final url = RegExp(
      r'https?://open\.spotify\.com/[^\s"<>]+',
      caseSensitive: false,
    ).firstMatch(embedHtml);
    if (url != null) {
      return _normalizeUrl(url.group(0)!);
    }

    return null;
  }

  /// Reads `height: …px` from wrapper styles, else a type-based default.
  static double extractEmbedHeight(
    String embedHtml, {
    required String embedUrl,
  }) {
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

    return defaultHeightForType(_embedTypeFromUrl(embedUrl));
  }

  /// Converts share URLs to `open.spotify.com/embed/...` iframe URLs.
  static String toEmbedUrl(String url) {
    final uri = Uri.parse(_normalizeUrl(url));
    final segments =
        uri.pathSegments.where((segment) => segment.isNotEmpty).toList();
    if (segments.isEmpty) return uri.toString();

    if (segments.first == 'embed') {
      return uri.toString();
    }

    if (segments.length >= 2 && _embedTypes.contains(segments[0])) {
      final type = segments[0];
      final id = segments[1];
      return Uri(
        scheme: 'https',
        host: 'open.spotify.com',
        path: '/embed/$type/$id',
        queryParameters:
            uri.queryParameters.isEmpty ? null : uri.queryParameters,
      ).toString();
    }

    return uri.toString();
  }

  /// Default iframe height when CMS markup omits an explicit height.
  static double defaultHeightForType(String? type) {
    switch (type) {
      case 'track':
        return 152;
      case 'episode':
      case 'show':
        return 232;
      default:
        return defaultHeight;
    }
  }

  static String? _embedTypeFromUrl(String url) {
    final segments = Uri.parse(url)
        .pathSegments
        .where((segment) => segment.isNotEmpty)
        .toList();
    if (segments.isEmpty) return null;
    if (segments.first == 'embed') {
      return segments.length >= 2 ? segments[1] : null;
    }
    return segments.first;
  }

  static String _normalizeUrl(String url) {
    final uri = Uri.parse(url);
    return uri.replace(scheme: 'https').toString();
  }

  @override
  String get htmlBaseUrl => 'https://open.spotify.com/';

  @override
  String get htmlScriptUrl => '';

  String get _heightCss =>
      height == height.roundToDouble() ? '${height.toInt()}' : '$height';

  @override
  String get htmlBody =>
      '<div id="spotify-player" style="left:0;width:100%;height:${_heightCss}px;position:relative;">'
      '<iframe src="$embedUrl" '
      'style="top:0;left:0;width:100%;height:100%;position:absolute;border:0;border-radius:12px;" '
      'allowfullscreen '
      'allow="clipboard-write *; encrypted-media *; fullscreen *; picture-in-picture *;">'
      '</iframe></div>';
}
