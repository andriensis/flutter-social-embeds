import 'package:flutter_social_embeds/platforms/vimeo.dart';
import 'package:flutter_social_embeds/social_embed_webview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sampleHtml =
      '<div style="left: 0; width: 100%; height: 0; position: relative; padding-bottom: 56.25%;">'
      '<iframe src="https://player.vimeo.com/video/127219197?app_id=122963" '
      'style="top: 0; left: 0; width: 100%; height: 100%; position: absolute; border: 0;" '
      'allowfullscreen scrolling="no" allow="encrypted-media *;"></iframe></div>';

  const playerUrl = 'https://player.vimeo.com/video/127219197';
  const permalink = 'https://vimeo.com/127219197';

  group('VimeoEmbedData', () {
    test('extractEmbedUrl from iframe in CMS markup', () {
      final url = VimeoEmbedData.extractEmbedUrl(sampleHtml);
      expect(url, contains('player.vimeo.com/video/127219197'));
      expect(url, contains('app_id=122963'));
    });

    test('toEmbedUrl preserves query params on player URLs', () {
      const withQuery = '$playerUrl?app_id=122963';
      expect(VimeoEmbedData.toEmbedUrl(withQuery), withQuery);
    });

    test('toEmbedUrl converts permalink to player URL', () {
      expect(
        VimeoEmbedData.toEmbedUrl(permalink),
        'https://player.vimeo.com/video/127219197',
      );
    });

    test('fromMarkup builds player URL with query params', () {
      final data = VimeoEmbedData.fromMarkup(sampleHtml);
      expect(data, isNotNull);
      expect(data!.embedUrl, contains('app_id=122963'));
      expect(data.aspectRatio, 16 / 9);
    });
  });

  group('SocialEmbed.identifyEmbed', () {
    test('recognizes Vimeo iframe markup', () {
      final embed = SocialEmbed.identifyEmbed(sampleHtml);
      expect(embed, isA<VimeoEmbedData>());
      final vimeo = embed as VimeoEmbedData;
      expect(vimeo.htmlBaseUrl, 'https://player.vimeo.com/');
      expect(vimeo.canChangeSize, isFalse);
      expect(vimeo.htmlBody, contains('padding-bottom:56.25%'));
    });
  });
}
