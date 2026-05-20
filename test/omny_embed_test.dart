import 'package:flutter_social_embeds/platforms/omny.dart';
import 'package:flutter_social_embeds/social_embed_webview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sampleHtml =
      '<div style="left: 0; width: 100%; height: 180px; position: relative;">'
      '<iframe src="https://omny.fm/shows/kqed-segmented-audio/kqed-newscast-68ab0a91-a1e2-47e1-837c-c0ad55783bdb" '
      'style="top: 0; left: 0; width: 100%; height: 100%; position: absolute; border: 0;" '
      'allowfullscreen></iframe></div>';

  const embedPlayerUrl =
      'https://omny.fm/shows/kqed-segmented-audio/kqed-newscast-68ab0a91-a1e2-47e1-837c-c0ad55783bdb/embed';

  group('OmnyEmbedData', () {
    test('toPlayerEmbedUrl appends /embed to episode page URLs', () {
      const pageUrl =
          'https://omny.fm/shows/kqed-segmented-audio/kqed-newscast-68ab0a91-a1e2-47e1-837c-c0ad55783bdb';
      expect(OmnyEmbedData.toPlayerEmbedUrl(pageUrl), embedPlayerUrl);
    });

    test('toPlayerEmbedUrl leaves existing embed URLs unchanged', () {
      expect(OmnyEmbedData.toPlayerEmbedUrl(embedPlayerUrl), embedPlayerUrl);
    });

    test('extractEmbedHeight reads CMS wrapper height', () {
      expect(OmnyEmbedData.extractEmbedHeight(sampleHtml), 180);
    });

    test('fromMarkup builds player embed URL and height', () {
      final data = OmnyEmbedData.fromMarkup(sampleHtml);
      expect(data, isNotNull);
      expect(data!.embedUrl, embedPlayerUrl);
      expect(data.height, 180);
    });
  });

  group('SocialEmbed.identifyEmbed', () {
    test('recognizes Omny iframe markup', () {
      final embed = SocialEmbed.identifyEmbed(sampleHtml);
      expect(embed, isA<OmnyEmbedData>());
      final omny = embed as OmnyEmbedData;
      expect(omny.embedUrl, endsWith('/embed'));
      expect(omny.htmlBaseUrl, 'https://omny.fm/');
      expect(omny.canChangeSize, isTrue);
      expect(omny.htmlBody, contains('height:180px'));
    });
  });
}
