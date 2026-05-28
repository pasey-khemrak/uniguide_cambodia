import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

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
  static final Set<String> _registeredViewTypes = {};

  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = 'google-map-embed-${widget.url.hashCode}';

    if (_registeredViewTypes.add(_viewType)) {
      ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
        return web.HTMLIFrameElement()
          ..src = widget.url
          ..style.border = '0'
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.display = 'block'
          ..setAttribute('allowfullscreen', 'true')
          ..setAttribute('referrerpolicy', 'no-referrer-when-downgrade')
          ..setAttribute('loading', 'lazy');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}
