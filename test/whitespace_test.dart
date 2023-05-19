import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  testWidgets(
    'test that lots of unnecessary whitespace is removed',
    (tester) async {
      await tester.pumpWidget(TestApp(
        child: Html(
          data: """\n  <h1>  Hello \t \t \n\n   \t\t\t World! </h1> \n  """,
        ),
      ));
      expect(find.text("Hello World!", findRichText: true), findsOneWidget);
    },
  );

  // See https://github.com/Sub6Resources/flutter_html/issues/1007
  testWidgets(
    'test that whitespace parser does not remove inline whitespace',
    (tester) async {
      final tree = await generateStyledElementTreeFromHtml(
        tester,
        html: "<b>Harry</b> <b>Potter</b>.",
      );

      expect(tree.getWhitespace(),
          equals("<body><b>Harry</b>◦<b>Potter</b>.</body>"));
    },
  );

  // See https://github.com/Sub6Resurces/flutter_html/issues/1146
  testWidgets(
    "test that extra newlines aren't added unnecessarily",
    (tester) async {
      final tree = await generateStyledElementTreeFromHtml(
        tester,
        html: """<html>
                  <div>
                    <div>
                      <div>
                        <div>
                          <div>center of nested div tree</div>
                        </div>
                      </div>
                    </div>
                  </div>
                  bottom of nested div tree
                  <div></div>
                  <div></div>
                  <div></div>
                  <div>center of div list </div>
                  <div></div>
                  <div></div>
                  <div></div>
                  bottom of div list
                  </html>
                  """,
      );

      expect(
          tree.getWhitespace(),
          equals(
              "<body><div><div><div><div><div>center◦of◦nested◦div◦tree</div></div></div></div></div>bottom◦of◦nested◦div◦tree<div></div><div></div><div></div><div>center◦of◦div◦list</div><div></div><div></div><div></div>bottom◦of◦div◦list</body>"));
    },
  );

  //See https://github.com/Sub6Resources/flutter_html/issues/1275
  testWidgets(
    "test that extra newlines aren't added unnecessarily for details/summary tags",
    (tester) async {
      final tree = await generateStyledElementTreeFromHtml(
        tester,
        html: """
<!DOCTYPE html>
<html>
<body>
<details>
  <summary><h1>Header</h1></summary>
  <p>These are the details.</p>
</details>
</body>
</html>
""",
      );

      expect(
          tree.getWhitespace(),
          equals(
              "<body><details><summary><h1>Header</h1></summary><p>These◦are◦the◦details.</p></details></body>"));
    },
  );

  // See https://github.com/Sub6Resources/flutter_html/issues/1251
  testWidgets(
    'test that preserved whitespace is actually preserved',
    (tester) async {
      final tree = await generateStyledElementTreeFromHtml(
        tester,
        html: """<p> test1</p><p> test2</p>""",
        styles: {
          "p": Style(
            whiteSpace: WhiteSpace.pre,
          ),
        },
      );

      expect(tree.getWhitespace(),
          equals("<body><p>◦test1</p><p>◦test2</p></body>"));
    },
  );

  // Note that line-breaks in code between inline elements are converted into
  // spaces, except when immediately following or preceding a <br>
  testWidgets(
    "test that <br> doesn't cause extra space that should be removed",
    (tester) async {
      final tree = await generateStyledElementTreeFromHtml(
        tester,
        html: """
        <span>...</span>
        <br />
        <span>3<span style="vertical-align: super; font-size: 0.9em;">x</span></span>
        <span>log<span style="vertical-align: sub; font-size: 0.9em;">2</span>(x)</span><br />
        <span>3<sup>x</sup></span>
        <span>log<sub>2</sub>(x)</span>
        """,
      );

      expect(
          tree.getWhitespace(),
          equals(
              "<body><span>...</span><br><span>3<span>x</span></span>◦<span>log<span>2</span>(x)</span><br><span>3<sup>x</sup></span>◦<span>log<sub>2</sub>(x)</span></body>"));
    },
  );
}

extension PrintWhitespace on StyledElement {
  String getWhitespace() {
    String whitespace = "";

    if (this is TextContentElement) {
      whitespace += (this as TextContentElement)
              .text
              ?.replaceAll("\n", "⏎")
              .replaceAll("\t", "⇥")
              .replaceAll(" ", "◦") ??
          "";
    }

    for (final child in children) {
      if (child.name != "[text]") {
        whitespace += "<${child.name}>";
      }
      whitespace += child.getWhitespace();
      if (child.name != "[text]" && child.name != "br") {
        whitespace += "</${child.name}>";
      }
    }

    return whitespace;
  }
}
