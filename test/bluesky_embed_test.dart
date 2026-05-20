import 'package:flutter_social_embeds/platforms/bluesky.dart';
import 'package:flutter_social_embeds/social_embed_webview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sampleHtml =
      '<blockquote class="bluesky-embed" '
      'data-bluesky-uri="at://did:plc:example/app.bsky.feed.post/3l23zp5prxl2e" '
      'data-bluesky-cid="bafyreidexample">'
      '<p lang="en">Hello from Bluesky</p>'
      '<a href="https://bsky.app/profile/example.com/post/3l23zp5prxl2e">Aug 19, 2024</a>'
      '</blockquote>'
      '<script async src="https://embed.bsky.app/static/embed.js" charset="utf-8"></script>';

  const postUrl = 'https://bsky.app/profile/example.com/post/3l23zp5prxl2e';

  group('BlueskyEmbedData', () {
    test('normalizeEmbedHtml removes duplicate embed.js script', () {
      expect(
        BlueskyEmbedData.normalizeEmbedHtml(sampleHtml),
        isNot(contains('embed.js')),
      );
      expect(
        BlueskyEmbedData.normalizeEmbedHtml(sampleHtml),
        contains('bluesky-embed'),
      );
    });

    test('fromMarkup with blockquote does not require oEmbed', () {
      final data = BlueskyEmbedData.fromMarkup(sampleHtml);
      expect(data, isNotNull);
      expect(data!.needsOEmbed, isFalse);
      expect(data.htmlBody, contains('embed.bsky.app/static/embed.js'));
    });

    test('fromMarkup with post URL only needs oEmbed', () {
      final data = BlueskyEmbedData.fromMarkup(postUrl);
      expect(data, isNotNull);
      expect(data!.needsOEmbed, isTrue);
      expect(data.pendingPostUrl, postUrl);
    });

    test('extractPostUrl finds bsky.app permalink', () {
      expect(BlueskyEmbedData.extractPostUrl(sampleHtml), contains('/post/'));
    });
  });

  group('SocialEmbed.identifyEmbed', () {
    test('recognizes Bluesky blockquote markup', () {
      final embed = SocialEmbed.identifyEmbed(sampleHtml);
      expect(embed, isA<BlueskyEmbedData>());
      expect((embed as BlueskyEmbedData).htmlBaseUrl, 'https://bsky.app/');
      expect(embed.canChangeSize, isTrue);
    });
  });
}
