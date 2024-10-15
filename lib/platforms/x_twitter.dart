import 'generic_platform.dart';

class XTwitterEmbedData extends SocialMediaGenericEmbedData {
  final String embedHtml;

  const XTwitterEmbedData({required this.embedHtml})
      : super(canChangeSize: true);

  @override
  String get htmlScriptUrl => 'https://platform.twitter.com/widgets.js';

  @override
  String get htmlBody => embedHtml + htmlScript;
}
