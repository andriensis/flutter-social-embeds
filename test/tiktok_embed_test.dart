import 'package:flutter_social_embeds/platforms/tiktok.dart';
import 'package:flutter_social_embeds/social_embed_webview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TikTokEmbedData.extractVideoId', () {
    test('from data-video-id on blockquote', () {
      const html =
          '<blockquote class="tiktok-embed" data-video-id="7565283205679467789" '
          'cite="https://www.tiktok.com/@kqedofficial/video/7565283205679467789">';
      expect(TikTokEmbedData.extractVideoId(html), '7565283205679467789');
    });

    test('from embed v2 iframe src', () {
      const html =
          '<iframe src="https://www.tiktok.com/embed/v2/7565283205679467789"></iframe>';
      expect(TikTokEmbedData.extractVideoId(html), '7565283205679467789');
    });

    test('from video page URL', () {
      const url =
          'https://www.tiktok.com/@kqedofficial/video/7565283205679467789';
      expect(TikTokEmbedData.extractVideoId(url), '7565283205679467789');
    });
  });

  group('SocialEmbed.identifyEmbed', () {
    test('recognizes raw TikTok iframe markup', () {
      const html =
          '<iframe src="https://www.tiktok.com/embed/v2/7565283205679467789"></iframe>';
      final embed = SocialEmbed.identifyEmbed(html);
      expect(embed, isA<TikTokEmbedData>());
      expect((embed as TikTokEmbedData).videoId, '7565283205679467789');
      expect(
        embed.htmlBody,
        contains('https://www.tiktok.com/embed/v2/7565283205679467789'),
      );
      expect(embed.aspectRatio, isNull);
      expect(embed.canChangeSize, isTrue);
      expect(
        embed.htmlBody,
        contains('height:${TikTokEmbedData.embedHeight}px'),
      );
    });
  });
}
