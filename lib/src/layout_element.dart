import 'package:flutter/material.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/src/anchor.dart';
import 'package:flutter_html/src/css_box_widget.dart';
import 'package:flutter_html/src/html_elements.dart';
import 'package:flutter_html/src/styled_element.dart';
import 'package:flutter_html/style.dart';
import 'package:html/dom.dart' as dom;

/// A [LayoutElement] is an element that breaks the normal Inline flow of
/// an html document with a more complex layout. LayoutElements handle
abstract class LayoutElement extends StyledElement {
  LayoutElement({
    String name = "[[No Name]]",
    required super.children,
    String? elementId,
    super.node,
  }) : super(name: name, style: Style(), elementId: elementId ?? "[[No ID]]");

  Widget? toWidget(RenderContext context);
}

class TableSectionLayoutElement extends LayoutElement {
  TableSectionLayoutElement({
    required String name,
    required List<StyledElement> children,
  }) : super(name: name, children: children);

  @override
  Widget toWidget(RenderContext context) {
    // Not rendered; TableLayoutElement will instead consume its children
    return const Text("TABLE SECTION");
  }
}

class TableRowLayoutElement extends LayoutElement {
  TableRowLayoutElement({
    required super.name,
    required super.children,
    required super.node,
  });

  @override
  Widget toWidget(RenderContext context) {
    // Not rendered; TableLayoutElement will instead consume its children
    return const Text("TABLE ROW");
  }
}

class TableCellElement extends StyledElement {
  int colspan = 1;
  int rowspan = 1;

  TableCellElement({
    required super.name,
    required super.elementId,
    required super.elementClasses,
    required super.children,
    required super.style,
    required super.node,
  }) {
    colspan = _parseSpan(this, "colspan");
    rowspan = _parseSpan(this, "rowspan");
  }

  static int _parseSpan(StyledElement element, String attributeName) {
    final spanValue = element.attributes[attributeName];
    return spanValue == null ? 1 : int.tryParse(spanValue) ?? 1;
  }
}

TableCellElement parseTableCellElement(
  dom.Element element,
  List<StyledElement> children,
) {
  final cell = TableCellElement(
    name: element.localName!,
    elementId: element.id,
    elementClasses: element.classes.toList(),
    children: children,
    node: element,
    style: Style(),
  );
  if (element.localName == "th") {
    cell.style = Style(
      fontWeight: FontWeight.bold,
    );
  }
  return cell;
}

class TableStyleElement extends StyledElement {
  TableStyleElement({
    required super.name,
    required super.children,
    required super.style,
    required super.node,
  });
}

TableStyleElement parseTableDefinitionElement(
  dom.Element element,
  List<StyledElement> children,
) {
  switch (element.localName) {
    case "colgroup":
    case "col":
      return TableStyleElement(
        name: element.localName!,
        children: children,
        node: element,
        style: Style(),
      );
    default:
      return TableStyleElement(
        name: "[[No Name]]",
        children: children,
        node: element,
        style: Style(),
      );
  }
}

class DetailsContentElement extends LayoutElement {
  List<dom.Element> elementList;

  DetailsContentElement({
    required super.name,
    required super.children,
    required dom.Element node,
    required this.elementList,
  }) : super(node: node, elementId: node.id);

  @override
  Widget toWidget(RenderContext context) {
    List<InlineSpan>? childrenList = children
        .map((tree) => context.parser.parseTree(context, tree))
        .toList();
    List<InlineSpan> toRemove = [];
    for (InlineSpan child in childrenList) {
      if (child is TextSpan &&
          child.text != null &&
          child.text!.trim().isEmpty) {
        toRemove.add(child);
      }
    }
    for (InlineSpan child in toRemove) {
      childrenList.remove(child);
    }
    InlineSpan? firstChild =
        childrenList.isNotEmpty == true ? childrenList.first : null;
    return ExpansionTile(
        key: AnchorKey.of(context.parser.key, this),
        expandedAlignment: Alignment.centerLeft,
        title: elementList.isNotEmpty == true &&
                elementList.first.localName == "summary"
            ? CssBoxWidget.withInlineSpanChildren(
                children: firstChild == null ? [] : [firstChild],
                style: style,
              )
            : const Text("Details"),
        children: [
          CssBoxWidget.withInlineSpanChildren(
            children: getChildren(
                childrenList,
                context,
                elementList.isNotEmpty == true &&
                        elementList.first.localName == "summary"
                    ? firstChild
                    : null),
            style: style,
          ),
        ]);
  }

  List<InlineSpan> getChildren(List<InlineSpan> children, RenderContext context,
      InlineSpan? firstChild) {
    if (firstChild != null) children.removeAt(0);
    return children;
  }
}

class EmptyLayoutElement extends LayoutElement {
  EmptyLayoutElement({required String name})
      : super(
          name: name,
          children: [],
        );

  @override
  Widget? toWidget(context) => null;
}

LayoutElement parseLayoutElement(
  dom.Element element,
  List<StyledElement> children,
) {
  switch (element.localName) {
    case "details":
      if (children.isEmpty) {
        return EmptyLayoutElement(name: "empty");
      }
      return DetailsContentElement(
        node: element,
        name: element.localName!,
        children: children,
        elementList: element.children,
      );
    case "thead":
    case "tbody":
    case "tfoot":
      return TableSectionLayoutElement(
        name: element.localName!,
        children: children,
      );
    case "tr":
      return TableRowLayoutElement(
        name: element.localName!,
        children: children,
        node: element,
      );
    default:
      return EmptyLayoutElement(name: "[[No Name]]");
  }
}
