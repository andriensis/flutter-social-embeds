import 'package:flutter_social_embeds/platforms/pbs.dart';
import 'package:flutter_social_embeds/social_embed_webview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sampleHtml =
      '<div style="max-width: 953px;"><div style="left: 0; width: 100%; height: 0; position: relative; padding-bottom: 56.25%; padding-top: 43px;">'
      '<iframe src="https://player.pbs.org/viralplayer/3084444582/" '
      'style="top: 0; left: 0; width: 100%; height: 100%; position: absolute; border: 0;" '
      'allowfullscreen scrolling="no" allow="encrypted-media *;"></iframe></div></div>';

  const pageUrl = 'https://player.pbs.org/viralplayer/3084444582';

  group('PbsEmbedData', () {
    test('extractEmbedUrl from iframe in CMS markup', () {
      expect(
        PbsEmbedData.extractEmbedUrl(sampleHtml),
        'https://player.pbs.org/viralplayer/3084444582/',
      );
    });

    test('toEmbedUrl adds trailing slash', () {
      expect(
        PbsEmbedData.toEmbedUrl(pageUrl),
        'https://player.pbs.org/viralplayer/3084444582/',
      );
    });

    test('fromMarkup builds player URL', () {
      final data = PbsEmbedData.fromMarkup(sampleHtml);
      expect(data, isNotNull);
      expect(data!.embedUrl, contains('viralplayer/3084444582'));
      expect(data.aspectRatio, 16 / 9);
    });
  });

  group('SocialEmbed.identifyEmbed', () {
    test('recognizes PBS iframe markup', () {
      final embed = SocialEmbed.identifyEmbed(sampleHtml);
      expect(embed, isA<PbsEmbedData>());
      final pbs = embed as PbsEmbedData;
      expect(pbs.htmlBaseUrl, 'https://player.pbs.org/');
      expect(pbs.canChangeSize, isFalse);
      expect(pbs.htmlBody, contains('padding-bottom:56.25%'));
    });
  });
}
