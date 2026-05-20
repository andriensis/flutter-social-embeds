import 'package:flutter_social_embeds/platforms/soundcloud.dart';
import 'package:flutter_social_embeds/social_embed_webview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sampleHtml =
      '<div style="left: 0; width: 100%; height: 166px; position: relative;">'
      '<iframe src="https://w.soundcloud.com/player/?visual=false&url=https%3A%2F%2Fapi.soundcloud.com%2Ftracks%2F1746273273&show_artwork=true&show_comments=false" '
      'style="top: 0; left: 0; width: 100%; height: 100%; position: absolute; border: 0;" '
      'allowfullscreen></iframe></div>';

  const pageUrl = 'https://soundcloud.com/berkeleyside/im-your-heat-pump';

  group('SoundCloudEmbedData', () {
    test('extractEmbedUrl from widget iframe in CMS markup', () {
      final url = SoundCloudEmbedData.extractEmbedUrl(sampleHtml);
      expect(url, startsWith('https://w.soundcloud.com/player/'));
      expect(url, contains('1746273273'));
    });

    test('toEmbedUrl converts track permalink to widget player', () {
      final embedUrl = SoundCloudEmbedData.toEmbedUrl(pageUrl);
      expect(embedUrl, startsWith('https://w.soundcloud.com/player/'));
      expect(
        embedUrl,
        contains(
          Uri.encodeComponent('https://soundcloud.com/berkeleyside/im-your-heat-pump'),
        ),
      );
    });

    test('extractEmbedHeight reads CMS wrapper height', () {
      expect(SoundCloudEmbedData.extractEmbedHeight(sampleHtml), 166);
    });

    test('fromMarkup preserves widget URL query params and height', () {
      final data = SoundCloudEmbedData.fromMarkup(sampleHtml);
      expect(data, isNotNull);
      expect(data!.embedUrl, contains('w.soundcloud.com/player'));
      expect(data.embedUrl, contains('visual=false'));
      expect(data.embedUrl, contains('show_artwork=true'));
      expect(data.embedUrl, contains('show_comments=false'));
      expect(data.height, 166);
    });

    test('toEmbedUrl passes query params from permalink URL', () {
      const urlWithParams =
          'https://soundcloud.com/berkeleyside/im-your-heat-pump?visual=true&show_comments=true&show_artwork=false';
      final embedUrl = SoundCloudEmbedData.toEmbedUrl(urlWithParams);
      expect(embedUrl, contains('visual=true'));
      expect(embedUrl, contains('show_comments=true'));
      expect(embedUrl, contains('show_artwork=false'));
      expect(
        embedUrl,
        contains(
          Uri.encodeComponent(
            'https://soundcloud.com/berkeleyside/im-your-heat-pump',
          ),
        ),
      );
    });
  });

  group('SocialEmbed.identifyEmbed', () {
    test('recognizes SoundCloud iframe markup', () {
      final embed = SocialEmbed.identifyEmbed(sampleHtml);
      expect(embed, isA<SoundCloudEmbedData>());
      final soundcloud = embed as SoundCloudEmbedData;
      expect(soundcloud.htmlBaseUrl, 'https://w.soundcloud.com/');
      expect(soundcloud.canChangeSize, isTrue);
      expect(soundcloud.htmlBody, contains('height:166px'));
    });
  });
}
