library flutter_html_iframe;

import 'package:flutter_html/custom_render.dart';

export 'iframe_unsupported.dart'
    if (dart.library.io) 'iframe_mobile.dart'
    if (dart.library.html) 'iframe_web.dart';

CustomRenderMatcher iframeMatcher() => (context) {
      return context.tree.element?.localName == "iframe";
    };
