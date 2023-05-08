import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/src/css_box_widget.dart';
import 'package:flutter_html/src/css_parser.dart';
import 'package:flutter_html/src/extension/extension.dart';
import 'package:flutter_html/src/html_elements.dart';
import 'package:flutter_html/src/style.dart';
import 'package:html/dom.dart' as dom;


class StyledElementBuiltIn extends Extension {
  const StyledElementBuiltIn();

  @override
  Set<String> get supportedTags => {
    "abbr",
    "acronym",
    "address",
    "b",
    "bdi",
    "bdo",
    "big",
    "cite",
    "code",
    "data",
    "del",
    "dfn",
    "em",
    "font",
    "i",
    "ins",
    "kbd",
    "mark",
    "q",
    "rt",
    "s",
    "samp",
    "small",
    "span",
    "strike",
    "strong",
    "sub",
    "sup",
    "time",
    "tt",
    "u",
    "var",
    "wbr",

    //BLOCK ELEMENTS
    "article",
    "aside",
    "blockquote",
    "body",
    "center",
    "dd",
    "div",
    "dl",
    "dt",
    "figcaption",
    "figure",
    "footer",
    "h1",
    "h2",
    "h3",
    "h4",
    "h5",
    "h6",
    "header",
    "hr",
    "html",
    "li",
    "main",
    "nav",
    "noscript",
    "ol",
    "p",
    "pre",
    "section",
    "summary",
    "ul",
  };

  @override
  StyledElement lex(ExtensionContext context, List<StyledElement> children) {
    StyledElement styledElement = StyledElement(
      name: context.elementName,
      elementId: context.id,
      elementClasses: context.classes.toList(),
      node: context.node as dom.Element,
      children: children,
      style: Style(),
    );

    switch (context.elementName) {
      case "abbr":
      case "acronym":
        styledElement.style = Style(
          textDecoration: TextDecoration.underline,
          textDecorationStyle: TextDecorationStyle.dotted,
        );
        break;
      case "address":
        continue italics;
      case "article":
        styledElement.style = Style(
          display: Display.block,
        );
        break;
      case "aside":
        styledElement.style = Style(
          display: Display.block,
        );
        break;
      bold:
      case "b":
        styledElement.style = Style(
          fontWeight: FontWeight.bold,
        );
        break;
      case "bdo":
        TextDirection textDirection =
        ((context.attributes["dir"] ?? "ltr") == "rtl")
            ? TextDirection.rtl
            : TextDirection.ltr;
        styledElement.style = Style(
          direction: textDirection,
        );
        break;
      case "big":
        styledElement.style = Style(
          fontSize: FontSize.larger,
        );
        break;
      case "blockquote":
        styledElement.style = Style(
          margin: Margins.symmetric(horizontal: 40.0, vertical: 14.0),
          display: Display.block,
        );
        break;
      case "body":
        styledElement.style = Style(
          margin: Margins.all(8.0),
          display: Display.block,
        );
        break;
      case "center":
        styledElement.style = Style(
          alignment: Alignment.center,
          display: Display.block,
        );
        break;
      case "cite":
        continue italics;
      monospace:
      case "code":
        styledElement.style = Style(
          fontFamily: 'Monospace',
        );
        break;
      case "dd":
        styledElement.style = Style(
          margin: Margins.only(left: 40.0),
          display: Display.block,
        );
        break;
      strikeThrough:
      case "del":
        styledElement.style = Style(
          textDecoration: TextDecoration.lineThrough,
        );
        break;
      case "dfn":
        continue italics;
      case "div":
        styledElement.style = Style(
          margin: Margins.all(0),
          display: Display.block,
        );
        break;
      case "dl":
        styledElement.style = Style(
          margin: Margins.symmetric(vertical: 14.0),
          display: Display.block,
        );
        break;
      case "dt":
        styledElement.style = Style(
          display: Display.block,
        );
        break;
      case "em":
        continue italics;
      case "figcaption":
        styledElement.style = Style(
          display: Display.block,
        );
        break;
      case "figure":
        styledElement.style = Style(
          margin: Margins.symmetric(vertical: 14.0, horizontal: 40.0),
          display: Display.block,
        );
        break;
      case "footer":
        styledElement.style = Style(
          display: Display.block,
        );
        break;
      case "font":
        styledElement.style = Style(
          color: context.attributes['color'] != null
              ? context.attributes['color']!.startsWith("#")
              ? ExpressionMapping.stringToColor(context.attributes['color']!)
              : ExpressionMapping.namedColorToColor(
              context.attributes['color']!)
              : null,
          fontFamily: context.attributes['face']?.split(",").first,
          fontSize: context.attributes['size'] != null
              ? numberToFontSize(context.attributes['size']!)
              : null,
        );
        break;
      case "h1":
        styledElement.style = Style(
          fontSize: FontSize(2, Unit.em),
          fontWeight: FontWeight.bold,
          margin: Margins.symmetric(vertical: 0.67, unit: Unit.em),
          display: Display.block,
        );
        break;
      case "h2":
        styledElement.style = Style(
          fontSize: FontSize(1.5, Unit.em),
          fontWeight: FontWeight.bold,
          margin: Margins.symmetric(vertical: 0.83, unit: Unit.em),
          display: Display.block,
        );
        break;
      case "h3":
        styledElement.style = Style(
          fontSize: FontSize(1.17, Unit.em),
          fontWeight: FontWeight.bold,
          margin: Margins.symmetric(vertical: 1, unit: Unit.em),
          display: Display.block,
        );
        break;
      case "h4":
        styledElement.style = Style(
          fontWeight: FontWeight.bold,
          margin: Margins.symmetric(vertical: 1.33, unit: Unit.em),
          display: Display.block,
        );
        break;
      case "h5":
        styledElement.style = Style(
          fontSize: FontSize(0.83, Unit.em),
          fontWeight: FontWeight.bold,
          margin: Margins.symmetric(vertical: 1.67, unit: Unit.em),
          display: Display.block,
        );
        break;
      case "h6":
        styledElement.style = Style(
          fontSize: FontSize(0.67, Unit.em),
          fontWeight: FontWeight.bold,
          margin: Margins.symmetric(vertical: 2.33, unit: Unit.em),
          display: Display.block,
        );
        break;
      case "header":
        styledElement.style = Style(
          display: Display.block,
        );
        break;
      case "hr":
        styledElement.style = Style(
          margin: Margins(
            top: Margin(0.5, Unit.em),
            bottom: Margin(0.5, Unit.em),
            left: Margin.auto(),
            right: Margin.auto(),
          ),
          border: Border.all(),
          display: Display.block,
        );
        break;
      case "html":
        styledElement.style = Style(
          display: Display.block,
        );
        break;
      italics:
      case "i":
        styledElement.style = Style(
          fontStyle: FontStyle.italic,
        );
        break;
      case "ins":
        continue underline;
      case "kbd":
        continue monospace;
      case "li":
        styledElement.style = Style(
          display: Display.listItem,
        );
        break;
      case "main":
        styledElement.style = Style(
          display: Display.block,
        );
        break;
      case "mark":
        styledElement.style = Style(
          color: Colors.black,
          backgroundColor: Colors.yellow,
        );
        break;
      case "nav":
        styledElement.style = Style(
          display: Display.block,
        );
        break;
      case "noscript":
        styledElement.style = Style(
          display: Display.block,
        );
        break;
      case "ol":
        styledElement.style = Style(
          display: Display.block,
          listStyleType: ListStyleType.decimal,
          padding: const EdgeInsets.only(left: 40),
        );
        break;
      case "ul":
        styledElement.style = Style(
          display: Display.block,
          listStyleType: ListStyleType.disc,
          padding: const EdgeInsets.only(left: 40),
        );
        break;
      case "p":
        styledElement.style = Style(
          margin: Margins.symmetric(vertical: 1, unit: Unit.em),
          display: Display.block,
        );
        break;
      case "pre":
        styledElement.style = Style(
          fontFamily: 'monospace',
          margin: Margins.symmetric(vertical: 14.0),
          whiteSpace: WhiteSpace.pre,
          display: Display.block,
        );
        break;
      case "q":
        styledElement.style = Style(
          before: "\"",
          after: "\"",
        );
        break;
      case "s":
        continue strikeThrough;
      case "samp":
        continue monospace;
      case "section":
        styledElement.style = Style(
          display: Display.block,
        );
        break;
      case "small":
        styledElement.style = Style(
          fontSize: FontSize.smaller,
        );
        break;
      case "strike":
        continue strikeThrough;
      case "strong":
        continue bold;
      case "sub":
        styledElement.style = Style(
          fontSize: FontSize.smaller,
          verticalAlign: VerticalAlign.sub,
        );
        break;
      case "sup":
        styledElement.style = Style(
          fontSize: FontSize.smaller,
          verticalAlign: VerticalAlign.sup,
        );
        break;
      case "tt":
        continue monospace;
      underline:
      case "u":
        styledElement.style = Style(
          textDecoration: TextDecoration.underline,
        );
        break;
      case "var":
        continue italics;
    }

    return styledElement;
  }

  @override
  InlineSpan parse(ExtensionContext context, Map<StyledElement, InlineSpan> Function() parseChildren) {
    if(context.styledElement!.style.display == Display.listItem ||
        ((context.styledElement!.style.display == Display.block ||
        context.styledElement!.style.display == Display.inlineBlock) &&
        (context.styledElement!.children.isNotEmpty || context.elementName == "hr"))) {
      return WidgetSpan(
        alignment: PlaceholderAlignment.baseline,
        baseline: TextBaseline.alphabetic,
        child: CssBoxWidget.withInlineSpanChildren(
          //TODO key: needs anchor key,
          style: context.styledElement!.style,
          shrinkWrap: context.parser.shrinkWrap,
          childIsReplaced:
          HtmlElements.replacedExternalElements.contains(context.styledElement!.name),
          children: parseChildren().entries.expandIndexed((i, child) => [
            child.value,
            if (i != context.styledElement!.children.length - 1 &&
                child.key.style.display == Display.block &&
                child.key.element?.localName != "html" &&
                child.key.element?.localName != "body")
              const TextSpan(text: "\n"),
          ])
              .toList(),
        ),
      );
    }

    return TextSpan(
      style: context.styledElement!.style.generateTextStyle(),
      children: parseChildren().entries
          .expand((child) => [
        child.value,
        if (child.key.style.display == Display.block &&
            child.key.element?.parent?.localName != "th" &&
            child.key.element?.parent?.localName != "td" &&
            child.key.element?.localName != "html" &&
            child.key.element?.localName != "body")
          const TextSpan(text: "\n"),
      ])
          .toList(),
    );
  }
}