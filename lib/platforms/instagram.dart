import 'generic_platform.dart';

/// Instagram embed data
class InstagramEmbedData extends SocialMediaGenericEmbedData {
  /// HTML of the embed
  final String embedHtml;

  /// Creates an instance of the embed data
  const InstagramEmbedData({required this.embedHtml})
      : super(canChangeSize: true);

  @override
  String get htmlScriptUrl => 'https://www.instagram.com/embed.js';

  @override
  String get htmlBody => embedHtml + htmlScript;
}
