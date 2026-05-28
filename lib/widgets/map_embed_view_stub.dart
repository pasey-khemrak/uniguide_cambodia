import 'package:flutter/material.dart';

class MapEmbedView extends StatelessWidget {
  const MapEmbedView({
    super.key,
    required this.url,
    required this.fallback,
  });

  final String url;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    return fallback;
  }
}
