import 'package:html/dom.dart' as dom;

/// Creates a map of nodes to element index that can be useful when ordering.
/// [double] is used over [int], since nodes may be added, if so just add "0.00000000001"
/// to the last node index, to find the new element current index
class NodeOrderProcessing {
  static Map<dom.Node, double> createNodeToIndexMap(dom.Node node) {
    _IntWrapper index = _IntWrapper(-1);
    Map<dom.Node, double> accumulator = {};
    _createNodeToIndexMapRecursive(node, accumulator, index);
    return accumulator;
  }

  static void _createNodeToIndexMapRecursive(
      dom.Node node, Map<dom.Node, double> accumulator, _IntWrapper index) {
    index.val++;
    accumulator[node] = index.val.toDouble();
    for (final child in node.nodes) {
      _createNodeToIndexMapRecursive(child, accumulator, index);
    }
  }

  static void addNewNode(Map<dom.Node, double> nodeToIndex, dom.Node node) {
    if (node.parent == null) {
      assert(nodeToIndex.isEmpty, "$node is not in nodeToIndex");
      nodeToIndex[node] = 0;
    } else {
      int indexOfThisInParent = 0;
      for (final parentChildNode in node.parent!.nodes) {
        if (parentChildNode == node) break;
        indexOfThisInParent++;
      }
      final double lastVal;
      if (indexOfThisInParent == 0) {
        // use parent
        lastVal = nodeToIndex[node.parent!]!;
      } else {
        // use prev sibling
        lastVal = nodeToIndex[node.parent!.nodes[indexOfThisInParent - 1]]!;
      }
      nodeToIndex[node] = lastVal + 0.00000001;

      // final double nextVal;
      // dom.Node? nextNode = getNextNodeInTraversal(node).skip(1).firstOrNull;
      // if(nextNode == null){
      //   nextVal = lastVal + 1;
      // }
      // else{
      //   nextVal = nodeToIndex[nextNode]!;
      // }
      // nodeToIndex[node] = lastVal + (nextVal - lastVal)/2;
    }
    // dom.Node currentNode = node;
    // while(currentNode.parent != null){
    //   int indexOfThisInParent = 0;
    //   for (final parentChildNode in currentNode.parent!.children) {
    //     if (parentChildNode == currentNode) break;
    //     indexOfThisInParent++;
    //   }
    //   if(indexOfThisInParent == 0){
    //     currentNode = currentNode.parent!;
    //     continue;
    //   }
    //   currentNode = currentNode.parent!.children[indexOfThisInParent - 1];
    //   break;
    // }
    // if(currentNode == node){
    //   assert()
    //   nodeToIndex[currentNode] = 1;
    // }
  }
}

class _IntWrapper {
  _IntWrapper(this.val);

  int val;
}

// ///. TODO add as depends
// /// Taken form cool_tools with small changes
// Iterable<dom.Node> getNextNodeInTraversal(dom.Node node) sync* {
//   yield* _getNextNodeHelper(node, 0);
// }
//
// Iterable<dom.Node> _getNextNodeHelper(dom.Node node, int skip) sync* {
//   Iterator<dom.Node> nextNodeThisOrBelowGen =
//       _getNextNodeThisOrBelow(node, skip).iterator;
//   while (nextNodeThisOrBelowGen.moveNext()) {
//     yield nextNodeThisOrBelowGen.current;
//   }
//
//   int parentShouldSkip;
//   dom.Node? parent = node.parent;
//   // has no parent, end generation
//   if (parent == null) {
//     return;
//   } else {
//     int parentShouldSkip = 1;
//     for (dom.Node parentChildNode in parent.nodes) {
//       if (parentChildNode == node) break;
//       parentShouldSkip++;
//     }
//     yield* _getNextNodeHelper(parent, parentShouldSkip);
//   }
// }
//
// /// Will return this node, if it has not children
// Iterable<dom.Node> _getNextNodeThisOrBelow(dom.Node node, int skip) sync* {
//   for (dom.Node childNode in node.nodes.skip(skip)) {
//     yield* _getNextNodeThisOrBelow(childNode, 0);
//   }
//   yield node;
// }
