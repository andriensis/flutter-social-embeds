import 'generic_platform.dart';

/// TikTok embed data
class TikTokEmbedData extends SocialMediaGenericEmbedData {
  /// HTML of the embed
  final String embedHtml;

  /// Creates an instance of the embed data
  const TikTokEmbedData({required this.embedHtml}) : super(canChangeSize: true);

  @override
  String get htmlScriptUrl => 'https://www.tiktok.com/embed.js';

  @override
  String get htmlBody => embedHtml + htmlScript;
}
