import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:webview_flutter/webview_flutter.dart';

class IframeWidget extends StatelessWidget {
  const IframeWidget({
    Key? key,
    required ExtensionContext? extensionContext,
    NavigationDelegate? navigationDelegate,
    WebViewController? controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
        "Iframes are currently not supported in this environment");
  }
}
