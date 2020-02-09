import 'dart:ui';

import 'package:csslib/visitor.dart' as css;
import 'package:csslib/parser.dart' as cssparser;
import 'package:flutter_html/style.dart';

Map<String, Style> cssToStyles(css.StyleSheet sheet) {
  sheet.topLevels.forEach((treeNode) {
    if (treeNode is css.RuleSet) {
      print(
          treeNode.selectorGroup.selectors.first.simpleSelectorSequences.first.simpleSelector.name);
    }
  });
}

Style declarationsToStyle(Map<String, List<css.Expression>> declarations) {
  Style style = new Style();
  declarations.forEach((property, value) {
    switch (property) {
      case 'background-color':
        style.backgroundColor = ExpressionMapping.expressionToColor(value.first);
        break;
      case 'color':
        style.color = ExpressionMapping.expressionToColor(value.first);
        break;
      case 'direction':
        style.direction = ExpressionMapping.expressionToDirection(value.first);
        break;
      case 'display':
        style.display = ExpressionMapping.expressionToDisplay(value.first);
        break;
      case 'font-family':
        style.fontFamily = ExpressionMapping.expressionToFontFamily(value.first);
        break;
      case 'font-feature-settings':
        style.fontFeatureSettings = ExpressionMapping.expressionToFontFeatureSettings(value);
        break;
      case 'text-shadow':
        style.textShadow = ExpressionMapping.expressionToTextShadow(value);
        break;
      case 'text-align':
        style.textAlign = ExpressionMapping.expressionToTextAlign(value.first);
        break;
    }
  });
  return style;
}

Style inlineCSSToStyle(String inlineStyle) {
  final sheet = cssparser.parse("*{$inlineStyle}");
  final declarations = DeclarationVisitor().getDeclarations(sheet);
  return declarationsToStyle(declarations);
}

class DeclarationVisitor extends css.Visitor {
  Map<String, List<css.Expression>> _result;
  String _currentProperty;

  Map<String, List<css.Expression>> getDeclarations(css.StyleSheet sheet) {
    _result = new Map<String, List<css.Expression>>();
    sheet.visit(this);
    return _result;
  }

  @override
  void visitDeclaration(css.Declaration node) {
    _currentProperty = node.property;
    _result[_currentProperty] = new List<css.Expression>();
    node.expression.visit(this);
  }

  @override
  void visitExpressions(css.Expressions node) {
    node.expressions.forEach((expression) {
      _result[_currentProperty].add(expression);
    });
  }
}

//Mapping functions
class ExpressionMapping {

  static Color expressionToColor(css.Expression value) {
    if (value is css.HexColorTerm) {
      return stringToColor(value.text);
    }
    //TODO(Sub6Resources): Support function-term values (rgba()/rgb())
    return null;
  }

  static Color stringToColor(String _text) {
    var text = _text.replaceFirst('#', '');
    if (text.length == 3)
      text = text.replaceAllMapped(
          RegExp(r"[a-f]|\d"), (match) => '${match.group(0)}${match.group(0)}');
    int color = int.parse(text, radix: 16);

    if (color <= 0xffffff) {
      return new Color(color).withAlpha(255);
    } else {
      return new Color(color);
    }
  }

  static TextAlign expressionToTextAlign(css.Expression value) {
    if (value is css.LiteralTerm) {
      switch(value.text) {
        case "center":
          return TextAlign.center;
        case "left":
          return TextAlign.left;
        case "right":
          return TextAlign.right;
        case "justify":
          return TextAlign.justify;
        case "end":
          return TextAlign.end;
        case "start":
          return TextAlign.start;
      }
    }
    return TextAlign.start;
  }

  static TextDirection expressionToDirection(css.Expression value) {
    if (value is css.LiteralTerm) {
      switch(value.text) {
        case "ltr":
          return TextDirection.ltr;
        case "rtl":
          return TextDirection.rtl;
      }
    }
    return TextDirection.ltr;
  }

  static List<FontFeature> expressionToFontFeatureSettings(List<css.Expression> value) {
    //TODO
    return [];
  }

  static List<Shadow> expressionToTextShadow(List<css.Expression> value) {
    //TODO
    return [];
  }

  static Display expressionToDisplay(css.Expression value) {
    if (value is css.LiteralTerm) {
      switch(value.text) {
        case 'block':
          return Display.BLOCK;
        case 'inline-block':
          return Display.INLINE_BLOCK;
        case 'inline':
          return Display.INLINE;
        case 'list-item':
          return Display.LIST_ITEM;
      }
    }
  }

  static String expressionToFontFamily(css.Expression value) {
    if(value is css.LiteralTerm)
      return value.text;
  }
}


