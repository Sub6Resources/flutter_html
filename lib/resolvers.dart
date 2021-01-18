import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/src/replaced_element.dart';
import 'package:flutter_svg/flutter_svg.dart';

abstract class ImageResolver {
  bool suppressImageTaps;
  String pathPrefix;
  Map<String, String> headers;
  bool ignoreWidth;
  bool ignoreHeight;
  Widget overrideImageLoader;
  String overrideAltText;
  Widget overrideAltTextWidget;
  CustomImageOptions customImageOptions;
  CustomSvgOptions customSvgOptions;

  ImageResolver({
    this.suppressImageTaps = false,
    this.pathPrefix = "",
    this.headers,
    this.ignoreWidth,
    this.ignoreHeight,
    this.overrideImageLoader,
    this.overrideAltText,
    this.overrideAltTextWidget,
    this.customImageOptions,
    this.customSvgOptions,
  });

  bool isMatch(ImageContentElement image);
  Widget render(ImageContentElement image, RenderContext context);
}

class DefaultNullResolver extends ImageResolver {
  DefaultNullResolver({
    bool suppressImageTaps = false,
    String overrideAltText,
    Widget overrideAltTextWidget,
  }) : super(
    suppressImageTaps: suppressImageTaps,
    overrideAltText: overrideAltText,
    overrideAltTextWidget: overrideAltTextWidget
  );

  @override
  bool isMatch(ImageContentElement image) {
    return image.src == null;
  }

  @override
  Widget render(ImageContentElement image, RenderContext context) {
    return overrideAltTextWidget ?? Text(overrideAltText ?? image.alt ?? "", style: context.style.generateTextStyle());
  }
}

class DefaultBase64Resolver extends ImageResolver {
  DefaultBase64Resolver({
    bool suppressImageTaps = false,
    String pathPrefix = "",
    bool ignoreWidth,
    bool ignoreHeight,
    String overrideAltText,
    Widget overrideAltTextWidget,
    CustomImageOptions customImageOptions,
  }) : super(
    suppressImageTaps: suppressImageTaps,
    pathPrefix: pathPrefix,
    ignoreWidth: ignoreWidth,
    ignoreHeight: ignoreHeight,
    overrideAltText: overrideAltText,
    overrideAltTextWidget: overrideAltTextWidget,
    customImageOptions: customImageOptions,
  );

  @override
  bool isMatch(ImageContentElement image) {
    return image.src.startsWith("data:image") && image.src.contains("base64,");
  }

  @override
  Widget render(ImageContentElement image, RenderContext context) {
    String newSrc = pathPrefix + image.src;
    final decodedImage = base64.decode(newSrc.split("base64,")[1].trim());
    precacheImage(
      MemoryImage(decodedImage),
      context.buildContext,
      onError: (exception, StackTrace stackTrace) {
        context.parser.onImageError?.call(exception, stackTrace);
      },
    );
    return Image.memory(
      decodedImage,
      width: ignoreWidth == true ? null : customImageOptions?.width ?? null,
      semanticLabel: customImageOptions?.semanticLabel ?? null,
      excludeFromSemantics: customImageOptions?.excludeFromSemantics ?? false,
      height: ignoreWidth == true ? null : customImageOptions?.width ?? null,
      color: customImageOptions?.color ?? null,
      colorBlendMode: customImageOptions?.colorBlendMode ?? null,
      fit: customImageOptions?.fit ?? null,
      alignment: customImageOptions?.alignment ?? Alignment.center,
      repeat: customImageOptions?.repeat ?? ImageRepeat.noRepeat,
      centerSlice: customImageOptions?.centerSlice ?? null,
      matchTextDirection: customImageOptions?.matchTextDirection ?? false,
      gaplessPlayback: customImageOptions?.gaplessPlayback ?? false,
      filterQuality: customImageOptions?.filterQuality ?? FilterQuality.low,
      isAntiAlias: customImageOptions?.isAntiAlias ?? false,
      frameBuilder: (ctx, child, frame, _) {
        if (frame == null) {
          return overrideAltTextWidget ?? Text(overrideAltText ?? image.alt ?? "", style: context.style.generateTextStyle());
        }
        return child;
      },
    );
  }
}

class DefaultAssetResolver extends ImageResolver {
  DefaultAssetResolver({
    bool suppressImageTaps = false,
    String pathPrefix = "",
    bool ignoreWidth,
    bool ignoreHeight,
    String overrideAltText,
    Widget overrideAltTextWidget,
    CustomImageOptions customImageOptions,
  }) : super(
    suppressImageTaps: suppressImageTaps,
    pathPrefix: pathPrefix,
    ignoreWidth: ignoreWidth,
    ignoreHeight: ignoreHeight,
    overrideAltText: overrideAltText,
    overrideAltTextWidget: overrideAltTextWidget,
    customImageOptions: customImageOptions,
  );

  @override
  bool isMatch(ImageContentElement image) {
    return image.src.startsWith("asset:");
  }

  @override
  Widget render(ImageContentElement image, RenderContext context) {
    String newSrc = pathPrefix + image.src;
    final assetPath = newSrc.replaceFirst('asset:', '');
    precacheImage(
      AssetImage(assetPath),
      context.buildContext,
      onError: (exception, StackTrace stackTrace) {
        context.parser.onImageError?.call(exception, stackTrace);
      },
    );
    return Image.asset(
      assetPath,
      width: ignoreWidth == true ? null : customImageOptions?.width ?? null,
      semanticLabel: customImageOptions?.semanticLabel ?? null,
      excludeFromSemantics: customImageOptions?.excludeFromSemantics ?? false,
      height: ignoreWidth == true ? null : customImageOptions?.width ?? null,
      color: customImageOptions?.color ?? null,
      colorBlendMode: customImageOptions?.colorBlendMode ?? null,
      fit: customImageOptions?.fit ?? null,
      alignment: customImageOptions?.alignment ?? Alignment.center,
      repeat: customImageOptions?.repeat ?? ImageRepeat.noRepeat,
      centerSlice: customImageOptions?.centerSlice ?? null,
      matchTextDirection: customImageOptions?.matchTextDirection ?? false,
      gaplessPlayback: customImageOptions?.gaplessPlayback ?? false,
      filterQuality: customImageOptions?.filterQuality ?? FilterQuality.low,
      isAntiAlias: customImageOptions?.isAntiAlias ?? false,
      frameBuilder: (ctx, child, frame, _) {
        if (frame == null) {
          return overrideAltTextWidget ?? Text(overrideAltText ?? image.alt ?? "", style: context.style.generateTextStyle());
        }
        return child;
      },
    );
  }
}

class DefaultSvgResolver extends ImageResolver {
  DefaultSvgResolver({
    bool suppressImageTaps = false,
    String pathPrefix = "",
    Map<String, String> headers,
    bool ignoreWidth,
    bool ignoreHeight,
    Widget overrideImageLoader,
    String overrideAltText,
    Widget overrideAltTextWidget,
    CustomSvgOptions customSvgOptions,
  }) : super(
    suppressImageTaps: suppressImageTaps,
    pathPrefix: pathPrefix,
    headers: headers,
    ignoreWidth: ignoreWidth,
    ignoreHeight: ignoreHeight,
    overrideImageLoader: overrideImageLoader,
    overrideAltText: overrideAltText,
    overrideAltTextWidget: overrideAltTextWidget,
    customSvgOptions: customSvgOptions,
  );

  @override
  bool isMatch(ImageContentElement image) {
    return image.src.endsWith(".svg");
  }

  @override
  Widget render(ImageContentElement image, RenderContext context) {
    String newSrc = pathPrefix + image.src;
    return SvgPicture.network(newSrc,
      headers: headers ?? null,
      placeholderBuilder: (BuildContext context) => overrideImageLoader ?? CircularProgressIndicator(),
      width: ignoreWidth == true ? null : customSvgOptions?.width ?? null,
      semanticsLabel: customSvgOptions?.semanticsLabel ?? null,
      excludeFromSemantics: customSvgOptions?.excludeFromSemantics ?? false,
      height: ignoreWidth == true ? null : customSvgOptions?.width ?? null,
      color: customSvgOptions?.color ?? null,
      colorBlendMode: customSvgOptions?.colorBlendMode ?? BlendMode.srcIn,
      fit: customSvgOptions?.fit ?? BoxFit.contain,
      alignment: customSvgOptions?.alignment ?? Alignment.center,
      matchTextDirection: customSvgOptions?.matchTextDirection ?? false,
      allowDrawingOutsideViewBox: customSvgOptions?.allowDrawingOutsideViewBox ?? false,
      cacheColorFilter: customSvgOptions?.cacheColorFilter ?? false,
      clipBehavior: customSvgOptions?.clipBehavior ?? Clip.hardEdge,
    );
  }
}

class DefaultNetworkResolver extends ImageResolver {
  DefaultNetworkResolver({
    bool suppressImageTaps = false,
    String pathPrefix = "",
    Map<String, String> headers,
    bool ignoreWidth,
    bool ignoreHeight,
    Widget overrideImageLoader,
    String overrideAltText,
    Widget overrideAltTextWidget,
    CustomImageOptions customImageOptions,
  }) : super(
    suppressImageTaps: suppressImageTaps,
    pathPrefix: pathPrefix,
    headers: headers,
    ignoreWidth: ignoreWidth,
    ignoreHeight: ignoreHeight,
    overrideImageLoader: overrideImageLoader,
    overrideAltText: overrideAltText,
    overrideAltTextWidget: overrideAltTextWidget,
    customImageOptions: customImageOptions,
  );

  @override
  bool isMatch(ImageContentElement uri) {
    return true;
  }

  @override
  Widget render(ImageContentElement image, RenderContext context) {
    String newSrc = pathPrefix + image.src;
    precacheImage(
      NetworkImage(newSrc),
      context.buildContext,
      onError: (exception, StackTrace stackTrace) {
        context.parser.onImageError?.call(exception, stackTrace);
      },
    );
    Completer<Size> completer = Completer();
    Image newImage = Image.network(newSrc, frameBuilder: (ctx, child, frame, _) {
      if (frame == null) {
        completer.completeError("error");
        return child;
      } else {
        return child;
      }
    });
    newImage.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo image, bool synchronousCall) {
        var myImage = image.image;
        Size size =
        Size(myImage.width.toDouble(), myImage.height.toDouble());
        completer.complete(size);
      }, onError: (object, stacktrace) {
        completer.completeError(object);
      }),
    );
    return FutureBuilder<Size>(
      future: completer.future,
      builder: (BuildContext buildContext, AsyncSnapshot<Size> snapshot) {
        if (snapshot.hasData) {
          return new Image.network(
            newSrc,
            headers: headers ?? null,
            width: ignoreWidth == true ? null : customImageOptions?.width ?? snapshot.data.width,
            semanticLabel: customImageOptions?.semanticLabel ?? null,
            excludeFromSemantics: customImageOptions?.excludeFromSemantics ?? false,
            height: ignoreWidth == true ? null : customImageOptions?.width ?? null,
            color: customImageOptions?.color ?? null,
            colorBlendMode: customImageOptions?.colorBlendMode ?? null,
            fit: customImageOptions?.fit ?? null,
            alignment: customImageOptions?.alignment ?? Alignment.center,
            repeat: customImageOptions?.repeat ?? ImageRepeat.noRepeat,
            centerSlice: customImageOptions?.centerSlice ?? null,
            matchTextDirection: customImageOptions?.matchTextDirection ?? false,
            gaplessPlayback: customImageOptions?.gaplessPlayback ?? false,
            filterQuality: customImageOptions?.filterQuality ?? FilterQuality.low,
            isAntiAlias: customImageOptions?.isAntiAlias ?? false,
            frameBuilder: (ctx, child, frame, _) {
              if (frame == null) {
                return overrideAltTextWidget ?? Text(overrideAltText ?? image.alt ?? "", style: context.style.generateTextStyle());
              }
              return child;
            },
          );
        } else if (snapshot.hasError) {
          return overrideAltTextWidget ?? Text(overrideAltText ?? image.alt ?? "", style: context.style.generateTextStyle());
        } else {
          return overrideImageLoader ?? CircularProgressIndicator();
        }
      },
    );
  }
}

/// The [CustomImageOptions] is a class that can define all the options for the [Image] widget when rendering <img> tags.
class CustomImageOptions {
  final double width;
  final double height;
  final Color color;
  final FilterQuality filterQuality;
  final BlendMode colorBlendMode;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final Rect centerSlice;
  final bool matchTextDirection;
  final bool gaplessPlayback;
  final String semanticLabel;
  final bool excludeFromSemantics;
  final bool isAntiAlias;

  CustomImageOptions({
    this.width,
    this.height,
    this.color,
    this.filterQuality,
    this.colorBlendMode,
    this.fit,
    this.alignment,
    this.repeat,
    this.centerSlice,
    this.matchTextDirection,
    this.gaplessPlayback,
    this.semanticLabel,
    this.excludeFromSemantics,
    this.isAntiAlias,
  });
}

/// The [CustomSvgOptions] is a class that can define all the options for the [SvgPicture] widget when rendering <img> tags that have an svg as their src.
class CustomSvgOptions {
  final double width;
  final double height;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final bool matchTextDirection;
  final bool allowDrawingOutsideViewBox;
  final Color color;
  final BlendMode colorBlendMode;
  final String semanticsLabel;
  final bool excludeFromSemantics;
  final Clip clipBehavior;
  final bool cacheColorFilter;

  CustomSvgOptions({
    this.allowDrawingOutsideViewBox,
    this.semanticsLabel,
    this.clipBehavior,
    this.cacheColorFilter,
    this.width,
    this.height,
    this.color,
    this.colorBlendMode,
    this.fit,
    this.alignment,
    this.matchTextDirection,
    this.excludeFromSemantics,
  });
}

final List<ImageResolver> defaultResolvers = [
  DefaultNullResolver(),
  DefaultBase64Resolver(),
  DefaultAssetResolver(),
  DefaultSvgResolver(),
  DefaultNetworkResolver()
];