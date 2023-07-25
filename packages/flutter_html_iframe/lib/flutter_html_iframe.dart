library flutter_html_iframe;

import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:flutter_html/flutter_html.dart';

import 'iframe_unsupported.dart'
    if (dart.library.io) 'iframe_mobile.dart'
    if (dart.library.html) 'iframe_web.dart';

class IframeHtmlExtension extends HtmlExtension {
  final NavigationDelegate? navigationDelegate;
  final WebViewController? controller;
  final IframeProperties? iframeProperties;

  const IframeHtmlExtension({
    this.navigationDelegate,
    this.controller,
    this.iframeProperties,
  });

  @override
  Set<String> get supportedTags => {"iframe"};

  @override
  InlineSpan build(ExtensionContext context) {
    return WidgetSpan(
      child: IframeWidget(
        extensionContext: context,
        navigationDelegate: navigationDelegate,
        controller: controller,
        iframeProperties: iframeProperties,
      ),
    );
  }
}

class IframeProperties {
  double? height;
  double? width;

  IframeProperties({this.height, this.width});

  @override
  String toString() => 'IframeProperties(height: $height, width: $width)';
}
