import 'package:flutter_social_embeds/platforms/megaphone.dart';
import 'package:flutter_social_embeds/social_embed_webview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sampleHtml =
      '<div style="left: 0; width: 100%; height: 200px; position: relative;">'
      '<iframe src="https://playlist.megaphone.fm/?e=KQINC5602068054&light=true" '
      'style="top: 0; left: 0; width: 100%; height: 100%; position: absolute; border: 0;" '
      'allowfullscreen></iframe></div>';

  const pageUrl =
      'https://playlist.megaphone.fm?e=KQINC5602068054&light=true';

  group('MegaphoneEmbedData', () {
    test('extractEmbedUrl from iframe src in CMS markup', () {
      expect(
        MegaphoneEmbedData.extractEmbedUrl(sampleHtml),
        'https://playlist.megaphone.fm/?e=KQINC5602068054&light=true',
      );
    });

    test('extractEmbedUrl from plain URL', () {
      expect(
        MegaphoneEmbedData.extractEmbedUrl(pageUrl),
        'https://playlist.megaphone.fm?e=KQINC5602068054&light=true',
      );
    });

    test('extractEmbedHeight reads CMS wrapper height', () {
      expect(MegaphoneEmbedData.extractEmbedHeight(sampleHtml), 200);
    });

    test('fromMarkup builds player URL and height', () {
      final data = MegaphoneEmbedData.fromMarkup(sampleHtml);
      expect(data, isNotNull);
      expect(data!.embedUrl, contains('e=KQINC5602068054'));
      expect(data.embedUrl, contains('light=true'));
      expect(data.height, 200);
    });
  });

  group('SocialEmbed.identifyEmbed', () {
    test('recognizes Megaphone iframe markup', () {
      final embed = SocialEmbed.identifyEmbed(sampleHtml);
      expect(embed, isA<MegaphoneEmbedData>());
      final megaphone = embed as MegaphoneEmbedData;
      expect(megaphone.htmlBaseUrl, 'https://playlist.megaphone.fm/');
      expect(megaphone.canChangeSize, isTrue);
      expect(megaphone.htmlBody, contains('height:200px'));
    });
  });
}
