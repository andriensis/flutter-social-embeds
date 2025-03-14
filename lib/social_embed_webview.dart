library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_social_embeds/platforms/facebook_post.dart';
import 'package:flutter_social_embeds/platforms/generic_platform.dart';
import 'package:flutter_social_embeds/platforms/instagram.dart';
import 'package:flutter_social_embeds/platforms/tiktok.dart';
import 'package:flutter_social_embeds/platforms/x_twitter.dart';
import 'package:flutter_social_embeds/platforms/youtube.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

part 'utils/common.dart';

/// Widget that displays a social embed html on a webview
class SocialEmbed extends StatefulWidget {
  /// HTML of the embedded widget
  final String htmlBody;

  /// Optional background color of the widget
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
  late final WebViewController webViewController;
  final String htmlBody;
  late SocialMediaGenericEmbedData? embedData;

  _SocialEmbedState({required this.htmlBody});

  @override
  void initState() {
    super.initState();

    embedData = _htmlToEmbedData(htmlBody);

    _initWebView();
  }

  @override
  Widget build(BuildContext context) {
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

  _initWebView() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'PageHeight',
        onMessageReceived: (message) {
          _setHeight(double.parse(message.message));
        },
      )
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (request) async {
          final uri = Uri.parse(request.url);
          if (request.isMainFrame && await canLaunchUrl(uri)) {
            launchUrl(uri, mode: LaunchMode.externalApplication);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        onPageStarted: (url) => _setWebBackgroundColor(),
        onPageFinished: (url) {
          _setWebBackgroundColor();
          if (embedData?.aspectRatio == null) {
            webViewController
                .runJavaScript('setTimeout(() => sendHeight(), 0)');
          }
        },
      ));
    if (widget.backgroundColor != null) {
      webViewController.setBackgroundColor(widget.backgroundColor!);
    }
    webViewController.loadRequest(_htmlToURI(getHtmlBody()));
  }

  void _setHeight(double height) {
    setState(() {
      _webviewHeight = height;
    });
  }

  void _setWebBackgroundColor() {
    final color = _colorToHtmlRGBA(getBackgroundColor(context));
    webViewController
        .runJavaScript('document.body.style= "background-color: $color"');
  }

  Color getBackgroundColor(BuildContext context) {
    return widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;
  }

  String getHtmlBody() => """
      <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=${widget.htmlScale}, user-scalable=no">
          <style>
            *{box-sizing: border-box;margin:0px; padding:0px;}
              #widget {
                        display: flex;
                        justify-content: center;
                        margin: 0 auto;
                        max-width:100%;
                    }      
          </style>
        </head>
        <body>
          <div id="widget">${embedData?.htmlBody}</div>
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
