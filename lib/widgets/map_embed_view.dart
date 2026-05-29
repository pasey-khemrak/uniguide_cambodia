export 'map_embed_view_stub.dart'
    if (dart.library.html) 'map_embed_view_web.dart'
    if (dart.library.io) 'map_embed_view_mobile.dart';
