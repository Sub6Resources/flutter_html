import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/src/utils.dart';

typedef CustomRenderMatcher = bool Function(RenderContext context);

CustomRenderMatcher tagMatcher(String tag) => (context) {
  return context.tree.element?.localName == tag;
};

CustomRenderMatcher blockElementMatcher() => (context) {
      return context.tree.style.display == Display.BLOCK &&
          (context.tree.children.isNotEmpty || context.tree.element?.localName == "hr");
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
  final InlineSpan Function(RenderContext, List<InlineSpan> Function())? inlineSpan;
  final Widget Function(RenderContext, List<InlineSpan> Function())? widget;

  CustomRender.inlineSpan({
    required this.inlineSpan,
  }) : widget = null;

  CustomRender.widget({
    required this.widget,
  }) : inlineSpan = null;
}

class SelectableCustomRender extends CustomRender {
  final TextSpan Function(RenderContext, List<TextSpan> Function()) textSpan;

  SelectableCustomRender.fromTextSpan({
    required this.textSpan,
  }) : super.inlineSpan(inlineSpan: null);
}

CustomRender blockElementRender({
  Style? style,
  Widget? child,
  List<InlineSpan>? children,}) =>
    CustomRender.inlineSpan(inlineSpan: (context, buildChildren) {
        if (context.parser.selectable) {
          return TextSpan(
            style: context.style.generateTextStyle(),
            children: (children as List<TextSpan>?) ?? context.tree.children
                .expandIndexed((i, childTree) => [
              if (childTree.style.display == Display.BLOCK &&
                  i > 0 &&
                  context.tree.children[i - 1] is ReplacedElement)
                TextSpan(text: "\n"),
              context.parser.parseTree(context, childTree),
              if (i != context.tree.children.length - 1 &&
                  childTree.style.display == Display.BLOCK &&
                  childTree.element?.localName != "html" &&
                  childTree.element?.localName != "body")
                TextSpan(text: "\n"),
            ])
                .toList(),
          );
        }
        return WidgetSpan(
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
          ));
    });

CustomRender listElementRender({
  Style? style,
  Widget? child,
  List<InlineSpan>? children}) =>
    CustomRender.inlineSpan(inlineSpan: (context, buildChildren) =>
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
                  padding: style?.padding?.nonNegative ?? context.tree.style.padding?.nonNegative
                      ?? EdgeInsets.only(left: (style?.direction ?? context.tree.style.direction) != TextDirection.rtl ? 10.0 : 0.0,
                          right: (style?.direction ?? context.tree.style.direction) == TextDirection.rtl ? 10.0 : 0.0),
                  child: style?.markerContent ?? context.style.markerContent
                ) : Container(height: 0, width: 0),
                Text("\t", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w400)),
                Expanded(
                    child: Padding(
                        padding: (style?.listStylePosition ?? context.tree.style.listStylePosition) == ListStylePosition.INSIDE ?
                          EdgeInsets.only(left: (style?.direction ?? context.tree.style.direction) != TextDirection.rtl ? 10.0 : 0.0,
                            right: (style?.direction ?? context.tree.style.direction) == TextDirection.rtl ? 10.0 : 0.0) : EdgeInsets.zero,
                        child: StyledText(
                          textSpan: TextSpan(
                            children: _getListElementChildren(style?.listStylePosition ?? context.tree.style.listStylePosition, buildChildren)
                              ..insertAll(0, context.tree.style.listStylePosition == ListStylePosition.INSIDE ?
                            [
                              WidgetSpan(alignment: PlaceholderAlignment.middle, child: style?.markerContent ?? context.style.markerContent ?? Container(height: 0, width: 0))
                            ] : []),
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
    CustomRender.inlineSpan(inlineSpan: (context, buildChildren) => WidgetSpan(
  alignment: alignment ?? (context.tree as ReplacedElement).alignment,
  baseline: baseline ?? TextBaseline.alphabetic,
  child: child ?? (context.tree as ReplacedElement).toWidget(context)!,
));

CustomRender textContentElementRender({String? text}) =>
    CustomRender.inlineSpan(inlineSpan: (context, buildChildren) =>
      TextSpan(text: (text ?? (context.tree as TextContentElement).text).transformed(context.tree.style.textTransform)));

CustomRender interactableElementRender({List<InlineSpan>? children}) =>
    CustomRender.inlineSpan(inlineSpan: (context, buildChildren) => TextSpan(
  children: children ?? (context.tree as InteractableElement).children
      .map((tree) => context.parser.parseTree(context, tree))
      .map((childSpan) {
    return _getInteractableChildren(context, context.tree as InteractableElement, childSpan,
        context.style.generateTextStyle().merge(childSpan.style));
  }).toList(),
));

CustomRender layoutElementRender({Widget? child}) =>
  CustomRender.inlineSpan(inlineSpan: (context, buildChildren) => WidgetSpan(
    child: child ?? (context.tree as LayoutElement).toWidget(context)!,
));

CustomRender verticalAlignRender({
  double? verticalOffset,
  Style? style,
  List<InlineSpan>? children}) =>
    CustomRender.inlineSpan(inlineSpan: (context, buildChildren) => WidgetSpan(
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
    CustomRender.inlineSpan(inlineSpan: (context, buildChildren) => TextSpan(
      style: style?.generateTextStyle() ?? context.style.generateTextStyle(),
      children: context.tree.children
          .expand((tree) => [
        context.parser.parseTree(context, tree),
        if (tree.style.display == Display.BLOCK &&
            tree.element?.parent?.localName != "th" &&
            tree.element?.parent?.localName != "td" &&
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
  replacedElementMatcher(): replacedElementRender(),
  interactableElementMatcher(): interactableElementRender(),
  layoutElementMatcher(): layoutElementRender(),
  verticalAlignMatcher(): verticalAlignRender(),
  fallbackMatcher(): fallbackRender(),
};

List<InlineSpan> _getListElementChildren(ListStylePosition? position, Function() buildChildren) {
  List<InlineSpan> children = buildChildren.call();
  if (position == ListStylePosition.INSIDE) {
    final tabSpan = WidgetSpan(
      child: Text("\t", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w400)),
    );
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
          context.parser.internalOnAnchorTap != null ?
              () => context.parser.internalOnAnchorTap!(tree.href, context, tree.attributes, tree.element)
              : null,
    );
  } else {
    return WidgetSpan(
      child: MultipleTapGestureDetector(
        onTap: context.parser.internalOnAnchorTap != null
            ? () => context.parser.internalOnAnchorTap!(tree.href, context, tree.attributes, tree.element)
            : null,
        child: GestureDetector(
          key: context.key,
          onTap: context.parser.internalOnAnchorTap != null
              ? () => context.parser.internalOnAnchorTap!(tree.href, context, tree.attributes, tree.element)
              : null,
          child: (childSpan as WidgetSpan).child,
        ),
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