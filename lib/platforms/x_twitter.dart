import 'generic_platform.dart';

/// X (Twitter) embed data
class XTwitterEmbedData extends SocialMediaGenericEmbedData {
  /// HTML of the embed
  final String embedHtml;

  /// Creates an instance of the embed data
  const XTwitterEmbedData({required this.embedHtml})
      : super(canChangeSize: true);

  @override
  String get htmlScriptUrl => 'https://platform.twitter.com/widgets.js';

  @override
  String get htmlBody => embedHtml + htmlScript;
}
