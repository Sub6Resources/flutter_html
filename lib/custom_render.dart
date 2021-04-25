
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/src/utils.dart';

typedef CustomRenderMatcher = bool Function(RenderContext context);

CustomRenderMatcher blockElementMatcher() => (context) {
  return context.tree.style.display == Display.BLOCK;
};

CustomRenderMatcher listElementMatcher() => (context) {
  return context.tree.style.display == Display.LIST_ITEM;
};

CustomRenderMatcher replacedElementMatcher() => (context) {
  return context.tree is ReplacedElement;
};

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
  final InlineSpan Function(RenderContext, Function())? inlineSpan;
  final Widget Function(RenderContext, Function())? widget;

  CustomRender.fromInlineSpan({
    required this.inlineSpan,
  }) : widget = null;

  CustomRender.fromWidget({
    required this.widget,
  }) : inlineSpan = null;
}

final CustomRender blockElementRender = CustomRender.fromInlineSpan(inlineSpan: (context, buildChildren) => WidgetSpan(
  child: ContainerSpan(
    newContext: context,
    style: context.tree.style,
    shrinkWrap: context.parser.shrinkWrap,
    children: buildChildren.call(),
  ),
));

final CustomRender listElementRender = CustomRender.fromInlineSpan(inlineSpan: (context, buildChildren) => WidgetSpan(
  child: ContainerSpan(
    newContext: context,
    style: context.tree.style,
    shrinkWrap: context.parser.shrinkWrap,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      textDirection: context.tree.style.direction,
      children: [
        context.tree.style.listStylePosition == ListStylePosition.OUTSIDE ?
        Padding(
          padding: context.tree.style.padding ?? EdgeInsets.only(left: context.tree.style.direction != TextDirection.rtl ? 10.0 : 0.0, right: context.tree.style.direction == TextDirection.rtl ? 10.0 : 0.0),
          child: Text(
              "${context.style.markerContent}",
              textAlign: TextAlign.right,
              style: context.style.generateTextStyle()
          ),
        ) : Container(height: 0, width: 0),
        Text("\t", textAlign: TextAlign.right),
        Expanded(
            child: Padding(
                padding: context.tree.style.listStylePosition == ListStylePosition.INSIDE ?
                EdgeInsets.only(left: context.tree.style.direction != TextDirection.rtl ? 10.0 : 0.0, right: context.tree.style.direction == TextDirection.rtl ? 10.0 : 0.0) : EdgeInsets.zero,
                child: StyledText(
                  textSpan: TextSpan(
                    text: (context.tree.style.listStylePosition ==
                        ListStylePosition.INSIDE)
                        ? '${context.style.markerContent}'
                        : null,
                    children: _getListElementChildren(context.tree.style.listStylePosition, buildChildren),
                    style: context.style.generateTextStyle(),
                  ),
                  style: context.style,
                  renderContext: context,
                )
            )
        )
      ],
    ),
  ),
));

final CustomRender replacedElementRender = CustomRender.fromInlineSpan(inlineSpan: (context, buildChildren) => WidgetSpan(
  alignment: (context.tree as ReplacedElement).alignment,
  baseline: TextBaseline.alphabetic,
  child: (context.tree as ReplacedElement).toWidget(context)!,
));

final CustomRender textContentElementRender = CustomRender.fromInlineSpan(inlineSpan: (context, buildChildren) =>
    TextSpan(text: (context.tree as TextContentElement).text));

final CustomRender interactableElementRender = CustomRender.fromInlineSpan(inlineSpan: (context, buildChildren) => TextSpan(
  children: (context.tree as InteractableElement).children
      .map((tree) => context.parser.parseTree(context, tree))
      .map((childSpan) {
    return _getInteractableChildren(context, context.tree as InteractableElement, childSpan,
        context.style.generateTextStyle().merge(childSpan.style));
  }).toList(),
));

final CustomRender layoutElementRender = CustomRender.fromInlineSpan(inlineSpan: (context, buildChildren) => WidgetSpan(
  child: (context.tree as LayoutElement).toWidget(context)!,
));

final CustomRender verticalAlignRender = CustomRender.fromInlineSpan(inlineSpan: (context, buildChildren) => WidgetSpan(
  child: Transform.translate(
    offset: Offset(0, _getVerticalOffset(context.tree)),
    child: StyledText(
      textSpan: TextSpan(
        style: context.style.generateTextStyle(),
        children: buildChildren.call(),
      ),
      style: context.style,
      renderContext: context,
    ),
  ),
));

final CustomRender fallbackRender = CustomRender.fromInlineSpan(inlineSpan: (context, buildChildren) => TextSpan(
  style: context.style.generateTextStyle(),
  children: buildChildren.call(),
));

final Map<CustomRenderMatcher, CustomRender> defaultRenders = {
  blockElementMatcher(): blockElementRender,
  listElementMatcher(): listElementRender,
  textContentElementMatcher(): textContentElementRender,
  replacedElementMatcher(): replacedElementRender,
  interactableElementMatcher(): interactableElementRender,
  layoutElementMatcher(): layoutElementRender,
  verticalAlignMatcher(): verticalAlignRender,
  fallbackMatcher(): fallbackRender,
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
        ..onTap = () => context.parser.onLinkTap?.call(tree.href, context, tree.attributes, tree.element),
    );
  } else {
    return WidgetSpan(
      child: RawGestureDetector(
        gestures: {
          MultipleTapGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<MultipleTapGestureRecognizer>(
                () => MultipleTapGestureRecognizer(),
                (instance) {
              instance..onTap = () => context.parser.onLinkTap?.call(tree.href, context, tree.attributes, tree.element);
            },
          ),
        },
        child: (childSpan as WidgetSpan).child,
      ),
    );
  }
}

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