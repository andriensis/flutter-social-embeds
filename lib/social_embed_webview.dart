library flutter_social_embeds;

import 'package:flutter/material.dart';
import 'package:flutter_social_embeds/platforms/generic_platform.dart';
import 'package:flutter_social_embeds/utils/common.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SocialEmbed extends StatefulWidget {
  final String htmlBody;
  final Color? backgroundColor;
  final double htmlScale;
  const SocialEmbed({
    Key? key,
    required this.htmlBody,
    this.htmlScale = 1.0,
    this.backgroundColor,
  })  : assert(
          htmlScale >= 0 && htmlScale <= 1,
          'htmlScale must be between 0.0 and 1.0',
        ),
        super(key: key);

  @override
  _SocialEmbedState createState() => _SocialEmbedState(htmlBody: htmlBody);
}

class _SocialEmbedState extends State<SocialEmbed> with WidgetsBindingObserver {
  double _webviewHeight = 300;
  late final WebViewController webViewController;
  final String htmlBody;
  late SocialMediaGenericEmbedData embedData;

  _SocialEmbedState({required this.htmlBody});

  @override
  void initState() {
    super.initState();

    embedData = htmlToEmbedData(htmlBody);

    _initWebView();
  }

  @override
  Widget build(BuildContext context) {
    final webView = WebViewWidget(controller: webViewController);

    final ar = embedData.aspectRatio;
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
        onPageFinished: (url) {
          final color = colorToHtmlRGBA(getBackgroundColor(context));
          webViewController
              .runJavaScript('document.body.style= "background-color: $color"');
          if (embedData.aspectRatio == null)
            webViewController
                .runJavaScript('setTimeout(() => sendHeight(), 0)');
        },
      ));

    webViewController.loadRequest(htmlToURI(getHtmlBody()));
  }

  void _setHeight(double height) {
    setState(() {
      _webviewHeight = height;
    });
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
          <div id="widget">${embedData.htmlBody}</div>
          ${(embedData.aspectRatio == null) ? dynamicHeightScriptSetup : ''}
          ${(embedData.canChangeSize) ? dynamicHeightScriptCheck : ''}
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
