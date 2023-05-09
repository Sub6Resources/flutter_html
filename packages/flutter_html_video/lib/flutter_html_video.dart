library flutter_html_video;

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:video_player/video_player.dart';
import 'package:html/dom.dart' as dom;
import 'dart:io';

typedef VideoControllerCallback = void Function(
    dom.Element?, ChewieController, VideoPlayerController);

/// A CustomRender function for rendering the <video> HTML tag.
CustomRender videoRender({VideoControllerCallback? onControllerCreated}) =>
    CustomRender.widget(
        widget: (context, buildChildren) =>
            VideoWidget(context: context, callback: onControllerCreated));

/// A CustomRenderMatcher for the <video> HTML tag
CustomRenderMatcher videoMatcher() => (context) {
      return context.tree.element?.localName == "video";
    };

/// A VideoWidget for displaying within the HTML tree.
class VideoWidget extends StatefulWidget {
  final RenderContext context;
  final VideoControllerCallback? callback;
  final List<DeviceOrientation>? deviceOrientationsOnEnterFullScreen;
  final List<DeviceOrientation> deviceOrientationsAfterFullScreen;

  const VideoWidget({
    Key? key,
    required this.context,
    this.callback,
    this.deviceOrientationsOnEnterFullScreen,
    this.deviceOrientationsAfterFullScreen = DeviceOrientation.values,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  ChewieController? _chewieController;
  VideoPlayerController? _videoController;
  double? _width;
  double? _height;

  @override
  void initState() {
    final attributes = widget.context.tree.element?.attributes ?? {};
    final sources = <String?>[
      if (attributes['src'] != null) attributes['src'],
      ...ReplacedElement.parseMediaSources(
          widget.context.tree.element!.children),
    ];
    final givenWidth = double.tryParse(attributes['width'] ?? "");
    final givenHeight = double.tryParse(attributes['height'] ?? "");
    if (sources.isNotEmpty && sources.first != null) {
      _width = givenWidth ?? (givenHeight ?? 150) * 2;
      _height = givenHeight ?? (givenWidth ?? 300) / 2;
      Uri sourceUri = Uri.parse(sources.first!);
      switch (sourceUri.scheme) {
        case 'asset':
          _videoController = VideoPlayerController.asset(sourceUri.path);
          break;
        case 'file':
          _videoController =
              VideoPlayerController.file(File.fromUri(sourceUri));
          break;
        default:
          _videoController =
              VideoPlayerController.network(sourceUri.toString());
          break;
      }
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        placeholder:
            attributes['poster'] != null && attributes['poster']!.isNotEmpty
                ? Image.network(attributes['poster']!)
                : Container(color: Colors.black),
        autoPlay: attributes['autoplay'] != null,
        looping: attributes['loop'] != null,
        showControls: attributes['controls'] != null,
        autoInitialize: true,
        aspectRatio:
            _width == null || _height == null ? null : _width! / _height!,
        deviceOrientationsOnEnterFullScreen:
            widget.deviceOrientationsOnEnterFullScreen,
        deviceOrientationsAfterFullScreen:
            widget.deviceOrientationsAfterFullScreen,
      );
      widget.callback?.call(
          widget.context.tree.element, _chewieController!, _videoController!);
    }
    super.initState();
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext bContext) {
    if (_chewieController == null) {
      return const SizedBox(height: 0, width: 0);
    }
    final child = Container(
      key: widget.context.key,
      child: Chewie(
        controller: _chewieController!,
      ),
    );
    return AspectRatio(
      aspectRatio: _width! / _height!,
      child: child,
    );
  }
}
