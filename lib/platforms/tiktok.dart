import 'generic_platform.dart';

class TikTokEmbedData extends SocialMediaGenericEmbedData {
  final String embedHtml;

  const TikTokEmbedData({required this.embedHtml}) : super(canChangeSize: true);

  @override
  String get htmlScriptUrl => 'https://www.tiktok.com/embed.js';

  @override
  String get htmlBody => embedHtml + htmlScript;
}
