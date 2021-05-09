import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:webview_flutter/webview_flutter.dart';

CustomRender iframeRender({NavigationDelegate? navigationDelegate}) => CustomRender.fromWidget(widget: (context, buildChildren) {
  return Container(
    child: Text("Iframes are currently not supported in this environment"),
  );
});