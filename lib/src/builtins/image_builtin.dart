import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/src/tree/image_element.dart';

class ImageBuiltIn extends Extension {

  final Map<String, String>? networkHeaders;

  //TODO how can the end user access this?
  const ImageBuiltIn({
    this.networkHeaders,
  });

  @override
  Set<String> get supportedTags => {
    "img",
  };

  @override
  bool matches(ExtensionContext context) {
    if (context.elementName != "img") {
      return false;
    }

    if (context.attributes['src'] == null) {
      return false;
    }

    final src = context.attributes['src']!;

    // Data Image Schema:
    final dataUri = _dataUriFormat.firstMatch(src);
    if (dataUri != null && dataUri.namedGroup('mime') != "image/svg+xml") {
      return true;
    }

    // Asset Image Schema:
    if (src.startsWith("asset:") && !src.endsWith(".svg")) {
      return true;
    }

    // Network Image Schema:
    try {
      final srcUri = Uri.parse(src);
      return !srcUri.path.endsWith(".svg");
    } on FormatException {
      return false;
    }
  }

  @override
  StyledElement lex(ExtensionContext context, List<StyledElement> children) {
    final parsedWidth = double.tryParse(context.attributes["width"] ?? "");
    final parsedHeight = double.tryParse(context.attributes["height"] ?? "");

    return ImageElement(
      name: context.elementName,
      children: children,
      style: Style(),
      node: context.node,
      elementId: context.id,
      src: context.attributes["src"]!,
      alt: context.attributes["alt"],
      width: parsedWidth != null? Width(parsedWidth): null,
      height: parsedHeight != null? Height(parsedHeight): null,
    );
  }

  @override
  InlineSpan parse(ExtensionContext context, Map<StyledElement, InlineSpan> Function() parseChildren) {
    final element = context.styledElement as ImageElement;

      final dataUri = _dataUriFormat.firstMatch(element.src);
      if (dataUri != null && dataUri.namedGroup('mime') != "image/svg+xml") {
        return WidgetSpan(
          child: _base64ImageRender(context),
        );
      }

    if (element.src.startsWith("asset:") && !element.src.endsWith(".svg")) {
      return WidgetSpan(
        child: _assetImageRender(context),
      );
    }

    try {
      final srcUri = Uri.parse(element.src);
      return WidgetSpan(
        child: _networkImageRender(context, srcUri),
      );
    } on FormatException {
      return const TextSpan(text: "");
    }
  }

  RegExp get _dataUriFormat => RegExp(r"^(?<scheme>data):(?<mime>image/[\w+\-.]+);(?<encoding>base64)?,\s+(?<data>.*)");

  //TODO remove repeated code between these methods:

  Widget _base64ImageRender(ExtensionContext context) {
    final element = context.styledElement as ImageElement;
    final decodedImage = base64.decode(element.src.split("base64,")[1].trim());
    final imageStyle = Style(
      width: element.width,
      height: element.height,
    ).merge(context.styledElement!.style);

    return CssBoxWidget(
      style: imageStyle,
      childIsReplaced: true,
      child: Image.memory(
        decodedImage,
        width: imageStyle.width?.value,
        height: imageStyle.height?.value,
        fit: BoxFit.fill,
        errorBuilder: (ctx, error, stackTrace) {
          return Text(
            element.alt ?? "",
            style: context.styledElement!.style.generateTextStyle(),
          );
        },
      ),
    );
  }

  Widget _assetImageRender(ExtensionContext context) {

    final element = context.styledElement as ImageElement;
    final assetPath = element.src.replaceFirst('asset:', '');
    final imageStyle = Style(
      width: element.width,
      height: element.height,
    ).merge(context.styledElement!.style);

    return CssBoxWidget(
      style: imageStyle,
      childIsReplaced: true,
      child: Image.asset(
        assetPath,
        width: imageStyle.width?.value,
        height: imageStyle.height?.value,
        fit: BoxFit.fill,

        errorBuilder: (ctx, error, stackTrace) {
          return Text(
            element.alt ?? "",
            style: context.styledElement!.style.generateTextStyle(),
          );
        },
      ),
    );
  }

  Widget _networkImageRender(ExtensionContext context, Uri srcUri) {
    final element = context.styledElement as ImageElement;
    final imageStyle = Style(
      width: element.width,
      height: element.height,
    ).merge(context.styledElement!.style);

    return CssBoxWidget(
      style: imageStyle,
      childIsReplaced: true,
      child: Image.network(
        element.src,
        width: imageStyle.width?.value,
        height: imageStyle.height?.value,
        fit: BoxFit.fill,
        headers: networkHeaders,
        errorBuilder: (ctx, error, stackTrace) {
          return Text(
            element.alt ?? "",
            style: context.styledElement!.style.generateTextStyle(),
          );
        },
      ),
    );
  }

}