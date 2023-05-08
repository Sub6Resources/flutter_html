import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class IframeWidget extends StatelessWidget {

  const IframeWidget({
    Key? key,
    NavigationDelegate? navigationDelegate,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return const Text(
        "Iframes are currently not supported in this environment");
  }
}
