import 'package:collection/collection.dart';

import 'dart:async';
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/src/utils.dart';

typedef CustomRenderMatcher = bool Function(RenderContext context);

CustomRenderMatcher blockElementMatcher() => (context) {
  return context.tree.style.display == Display.BLOCK
      && context.tree.children.isNotEmpty;
};

CustomRenderMatcher listElementMatcher() => (context) {
  return context.tree.style.display == Display.LIST_ITEM;
};

CustomRenderMatcher replacedElementMatcher() => (context) {
  return context.tree is ReplacedElement;
};

CustomRenderMatcher dataUriMatcher({String? encoding = 'base64', String? mime}) => (context) {
  if (context.tree.element?.attributes == null
      || _src(context.tree.element!.attributes.cast()) == null) return false;
  final dataUri = _dataUriFormat.firstMatch(_src(context.tree.element!.attributes.cast())!);
  return dataUri != null &&
      (mime == null || dataUri.namedGroup('mime') == mime) &&
      (encoding == null || dataUri.namedGroup('encoding') == ';$encoding');
};

CustomRenderMatcher networkSourceMatcher({
  List<String> schemas: const ["https", "http"],
  List<String>? domains,
  String? extension,
}) =>
        (context) {
      if (context.tree.element?.attributes.cast() == null
          || _src(context.tree.element!.attributes.cast()) == null) return false;
      try {
        final src = Uri.parse(_src(context.tree.element!.attributes.cast())!);
        return schemas.contains(src.scheme) &&
            (domains == null || domains.contains(src.host)) &&
            (extension == null || src.path.endsWith(".$extension"));
      } catch (e) {
        return false;
      }
    };

CustomRenderMatcher assetUriMatcher() => (context) =>
    context.tree.element?.attributes.cast() != null
    && _src(context.tree.element!.attributes.cast()) != null
    && _src(context.tree.element!.attributes.cast())!.startsWith("asset:");

CustomRenderMatcher textContentElementMatcher() => (context) {
  return context.tree is TextContentElement;
};

CustomRenderMatcher interactableElementMatcher() => (context) {
  return context.tree is InteractableElement;
};

CustomRenderMatcher layoutElementMatcher() => (context) {
  return context.tree is LayoutElement;
};

CustomRenderMatcher verticalAlignMatcher() => (context) {
  return context.tree.style.verticalAlign != null
      && context.tree.style.verticalAlign != VerticalAlign.BASELINE;
};

CustomRenderMatcher fallbackMatcher() => (context) {
  return true;
};

class CustomRender {
  final InlineSpan Function(RenderContext, List<InlineSpan> Function())? inlineSpan;
  final Widget Function(RenderContext, List<InlineSpan> Function())? widget;

  CustomRender.fromInlineSpan({
    required this.inlineSpan,
  }) : widget = null;

  CustomRender.fromWidget({
    required this.widget,
  }) : inlineSpan = null;
}

CustomRender blockElementRender({
  Style? style,
  Widget? child,
  List<InlineSpan>? children}) =>
    CustomRender.fromInlineSpan(inlineSpan: (context, buildChildren) =>
        WidgetSpan(
          child: ContainerSpan(
            key: context.key,
            newContext: context,
            style: style ?? context.tree.style,
            shrinkWrap: context.parser.shrinkWrap,
            children: children ?? context.tree.children
                .expandIndexed((i, childTree) => [
              if (context.parser.shrinkWrap &&
                  childTree.style.display == Display.BLOCK &&
                  i > 0 &&
                  context.tree.children[i - 1] is ReplacedElement)
                TextSpan(text: "\n"),
              context.parser.parseTree(context, childTree),
              if (context.parser.shrinkWrap &&
                  i != context.tree.children.length - 1 &&
                  childTree.style.display == Display.BLOCK &&
                  childTree.element?.localName != "html" &&
                  childTree.element?.localName != "body")
                TextSpan(text: "\n"),
            ])
                .toList(),
          ),
));

CustomRender listElementRender({
  Style? style,
  Widget? child,
  List<InlineSpan>? children}) =>
    CustomRender.fromInlineSpan(inlineSpan: (context, buildChildren) =>
        WidgetSpan(
          child: ContainerSpan(
            key: context.key,
            newContext: context,
            style: style ?? context.tree.style,
            shrinkWrap: context.parser.shrinkWrap,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              textDirection: style?.direction ?? context.tree.style.direction,
              children: [
                (style?.listStylePosition ?? context.tree.style.listStylePosition) == ListStylePosition.OUTSIDE ?
                Padding(
                  padding: style?.padding ?? context.tree.style.padding
                      ?? EdgeInsets.only(left: (style?.direction ?? context.tree.style.direction) != TextDirection.rtl ? 10.0 : 0.0,
                          right: (style?.direction ?? context.tree.style.direction) == TextDirection.rtl ? 10.0 : 0.0),
                  child: Text(
                      "${style?.markerContent ?? context.style.markerContent}",
                      textAlign: TextAlign.right,
                      style: style?.generateTextStyle() ?? context.style.generateTextStyle()
                  ),
                ) : Container(height: 0, width: 0),
                Text("\t", textAlign: TextAlign.right),
                Expanded(
                    child: Padding(
                        padding: (style?.listStylePosition ?? context.tree.style.listStylePosition) == ListStylePosition.INSIDE ?
                          EdgeInsets.only(left: (style?.direction ?? context.tree.style.direction) != TextDirection.rtl ? 10.0 : 0.0,
                            right: (style?.direction ?? context.tree.style.direction) == TextDirection.rtl ? 10.0 : 0.0) : EdgeInsets.zero,
                        child: StyledText(
                          textSpan: TextSpan(
                            text: ((style?.listStylePosition ?? context.tree.style.listStylePosition) ==
                                ListStylePosition.INSIDE)
                                ? "${style?.markerContent ?? context.style.markerContent}"
                                : null,
                            children: _getListElementChildren(style?.listStylePosition ?? context.tree.style.listStylePosition, buildChildren),
                            style: style?.generateTextStyle() ?? context.style.generateTextStyle(),
                          ),
                          style: style ?? context.style,
                          renderContext: context,
                        )
                    )
                )
              ],
            ),
          ),
));

CustomRender replacedElementRender({PlaceholderAlignment? alignment, TextBaseline? baseline, Widget? child}) =>
    CustomRender.fromInlineSpan(inlineSpan: (context, buildChildren) => WidgetSpan(
  alignment: alignment ?? (context.tree as ReplacedElement).alignment,
  baseline: baseline ?? TextBaseline.alphabetic,
  child: child ?? (context.tree as ReplacedElement).toWidget(context)!,
));

CustomRender textContentElementRender({String? text}) =>
    CustomRender.fromInlineSpan(inlineSpan: (context, buildChildren) =>
      TextSpan(text: text ?? (context.tree as TextContentElement).text));

CustomRender base64ImageRender() => CustomRender.fromWidget(widget: (context, buildChildren) {
  final decodedImage = base64.decode(_src(context.tree.element!.attributes.cast())!.split("base64,")[1].trim());
  precacheImage(
    MemoryImage(decodedImage),
    context.buildContext,
    onError: (exception, StackTrace? stackTrace) {
      context.parser.onImageError?.call(exception, stackTrace);
    },
  );
  final widget = Image.memory(
    decodedImage,
    frameBuilder: (ctx, child, frame, _) {
      if (frame == null) {
        return Text(_alt(context.tree.element!.attributes.cast()) ?? "", style: context.style.generateTextStyle());
      }
      return child;
    },
  );
  return Builder(
      builder: (buildContext) {
        return GestureDetector(
          key: context.key,
          child: widget,
          onTap: () {
            if (MultipleTapGestureDetector.of(buildContext) != null) {
              MultipleTapGestureDetector.of(buildContext)!.onTap?.call();
            }
            context.parser.onImageTap?.call(
                _src(context.tree.element!.attributes.cast())!.split("base64,")[1].trim(),
                context,
                context.tree.element!.attributes.cast(),
                context.tree.element
            );
          },
        );
      }
  );
});

CustomRender assetImageRender({
  double? width,
  double? height,
}) => CustomRender.fromWidget(widget: (context, buildChildren) {
  final assetPath = _src(context.tree.element!.attributes.cast())!.replaceFirst('asset:', '');
  final widget = Image.asset(
    assetPath,
    width: width ?? _width(context.tree.element!.attributes.cast()),
    height: height ?? _height(context.tree.element!.attributes.cast()),
    frameBuilder: (ctx, child, frame, _) {
      if (frame == null) {
        return Text(_alt(context.tree.element!.attributes.cast()) ?? "", style: context.style.generateTextStyle());
      }
      return child;
    },
  );
  return Builder(
      builder: (buildContext) {
        return GestureDetector(
          key: context.key,
          child: widget,
          onTap: () {
            if (MultipleTapGestureDetector.of(buildContext) != null) {
              MultipleTapGestureDetector.of(buildContext)!.onTap?.call();
            }
            context.parser.onImageTap?.call(
                assetPath,
                context,
                context.tree.element!.attributes.cast(),
                context.tree.element
            );
          },
        );
      }
  );
});

CustomRender networkImageRender({
  Map<String, String>? headers,
  String Function(String?)? mapUrl,
  double? width,
  double? height,
  Widget Function(String?)? altWidget,
  Widget Function()? loadingWidget,
}) => CustomRender.fromWidget(widget: (context, buildChildren) {
  final src = mapUrl?.call(_src(context.tree.element!.attributes.cast()))
      ?? _src(context.tree.element!.attributes.cast())!;
  precacheImage(
    NetworkImage(
      src,
      headers: headers,
    ),
    context.buildContext,
    onError: (exception, StackTrace? stackTrace) {
      context.parser.onImageError?.call(exception, stackTrace);
    },
  );
  Completer<Size> completer = Completer();
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

  image.image.resolve(ImageConfiguration()).addListener(
    ImageStreamListener((ImageInfo image, bool synchronousCall) {
      var myImage = image.image;
      Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
      if (!completer.isCompleted) {
        completer.complete(size);
      }
    }, onError: (object, stacktrace) {
      if (!completer.isCompleted) {
        completer.completeError(object);
      }
    }),
  );
  final widget = FutureBuilder<Size>(
    future: completer.future,
    builder: (BuildContext buildContext, AsyncSnapshot<Size> snapshot) {
      if (snapshot.hasData) {
        return Image.network(
          src,
          headers: headers,
          width: width ?? _width(context.tree.element!.attributes.cast())
              ?? snapshot.data!.width,
          height: height ?? _height(context.tree.element!.attributes.cast()),
          frameBuilder: (ctx, child, frame, _) {
            if (frame == null) {
              return altWidget?.call(_alt(context.tree.element!.attributes.cast())) ??
                  Text(_alt(context.tree.element!.attributes.cast())
                      ?? "", style: context.style.generateTextStyle());
            }
            return child;
          },
        );
      } else if (snapshot.hasError) {
        return altWidget?.call(_alt(context.tree.element!.attributes.cast())) ??
            Text(_alt(context.tree.element!.attributes.cast())
                ?? "", style: context.style.generateTextStyle());
      } else {
        return loadingWidget?.call() ?? const CircularProgressIndicator();
      }
    },
  );
  return Builder(
      builder: (buildContext) {
        return GestureDetector(
          key: context.key,
          child: widget,
          onTap: () {
            if (MultipleTapGestureDetector.of(buildContext) != null) {
              MultipleTapGestureDetector.of(buildContext)!.onTap?.call();
            }
            context.parser.onImageTap?.call(
                src,
                context,
                context.tree.element!.attributes.cast(),
                context.tree.element
            );
          },
        );
      }
  );
});

CustomRender interactableElementRender({List<InlineSpan>? children}) =>
    CustomRender.fromInlineSpan(inlineSpan: (context, buildChildren) => TextSpan(
  children: children ?? (context.tree as InteractableElement).children
      .map((tree) => context.parser.parseTree(context, tree))
      .map((childSpan) {
    return _getInteractableChildren(context, context.tree as InteractableElement, childSpan,
        context.style.generateTextStyle().merge(childSpan.style));
  }).toList(),
));

CustomRender layoutElementRender({Widget? child}) =>
  CustomRender.fromInlineSpan(inlineSpan: (context, buildChildren) => WidgetSpan(
    child: child ?? (context.tree as LayoutElement).toWidget(context)!,
));

CustomRender verticalAlignRender({
  double? verticalOffset,
  Style? style,
  List<InlineSpan>? children}) =>
    CustomRender.fromInlineSpan(inlineSpan: (context, buildChildren) => WidgetSpan(
  child: Transform.translate(
    key: context.key,
    offset: Offset(0, verticalOffset ?? _getVerticalOffset(context.tree)),
    child: StyledText(
      textSpan: TextSpan(
        style: style?.generateTextStyle() ?? context.style.generateTextStyle(),
        children: children ?? buildChildren.call(),
      ),
      style: context.style,
      renderContext: context,
    ),
  ),
));

CustomRender fallbackRender({Style? style, List<InlineSpan>? children}) =>
    CustomRender.fromInlineSpan(inlineSpan: (context, buildChildren) => TextSpan(
      style: style?.generateTextStyle() ?? context.style.generateTextStyle(),
      children: context.tree.children
          .expand((tree) => [
        context.parser.parseTree(context, tree),
        if (tree.style.display == Display.BLOCK &&
            tree.element?.localName != "html" &&
            tree.element?.localName != "body")
          TextSpan(text: "\n"),
      ])
          .toList(),
));

final Map<CustomRenderMatcher, CustomRender> defaultRenders = {
  blockElementMatcher(): blockElementRender(),
  listElementMatcher(): listElementRender(),
  textContentElementMatcher(): textContentElementRender(),
  dataUriMatcher(): base64ImageRender(),
  assetUriMatcher(): assetImageRender(),
  networkSourceMatcher(): networkImageRender(),
  replacedElementMatcher(): replacedElementRender(),
  interactableElementMatcher(): interactableElementRender(),
  layoutElementMatcher(): layoutElementRender(),
  verticalAlignMatcher(): verticalAlignRender(),
  fallbackMatcher(): fallbackRender(),
};

List<InlineSpan> _getListElementChildren(ListStylePosition? position, Function() buildChildren) {
  InlineSpan tabSpan = WidgetSpan(child: Text("\t", textAlign: TextAlign.right));
  List<InlineSpan> children = buildChildren.call();
  if (position == ListStylePosition.INSIDE) {
    children.insert(0, tabSpan);
  }
  return children;
}

InlineSpan _getInteractableChildren(RenderContext context, InteractableElement tree, InlineSpan childSpan, TextStyle childStyle) {
  if (childSpan is TextSpan) {
    return TextSpan(
      text: childSpan.text,
      children: childSpan.children
          ?.map((e) => _getInteractableChildren(context, tree, e, childStyle.merge(childSpan.style)))
          .toList(),
      style: context.style.generateTextStyle().merge(
          childSpan.style == null
              ? childStyle
              : childStyle.merge(childSpan.style)),
      semanticsLabel: childSpan.semanticsLabel,
      recognizer: TapGestureRecognizer()
        ..onTap =
          context.parser.onAnchorTap != null ?
              () => context.parser.onAnchorTap!(tree.href, context, tree.attributes, tree.element)
              : null,
    );
  } else {
    return WidgetSpan(
      child: MultipleTapGestureDetector(
        onTap: context.parser.onAnchorTap != null
            ? () => context.parser.onAnchorTap!(tree.href, context, tree.attributes, tree.element)
            : null,
        child: GestureDetector(
          key: context.key,
          onTap: context.parser.onAnchorTap != null
              ? () => context.parser.onAnchorTap!(tree.href, context, tree.attributes, tree.element)
              : null,
          child: (childSpan as WidgetSpan).child,
        ),
      ),
    );
  }
}

final _dataUriFormat = RegExp("^(?<scheme>data):(?<mime>image\/[\\w\+\-\.]+)(?<encoding>;base64)?\,(?<data>.*)");

double _getVerticalOffset(StyledElement tree) {
  switch (tree.style.verticalAlign) {
    case VerticalAlign.SUB:
      return tree.style.fontSize!.size! / 2.5;
    case VerticalAlign.SUPER:
      return tree.style.fontSize!.size! / -2.5;
    default:
      return 0;
  }
}

String? _src(Map<String, String> attributes) {
  return attributes["src"];
}

String? _alt(Map<String, String> attributes) {
  return attributes["alt"];
}

double? _height(Map<String, String> attributes) {
  final heightString = attributes["height"];
  return heightString == null ? heightString as double? : double.tryParse(heightString);
}

double? _width(Map<String, String> attributes) {
  final widthString = attributes["width"];
  return widthString == null ? widthString as double? : double.tryParse(widthString);
}
