import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:chewie/chewie.dart';
import 'package:chewie_audio/chewie_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/src/html_elements.dart';
import 'package:flutter_html/src/utils.dart';
import 'package:flutter_html/style.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:html/dom.dart' as dom;
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// A [ReplacedElement] is a type of [StyledElement] that does not require its [children] to be rendered.
///
/// A [ReplacedElement] may use its children nodes to determine relevant information
/// (e.g. <video>'s <source> tags), but the children nodes will not be saved as [children].
abstract class ReplacedElement extends StyledElement {
  PlaceholderAlignment alignment;

  ReplacedElement(
      {String name,
      Style style,
      dom.Element node,
      this.alignment = PlaceholderAlignment.aboveBaseline})
      : super(name: name, children: null, style: style, node: node);

  static List<String> parseMediaSources(List<dom.Element> elements) {
    return elements
        .where((element) => element.localName == 'source')
        .map((element) {
      return element.attributes['src'];
    }).toList();
  }

  Widget toWidget(RenderContext context);
}

/// [TextContentElement] is a [ContentElement] with plaintext as its content.
class TextContentElement extends ReplacedElement {
  String text;

  TextContentElement({
    Style style,
    this.text,
  }) : super(name: "[text]", style: style);

  @override
  String toString() {
    return "\"${text.replaceAll("\n", "\\n")}\"";
  }

  @override
  Widget toWidget(_) => null;
}

/// [ImageContentElement] is a [ReplacedElement] with an image as its content.
/// https://developer.mozilla.org/en-US/docs/Web/HTML/Element/img
class ImageContentElement extends ReplacedElement {
  final String src;
  final String alt;

  ImageContentElement({
    String name,
    Style style,
    this.src,
    this.alt,
    dom.Element node,
  }) : super(
          name: name,
          style: style,
          node: node,
          alignment: PlaceholderAlignment.middle,
        );

  @override
  Widget toWidget(RenderContext context) {
    Widget imageWidget;
    if (src == null) {
      imageWidget = Text(alt ?? "", style: context.style.generateTextStyle());
    } else if (src.startsWith("data:image") && src.contains("base64,")) {
      final decodedImage = base64.decode(src.split("base64,")[1].trim());
      precacheImage(
        MemoryImage(decodedImage),
        context.buildContext,
        onError: (exception, StackTrace stackTrace) {
          context.parser.onImageError?.call(exception, stackTrace);
        },
      );
      imageWidget = Image.memory(
        decodedImage,
        frameBuilder: (ctx, child, frame, _) {
          if (frame == null) {
            return Text(alt ?? "", style: context.style.generateTextStyle());
          }
          return child;
        },
      );
    } else if (src.startsWith("asset:")) {
      final assetPath = src.replaceFirst('asset:', '');
      precacheImage(
        AssetImage(assetPath),
        context.buildContext,
        onError: (exception, StackTrace stackTrace) {
          context.parser.onImageError?.call(exception, stackTrace);
        },
      );
      imageWidget = Image.asset(
        assetPath,
        frameBuilder: (ctx, child, frame, _) {
          if (frame == null) {
            return Text(alt ?? "", style: context.style.generateTextStyle());
          }
          return child;
        },
      );
    } else {
      precacheImage(
        NetworkImage(src),
        context.buildContext,
        onError: (exception, StackTrace stackTrace) {
          context.parser.onImageError?.call(exception, stackTrace);
        },
      );
      Completer<Size> completer = Completer();
      Image image = Image.network(src, frameBuilder: (ctx, child, frame, _) {
        if (frame == null) {
          completer.completeError("error");
          return child;
        } else {
          return child;
        }
      });
      image.image.resolve(ImageConfiguration()).addListener(
        ImageStreamListener(
              (ImageInfo image, bool synchronousCall) {
            var myImage = image.image;
            Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
            completer.complete(size);
          }, onError: (object, stacktrace) {
            completer.completeError(object);
          }
        ),
      );
      imageWidget = FutureBuilder<Size>(
        future: completer.future,
        builder: (BuildContext buildContext, AsyncSnapshot<Size> snapshot) {
          if (snapshot.hasData) {
            return new Image.network(
              src,
              width: snapshot.data.width,
              frameBuilder: (ctx, child, frame, _) {
                if (frame == null) {
                  return Text(alt ?? "", style: context.style.generateTextStyle());
                }
                return child;
              },
            );
          } else if (snapshot.hasError) {
            return Text(alt ?? "", style: context.style.generateTextStyle());
          } else {
            return new CircularProgressIndicator();
          }
        },
      );
    }

    return ContainerSpan(
      style: style,
      newContext: context,
      shrinkWrap: context.parser.shrinkWrap,
      child: RawGestureDetector(
        child: imageWidget,
        gestures: {
          MultipleTapGestureRecognizer: GestureRecognizerFactoryWithHandlers<
              MultipleTapGestureRecognizer>(
            () => MultipleTapGestureRecognizer(),
            (instance) {
              instance..onTap = () => context.parser.onImageTap?.call(src);
            },
          ),
        },
      ),
    );
  }
}

/// [IframeContentElement is a [ReplacedElement] with web content.
class IframeContentElement extends ReplacedElement {
  final String src;
  final double width;
  final double height;
  final NavigationDelegate navigationDelegate;

  IframeContentElement({
    String name,
    Style style,
    this.src,
    this.width,
    this.height,
    dom.Element node,
    this.navigationDelegate,
  }) : super(name: name, style: style, node: node);

  @override
  Widget toWidget(RenderContext context) {
    return Container(
      width: width ?? (height ?? 150) * 2,
      height: height ?? (width ?? 300) / 2,
      child: WebView(
        initialUrl: src,
        javascriptMode: JavascriptMode.unrestricted,
        navigationDelegate: navigationDelegate,
        gestureRecognizers: {
          Factory(() => PlatformViewVerticalGestureRecognizer())
        },
      ),
    );
  }
}

/// [AudioContentElement] is a [ContentElement] with an audio file as its content.
class AudioContentElement extends ReplacedElement {
  final List<String> src;
  final bool showControls;
  final bool autoplay;
  final bool loop;
  final bool muted;

  AudioContentElement({
    String name,
    Style style,
    this.src,
    this.showControls,
    this.autoplay,
    this.loop,
    this.muted,
    dom.Element node,
  }) : super(name: name, style: style, node: node);

  @override
  Widget toWidget(RenderContext context) {
    return Container(
      width: context.style.width ?? 300,
      child: ChewieAudio(
        controller: ChewieAudioController(
          videoPlayerController: VideoPlayerController.network(
            src.first ?? "",
          ),
          autoPlay: autoplay,
          looping: loop,
          showControls: showControls,
          autoInitialize: true,
        ),
      ),
    );
  }
}

/// [VideoContentElement] is a [ContentElement] with a video file as its content.
class VideoContentElement extends ReplacedElement {
  final List<String> src;
  final String poster;
  final bool showControls;
  final bool autoplay;
  final bool loop;
  final bool muted;
  final double width;
  final double height;

  VideoContentElement({
    String name,
    Style style,
    this.src,
    this.poster,
    this.showControls,
    this.autoplay,
    this.loop,
    this.muted,
    this.width,
    this.height,
    dom.Element node,
  }) : super(name: name, style: style, node: node);

  @override
  Widget toWidget(RenderContext context) {
    final double _width = width ?? (height ?? 150) * 2;
    final double _height = height ?? (width ?? 300) / 2;
    return Container(
      child: Chewie(
        controller: ChewieController(
          videoPlayerController: VideoPlayerController.network(
            src.first ?? "",
          ),
          placeholder: poster != null
              ? Image.network(poster)
              : Container(color: Colors.black),
          autoPlay: autoplay,
          looping: loop,
          showControls: showControls,
          autoInitialize: true,
          aspectRatio: _width / _height,
        ),
      ),
    );
  }
}

/// [SvgContentElement] is a [ReplacedElement] with an SVG as its contents.
class SvgContentElement extends ReplacedElement {
  final String data;
  final double width;
  final double height;

  SvgContentElement({
    this.data,
    this.width,
    this.height,
  });

  @override
  Widget toWidget(RenderContext context) {
    return SvgPicture.string(
      data,
      width: width,
      height: height,
    );
  }
}

class EmptyContentElement extends ReplacedElement {
  EmptyContentElement({String name = "empty"}) : super(name: name);

  @override
  Widget toWidget(_) => null;
}

class RubyElement extends ReplacedElement {
  dom.Element element;

  RubyElement({@required this.element, String name = "ruby"})
      : super(name: name, alignment: PlaceholderAlignment.middle);

  @override
  Widget toWidget(RenderContext context) {
    dom.Node textNode;
    List<Widget> widgets = List<Widget>();
    //TODO calculate based off of parent font size.
    final rubySize = max(9.0, context.style.fontSize.size / 2);
    final rubyYPos = rubySize + rubySize / 2;
    element.nodes.forEach((c) {
      if (c.nodeType == dom.Node.TEXT_NODE) {
        textNode = c;
      }
      if (c is dom.Element) {
        if (c.localName == "rt" && textNode != null) {
          final widget = Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                  alignment: Alignment.bottomCenter,
                  child: Center(
                      child: Transform(
                          transform:
                              Matrix4.translationValues(0, -(rubyYPos), 0),
                          child: Text(c.innerHtml,
                              style: context.style
                                  .generateTextStyle()
                                  .copyWith(fontSize: rubySize))))),
              Container(
                  child: Text(textNode.text.trim(),
                      style: context.style.generateTextStyle())),
            ],
          );
          widgets.add(widget);
        }
      }
    });
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      textBaseline: TextBaseline.alphabetic,
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }
}

ReplacedElement parseReplacedElement(
  dom.Element element,
  NavigationDelegate navigationDelegateForIframe,
) {
  switch (element.localName) {
    case "audio":
      final sources = <String>[
        if (element.attributes['src'] != null) element.attributes['src'],
        ...ReplacedElement.parseMediaSources(element.children),
      ];
      return AudioContentElement(
        name: "audio",
        src: sources,
        showControls: element.attributes['controls'] != null,
        loop: element.attributes['loop'] != null,
        autoplay: element.attributes['autoplay'] != null,
        muted: element.attributes['muted'] != null,
        node: element,
      );
    case "br":
      return TextContentElement(
        text: "\n",
        style: Style(whiteSpace: WhiteSpace.PRE),
      );
    case "iframe":
      return IframeContentElement(
        name: "iframe",
        src: element.attributes['src'],
        width: double.tryParse(element.attributes['width'] ?? ""),
        height: double.tryParse(element.attributes['height'] ?? ""),
        navigationDelegate: navigationDelegateForIframe,
      );
    case "img":
      return ImageContentElement(
        name: "img",
        src: element.attributes['src'],
        alt: element.attributes['alt'],
        node: element,
      );
    case "video":
      final sources = <String>[
        if (element.attributes['src'] != null) element.attributes['src'],
        ...ReplacedElement.parseMediaSources(element.children),
      ];
      return VideoContentElement(
        name: "video",
        src: sources,
        poster: element.attributes['poster'],
        showControls: element.attributes['controls'] != null,
        loop: element.attributes['loop'] != null,
        autoplay: element.attributes['autoplay'] != null,
        muted: element.attributes['muted'] != null,
        width: double.tryParse(element.attributes['width'] ?? ""),
        height: double.tryParse(element.attributes['height'] ?? ""),
        node: element,
      );
    case "svg":
      return SvgContentElement(
        data: element.outerHtml,
        width: double.tryParse(element.attributes['width'] ?? ""),
        height: double.tryParse(element.attributes['height'] ?? ""),
      );
    case "ruby":
      return RubyElement(
        element: element,
      );
    default:
      return EmptyContentElement(name: element.localName);
  }
}

// TODO(Sub6Resources): Remove when https://github.com/flutter/flutter/issues/36304 is resolved
class PlatformViewVerticalGestureRecognizer
    extends VerticalDragGestureRecognizer {
  PlatformViewVerticalGestureRecognizer({PointerDeviceKind kind})
      : super(kind: kind);

  Offset _dragDistance = Offset.zero;

  @override
  void addPointer(PointerEvent event) {
    startTrackingPointer(event.pointer);
  }

  @override
  void handleEvent(PointerEvent event) {
    _dragDistance = _dragDistance + event.delta;
    if (event is PointerMoveEvent) {
      final double dy = _dragDistance.dy.abs();
      final double dx = _dragDistance.dx.abs();

      if (dy > dx && dy > kTouchSlop) {
        // vertical drag - accept
        resolve(GestureDisposition.accepted);
        _dragDistance = Offset.zero;
      } else if (dx > kTouchSlop && dx > dy) {
        // horizontal drag - stop tracking
        stopTrackingPointer(event.pointer);
        _dragDistance = Offset.zero;
      }
    }
  }

  @override
  String get debugDescription => 'horizontal drag (platform view)';

  @override
  void didStopTrackingLastPointer(int pointer) {}
}
