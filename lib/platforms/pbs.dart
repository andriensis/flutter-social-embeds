import 'generic_platform.dart';

/// PBS viral player embed data
class PbsEmbedData extends SocialMediaGenericEmbedData {
  /// PBS player iframe URL (`player.pbs.org/viralplayer/{id}`)
  final String embedUrl;

  /// Creates an instance of the embed data
  const PbsEmbedData({required this.embedUrl})
      : super(
          aspectRatio: 16 / 9,
          canChangeSize: false,
        );

  /// Builds embed data from CMS markup or a plain PBS player URL.
  static PbsEmbedData? fromMarkup(String embedHtml) {
    final embedUrl = extractEmbedUrl(embedHtml);
    if (embedUrl == null) return null;
    return PbsEmbedData(embedUrl: toEmbedUrl(embedUrl));
  }

  /// Extracts a PBS viral player URL from iframe markup or a plain link.
  static String? extractEmbedUrl(String embedHtml) {
    final iframeSrc = RegExp(
      r'''<iframe[^>]+src=["'](https?://player\.pbs\.org/[^"']+)["']''',
      caseSensitive: false,
    ).firstMatch(embedHtml);
    if (iframeSrc != null) {
      return _normalizeUrl(iframeSrc.group(1)!);
    }

    final url = RegExp(
      r'https?://player\.pbs\.org/[^\s"<>]+',
      caseSensitive: false,
    ).firstMatch(embedHtml);
    if (url != null) {
      return _normalizeUrl(url.group(0)!);
    }

    return null;
  }

  /// Normalizes the player URL (https, trailing slash on path).
  static String toEmbedUrl(String url) {
    final uri = Uri.parse(_normalizeUrl(url));
    if (!uri.path.endsWith('/')) {
      return uri.replace(path: '${uri.path}/').toString();
    }
    return uri.toString();
  }

  static String _normalizeUrl(String url) {
    final uri = Uri.parse(url);
    return uri.replace(scheme: 'https').toString();
  }

  @override
  String get htmlBaseUrl => 'https://player.pbs.org/';

  @override
  String get htmlScriptUrl => '';

  @override
  String get htmlBody =>
      '<div style="max-width:953px;margin:0 auto;width:100%;">'
      '<div style="left:0;width:100%;height:0;position:relative;padding-bottom:56.25%;">'
      '<iframe src="$embedUrl" '
      'style="top:0;left:0;width:100%;height:100%;position:absolute;border:0;" '
      'allowfullscreen scrolling="no" allow="encrypted-media *;"></iframe>'
      '</div></div>';
}
