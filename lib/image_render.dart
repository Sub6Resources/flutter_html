import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:html/dom.dart' as dom;

typedef ImageSourceMatcher = bool Function(
  Map<String, String> attributes,
  dom.Element element,
);

ImageSourceMatcher base64UriMatcher() => (attributes, element) =>
    attributes["src"].startsWith("data:image") &&
    attributes["src"].contains("base64,");

ImageSourceMatcher networkSourceMatcher({
  List<String> schemas: const ["https", "http"],
  List<String> domains,
  String extension,
}) =>
    (attributes, element) {
      final src = Uri.parse(attributes["src"]);
      return schemas.contains(src.scheme) &&
          (domains == null || domains.contains(src.host)) &&
          (extension == null || src.path.endsWith(".$extension"));
    };

typedef ImageRender = Widget Function(
  RenderContext context,
  Map<String, String> attributes,
  dom.Element element,
);

ImageRender base64ImageRender() => (context, attributes, element) {
      final decodedImage =
          base64.decode(attributes["src"].split("base64,")[1].trim());
      precacheImage(
        MemoryImage(decodedImage),
        context.buildContext,
        onError: (exception, StackTrace stackTrace) {
          context.parser.onImageError?.call(exception, stackTrace);
        },
      );
      return Image.memory(
        decodedImage,
        frameBuilder: (ctx, child, frame, _) {
          if (frame == null) {
            return Text(attributes["alt"] ?? "",
                style: context.style.generateTextStyle());
          }
          return child;
        },
      );
    };

ImageRender networkImageRender({
  Map<String, String> headers,
  double width,
  double height,
  Widget Function(String) altWidget,
}) =>
    (context, attributes, element) {
      precacheImage(
        NetworkImage(attributes["src"]),
        context.buildContext,
        onError: (exception, StackTrace stackTrace) {
          context.parser.onImageError?.call(exception, stackTrace);
        },
      );
      return Image.network(
        attributes["src"],
        headers: headers,
        width: width,
        height: height,
        frameBuilder: (ctx, child, frame, _) {
          if (frame == null) {
            return altWidget.call(attributes["alt"]) ??
                Text(attributes["alt"] ?? "",
                    style: context.style.generateTextStyle());
          }
          return child;
        },
      );
    };

ImageRender svgNetworkImageRender() => (context, attributes, element) {
      return SvgPicture.network(
        attributes["src"],
      );
    };

final Map<ImageSourceMatcher, ImageRender> defaultImageRenders = {
  base64UriMatcher(): base64ImageRender(),
  networkSourceMatcher(extension: "svg"): svgNetworkImageRender(),
  networkSourceMatcher(): networkImageRender(),
};
