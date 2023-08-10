import 'package:html/dom.dart' as dom;

/// Creates a map of nodes to element index that can be useful when ordering.
/// [double] is used over [int], since nodes may be added, if so just add "0.00000000001"
/// to the last node index, to find the new element current index
class NodeOrderProcessing {
  static Map<dom.Node, int> createNodeToIndexMap(dom.Node node) {
    _IntWrapper index = _IntWrapper(-1);
    Map<dom.Node, int> accumulator = {};
    _createNodeToIndexMapRecursive(node, accumulator, index);
    return accumulator;
  }

  static void _createNodeToIndexMapRecursive(
      dom.Node node, Map<dom.Node, int> accumulator, _IntWrapper index) {
    index.val++;
    accumulator[node] = index.val;
    for (final child in node.nodes) {
      _createNodeToIndexMapRecursive(child, accumulator, index);
    }
  }

  static void reIndexNodeToIndexMapWith(
      Map<dom.Node, int> nodeToIndex, dom.Node node) {
    dom.Node root = node;
    while (root.parent != null) {
      root = root.parent!;
    }
    assert(nodeToIndex[root] == 0, "$node is not in nodeToIndex");
    nodeToIndex.clear();
    _IntWrapper index = _IntWrapper(-1);
    _createNodeToIndexMapRecursive(root, nodeToIndex, index);
  }
}

class _IntWrapper {
  _IntWrapper(this.val);

  int val;
}
