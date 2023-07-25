import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_iframe/flutter_html_iframe.dart';
import 'package:webview_flutter/webview_flutter.dart';

class IframeWidget extends StatelessWidget {
  final NavigationDelegate? navigationDelegate;
  final ExtensionContext extensionContext;
  final WebViewController? controller;
  final IframeProperties? iframeProperties;

  const IframeWidget({
    Key? key,
    required this.extensionContext,
    this.navigationDelegate,
    this.controller,
    this.iframeProperties,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sandboxMode = extensionContext.attributes["sandbox"];

    // The decision here was to allow the developer to have full control over the
    // WebViewController they have passed in and to NOT override the JavaScriptMode
    // they might have already set.
    WebViewController controller = this.controller ?? WebViewController()
      ..setJavaScriptMode(sandboxMode == null || sandboxMode == "allow-scripts"
          ? JavaScriptMode.unrestricted
          : JavaScriptMode.disabled);

    if (navigationDelegate != null) {
      controller.setNavigationDelegate(navigationDelegate!);
    }

    final UniqueKey key = UniqueKey();

    final givenWidth = iframeProperties?.width ??
        double.tryParse(extensionContext.attributes['width'] ?? "");
    final givenHeight = iframeProperties?.height ??
        double.tryParse(extensionContext.attributes['height'] ?? "");

    Uri? srcUri;

    if (extensionContext.attributes['srcdoc'] != null) {
      srcUri = Uri.dataFromString(
        extensionContext.attributes['srcdoc'] ?? '',
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8'),
      );
    } else {
      srcUri = Uri.tryParse(extensionContext.attributes['src'] ?? "") ?? Uri();
    }

    return SizedBox(
      width: givenWidth ?? (givenHeight ?? 150) * 2,
      height: givenHeight ?? (givenWidth ?? 300) / 2,
      child: CssBoxWidget(
        style: extensionContext.styledElement!.style,
        childIsReplaced: true,
        child: WebViewWidget(
          controller: controller..loadRequest(srcUri),
          key: key,
          gestureRecognizers: {Factory(() => VerticalDragGestureRecognizer())},
        ),
      ),
    );
  }
}
