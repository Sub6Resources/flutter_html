import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/src/html_elements.dart';
import 'package:flutter_html/src/styled_element.dart';
import 'package:flutter_html/style.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
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
    final rows = <TableRowLayoutElement>[];
    List<TrackSize> columnSizes = <TrackSize>[];
    for (var child in children) {
      if (child is TableStyleElement) {
        // Map <col> tags to predetermined column track sizes
        columnSizes = child.children
            .where((c) => c.name == "col")
            .map((c) {
              final span =
                  int.parse(c.attributes["span"] ?? "1", onError: (_) => 1);
              final colWidth = c.attributes["width"];
              return List.generate(span, (index) {
                if (colWidth != null && colWidth.endsWith("%")) {
                  final percentageSize = double.tryParse(
                      colWidth.substring(0, colWidth.length - 1));
                  return percentageSize != null
                      ? FlexibleTrackSize(percentageSize * 0.01)
                      : FlexibleTrackSize(1);
                } else if (colWidth != null) {
                  final fixedPxSize = double.tryParse(colWidth);
                  return fixedPxSize != null
                      ? FixedTrackSize(fixedPxSize)
                      : FlexibleTrackSize(1);
                } else {
                  return FlexibleTrackSize(1);
                }
              });
            })
            .expand((element) => element)
            .toList(growable: false);
      } else if (child is TableSectionLayoutElement) {
        rows.addAll(child.children.whereType());
      } else if (child is TableRowLayoutElement) {
        rows.add(child);
      }
    }

    // All table rows have a height intrinsic to their (spanned) contents
    final rowSizes =
        List.generate(rows.length, (_) => IntrinsicContentTrackSize());

    // Calculate column bounds
    int columnMax = rows
        .map((row) => row.children
            .whereType<TableCellElement>()
            .fold(0, (int value, child) => value + child.colspan))
        .fold(0, max);

    // Place the cells in the rows/columns
    final cells = <GridPlacement>[];
    final columnRowOffset = List.generate(columnMax + 1, (_) => 0);
    int rowi = 0;
    for (var row in rows) {
      int columni = 0;
      for (var child in row.children) {
        if (columnRowOffset[columni] > 0) {
          columnRowOffset[columni] = columnRowOffset[columni] - 1;
          columni++;
        }
        if (child is TableCellElement) {
          cells.add(GridPlacement(
            child: Container(
              width: double.infinity,
              padding: child.style.padding ?? row.style.padding,
              decoration: BoxDecoration(
                color: child.style.backgroundColor ?? row.style.backgroundColor,
                border: child.style.border ?? row.style.border,
              ),
              child: SizedBox.expand(
                child: Container(
                  alignment: child.style.alignment ?? style.alignment ??
                      Alignment.centerLeft,
                  child: StyledText(
                    textSpan: context.parser.parseTree(context, child),
                    style: child.style,
                  ),
                ),
              ),
            ),
            columnStart: columni,
            columnSpan: child.colspan,
            rowStart: rowi,
            rowSpan: child.rowspan,
          ));
          columnRowOffset[columni] = child.rowspan - 1;
          columni += child.colspan;
        }
      }
      rowi++;
    }

    // Create column tracks (insofar there were no colgroups that already defined them)
    List<TrackSize> finalColumnSizes = (columnSizes ?? <TrackSize>[]).take(
        columnMax).toList();
    finalColumnSizes += List.generate(
        max(0, columnMax - finalColumnSizes.length),
            (_) => FlexibleTrackSize(1));
    return Container(
      decoration: BoxDecoration(
        color: style.backgroundColor,
        border: style.border,
      ),
      width: style.width,
      height: style.height,
      child: LayoutGrid(
        gridFit: GridFit.loose,
        templateColumnSizes: finalColumnSizes,
        templateRowSizes: rowSizes,
        children: cells,
      ),
    );
  }
}


class TableSectionLayoutElement extends LayoutElement {
  TableSectionLayoutElement({
    String name,
    @required List<StyledElement> children,
  }) : super(name: name, children: children);

  @override
  Widget toWidget(RenderContext context) {
    // Not rendered; TableLayoutElement will instead consume its children
    return Container(child: Text("TABLE SECTION"));
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
    // Not rendered; TableLayoutElement will instead consume its children
    return Container(child: Text("TABLE ROW"));
  }
}

class TableCellElement extends StyledElement {
  int colspan = 1;
  int rowspan = 1;

  TableCellElement({
    String name,
    String elementId,
    List<String> elementClasses,
    @required List<StyledElement> children,
    Style style,
    dom.Element node,
  }) : super(
      name: name,
      elementId: elementId,
      elementClasses: elementClasses,
      children: children,
      style: style,
      node: node) {
    colspan = _parseSpan(this, "colspan");
    rowspan = _parseSpan(this, "rowspan");
  }

  static int _parseSpan(StyledElement element, String attributeName) {
    final spanValue = element.attributes[attributeName];
    return spanValue == null ? 1 : int.tryParse(spanValue) ?? 1;
  }
}

TableCellElement parseTableCellElement(dom.Element element,
    List<StyledElement> children,
) {
  final cell = TableCellElement(
    name: element.localName,
    elementId: element.id,
    elementClasses: element.classes.toList(),
    children: children,
    node: element,
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
    String name,
    List<StyledElement> children,
    Style style,
    dom.Element node,
  }) : super(name: name, children: children, style: style, node: node);
}

TableStyleElement parseTableDefinitionElement(dom.Element element,
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

LayoutElement parseLayoutElement(dom.Element element,
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
