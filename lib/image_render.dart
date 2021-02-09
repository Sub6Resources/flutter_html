import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:html/dom.dart' as dom;

typedef ImageSourceMatcher = bool Function(
  Map<String, String> attributes,
  dom.Element element,
);

ImageSourceMatcher base64DataUriMatcher() => (attributes, element) =>
    _src(attributes) != null &&
    _src(attributes).startsWith("data:image") &&
    _src(attributes).contains("base64,");

ImageSourceMatcher networkSourceMatcher({
  List<String> schemas: const ["https", "http"],
  List<String> domains,
  String extension,
}) =>
    (attributes, element) {
      if (_src(attributes) == null) return false;
      try {
        final src = Uri.parse(_src(attributes));
        return schemas.contains(src.scheme) &&
            (domains == null || domains.contains(src.host)) &&
            (extension == null || src.path.endsWith(".$extension"));
      } catch (e) {
        return false;
      }
    };

ImageSourceMatcher assetUriMatcher() => (attributes, element) =>
    _src(attributes) != null && _src(attributes).startsWith("asset:");

typedef ImageRender = Widget Function(
  RenderContext context,
  Map<String, String> attributes,
  dom.Element element,
);

ImageRender base64ImageRender() => (context, attributes, element) {
      final decodedImage =
          base64.decode(_src(attributes).split("base64,")[1].trim());
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
            return Text(_alt(attributes) ?? "",
                style: context.style.generateTextStyle());
          }
          return child;
        },
      );
    };

ImageRender assetImageRender({
  double width,
  double height,
}) =>
    (context, attributes, element) {
      final assetPath = _src(attributes).replaceFirst('asset:', '');
      if (_src(attributes).endsWith(".svg")) {
        return SvgPicture.asset(assetPath);
      } else {
        return Image.asset(
          assetPath,
          width: width ?? _width(attributes),
          height: height ?? _height(attributes),
          frameBuilder: (ctx, child, frame, _) {
            if (frame == null) {
              return Text(_alt(attributes) ?? "",
                  style: context.style.generateTextStyle());
            }
            return child;
          },
        );
      }
    };

ImageRender networkImageRender({
  Map<String, String> headers,
  String Function(String) mapUrl,
  double width,
  double height,
  Widget Function(String) altWidget,
}) =>
    (context, attributes, element) {
      final src = mapUrl?.call(_src(attributes)) ?? _src(attributes);
      precacheImage(
        NetworkImage(
          src,
          headers: headers,
        ),
        context.buildContext,
        onError: (exception, StackTrace stackTrace) {
          context.parser.onImageError?.call(exception, stackTrace);
        },
      );
      Completer<Size> completer = Completer();
      Image image =
          Image.network(src, frameBuilder: (ctx, child, frame, _) {
        if (frame == null) {
          if (!completer.isCompleted) {
            completer.completeError("error");
          }
          return child;
        } else {
          return child;
        }
      });

      image.image.resolve(ImageConfiguration()).addListener(
            ImageStreamListener((ImageInfo image, bool synchronousCall) {
              var myImage = image.image;
              Size size =
                  Size(myImage.width.toDouble(), myImage.height.toDouble());
              if (!completer.isCompleted) {
                completer.complete(size);
              }
            }, onError: (object, stacktrace) {
              if (!completer.isCompleted) {
                completer.completeError(object);
              }
            }),
          );
      return FutureBuilder<Size>(
        future: completer.future,
        builder: (BuildContext buildContext, AsyncSnapshot<Size> snapshot) {
          if (snapshot.hasData) {
            return Image.network(
              src,
              headers: headers,
              width: width ?? _width(attributes) ?? snapshot.data.width,
              height: height ?? _height(attributes),
              frameBuilder: (ctx, child, frame, _) {
                if (frame == null) {
                  return altWidget.call(_alt(attributes)) ??
                      Text(_alt(attributes) ?? "",
                          style: context.style.generateTextStyle());
                }
                return child;
              },
            );
          } else if (snapshot.hasError) {
            return altWidget?.call(_alt(attributes)) ?? Text(_alt(attributes) ?? "",
                style: context.style.generateTextStyle());
          } else {
            return new CircularProgressIndicator();
          }
        },
      );
    };

ImageRender svgNetworkImageRender() => (context, attributes, element) {
      return SvgPicture.network(attributes["src"]);
    };

final Map<ImageSourceMatcher, ImageRender> defaultImageRenders = {
  base64DataUriMatcher(): base64ImageRender(),
  assetUriMatcher(): assetImageRender(),
  networkSourceMatcher(extension: "svg"): svgNetworkImageRender(),
  networkSourceMatcher(): networkImageRender(),
};

String _src(Map<String, String> attributes) {
  return attributes["src"];
}

String _alt(Map<String, String> attributes) {
  return attributes["alt"];
}

double _height(Map<String, String> attributes) {
  final heightString = attributes["height"];
  return heightString == null ? heightString : double.tryParse(heightString);
}

double _width(Map<String, String> attributes) {
  final widthString = attributes["width"];
  return widthString == null ? widthString : double.tryParse(widthString);
}
