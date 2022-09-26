import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_iframe/shims/dart_ui.dart' as ui;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:webview_flutter/webview_flutter.dart';

CustomRender iframeRender({NavigationDelegate? navigationDelegate}) =>
    CustomRender.widget(widget: (context, buildChildren) {
      final givenWidth =
          double.tryParse(context.tree.element?.attributes['width'] ?? "");
      final givenHeight =
          double.tryParse(context.tree.element?.attributes['height'] ?? "");
      final html.IFrameElement iframe = html.IFrameElement()
        ..width = (givenWidth ?? (givenHeight ?? 150) * 2).toString()
        ..height = (givenHeight ?? (givenWidth ?? 300) / 2).toString()
        ..src = context.tree.element?.attributes['src']
        ..style.border = 'none';
      final String createdViewId = getRandString(10);
      ui.platformViewRegistry
          .registerViewFactory(createdViewId, (int viewId) => iframe);
      return SizedBox(
        width:
            double.tryParse(context.tree.element?.attributes['width'] ?? "") ??
                (double.tryParse(
                            context.tree.element?.attributes['height'] ?? "") ??
                        150) *
                    2,
        height: double.tryParse(
                context.tree.element?.attributes['height'] ?? "") ??
            (double.tryParse(context.tree.element?.attributes['width'] ?? "") ??
                    300) /
                2,
        child: CssBoxWidget(
          style: context.style,
          childIsReplaced: true,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: HtmlElementView(
              viewType: createdViewId,
            ),
          ),
        ),
      );
    });

String getRandString(int len) {
  var random = Random.secure();
  var values = List<int>.generate(len, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}
