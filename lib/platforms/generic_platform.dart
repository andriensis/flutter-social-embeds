/// Generic social media embed data
abstract class SocialMediaGenericEmbedData {
  /// Generic social media embed data
  const SocialMediaGenericEmbedData({
    this.canChangeSize = false,
    this.aspectRatio,
  });

  /// Aspect ratio of the embed
  final double? aspectRatio;

  /// Whether the embed can change size after being loaded or not
  final bool canChangeSize;

  /// The HTML of the embed
  String get htmlBody;

  /// Base URL for [WebViewController.loadHtmlString], giving the page a real origin.
  /// When null, HTML is loaded via a data URI instead.
  String? get htmlBaseUrl => null;

  /// The JS script to load on the embed
  String get htmlScriptUrl;

  /// Computed script tag to load on the embed
  String get htmlScript => """
    <script type="text/javascript" src="$htmlScriptUrl"></script>
  """;
}
