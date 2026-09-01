// Adapted from package:html's internal `SelectorEvaluator`
// (https://github.com/dart-lang/tools/blob/main/pkgs/html/lib/src/query_selector.dart),
// which is not part of that package's public API (it lives under `lib/src/`)
// and may change or disappear without notice, as happened in html 0.15.7
// (https://github.com/dart-lang/tools/issues/2574). Vendoring it here, built
// only on package:html's public `Element`/`Node` API and package:csslib's
// public selector AST, removes flutter_html's dependency on html package
// internals.
//
// Copyright (c) 2006-2012 The Authors (see html package LICENSE). Used under
// the terms of the html package's MIT-style license.

import 'package:csslib/parser.dart';
import 'package:csslib/visitor.dart';
import 'package:html/dom.dart';

/// Returns whether [element] matches the CSS [selector].
bool matches(Element element, String selector) =>
    _SelectorEvaluator().matches(element, _parseSelectorList(selector));

// http://dev.w3.org/csswg/selectors-4/#grouping
SelectorGroup _parseSelectorList(String selector) {
  final errors = <Message>[];
  final group = parseSelectorGroup(selector, errors: errors);
  if (group == null || errors.isNotEmpty) {
    throw FormatException("'$selector' is not a valid selector: $errors");
  }
  return group;
}

class _SelectorEvaluator extends Visitor {
  /// The current HTML element to match against.
  Element? _element;

  bool matches(Element element, SelectorGroup selector) {
    _element = element;
    return visitSelectorGroup(selector);
  }

  @override
  bool visitSelectorGroup(SelectorGroup node) =>
      node.selectors.any(visitSelector);

  @override
  bool visitSelector(Selector node) {
    final old = _element;
    var result = true;

    // Note: evaluate selectors right-to-left as it's more efficient.
    int? combinator;
    for (var s in node.simpleSelectorSequences.reversed) {
      if (combinator == null) {
        result = s.simpleSelector.visit(this) as bool;
      } else {
        if (combinator == TokenKind.COMBINATOR_DESCENDANT) {
          // descendant combinator
          // http://dev.w3.org/csswg/selectors-4/#descendant-combinators
          do {
            _element = _element!.parent;
          } while (_element != null && !(s.simpleSelector.visit(this) as bool));

          if (_element == null) result = false;
        } else if (combinator == TokenKind.COMBINATOR_TILDE) {
          // Following-sibling combinator
          // http://dev.w3.org/csswg/selectors-4/#general-sibling-combinators
          do {
            _element = _element!.previousElementSibling;
          } while (_element != null && !(s.simpleSelector.visit(this) as bool));

          if (_element == null) result = false;
        }
        combinator = null;
      }

      if (!result) break;

      switch (s.combinator) {
        case TokenKind.COMBINATOR_PLUS:
          // Next-sibling combinator
          // http://dev.w3.org/csswg/selectors-4/#adjacent-sibling-combinators
          _element = _element!.previousElementSibling;
          break;
        case TokenKind.COMBINATOR_GREATER:
          // Child combinator
          // http://dev.w3.org/csswg/selectors-4/#child-combinators
          _element = _element!.parent;
          break;
        case TokenKind.COMBINATOR_DESCENDANT:
        case TokenKind.COMBINATOR_TILDE:
          // We need to iterate through all siblings or parents.
          // For now, just remember what the combinator was.
          combinator = s.combinator;
          break;
        case TokenKind.COMBINATOR_NONE:
          break;
        default:
          throw _unsupported(node);
      }

      if (_element == null) {
        result = false;
        break;
      }
    }

    _element = old;
    return result;
  }

  UnimplementedError _unimplemented(SimpleSelector selector) =>
      UnimplementedError("'$selector' selector of type "
          '${selector.runtimeType} is not implemented');

  FormatException _unsupported(TreeNode selector) =>
      FormatException("'$selector' is not a valid selector");

  @override
  bool visitPseudoClassSelector(PseudoClassSelector node) {
    switch (node.name) {
      // http://dev.w3.org/csswg/selectors-4/#structural-pseudos

      // http://dev.w3.org/csswg/selectors-4/#the-root-pseudo
      case 'root':
        return _element!.localName == 'html' && _element!.parentNode == null;

      // http://dev.w3.org/csswg/selectors-4/#the-empty-pseudo
      case 'empty':
        return _element!.nodes
            .any((n) => !(n is Element || n is Text && n.text.isNotEmpty));

      // http://dev.w3.org/csswg/selectors-4/#the-blank-pseudo
      case 'blank':
        return _element!.nodes.any((n) => !(n is Element ||
            n is Text && n.text.runes.any((r) => !_isWhitespaceCC(r))));

      // http://dev.w3.org/csswg/selectors-4/#the-first-child-pseudo
      case 'first-child':
        return _element!.previousElementSibling == null;

      // http://dev.w3.org/csswg/selectors-4/#the-last-child-pseudo
      case 'last-child':
        return _element!.nextElementSibling == null;

      // http://dev.w3.org/csswg/selectors-4/#the-only-child-pseudo
      case 'only-child':
        return _element!.previousElementSibling == null &&
            _element!.nextElementSibling == null;

      // http://dev.w3.org/csswg/selectors-4/#link
      case 'link':
        return _element!.attributes['href'] != null;

      case 'visited':
        // Always return false since we aren't a browser. This is allowed per:
        // http://dev.w3.org/csswg/selectors-4/#visited-pseudo
        return false;
    }

    // :before, :after, :first-letter/line can't match DOM elements.
    if (_isLegacyPsuedoClass(node.name)) return false;

    throw _unimplemented(node);
  }

  @override
  bool visitPseudoElementSelector(PseudoElementSelector node) {
    // :before, :after, :first-letter/line can't match DOM elements.
    if (_isLegacyPsuedoClass(node.name)) return false;

    throw _unimplemented(node);
  }

  static bool _isLegacyPsuedoClass(String name) {
    switch (name) {
      case 'before':
      case 'after':
      case 'first-line':
      case 'first-letter':
        return true;
      default:
        return false;
    }
  }

  @override
  bool visitPseudoElementFunctionSelector(PseudoElementFunctionSelector node) =>
      throw _unimplemented(node);

  @override
  bool visitPseudoClassFunctionSelector(PseudoClassFunctionSelector node) {
    switch (node.name) {
      // http://dev.w3.org/csswg/selectors-4/#child-index

      // http://dev.w3.org/csswg/selectors-4/#the-nth-child-pseudo
      case 'nth-child':
        final exprs = node.expression.expressions;
        if (exprs.length == 1 && exprs[0] is LiteralTerm) {
          final literal = exprs[0] as LiteralTerm;

          if (literal.value is! num) {
            // non numeric values (e.g. `nth-child(even)`) are not supported
            return false;
          }

          final numericLiteral = literal.value as num;
          final parent = _element!.parentNode;
          return parent != null &&
              numericLiteral > 0 &&
              parent.nodes.indexOf(_element) == numericLiteral;
        }
        break;

      // http://dev.w3.org/csswg/selectors-4/#the-lang-pseudo
      case 'lang':
        // TODO: shouldn't need to get the raw text here, but csslib gets
        // confused by the "-" in the expression, such as in "es-AR".
        final toMatch = node.expression.span.text;
        final lang = _getInheritedLanguage(_element);
        return lang != null && lang.startsWith(toMatch);
    }
    throw _unimplemented(node);
  }

  static String? _getInheritedLanguage(Node? node) {
    while (node != null) {
      final lang = node.attributes['lang'];
      if (lang != null) return lang;
      node = node.parent;
    }
    return null;
  }

  @override
  bool visitNamespaceSelector(NamespaceSelector node) {
    // Match element tag name
    if (!(node.nameAsSimpleSelector!.visit(this) as bool)) return false;

    if (node.isNamespaceWildcard) return true;

    if (node.namespace == '') return _element!.namespaceUri == null;

    throw _unimplemented(node);
  }

  @override
  bool visitElementSelector(ElementSelector node) =>
      node.isWildcard || _element!.localName == node.name.toLowerCase();

  @override
  bool visitIdSelector(IdSelector node) => _element!.id == node.name;

  @override
  bool visitClassSelector(ClassSelector node) =>
      _element!.classes.contains(node.name);

  // TODO: negation should support any selectors in level 4, not just simple
  // selectors. http://dev.w3.org/csswg/selectors-4/#negation
  @override
  bool visitNegationSelector(NegationSelector node) =>
      !(node.negationArg!.visit(this) as bool);

  @override
  bool visitAttributeSelector(AttributeSelector node) {
    // Match name first
    final value = _element!.attributes[node.name.toLowerCase()];
    if (value == null) return false;

    if (node.operatorKind == TokenKind.NO_MATCH) return true;

    final select = '${node.value}';
    return switch (node.operatorKind) {
      TokenKind.EQUALS => value == select,
      TokenKind.INCLUDES =>
        value.split(' ').any((v) => v.isNotEmpty && v == select),
      TokenKind.DASH_MATCH => value.startsWith(select) &&
          (value.length == select.length || value[select.length] == '-'),
      TokenKind.PREFIX_MATCH => value.startsWith(select),
      TokenKind.SUFFIX_MATCH => value.endsWith(select),
      TokenKind.SUBSTRING_MATCH => value.contains(select),
      _ => throw _unsupported(node)
    };
  }
}

bool _isWhitespaceCC(int codeUnit) {
  switch (codeUnit) {
    case 0x09: // TAB
    case 0x0A: // LF
    case 0x0C: // FF
    case 0x0D: // CR
    case 0x20: // SPACE
      return true;
  }
  return false;
}
