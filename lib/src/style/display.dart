/// Equivalent to CSS `display`
///
/// (https://www.w3.org/TR/css-display-3/#the-display-properties)
enum Display {
  /// Equivalent to css `display: none;`
  none(
    displayBox: DisplayBox.none,
  ),

  /// Equivalent to css `display: contents;`
  ///
  /// Not supported by flutter_html
  contents(
    displayBox: DisplayBox.contents,
  ),

  /// Equivalent to css `display: block;`
  block(
    displayOutside: DisplayOutside.block,
    displayInside: DisplayInside.flow,
  ),

  /// Equivalent to css `display: flow-root;`
  ///
  /// Not supported by flutter_html
  flowRoot(
    displayOutside: DisplayOutside.block,
    displayInside: DisplayInside.flowRoot,
  ),

  /// Equivalent to css `display: inline;`
  inline(
    displayOutside: DisplayOutside.inline,
    displayInside: DisplayInside.flow,
  ),

  /// Equivalent to css `display: inline-block;`
  inlineBlock(
    displayOutside: DisplayOutside.inline,
    displayInside: DisplayInside.flowRoot,
  ),

  /// Equivalent to css `display: run-in;`
  ///
  /// Not supported by flutter_html
  runIn(
    displayOutside: DisplayOutside.runIn,
    displayInside: DisplayInside.flow,
  ),

  /// Equivalent to css `display: list-item;`
  listItem(
    displayOutside: DisplayOutside.block,
    displayInside: DisplayInside.flow,
    displayListItem: true,
  ),

  /// Equivalent to css `display: inline list-item;`
  inlineListItem(
    displayOutside: DisplayOutside.inline,
    displayInside: DisplayInside.flow,
    displayListItem: true,
  ),

  /// Equivalent to css `display: flex;`
  ///
  /// Not supported by flutter_html
  flex(
    displayOutside: DisplayOutside.block,
    displayInside: DisplayInside.flex,
  ),

  /// Equivalent to css `display: inline-flex;`
  ///
  /// Not supported by flutter_html
  inlineFlex(
    displayOutside: DisplayOutside.inline,
    displayInside: DisplayInside.flex,
  ),

  /// Equivalent to css `display: grid;`
  ///
  /// Not supported by flutter_html
  grid(
    displayOutside: DisplayOutside.block,
    displayInside: DisplayInside.grid,
  ),

  /// Equivalent to css `display: inline-grid;`
  ///
  /// Not supported by flutter_html
  inlineGrid(
    displayOutside: DisplayOutside.inline,
    displayInside: DisplayInside.grid,
  ),

  /// Equivalent to css `display: ruby;`
  ruby(
    displayOutside: DisplayOutside.inline,
    displayInside: DisplayInside.ruby,
  ),

  /// Equivalent to css `display: block ruby;`
  blockRuby(
    displayOutside: DisplayOutside.block,
    displayInside: DisplayInside.ruby,
  ),

  /// Equivalent to css `display: table;`
  table(
    displayOutside: DisplayOutside.block,
    displayInside: DisplayInside.table,
  ),

  /// Equivalent to css `display: inline-table;`
  inlineTable(
    displayOutside: DisplayOutside.inline,
    displayInside: DisplayInside.table,
  ),

  /// Equivalent to css `display: table-row-group;`
  tableRowGroup(
    displayInternal: DisplayInternal.tableRowGroup,
  ),

  /// Equivalent to css `display: table-header-group;`
  tableHeaderGroup(
    displayInternal: DisplayInternal.tableHeaderGroup,
  ),

  /// Equivalent to css `display: table-footer-group;`
  tableFooterGroup(
    displayInternal: DisplayInternal.tableFooterGroup,
  ),

  /// Equivalent to css `display: table-row;`
  tableRow(
    displayInternal: DisplayInternal.tableRowGroup,
  ),

  /// Equivalent to css `display: table-cell;`
  tableCell(
    displayInternal: DisplayInternal.tableCell,
    displayInside: DisplayInside.flowRoot,
  ),

  /// Equivalent to css `display: table-column-group;`
  tableColumnGroup(
    displayInternal: DisplayInternal.tableColumnGroup,
  ),

  /// Equivalent to css `display: table-column;`
  tableColumn(
    displayInternal: DisplayInternal.tableColumn,
  ),

  /// Equivalent to css `display: table-caption;`
  tableCaption(
    displayInternal: DisplayInternal.tableCaption,
    displayInside: DisplayInside.flowRoot,
  ),

  /// Equivalent to css `display: ruby-base;`
  rubyBase(
    displayInternal: DisplayInternal.rubyBase,
    displayInside: DisplayInside.flow,
  ),

  /// Equivalent to css `display: ruby-text;`
  rubyText(
    displayInternal: DisplayInternal.rubyText,
    displayInside: DisplayInside.flow,
  ),

  /// Equivalent to css `display: ruby-base-container;`
  rubyBaseContainer(
    displayInternal: DisplayInternal.rubyBaseContainer,
  ),

  /// Equivalent to css `display: ruby-text-container;`
  rubyTextContainer(
    displayInternal: DisplayInternal.rubyTextContainer,
  );

  const Display({
    this.displayOutside,
    this.displayInside,
    this.displayListItem = false,
    this.displayInternal,
    this.displayBox,
  });

  final DisplayOutside? displayOutside;
  final DisplayInside? displayInside;
  final bool displayListItem;
  final DisplayInternal? displayInternal;
  final DisplayBox? displayBox;

  /// Evaluates to `true` if `displayOutside` is equal to
  /// `DisplayOutside.block`.
  bool get isBlock {
    return displayOutside == DisplayOutside.block;
  }
}

enum DisplayOutside {
  block,
  inline,
  runIn, // not supported
}

enum DisplayInside {
  flow,
  flowRoot,
  table,
  flex, // not supported
  grid, // not supported
  ruby,
}

enum DisplayInternal {
  tableRowGroup,
  tableHeaderGroup,
  tableFooterGroup,
  tableRow,
  tableCell,
  tableColumnGroup,
  tableColumn,
  tableCaption,
  rubyBase,
  rubyText,
  rubyBaseContainer,
  rubyTextContainer,
}

enum DisplayBox {
  contents, // not supported
  none,
}
