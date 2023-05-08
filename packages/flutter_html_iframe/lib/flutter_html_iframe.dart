library flutter_html_iframe;

import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'iframe_unsupported.dart'
    if (dart.library.io) 'iframe_mobile.dart'
    if (dart.library.html) 'iframe_web.dart';

class IframeHtmlExtension extends Extension {

  final NavigationDelegate? navigationDelegate;

  const IframeHtmlExtension({
    this.navigationDelegate,
  });

  @override
  Set<String> get supportedTags => {"iframe"};

  @override
  InlineSpan parse(ExtensionContext context, parseChildren) {
    return WidgetSpan(
      child: IframeWidget(
        extensionContext: context,
        navigationDelegate: navigationDelegate,
      ),
    );
  }

}
