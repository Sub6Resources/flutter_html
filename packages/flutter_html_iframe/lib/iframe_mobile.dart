import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

CustomRender iframeRender() =>
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
          child: InAppWebView(
            initialUrlRequest: URLRequest(
              url: Uri.parse(context.tree.element?.attributes['src'] ?? ""),
            ),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                javaScriptEnabled:
                    sandboxMode == null || sandboxMode == "allow-scripts",
              ),
            ),
            key: key,
            gestureRecognizers: {
              Factory<VerticalDragGestureRecognizer>(
                () => VerticalDragGestureRecognizer(),
              )
            },
          ),
        ),
      );
    });
