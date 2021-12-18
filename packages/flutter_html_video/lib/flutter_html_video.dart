library flutter_html_video;

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:video_player/video_player.dart';
import 'package:html/dom.dart' as dom;

typedef VideoControllerCallback = void Function(dom.Element?, ChewieController, VideoPlayerController);

CustomRender videoRender({VideoControllerCallback? onControllerCreated})
  => CustomRender.widget(widget: (context, buildChildren)
    => VideoWidget(context: context, callback: onControllerCreated));

CustomRenderMatcher videoMatcher() => (context) {
  return context.tree.element?.localName == "video";
};

class VideoWidget extends StatefulWidget {
  final RenderContext context;
  final VideoControllerCallback? callback;

  VideoWidget({
    required this.context,
    this.callback,
  });

  @override
  State<StatefulWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  ChewieController? chewieController;
  VideoPlayerController? videoController;
  double? _width;
  double? _height;
  late final List<String?> sources;

  @override
  void initState() {
    final attributes = widget.context.tree.element?.attributes ?? {};
    final sources = <String?>[
      if (attributes['src'] != null)
        attributes['src'],
      ...ReplacedElement.parseMediaSources(widget.context.tree.element!.children),
    ];
    if (sources.isNotEmpty && sources.first != null) {
      _width = double.tryParse(attributes['width'] ?? (attributes['height'] ?? 150) * 2);
      _height = double.tryParse(attributes['height'] ?? (attributes['width'] ?? 300) / 2);
      videoController = VideoPlayerController.network(sources.first!);
      chewieController = ChewieController(
        videoPlayerController: videoController!,
        placeholder: attributes['poster'] != null && attributes['poster']!.isNotEmpty
            ? Image.network(attributes['poster']!)
            : Container(color: Colors.black),
        autoPlay: attributes['autoplay'] != null,
        looping: attributes['loop'] != null,
        showControls: attributes['controls'] != null,
        autoInitialize: true,
        aspectRatio: _width == null || _height == null ? null : _width! / _height!,
      );
      widget.callback?.call(widget.context.tree.element, chewieController!, videoController!);
    }
    super.initState();
  }

  @override
  void dispose() {
    chewieController?.dispose();
    videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext bContext) {
    if (sources.isEmpty || sources.first == null) {
      return Container(height: 0, width: 0);
    }
    final child = Container(
      key: widget.context.key,
      child: Chewie(
        controller: chewieController!,
      ),
    );
    if (_width == null || _height == null) {
      return child;
    }
    return AspectRatio(
      aspectRatio: _width! / _height!,
      child: child,
    );
  }
}