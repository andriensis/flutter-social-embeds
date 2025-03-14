import 'generic_platform.dart';

/// Facebook (post) embed data
class FacebookPostEmbedData extends SocialMediaGenericEmbedData {
  /// HTML of the embed
  final String embedHtml;

  /// Creates an instance of the embed data
  const FacebookPostEmbedData({required this.embedHtml})
      : super(canChangeSize: true);

  @override
  String get htmlScriptUrl => '';

  @override
  String get htmlScript => '';

  @override
  String get htmlBody => embedHtml + htmlScript;
}
