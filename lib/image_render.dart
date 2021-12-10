import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:html/dom.dart' as dom;

typedef ImageSourceMatcher = bool Function(
  Map<String, String> attributes,
  dom.Element? element,
);

final _dataUriFormat = RegExp(
    "^(?<scheme>data):(?<mime>image\/[\\w\+\-\.]+)(?<encoding>;base64)?\,(?<data>.*)");

ImageSourceMatcher dataUriMatcher(
        {String? encoding = 'base64', String? mime}) =>
    (attributes, element) {
      if (_src(attributes) == null) return false;
      final dataUri = _dataUriFormat.firstMatch(_src(attributes)!);
      return dataUri != null &&
          (mime == null || dataUri.namedGroup('mime') == mime) &&
          (encoding == null || dataUri.namedGroup('encoding') == ';$encoding');
    };

ImageSourceMatcher networkSourceMatcher({
  List<String> schemas: const ["https", "http"],
  List<String>? domains,
  String? extension,
}) =>
    (attributes, element) {
      if (_src(attributes) == null) return false;
      try {
        final src = Uri.parse(_src(attributes)!);
        return schemas.contains(src.scheme) &&
            (domains == null || domains.contains(src.host)) &&
            (extension == null || src.path.endsWith(".$extension"));
      } catch (e) {
        return false;
      }
    };

ImageSourceMatcher assetUriMatcher() => (attributes, element) =>
    _src(attributes) != null && _src(attributes)!.startsWith("asset:");

typedef ImageRender = Widget? Function(
  RenderContext context,
  Map<String, String> attributes,
  dom.Element? element,
);

ImageRender base64ImageRender() => (context, attributes, element) {
      final decodedImage =
          base64.decode(_src(attributes)!.split("base64,")[1].trim());
      precacheImage(
        MemoryImage(decodedImage),
        context.buildContext,
        onError: (exception, StackTrace? stackTrace) {
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
  double? width,
  double? height,
}) =>
    (context, attributes, element) {
      final assetPath = _src(attributes)!.replaceFirst('asset:', '');
      if (_src(attributes)!.endsWith(".svg")) {
        return SvgPicture.asset(assetPath,
            width: width ?? _width(attributes),
            height: height ?? _height(attributes));
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
  Map<String, String>? headers,
  String Function(String?)? mapUrl,
  double? width,
  double? height,
  Widget Function(String?)? altWidget,
  Widget Function()? loadingWidget,
}) =>
    (context, attributes, element) {
      final src = mapUrl?.call(_src(attributes)) ?? _src(attributes)!;
      Completer<Size> completer = Completer();
      if (context.parser.cachedImageSizes[src] != null) {
        completer.complete(context.parser.cachedImageSizes[src]);
      } else {
        Image image = Image.network(src, frameBuilder: (ctx, child, frame, _) {
          if (frame == null) {
            if (!completer.isCompleted) {
              completer.completeError("error");
            }
            return child;
          } else {
            return child;
          }
        });

        ImageStreamListener? listener;
        listener = ImageStreamListener((ImageInfo imageInfo, bool synchronousCall) {
          var myImage = imageInfo.image;
          Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
          if (!completer.isCompleted) {
            context.parser.cachedImageSizes[src] = size;
            completer.complete(size);
            image.image.resolve(ImageConfiguration()).removeListener(listener!);
          }
        }, onError: (object, stacktrace) {
          if (!completer.isCompleted) {
            completer.completeError(object);
            image.image.resolve(ImageConfiguration()).removeListener(listener!);
          }
        });

        image.image.resolve(ImageConfiguration()).addListener(listener);
      }

      return FutureBuilder<Size>(
        future: completer.future,
        initialData: context.parser.cachedImageSizes[src],
        builder: (BuildContext buildContext, AsyncSnapshot<Size> snapshot) {
          if (snapshot.hasData) {
            return Container(
              constraints: BoxConstraints(
                  maxWidth: width ?? _width(attributes) ?? snapshot.data!.width,
                  maxHeight:
                      (width ?? _width(attributes) ?? snapshot.data!.width) /
                          _aspectRatio(attributes, snapshot)),
              child: AspectRatio(
                aspectRatio: _aspectRatio(attributes, snapshot),
                child: Image.network(
                  src,
                  headers: headers,
                  width: width ?? _width(attributes) ?? snapshot.data!.width,
                  height: height ?? _height(attributes),
                  frameBuilder: (ctx, child, frame, _) {
                    if (frame == null) {
                      return altWidget?.call(_alt(attributes)) ??
                          Text(_alt(attributes) ?? "",
                              style: context.style.generateTextStyle());
                    }
                    return child;
                  },
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return altWidget?.call(_alt(attributes)) ??
                Text(_alt(attributes) ?? "",
                    style: context.style.generateTextStyle());
          } else {
            return loadingWidget?.call() ?? const CircularProgressIndicator();
          }
        },
      );
    };

ImageRender svgDataImageRender() => (context, attributes, element) {
      final dataUri = _dataUriFormat.firstMatch(_src(attributes)!);
      final data = dataUri?.namedGroup('data');
      if (data == null) return null;
      if (dataUri?.namedGroup('encoding') == ';base64') {
        final decodedImage = base64.decode(data.trim());
        return SvgPicture.memory(
          decodedImage,
          width: _width(attributes),
          height: _height(attributes),
        );
      }
      return SvgPicture.string(Uri.decodeFull(data));
    };

ImageRender svgNetworkImageRender() => (context, attributes, element) {
      return SvgPicture.network(
        attributes["src"]!,
        width: _width(attributes),
        height: _height(attributes),
      );
    };

final Map<ImageSourceMatcher, ImageRender> defaultImageRenders = {
  dataUriMatcher(mime: 'image/svg+xml', encoding: null): svgDataImageRender(),
  dataUriMatcher(): base64ImageRender(),
  assetUriMatcher(): assetImageRender(),
  networkSourceMatcher(extension: "svg"): svgNetworkImageRender(),
  networkSourceMatcher(): networkImageRender(),
};

String? _src(Map<String, String> attributes) {
  return attributes["src"];
}

String? _alt(Map<String, String> attributes) {
  return attributes["alt"];
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

double _aspectRatio(
    Map<String, String> attributes, AsyncSnapshot<Size> calculated) {
  final heightString = attributes["height"];
  final widthString = attributes["width"];
  if (heightString != null && widthString != null) {
    final height = double.tryParse(heightString);
    final width = double.tryParse(widthString);
    return height == null || width == null
        ? calculated.data!.aspectRatio
        : width / height;
  }
  return calculated.data!.aspectRatio;
}
