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
    List<TrackSize> columnSizes;
    for (var child in children) {
      if (child.name == "colgroup") {
        // Map <col> tags to predetermined column track sizes
        columnSizes = child.children.where((c) => c.name == "col").map((c) {
          final colWidth = c.attributes["width"];
          if (colWidth != null && colWidth.endsWith("%")) {
            final percentageSize =
                double.tryParse(colWidth.substring(0, colWidth.length - 1));
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
        }).toList(growable: false);
      } else if (child is TableSectionLayoutElement) {
        rows.addAll(child.children.whereType());
      } else if (child is TableRowLayoutElement) {
        rows.add(child);
      }
    }

    // All table rows have a height intrinsic to their (spanned) contents
    final rowSizes =
        List.generate(rows.length, (_) => IntrinsicContentTrackSize());

    // Calculate column bounds to handle rowspan skipping
    int columnMax = rows.map((row) {
      return row.children
          .where((tag) => tag.name == "th" || tag.name == "td")
          .fold(0, (int value, child) {
        final colspanText = child.attributes["colspan"];
        final colspan =
            colspanText == null ? 1 : int.tryParse(colspanText) ?? 1;
        return value + colspan;
      });
    }).fold(0, max);

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
        if (child.name == "th" || child.name == "td") {
          final colspanText = child.attributes["colspan"];
          final rowspanText = child.attributes["rowspan"];
          final colspan =
              colspanText == null ? 1 : int.tryParse(colspanText) ?? 1;
          final rowspan =
              rowspanText == null ? 1 : int.tryParse(rowspanText) ?? 1;
          cells.add(GridPlacement(
            child: Container(
              width: double.infinity,
              padding: child.style.padding ?? row.style.padding,
              decoration: BoxDecoration(
                color: child.style.backgroundColor ?? row.style.backgroundColor,
                border: child.style.border ?? row.style.border,
              ),
              child: StyledText(
                textSpan: context.parser.parseTree(context, child),
                style: child.style,
              ),
            ),
            columnStart: columni,
            columnSpan: colspan,
            rowStart: rowi,
            rowSpan: rowspan,
          ));
          columnRowOffset[columni] = rowspan - 1;
          columni += colspan;
        }
      }
      rowi++;
    }

    final finalColumnSizes =
        columnSizes ?? List.generate(columnMax, (_) => FlexibleTrackSize(1));
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
    return Container(child: Text("TABLE ROW"));
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
