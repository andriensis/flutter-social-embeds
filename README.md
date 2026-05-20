# Flutter Social Embeds

This package lets you show social network embeds on your app.

Updated package to use Flutter a minimum of 3.35.0.

## Supported Platforms:
* Instagram
* X (Twitter)
* TikTok
* Youtube
* Bluesky
* Megaphone
* Omny
* PBS
* Soundcloud
* Spotify
* Vimeo

## How to use?

**1:** Add this to your package's pubspec.yaml file:
```yaml
dependencies:
  social_embed_webview: LATEST_VERSION
```

**2:** You can install packages from the command line:
```bash
$ flutter packages get
```

**3:** This package uses webview_flutter. If you don't already have webview_flutter package installed on your project you should follow the configuration steps [here](https://pub.dev/packages/webview_flutter) 

## Example

Pass the embed HTML from your CMS (or a supported URL). The package detects the platform and renders it in a `WebView`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_social_embeds/social_embed_webview.dart';

// Instagram — permalink or full CMS blockquote
const instagramEmbed = 'https://www.instagram.com/p/C_Uzy94sKLc/';

// X (Twitter) — blockquote + widgets.js from CMS
const xEmbed =
    '<blockquote class="twitter-tweet"><p lang="en" dir="ltr">gonna start tweeting like I have 10 followers</p>&mdash; Opera GX (@operagxofficial) <a href="https://twitter.com/operagxofficial/status/1845867823765082224?ref_src=twsrc%5Etfw">October 14, 2024</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>';

// TikTok — blockquote with data-video-id (or tiktok.com URL)
const tikTokEmbed =
    '<blockquote class="tiktok-embed" cite="https://www.tiktok.com/@scout2015/video/6718335390845095173" data-video-id="6718335390845095173" style="max-width:605px;min-width:325px;"><section><a target="_blank" title="@scout2015" href="https://www.tiktok.com/@scout2015?refer=embed">@scout2015</a></section></blockquote> <script async src="https://www.tiktok.com/embed.js"></script>';

// YouTube — standard iframe embed
const youtubeEmbed =
    '<iframe width="560" height="315" src="https://www.youtube.com/embed/7OvsVSWB4TI" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>';

// Bluesky — post URL (fetches oEmbed) or full embed snippet from Bluesky
const blueskyEmbed =
    'https://bsky.app/profile/kqednews.kqed.org/post/3m466ge6sdv2k';

// Megaphone — CMS iframe wrapper
const megaphoneEmbed =
    '<div style="left: 0; width: 100%; height: 200px; position: relative;"><iframe src="https://playlist.megaphone.fm/?e=KQINC5602068054&light=true" style="top: 0; left: 0; width: 100%; height: 100%; position: absolute; border: 0;" allowfullscreen></iframe></div>';

// Omny — episode page URL is converted to /embed automatically
const omnyEmbed =
    '<div style="left: 0; width: 100%; height: 180px; position: relative;"><iframe src="https://omny.fm/shows/kqed-segmented-audio/kqed-newscast-68ab0a91-a1e2-47e1-837c-c0ad55783bdb" style="top: 0; left: 0; width: 100%; height: 100%; position: absolute; border: 0;" allowfullscreen></iframe></div>';

// PBS — viral player (16:9)
const pbsEmbed =
    '<div style="max-width: 953px;"><div style="left: 0; width: 100%; height: 0; position: relative; padding-bottom: 56.25%;"><iframe src="https://player.pbs.org/viralplayer/3084444582/" style="top: 0; left: 0; width: 100%; height: 100%; position: absolute; border: 0;" allowfullscreen scrolling="no" allow="encrypted-media *;"></iframe></div></div>';

// SoundCloud — widget player iframe from CMS
const soundCloudEmbed =
    '<div style="left: 0; width: 100%; height: 166px; position: relative;"><iframe src="https://w.soundcloud.com/player/?visual=false&url=https%3A%2F%2Fapi.soundcloud.com%2Ftracks%2F1746273273&show_artwork=true&show_comments=false" style="top: 0; left: 0; width: 100%; height: 100%; position: absolute; border: 0;" allowfullscreen></iframe></div>';

// Spotify — playlist embed from CMS
const spotifyEmbed =
    '<div style="left: 0; width: 100%; height: 352px; position: relative;"><iframe src="https://open.spotify.com/embed/playlist/3N1NzeeX3RtlJYrbOH60WH?utm_source=oembed" style="top: 0; left: 0; width: 100%; height: 100%; position: absolute; border: 0; border-radius: 12px;" allowfullscreen allow="clipboard-write *; encrypted-media *; fullscreen *; picture-in-picture *;"></iframe></div>';

// Vimeo — player iframe (16:9)
const vimeoEmbed =
    '<div style="left: 0; width: 100%; height: 0; position: relative; padding-bottom: 56.25%;"><iframe src="https://player.vimeo.com/video/127219197?app_id=122963" style="top: 0; left: 0; width: 100%; height: 100%; position: absolute; border: 0;" allowfullscreen scrolling="no" allow="encrypted-media *;"></iframe></div>';

return Scaffold(
  body: ListView(
    children: const [
      SocialEmbed(htmlBody: instagramEmbed),
      SocialEmbed(htmlBody: xEmbed),
      SocialEmbed(htmlBody: tikTokEmbed),
      SocialEmbed(htmlBody: youtubeEmbed),
      SocialEmbed(htmlBody: blueskyEmbed),
      SocialEmbed(htmlBody: megaphoneEmbed),
      SocialEmbed(htmlBody: omnyEmbed),
      SocialEmbed(htmlBody: pbsEmbed),
      SocialEmbed(htmlBody: soundCloudEmbed),
      SocialEmbed(htmlBody: spotifyEmbed),
      SocialEmbed(htmlBody: vimeoEmbed),
    ],
  ),
);

// Optional: inspect detected platform before building
final embed = SocialEmbed.identifyEmbed(omnyEmbed);
// embed is OmnyEmbedData with normalized /embed player URL
```
<img src="https://raw.githubusercontent.com/andriensis/flutter-social-embeds/main/doc/instagram.png" alt="Instagram embed" width="200"/>
<img src="https://raw.githubusercontent.com/andriensis/flutter-social-embeds/main/doc/x.png" alt="X embed" width="200"/>
<img src="https://raw.githubusercontent.com/andriensis/flutter-social-embeds/main/doc/youtube.png" alt="YouTube embed" width="200"/>
