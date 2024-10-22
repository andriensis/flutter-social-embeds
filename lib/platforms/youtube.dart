import 'package:flutter_social_embeds/platforms/generic_platform.dart';

class YoutubeEmbedData extends SocialMediaGenericEmbedData {
  final String videoId;

  const YoutubeEmbedData({required this.videoId}) : super();

  @override
  String get htmlScriptUrl => 'https://www.youtube.com/iframe_api';

  @override
  String get htmlBody =>
      """
    <div id="player" style="position: fixed; top: 0px;"></div>
    <script>
      let player;
      function onYouTubeIframeAPIReady() {
        player = new YT.Player('player', {
          height: '100%',
          width: '100%',
          videoId: '$videoId',
          playerVars: {
          }
        });
      }

      function stopVideo() {
        player.stopVideo();
      }

      function pauseVideo() {
        player.pauseVideo();
      }
    </script>
  """ +
      htmlScript;
}
