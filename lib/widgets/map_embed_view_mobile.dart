import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MapEmbedView extends StatefulWidget {
  const MapEmbedView({
    super.key,
    required this.url,
    required this.fallback,
  });

  final String url;
  final Widget fallback;

  @override
  State<MapEmbedView> createState() => _MapEmbedViewState();
}

class _MapEmbedViewState extends State<MapEmbedView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  bool get _supportsWebView {
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFF1F3F4))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onWebResourceError: (error) {
            if (mounted && (error.isForMainFrame ?? true)) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
          },
        ),
      );

    _loadMap();
  }

  @override
  void didUpdateWidget(covariant MapEmbedView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.url != widget.url) {
      _loadMap();
    }
  }

  Future<void> _loadMap() async {
    final uri = Uri.tryParse(widget.url);
    if (!_supportsWebView || uri == null || !uri.hasScheme) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    await _controller.loadHtmlString(_mapIframeHtml(uri.toString()));
  }

  String _mapIframeHtml(String url) {
    final escapedUrl = _escapeHtmlAttribute(url);
    return '''
<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
      html, body {
        margin: 0;
        padding: 0;
        width: 100%;
        height: 100%;
        overflow: hidden;
        background: #f1f3f4;
      }
      iframe {
        border: 0;
        width: 100%;
        height: 100%;
        display: block;
      }
    </style>
  </head>
  <body>
    <iframe
      src="$escapedUrl"
      allowfullscreen
      loading="lazy"
      referrerpolicy="no-referrer-when-downgrade">
    </iframe>
  </body>
</html>
''';
  }

  String _escapeHtmlAttribute(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
  }

  @override
  Widget build(BuildContext context) {
    if (!_supportsWebView || _hasError) {
      return widget.fallback;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          const ColoredBox(
            color: Color(0xFFF1F3F4),
            child: Center(
              child: SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
            ),
          ),
      ],
    );
  }
}
