import 'package:catex/src/lookup/context.dart';
import 'package:catex/src/lookup/exception.dart';
import 'package:catex/src/lookup/fonts.dart';
import 'package:catex/src/lookup/modes.dart';
import 'package:catex/src/lookup/styles.dart';
import 'package:catex/src/parsing/parsing.dart';
import 'package:catex/src/rendering/rendering.dart';
import 'package:catex/src/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';

/// The context that will be passed to the root node in [CaTeX].
///
/// This *does **not** mean* that everything will be rendered
/// using this context. Symbols use different fonts by default.
/// Additionally, there are font functions that modify the font style,
/// color functions that modify the color, and other functions
/// that will need to size their children smaller, e.g. to display a fraction.
/// In general, the context can be modified by any node for its subtree.
final defaultCaTeXContext = CaTeXContext(
  // The color and size are overridden using the DefaultTextStyle
  // in the CaTeX widget.
  color: const Color(0xffffffff),
  textSize: 32 * 1.21,
  style: CaTeXStyle.d,
  fontFamily: CaTeXFont.main.family,
  // The weight and style are initialized as null in
  // order to be able to override e.g. the italic letter
  // behavior using \rm.
);

/// The mode at the root of the tree.
///
/// This can be modified by any node, e.g.
/// a `\text` function will put its subtree into text mode
/// and a `$` will switch to math mode.
/// It simply means that CaTeX will start out in this mode.
const startParsingMode = CaTeXMode.math;

/// Widget that displays TeX using the CaTeX library.
///
/// You can style the base text color and text size using
/// [DefaultTextStyle].
class CustomCaTeX extends StatefulWidget {
  /// Constructs a [CaTeX] widget from an [input] string.
  const CustomCaTeX(this.input, {Key key})
      : assert(input != null),
        super(key: key);

  /// TeX input string that should be rendered by CaTeX.CustomRenderTree
  final String input;

  @override
  State createState() => _CaTeXState();
}

class _CaTeXState extends State<CustomCaTeX> {
  NodeWidget _rootNode;
  Exception exception;

  void _parse() {
    exception = null;
    try {
      // ignore: avoid_redundant_argument_values
      _rootNode = Parser(widget.input, mode: startParsingMode)
          .parse()
          .createWidget(defaultCaTeXContext.copyWith(
            color: DefaultTextStyle.of(context).style.color,
            textSize: DefaultTextStyle.of(context).style.fontSize * 1.21,
          ));
    } on CaTeXException catch (e) {
      exception = e;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _parse();
  }

  @override
  void didUpdateWidget(CustomCaTeX oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.input != widget.input) setState(_parse);
  }

  @override
  Widget build(BuildContext context) {
    if (exception != null) {
      // Throwing the parsing exception here will make sure that it is
      // displayed by the Flutter ErrorWidget.
      return Text(widget.input, style: TextStyle(fontFamily: 'monospace'));
    }

    // Rendering a full tree can be expensive and the tree never changes.
    // Because of this, we want to insert a repaint boundary between the
    // CaTeX output and the rest of the widget tree.
    return _TreeWidget(_rootNode, state: this);
  }
}

class _TreeWidget extends SingleChildRenderObjectWidget {
  _TreeWidget(
    NodeWidget child, {
    Key key,
    this.state,
  })  : assert(child != null),
        _context = child.context,
        super(child: child, key: key);

  final CaTeXContext _context;
  final _CaTeXState state;

  @override
  RenderTree createRenderObject(BuildContext context) =>
      CustomRenderTree(_context, state: state);

  @override
  void updateRenderObject(BuildContext context, RenderTree renderObject) {
    renderObject.context = _context;
  }

  @override
  SingleChildRenderObjectElement createElement() =>
      CustomSingleChildRenderObjectElement(this, state: state);
}

class CustomSingleChildRenderObjectElement
    extends SingleChildRenderObjectElement {
  final _CaTeXState state;
  CustomSingleChildRenderObjectElement(SingleChildRenderObjectWidget widget,
      {this.state})
      : super(widget);

  @override
  void mount(Element parent, dynamic newSlot) {
    try {
      super.mount(parent, newSlot);
    } catch (e) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        state.setState(() => state.exception = e);
      });
    }
  }
}

class CustomRenderTree extends RenderTree {
  final _CaTeXState state;
  CustomRenderTree(CaTeXContext context, {this.state}) : super(context);

  @override
  void performLayout() {
    try {
      super.performLayout();
    } catch (e) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        state.setState(() => state.exception = e);
      });
    }
  }
}
