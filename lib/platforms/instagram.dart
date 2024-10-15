import 'generic_platform.dart';

class InstagramEmbedData extends SocialMediaGenericEmbedData {
  final String embedHtml;

  const InstagramEmbedData({required this.embedHtml})
      : super(bottomMargin: 0, canChangeSize: true);

  @override
  String get htmlScriptUrl => 'https://www.instagram.com/embed.js';

  @override
  String get htmlBody => embedHtml + htmlScript;
}
