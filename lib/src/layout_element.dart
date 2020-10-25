import 'package:flutter/material.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/src/html_elements.dart';
import 'package:flutter_html/src/styled_element.dart';
import 'package:flutter_html/style.dart';
import 'package:html/dom.dart' as dom;

/// A [LayoutElement] is an element that breaks the normal Inline flow of
/// an html document with a more complex layout. LayoutElements handle
abstract class LayoutElement extends StyledElement {
  LayoutElement({
    String name,
    List<StyledElement> children,
    Style style,
    dom.Element node,
  }) : super(name: name, children: children, style: style, node: node);

  Widget toWidget(RenderContext context);
}

class TableLayoutElement extends LayoutElement {
  TableLayoutElement({
    String name,
    Style style,
    @required List<StyledElement> children,
    dom.Element node,
  }) : super(name: name, style: style, children: children, node: node);

  @override
  Widget toWidget(RenderContext context) {
    final colWidths = children
        .where((c) => c.name == "colgroup")
        .map((group) {
          return group.children.where((c) => c.name == "col").map((c) {
            final widthStr = c.attributes["width"] ?? "";
            if (widthStr.endsWith("%")) {
              final width =
                  double.tryParse(widthStr.substring(0, widthStr.length - 1)) *
                      0.01;
              return FractionColumnWidth(width);
            } else {
              final width = double.tryParse(widthStr);
              return width != null ? FixedColumnWidth(width) : null;
            }
          });
        })
        .expand((i) => i)
        .toList()
        .asMap();

    return Container(
        decoration: BoxDecoration(
          color: style.backgroundColor,
          border: style.border,
        ),
        width: style.width,
        height: style.height,
        child: Table(
          columnWidths: colWidths,
          children: children
              .map((c) {
                if (c is TableSectionLayoutElement) {
                  return c.toTableRows(context);
                }
                return null;
              })
              .where((t) {
                return t != null;
              })
              .toList()
              .expand((i) => i)
              .toList(),
        ));
  }
}

class TableSectionLayoutElement extends LayoutElement {
  TableSectionLayoutElement({
    String name,
    @required List<StyledElement> children,
  }) : super(name: name, children: children);

  @override
  Widget toWidget(RenderContext context) {
    return Container(child: Text("TABLE SECTION"));
  }

  List<TableRow> toTableRows(RenderContext context) {
    int largest = 0;
    children.forEach((element) {
      if (element.children != null) {
        element.children.removeWhere((element1) => element1.children == null);
      }
      if (element.children != null && element.children.toList().length > largest) {
        largest = element.children.toList().length;
      }
    });
    children.forEach((element) {
      if (element.children != null && element.children.toList().length != largest) {
        element.differenceBetweenLargest = largest - element.children.toList().length;
      }
    });
    print("largest row contains $largest items");
    return children.map((c) {
      if (c is TableRowLayoutElement) {
        print("difference between element length and largest row length ${c.differenceBetweenLargest}");
        return c.toTableRow(context, c.differenceBetweenLargest);
      }
      return null;
    }).where((t) {
      return t != null;
    }).toList();
  }
}

class TableRowLayoutElement extends LayoutElement {
  TableRowLayoutElement({
    String name,
    @required List<StyledElement> children,
    dom.Element node,
  }) : super(name: name, children: children, node: node);

  @override
  Widget toWidget(RenderContext context) {
    return Container(child: Text("TABLE ROW"));
  }

  TableRow toTableRow(RenderContext context, int difference) {
    List<TableCell> extraCells = [];
    if (difference != null && difference != 0) {
      int iterator = 1;
      print("adding $difference extra cells to equalize row lengths");
      while (iterator <= difference) {
        extraCells.add(TableCell(child: Container()));
        iterator++;
      }
    }
    List<Widget> rowChildren = children
        .map((c) {
      if (c is StyledElement && c.name == 'td' || c.name == 'th') {
        return TableCell(
            child: Container(
                padding: c.style.padding,
                decoration: BoxDecoration(
                  color: c.style.backgroundColor,
                  border: c.style.border,
                ),
                child: StyledText(
                  textSpan: context.parser.parseTree(context, c),
                  style: c.style,
                )));
      }
      return null;
    })
        .where((c) => c != null)
        .toList();
    rowChildren.addAll(extraCells);
    print("new length for row ${rowChildren.length} (should equal largest row length)");
    return TableRow(
        decoration: BoxDecoration(
          border: style.border,
          color: style.backgroundColor,
        ),
        children: rowChildren);
  }
}

class TableStyleElement extends StyledElement {
  TableStyleElement({
    String name,
    List<StyledElement> children,
    Style style,
    dom.Element node,
  }) : super(name: name, children: children, style: style, node: node);
}

TableStyleElement parseTableDefinitionElement(
  dom.Element element,
  List<StyledElement> children,
) {
  switch (element.localName) {
    case "colgroup":
    case "col":
      return TableStyleElement(
        name: element.localName,
        children: children,
        node: element,
      );
    default:
      return TableStyleElement();
  }
}

LayoutElement parseLayoutElement(
  dom.Element element,
  List<StyledElement> children,
) {
  switch (element.localName) {
    case "table":
      return TableLayoutElement(
        name: element.localName,
        children: children,
        node: element,
      );
      break;
    case "thead":
    case "tbody":
    case "tfoot":
      return TableSectionLayoutElement(
        name: element.localName,
        children: children,
      );
      break;
    case "tr":
      return TableRowLayoutElement(
        name: element.localName,
        children: children,
        node: element,
      );
      break;
    default:
      return TableLayoutElement(children: children);
  }
}
