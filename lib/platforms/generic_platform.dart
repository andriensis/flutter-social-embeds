abstract class SocialMediaGenericEmbedData {
  const SocialMediaGenericEmbedData({
    this.canChangeSize = false,
    this.aspectRatio,
  });

  final double? aspectRatio;
  final bool canChangeSize;
  String get htmlBody;
  String get htmlScriptUrl;
  String get htmlScript => """
    <script type="text/javascript" src="$htmlScriptUrl"></script>
  """;
}
