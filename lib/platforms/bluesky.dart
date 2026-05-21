import 'dart:convert';

import 'package:flutter_social_embeds/platforms/generic_platform.dart';
import 'package:http/http.dart' as http;

/// Bluesky post embed data (blockquote + [embed.bsky.app] widget script).
class BlueskyEmbedData extends SocialMediaGenericEmbedData {
  /// Blockquote markup (script tag is appended via [htmlScript]).
  final String embedHtml;

  /// When set, [fetchOEmbedHtml] must be called before rendering.
  final String? pendingPostUrl;

  /// Creates an instance of the embed data.
  const BlueskyEmbedData({
    required this.embedHtml,
    this.pendingPostUrl,
  }) : super(canChangeSize: true);

  /// Whether oEmbed must be fetched from [pendingPostUrl] first.
  bool get needsOEmbed => pendingPostUrl != null;

  /// Builds embed data from CMS markup or a bsky.app post URL.
  static BlueskyEmbedData? fromMarkup(String embedHtml) {
    if (_hasEmbedMarkup(embedHtml)) {
      return BlueskyEmbedData(embedHtml: normalizeEmbedHtml(embedHtml));
    }
    final postUrl = extractPostUrl(embedHtml);
    if (postUrl != null) {
      return BlueskyEmbedData(embedHtml: '', pendingPostUrl: postUrl);
    }
    return null;
  }

  static bool _hasEmbedMarkup(String embedHtml) =>
      embedHtml.contains('bluesky-embed') ||
      embedHtml.contains('embed.bsky.app');

  /// Strips duplicate widget scripts; oEmbed HTML includes one already.
  static String normalizeEmbedHtml(String embedHtml) {
    return embedHtml
        .replaceAll(
          RegExp(
            r'<script[^>]*embed\.bsky\.app[^>]*></script>',
            caseSensitive: false,
          ),
          '',
        )
        .trim();
  }

  /// Extracts a `bsky.app/profile/.../post/...` URL from markup or plain text.
  static String? extractPostUrl(String embedHtml) {
    final match = RegExp(
      r'https?://bsky\.app/profile/[^\s"<>]+/post/[^\s"<>]+',
      caseSensitive: false,
    ).firstMatch(embedHtml);
    if (match != null) {
      return _normalizeUrl(match.group(0)!);
    }
    return null;
  }

  /// Fetches the official embed HTML snippet from Bluesky oEmbed.
  ///
  /// See https://docs.bsky.app/docs/advanced-guides/oembed
  static Future<String?> fetchOEmbedHtml(String postUrl) async {
    final uri = Uri.https('embed.bsky.app', '/oembed', {
      'url': postUrl,
      'format': 'json',
    });
    final response = await http.get(uri);
    if (response.statusCode != 200) return null;

    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) return null;
    final html = body['html'];
    if (html is! String || html.isEmpty) return null;
    return normalizeEmbedHtml(html);
  }

  /// Minimal fallback when oEmbed is unavailable.
  static String fallbackEmbedHtml(String postUrl) =>
      '<blockquote class="bluesky-embed">'
      '<p><a href="$postUrl">View post on Bluesky</a></p>'
      '</blockquote>';

  static String _normalizeUrl(String url) {
    final uri = Uri.parse(url);
    return uri.replace(scheme: 'https').toString();
  }

  @override
  String get htmlBaseUrl => 'https://bsky.app/';

  @override
  String get htmlScriptUrl => 'https://embed.bsky.app/static/embed.js';

  @override
  String get htmlBody => embedHtml + htmlScript;
}
