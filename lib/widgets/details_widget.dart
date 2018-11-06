import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;

typedef ParseNodeFunction = List<Widget> Function(List<dom.Node> nodeList);

class DetailsWidget extends StatefulWidget {
  final dom.Element node;
  final ParseNodeFunction parseFunc;

  DetailsWidget(this.node, this.parseFunc);

  _DetailsWidgetState createState() => _DetailsWidgetState();
}

class _DetailsWidgetState extends State<DetailsWidget> {
  dom.Node _summaryNode;
  bool _isOpen = false;

  void initState() {
    super.initState();
    _summaryNode = widget.node.children
        .firstWhere((el) => el.localName == "summary", orElse: () => null);
    _isOpen = _summaryNode != null
        ? _summaryNode.attributes.containsKey("open")
        : false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryWidget(),
        _buildChildrenWidget(),
      ],
    );
  }

  Widget _buildSummaryWidget() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isOpen = !_isOpen;
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            _isOpen ? "\u{25BC}" : "\u{25B6}",
          ),
          SizedBox(
            width: 6.0,
          ),
          Flexible(
            child: Wrap(
                children: _summaryNode != null
                    ? widget.parseFunc(_summaryNode.nodes)
                    : [Container()]),
          )
        ],
      ),
    );
  }

  Widget _buildChildrenWidget() {
    return Wrap(
      children: _isOpen ? widget.parseFunc(widget.node.nodes) : [Container()],
    );
  }
}
