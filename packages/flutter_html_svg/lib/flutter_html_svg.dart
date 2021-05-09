library flutter_html_svg;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';

CustomRender svgTagRender() => CustomRender.fromWidget(widget: (context, buildChildren) {
  return SvgPicture.string(
    context.tree.element?.outerHtml ?? "",
    key: context.key,
    width: double.tryParse(context.tree.element?.attributes['width'] ?? ""),
    height: double.tryParse(context.tree.element?.attributes['width'] ?? ""),
  );
});

CustomRender svgDataImageRender() => CustomRender.fromWidget(widget: (context, buildChildren) {
  final dataUri = _dataUriFormat.firstMatch(_src(context.tree.element?.attributes.cast() ?? <String, String>{})!);
  final data = dataUri?.namedGroup('data');
  if (data == null) return Container(height: 0, width: 0);
  if (dataUri?.namedGroup('encoding') == ';base64') {
    final decodedImage = base64.decode(data.trim());
    return SvgPicture.memory(
      decodedImage,
      width: _width(context.tree.element?.attributes.cast() ?? <String, String>{}),
      height: _height(context.tree.element?.attributes.cast() ?? <String, String>{}),
    );
  }
  return SvgPicture.string(Uri.decodeFull(data));
});

CustomRender svgNetworkImageRender() => CustomRender.fromWidget(widget: (context, buildChildren) {
  if (context.tree.element?.attributes["src"] == null) {
    return Container(height: 0, width: 0);
  }
  return SvgPicture.network(
    context.tree.element!.attributes["src"]!,
    width: _width(context.tree.element!.attributes.cast()),
    height: _height(context.tree.element!.attributes.cast()),
  );
});

CustomRender svgAssetImageRender() => CustomRender.fromWidget(widget: (context, buildChildren) {
  if ( _src(context.tree.element?.attributes.cast() ?? <String, String>{}) == null) {
    return Container(height: 0, width: 0);
  }
  return SvgPicture.asset( _src(context.tree.element!.attributes.cast())!);
});

CustomRenderMatcher svgTagMatcher() => (context) {
  return context.tree.element?.localName == "svg";
};

CustomRenderMatcher svgDataUriMatcher({String? encoding = 'base64', String? mime = 'image/svg+xml'}) => (context) {
  if (_src(context.tree.element?.attributes.cast() ?? <String, String>{}) == null) return false;
  final dataUri = _dataUriFormat.firstMatch(_src(context.tree.element?.attributes.cast() ?? <String, String>{})!);
  return context.tree.element?.localName == "img" &&
      dataUri != null &&
      (mime == null || dataUri.namedGroup('mime') == mime) &&
      (encoding == null || dataUri.namedGroup('encoding') == ';$encoding');
};

CustomRenderMatcher svgNetworkSourceMatcher({
  List<String> schemas: const ["https", "http"],
  List<String>? domains,
  String? extension = "svg",
}) => (context) {
      if (_src(context.tree.element?.attributes.cast() ?? <String, String>{}) == null) return false;
      try {
        final src = Uri.parse(_src(context.tree.element?.attributes.cast() ?? <String, String>{})!);
        return context.tree.element?.localName == "img" &&
            schemas.contains(src.scheme) &&
            (domains == null || domains.contains(src.host)) &&
            (extension == null || src.path.endsWith(".$extension"));
      } catch (e) {
        return false;
      }
    };

CustomRenderMatcher svgAssetUriMatcher() => (context) =>
    context.tree.element?.localName == "img" &&
    _src(context.tree.element?.attributes.cast() ?? <String, String>{}) != null
    && _src(context.tree.element?.attributes.cast() ?? <String, String>{})!.startsWith("asset:")
    && _src(context.tree.element?.attributes.cast() ?? <String, String>{})!.endsWith(".svg");

final _dataUriFormat = RegExp("^(?<scheme>data):(?<mime>image\/[\\w\+\-\.]+)(?<encoding>;base64)?\,(?<data>.*)");

String? _src(Map<String, String> attributes) {
  return attributes["src"];
}

double? _height(Map<String, String> attributes) {
  final heightString = attributes["height"];
  return heightString == null ? heightString as double? : double.tryParse(heightString);
}

double? _width(Map<String, String> attributes) {
  final widthString = attributes["width"];
  return widthString == null ? widthString as double? : double.tryParse(widthString);
}