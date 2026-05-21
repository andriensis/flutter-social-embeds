library;

import 'dart:convert';

import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_social_embeds/platforms/bluesky.dart';
import 'package:flutter_social_embeds/platforms/facebook_post.dart';
import 'package:flutter_social_embeds/platforms/generic_platform.dart';
import 'package:flutter_social_embeds/platforms/instagram.dart';
import 'package:flutter_social_embeds/platforms/megaphone.dart';
import 'package:flutter_social_embeds/platforms/omny.dart';
import 'package:flutter_social_embeds/platforms/pbs.dart';
import 'package:flutter_social_embeds/platforms/soundcloud.dart';
import 'package:flutter_social_embeds/platforms/spotify.dart';
import 'package:flutter_social_embeds/platforms/tiktok.dart';
import 'package:flutter_social_embeds/platforms/vimeo.dart';
import 'package:flutter_social_embeds/platforms/x_twitter.dart';
import 'package:flutter_social_embeds/platforms/youtube.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

part 'utils/common.dart';

/// Widget that displays a social embed html on a webview
class SocialEmbed extends StatefulWidget {
  /// HTML of the embedded widget
  final String htmlBody;

  /// Optional background color of the widget. Defaults to transparent.
  final Color? backgroundColor;

  /// Optional html scale (0.0 to 1.0) to reduce zoom of the embed
  final double htmlScale;

  /// Provides a widget that displays a social embed script
  const SocialEmbed({
    super.key,
    required this.htmlBody,
    this.htmlScale = 1.0,
    this.backgroundColor,
  }) : assert(
          htmlScale >= 0 && htmlScale <= 1,
          'htmlScale must be between 0.0 and 1.0',
        );

  @override
  // ignore: library_private_types_in_public_api
  _SocialEmbedState createState() => _SocialEmbedState(htmlBody: htmlBody);

  /// Returns a nullable SocialMediaGenericEmbedData identifying any social embed on the html
  /// [embedHtml] is the string containing the html embed
  static SocialMediaGenericEmbedData? identifyEmbed(String embedHtml) =>
      _htmlToEmbedData(embedHtml);
}

class _SocialEmbedState extends State<SocialEmbed> with WidgetsBindingObserver {
  double _webviewHeight = 300;
  late WebViewController webViewController;
  final String htmlBody;
  late SocialMediaGenericEmbedData? embedData;
  bool _webViewReady = false;
  Set<String> _allowedNavigationHosts = {};

  _SocialEmbedState({required this.htmlBody});

  @override
  void initState() {
    super.initState();

    embedData = _htmlToEmbedData(htmlBody);
    if (embedData is TikTokEmbedData) {
      _webviewHeight = TikTokEmbedData.embedHeight;
    } else if (embedData is OmnyEmbedData) {
      _webviewHeight = (embedData as OmnyEmbedData).height;
    } else if (embedData is SpotifyEmbedData) {
      _webviewHeight = (embedData as SpotifyEmbedData).height;
    } else if (embedData is MegaphoneEmbedData) {
      _webviewHeight = (embedData as MegaphoneEmbedData).height;
    } else if (embedData is SoundCloudEmbedData) {
      _webviewHeight = (embedData as SoundCloudEmbedData).height;
    }

    final bluesky = embedData;
    if (bluesky is BlueskyEmbedData && bluesky.needsOEmbed) {
      _resolveBlueskyEmbed(bluesky.pendingPostUrl!);
    } else {
      _webViewReady = true;
      _initWebView();
    }
  }

  Future<void> _resolveBlueskyEmbed(String postUrl) async {
    final html = await BlueskyEmbedData.fetchOEmbedHtml(postUrl);
    if (!mounted) return;
    embedData = BlueskyEmbedData(
      embedHtml: html ?? BlueskyEmbedData.fallbackEmbedHtml(postUrl),
    );
    _webViewReady = true;
    _initWebView();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_webViewReady) {
      return SizedBox(
        height: _webviewHeight / 100 * widget.htmlScale * 100,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final webView = WebViewWidget(controller: webViewController);

    final ar = embedData?.aspectRatio;
    return (ar != null)
        ? ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height / 1.5,
              maxWidth: double.infinity,
            ),
            child: AspectRatio(aspectRatio: ar, child: webView),
          )
        : SizedBox(
            height: _webviewHeight / 100 * widget.htmlScale * 100,
            child: webView);
  }

  static String get _userAgent {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
          'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 '
          'Safari/604.1';
    }
    return 'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/124.0.0.0 Mobile Safari/537.36';
  }

  Set<String> _collectAllowedHosts() {
    final hosts = <String>{};

    void addHost(String? host) {
      if (host != null && host.isNotEmpty) {
        hosts.add(host.toLowerCase());
      }
    }

    final baseUrl = embedData?.htmlBaseUrl;
    if (baseUrl != null) {
      addHost(Uri.tryParse(baseUrl)?.host);
    }

    final sources = '${embedData?.htmlBody ?? ''}$htmlBody';
    for (final match in RegExp(r'https?://([^/"<>]+)').allMatches(sources)) {
      addHost(match.group(1));
    }

    return hosts;
  }

  bool _isAllowedEmbedNavigation(Uri uri) {
    if (uri.scheme == 'about' || uri.scheme == 'blob') {
      return true;
    }
    if (!uri.hasScheme || uri.host.isEmpty) {
      return true;
    }

    final host = uri.host.toLowerCase();
    for (final allowed in _allowedNavigationHosts) {
      if (host == allowed || host.endsWith('.$allowed')) {
        return true;
      }
    }
    return false;
  }

  Future<NavigationDecision> _onNavigationRequest(
    NavigationRequest request,
  ) async {
    if (!request.isMainFrame) {
      return NavigationDecision.navigate;
    }

    final uri = Uri.tryParse(request.url);
    if (uri == null || _isAllowedEmbedNavigation(uri)) {
      return NavigationDecision.navigate;
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  void _initWebView() {
    _allowedNavigationHosts = _collectAllowedHosts();

    webViewController = WebViewController()
      ..setUserAgent(_userAgent)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'PageHeight',
        onMessageReceived: (message) {
          _setHeight(double.parse(message.message));
        },
      )
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: _onNavigationRequest,
        onPageStarted: (url) => _setWebBackgroundColor(webViewController),
        onPageFinished: (url) {
          _setWebBackgroundColor(webViewController);
          if (embedData?.aspectRatio == null) {
            webViewController.runJavaScript(
              'setTimeout(() => sendHeight(), 0);'
              'setTimeout(() => sendHeight(), 500);',
            );
          }
        },
      ));
    webViewController.setBackgroundColor(_resolveBackgroundColor());
    _loadHtml(webViewController, getHtmlBody());
  }

  void _loadHtml(WebViewController controller, String html) {
    final baseUrl = embedData?.htmlBaseUrl;
    if (baseUrl != null) {
      controller.loadHtmlString(html, baseUrl: baseUrl);
    } else {
      controller.loadRequest(_htmlToURI(html));
    }
  }

  void _setHeight(double height) {
    setState(() {
      _webviewHeight = height;
    });
  }

  void _setWebBackgroundColor(WebViewController controller) {
    final color = _colorToHtmlRGBA(_resolveBackgroundColor(context));
    controller.runJavaScript(
      'document.documentElement.style.backgroundColor="$color";'
      'document.body.style.backgroundColor="$color";',
    );
  }

  Color _resolveBackgroundColor([BuildContext? context]) {
    return widget.backgroundColor ?? Colors.transparent;
  }

  Color getBackgroundColor(BuildContext context) => _resolveBackgroundColor(context);

  String get _widgetHtml => embedData?.htmlBody ?? htmlBody;

  String getHtmlBody() => """
      <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=${widget.htmlScale}, user-scalable=no">
          <style>
            *{box-sizing: border-box;margin:0px; padding:0px;}
            html, body { background: transparent; }
              #widget {
                        display: flex;
                        justify-content: center;
                        margin: 0 auto;
                        max-width:100%;
                    }      
          </style>
        </head>
        <body>
          <div id="widget">$_widgetHtml</div>
          ${(embedData?.aspectRatio == null) ? dynamicHeightScriptSetup : ''}
          ${(embedData?.canChangeSize == true) ? dynamicHeightScriptCheck : ''}
        </body>
      </html>
    """;

  static const String dynamicHeightScriptSetup = """
    <script type="text/javascript">
      const widget = document.getElementById('widget');
      const sendHeight = () => PageHeight.postMessage(widget.clientHeight);
    </script>
  """;

  static const String dynamicHeightScriptCheck = """
    <script type="text/javascript">
      const onWidgetResize = (widgets) => sendHeight();
      const resize_ob = new ResizeObserver(onWidgetResize);
      resize_ob.observe(widget);
    </script>
  """;
}
