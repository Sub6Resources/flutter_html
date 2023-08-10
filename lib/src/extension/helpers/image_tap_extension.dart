import 'package:flutter/widgets.dart';
import 'package:flutter_html/src/builtins/image_builtin.dart';
import 'package:flutter_html/src/css_box_widget.dart';
import 'package:flutter_html/src/extension/html_extension.dart';
import 'package:flutter_html/src/html_parser.dart';
import 'package:flutter_html/src/style.dart';
import 'package:flutter_html/src/tree/styled_element.dart';
import 'package:flutter_html/src/utils.dart';
import 'package:html/dom.dart' as html;

class OnImageTapExtension extends ImageBuiltIn {
  final OnTap onImageTap;

  OnImageTapExtension({required this.onImageTap});

  @override
  Set<String> get supportedTags => {"img"};

  @override
  bool matches(ExtensionContext context) {
    switch (context.currentStep) {
      case CurrentStep.preparing:
        return super.matches(context);
      case CurrentStep.building:
        return context.styledElement is ImageTapExtensionElement;
      default:
        return false;
    }
  }

  @override
  StyledElement prepare(
      ExtensionContext context, List<StyledElement> children) {
    return ImageTapExtensionElement(
      node: html.Element.tag("img-tap"),
      nodeToIndex: context.nodeToIndex,
      style: Style(),
      children: [
        super.prepare(context, children),
      ],
      name: "img-tap",
      elementId: context.id,
      elementClasses: context.classes.toList(),
    );
  }

  @override
  InlineSpan build(ExtensionContext context) {
    final children = context.buildChildrenMapMemoized!;

    assert(
      children.keys.isNotEmpty,
      "The OnImageTapExtension has been thwarted! It no longer has an `img` child",
    );

    final actualImage = children.keys.first;

    return WidgetSpan(
      child: Builder(builder: (buildContext) {
        return GestureDetector(
          child: CssBoxWidget.withInlineSpanChildren(
            children: children.values.toList(),
            style: context.styledElement!.style,
          ),
          onTap: () {
            if (MultipleTapGestureDetector.of(buildContext) != null) {
              MultipleTapGestureDetector.of(buildContext)!.onTap?.call();
            }
            onImageTap(
              actualImage.attributes['src'],
              actualImage.attributes,
              actualImage.element,
            );
          },
        );
      }),
    );
  }
}

class ImageTapExtensionElement extends StyledElement {
  ImageTapExtensionElement({
    super.parent,
    super.children,
    super.elementClasses,
    super.elementId,
    super.name,
    required super.node,
    required super.nodeToIndex,
    required super.style,
  });
}
