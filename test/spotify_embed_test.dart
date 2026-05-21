import 'package:flutter_social_embeds/platforms/spotify.dart';
import 'package:flutter_social_embeds/social_embed_webview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sampleHtml =
      '<div style="left: 0; width: 100%; height: 352px; position: relative;">'
      '<iframe src="https://open.spotify.com/embed/playlist/3N1NzeeX3RtlJYrbOH60WH?utm_source=oembed" '
      'style="top: 0; left: 0; width: 100%; height: 100%; position: absolute; border: 0; border-radius: 12px;" '
      'allowfullscreen allow="clipboard-write *; encrypted-media *; fullscreen *; picture-in-picture *;">'
      '</iframe></div>';

  const pageUrl =
      'https://open.spotify.com/playlist/3N1NzeeX3RtlJYrbOH60WH';
  const embedUrl =
      'https://open.spotify.com/embed/playlist/3N1NzeeX3RtlJYrbOH60WH';

  group('SpotifyEmbedData', () {
    test('toEmbedUrl converts share URLs to embed URLs', () {
      expect(SpotifyEmbedData.toEmbedUrl(pageUrl), embedUrl);
    });

    test('toEmbedUrl preserves query params on embed URLs', () {
      const withQuery =
          'https://open.spotify.com/embed/playlist/3N1NzeeX3RtlJYrbOH60WH?utm_source=oembed';
      expect(SpotifyEmbedData.toEmbedUrl(withQuery), withQuery);
    });

    test('extractEmbedHeight reads CMS wrapper height', () {
      expect(
        SpotifyEmbedData.extractEmbedHeight(
          sampleHtml,
          embedUrl: embedUrl,
        ),
        352,
      );
    });

    test('fromMarkup builds embed URL and height', () {
      final data = SpotifyEmbedData.fromMarkup(sampleHtml);
      expect(data, isNotNull);
      expect(data!.embedUrl, contains('/embed/playlist/3N1NzeeX3RtlJYrbOH60WH'));
      expect(data.height, 352);
    });
  });

  group('SocialEmbed.identifyEmbed', () {
    test('recognizes Spotify iframe markup', () {
      final embed = SocialEmbed.identifyEmbed(sampleHtml);
      expect(embed, isA<SpotifyEmbedData>());
      final spotify = embed as SpotifyEmbedData;
      expect(spotify.htmlBaseUrl, 'https://open.spotify.com/');
      expect(spotify.canChangeSize, isTrue);
      expect(spotify.htmlBody, contains('height:352px'));
    });
  });
}
