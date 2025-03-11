import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_iframe/shims/dart_ui.dart' as ui;
import 'package:web/web.dart' show HTMLIFrameElement;

import 'package:webview_flutter/webview_flutter.dart';

class IframeWidget extends StatelessWidget {
  final NavigationDelegate? navigationDelegate;
  final ExtensionContext extensionContext;

  const IframeWidget({
    super.key,
    required this.extensionContext,
    this.navigationDelegate,
  });

  @override
  Widget build(BuildContext context) {
    final givenWidth =
        double.tryParse(extensionContext.attributes['width'] ?? "");
    final givenHeight =
        double.tryParse(extensionContext.attributes['height'] ?? "");
    final HTMLIFrameElement iframe = HTMLIFrameElement()
      ..width = (givenWidth ?? (givenHeight ?? 150) * 2).toString()
      ..height = (givenHeight ?? (givenWidth ?? 300) / 2).toString()
      ..src = extensionContext.attributes['src'] ?? ""
      ..style.border = 'none';
    final String createdViewId = _getRandString(10);
    ui.platformViewRegistry
        .registerViewFactory(createdViewId, (int viewId) => iframe);
    return SizedBox(
      width: double.tryParse(extensionContext.attributes['width'] ?? "") ??
          (double.tryParse(extensionContext.attributes['height'] ?? "") ??
                  150) *
              2,
      height: double.tryParse(extensionContext.attributes['height'] ?? "") ??
          (double.tryParse(extensionContext.attributes['width'] ?? "") ?? 300) /
              2,
      child: CssBoxWidget(
        style: extensionContext.styledElement!.style,
        childIsReplaced: true,
        child: Directionality(
          textDirection: extensionContext.styledElement!.style.direction!,
          child: HtmlElementView(
            viewType: createdViewId,
          ),
        ),
      ),
    );
  }
}

String _getRandString(int len) {
  var random = Random.secure();
  var values = List<int>.generate(len, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}
