import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:webview_flutter/webview_flutter.dart';

CustomRender iframeRender({NavigationDelegate? navigationDelegate}) =>
    CustomRender.widget(widget: (context, buildChildren) {
      final sandboxMode = context.tree.element?.attributes["sandbox"];
      final UniqueKey key = UniqueKey();
      final givenWidth =
          double.tryParse(context.tree.element?.attributes['width'] ?? "");
      final givenHeight =
          double.tryParse(context.tree.element?.attributes['height'] ?? "");
      return SizedBox(
        width: givenWidth ?? (givenHeight ?? 150) * 2,
        height: givenHeight ?? (givenWidth ?? 300) / 2,
        child: CssBoxWidget(
          style: context.style,
          childIsReplaced: true,
          child: WebView(
            initialUrl: context.tree.element?.attributes['src'],
            key: key,
            javascriptMode:
                sandboxMode == null || sandboxMode == "allow-scripts"
                    ? JavascriptMode.unrestricted
                    : JavascriptMode.disabled,
            navigationDelegate: navigationDelegate,
            gestureRecognizers: {
              Factory<VerticalDragGestureRecognizer>(
                  () => VerticalDragGestureRecognizer())
            },
          ),
        ),
      );
    });
