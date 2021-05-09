import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:webview_flutter/webview_flutter.dart';

CustomRender iframeRender({NavigationDelegate? navigationDelegate}) => CustomRender.fromWidget(widget: (context, buildChildren) {
  final sandboxMode = context.tree.element?.attributes["sandbox"];
  final UniqueKey key = UniqueKey();
  return Container(
    width: double.tryParse(context.tree.element?.attributes['width'] ?? "")
        ?? (double.tryParse(context.tree.element?.attributes['height'] ?? "") ?? 150) * 2,
    height: double.tryParse(context.tree.element?.attributes['height'] ?? "")
        ?? (double.tryParse(context.tree.element?.attributes['width'] ?? "") ?? 300) / 2,
    child: WebView(
      initialUrl: context.tree.element?.attributes['src'],
      key: key,
      javascriptMode: sandboxMode == null || sandboxMode == "allow-scripts"
          ? JavascriptMode.unrestricted
          : JavascriptMode.disabled,
      navigationDelegate: navigationDelegate,
      gestureRecognizers: {
        Factory<VerticalDragGestureRecognizer>(() => VerticalDragGestureRecognizer())
      },
    ),
  );
});
