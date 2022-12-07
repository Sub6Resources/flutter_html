library flutter_html_svg;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
// ignore: implementation_imports
import 'package:flutter_html/src/utils.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The CustomRender function that renders the <svg> HTML tag.
CustomRender svgTagRender() =>
    CustomRender.widget(widget: (context, buildChildren) {
      final attributes =
          context.tree.element?.attributes.cast<String, String>() ??
              <String, String>{};

      return Builder(
          key: context.key,
          builder: (buildContext) {
            return GestureDetector(
              child: SvgPicture.string(
                context.tree.element?.outerHtml ?? "",
                width: _width(attributes),
                height: _height(attributes),
              ),
              onTap: () {
                if (MultipleTapGestureDetector.of(buildContext) != null) {
                  MultipleTapGestureDetector.of(buildContext)!.onTap?.call();
                }
                context.parser.onImageTap?.call(
                    context.tree.element?.outerHtml ?? "",
                    context,
                    attributes,
                    context.tree.element);
              },
            );
          });
    });

/// The CustomRender function that renders an <img> tag with hardcoded svg data.
CustomRender svgDataImageRender() =>
    CustomRender.widget(widget: (context, buildChildren) {
      final attributes =
          context.tree.element?.attributes.cast<String, String>() ??
              <String, String>{};
      final dataUri = _dataUriFormat.firstMatch(_src(attributes)!);
      final data = dataUri?.namedGroup('data');

      if (data == null || data.isEmpty) {
        return const SizedBox(height: 0, width: 0);
      }
      return Builder(
          key: context.key,
          builder: (buildContext) {
            final width = _width(attributes);
            final height = _height(attributes);

            return GestureDetector(
              child: dataUri?.namedGroup('encoding') == ';base64'
                  ? SvgPicture.memory(
                      base64.decode(data.trim()),
                      width: width,
                      height: height,
                    )
                  : SvgPicture.string(
                      Uri.decodeFull(data),
                      width: width,
                      height: height,
                    ),
              onTap: () {
                if (MultipleTapGestureDetector.of(buildContext) != null) {
                  MultipleTapGestureDetector.of(buildContext)!.onTap?.call();
                }
                context.parser.onImageTap?.call(Uri.decodeFull(data), context,
                    attributes, context.tree.element);
              },
            );
          });
    });

/// The CustomRender function that renders an <img> tag with a network svg image.
CustomRender svgNetworkImageRender() =>
    CustomRender.widget(widget: (context, buildChildren) {
      final attributes =
          context.tree.element?.attributes.cast<String, String>() ??
              <String, String>{};

      if (attributes["src"] == null) {
        return const SizedBox(height: 0, width: 0);
      }
      return Builder(
          key: context.key,
          builder: (buildContext) {
            return GestureDetector(
              child: SvgPicture.network(
                attributes["src"]!,
                width: _width(attributes),
                height: _height(attributes),
              ),
              onTap: () {
                if (MultipleTapGestureDetector.of(buildContext) != null) {
                  MultipleTapGestureDetector.of(buildContext)!.onTap?.call();
                }
                context.parser.onImageTap?.call(attributes["src"]!, context,
                    attributes, context.tree.element);
              },
            );
          });
    });

/// The CustomRender function that renders an <img> tag with an svg asset in your app
CustomRender svgAssetImageRender({AssetBundle? bundle}) =>
    CustomRender.widget(widget: (context, buildChildren) {
      final attributes =
          context.tree.element?.attributes.cast<String, String>() ??
              <String, String>{};

      if (_src(attributes) == null) {
        return const SizedBox(height: 0, width: 0);
      }

      final assetPath = _src(context.tree.element!.attributes.cast())!
          .replaceFirst('asset:', '');
      return Builder(
          key: context.key,
          builder: (buildContext) {
            return GestureDetector(
              child: SvgPicture.asset(
                assetPath,
                bundle: bundle,
                width: _width(attributes),
                height: _height(attributes),
              ),
              onTap: () {
                if (MultipleTapGestureDetector.of(buildContext) != null) {
                  MultipleTapGestureDetector.of(buildContext)!.onTap?.call();
                }
                context.parser.onImageTap?.call(
                    assetPath, context, attributes, context.tree.element);
              },
            );
          });
    });

/// The CustomRenderMatcher for the <svg> HTML tag.
CustomRenderMatcher svgTagMatcher() => (context) {
      return context.tree.element?.localName == "svg";
    };

/// A CustomRenderMatcher for an <img> tag with encoded svg data.
CustomRenderMatcher svgDataUriMatcher(
        {String? encoding = 'base64', String? mime = 'image/svg+xml'}) =>
    (context) {
      final attributes =
          context.tree.element?.attributes.cast<String, String>() ??
              <String, String>{};

      if (_src(attributes) == null) {
        return false;
      }

      final dataUri = _dataUriFormat.firstMatch(_src(attributes)!);

      return context.tree.element?.localName == "img" &&
          dataUri != null &&
          (mime == null || dataUri.namedGroup('mime') == mime) &&
          (encoding == null || dataUri.namedGroup('encoding') == ';$encoding');
    };

/// A CustomRenderMatcher for an <img> tag with an svg tag over the network
CustomRenderMatcher svgNetworkSourceMatcher({
  List<String> schemas = const ["https", "http"],
  List<String>? domains,
  String? extension = "svg",
}) =>
    (context) {
      final attributes =
          context.tree.element?.attributes.cast<String, String>() ??
              <String, String>{};

      if (_src(attributes) == null) {
        return false;
      }

      try {
        final src = Uri.parse(_src(attributes)!);

        return context.tree.element?.localName == "img" &&
            schemas.contains(src.scheme) &&
            (domains == null || domains.contains(src.host)) &&
            (extension == null || src.path.endsWith(".$extension"));
      } catch (e) {
        return false;
      }
    };

/// A CustomRenderMatcher for an <img> tag with an in-app svg asset
CustomRenderMatcher svgAssetUriMatcher() => (context) {
      final attributes =
          context.tree.element?.attributes.cast<String, String>() ??
              <String, String>{};

      return context.tree.element?.localName == "img" &&
          _src(attributes) != null &&
          _src(attributes)!.startsWith("asset:") &&
          _src(attributes)!.endsWith(".svg");
    };

final _dataUriFormat = RegExp(
    "^(?<scheme>data):(?<mime>image\\/[\\w\\+\\-\\.]+)(?<encoding>;base64)?\\,(?<data>.*)");

String? _src(Map<String, String> attributes) {
  return attributes["src"];
}

double? _height(Map<String, String> attributes) {
  final heightString = attributes["height"];
  return heightString == null
      ? heightString as double?
      : double.tryParse(heightString);
}

double? _width(Map<String, String> attributes) {
  final widthString = attributes["width"];
  return widthString == null
      ? widthString as double?
      : double.tryParse(widthString);
}
