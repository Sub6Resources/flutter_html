library flutter_html;

import 'package:flutter/material.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/style.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Html extends StatelessWidget {
  /// The `Html` widget takes HTML as input and displays a RichText
  /// tree of the parsed HTML content.
  ///
  /// **Attributes**
  /// **data** *required* takes in a String of HTML data.
  ///
  ///
  /// **onLinkTap** This function is called whenever a link (`<a href>`)
  /// is tapped.
  /// **customRender** This function allows you to return your own widgets
  /// for existing or custom HTML tags.
  /// See [its wiki page](https://github.com/Sub6Resources/flutter_html/wiki/All-About-customRender) for more info.
  ///
  /// **onImageError** This is called whenever an image fails to load or
  /// display on the page.
  ///
  /// **shrinkWrap** This makes the Html widget take up only the width it
  /// needs and no more.
  ///
  /// **onImageTap** This is called whenever an image is tapped.
  ///
  /// **blacklistedElements** Tag names in this array are ignored during parsing and rendering.
  ///
  /// **style** Pass in the style information for the Html here.
  /// See [its wiki page](https://github.com/Sub6Resources/flutter_html/wiki/Style) for more info.
  Html({
    Key key,
    @required this.data,
    this.imageHeaders,
    this.onLinkTap,
    this.customRender,
    this.onImageError,
    this.shrinkWrap = false,
    this.onImageTap,
    this.blacklistedElements = const [],
    this.style,
    this.navigationDelegateForIframe,
  }) : super(key: key);

  final String data;
  final Map<String, String> imageHeaders;
  final OnTap onLinkTap;
  final ImageErrorListener onImageError;
  final bool shrinkWrap;

  /// Properties for the Image widget that gets rendered by the rich text parser
  final OnTap onImageTap;

  final List<String> blacklistedElements;

  /// Either return a custom widget for specific node types or return null to
  /// fallback to the default rendering.
  final Map<String, CustomRender> customRender;

  /// Fancy New Parser parameters
  final Map<String, Style> style;

  /// Decides how to handle a specific navigation request in the WebView of an
  /// Iframe. It's necessary to use the webview_flutter package inside the app
  /// to use NavigationDelegate.
  final NavigationDelegate navigationDelegateForIframe;

  @override
  Widget build(BuildContext context) {
    final double width = shrinkWrap ? null : MediaQuery.of(context).size.width;

    return Container(
      width: width,
      child: HtmlParser(
        htmlData: data,
        imageHeaders: imageHeaders,
        onLinkTap: onLinkTap,
        onImageTap: onImageTap,
        onImageError: onImageError,
        shrinkWrap: shrinkWrap,
        style: style,
        customRender: customRender,
        blacklistedElements: blacklistedElements,
        navigationDelegateForIframe: navigationDelegateForIframe,
      ),
    );
  }
}
