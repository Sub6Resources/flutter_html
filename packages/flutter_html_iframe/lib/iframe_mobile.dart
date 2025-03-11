import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:webview_flutter/webview_flutter.dart';

class IframeWidget extends StatelessWidget {
  final NavigationDelegate? navigationDelegate;
  final ExtensionContext extensionContext;

  const IframeWidget({
    Key? key,
    required this.extensionContext,
    this.navigationDelegate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final WebViewController controller = WebViewController();

    final sandboxMode = extensionContext.attributes["sandbox"];
    controller.setJavaScriptMode(
        sandboxMode == null || sandboxMode == "allow-scripts"
            ? JavaScriptMode.unrestricted
            : JavaScriptMode.disabled);

    if (navigationDelegate != null) {
      controller.setNavigationDelegate(navigationDelegate!);
    }

    final UniqueKey key = UniqueKey();
    final givenWidth =
        double.tryParse(extensionContext.attributes['width'] ?? "");
    final givenHeight =
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
