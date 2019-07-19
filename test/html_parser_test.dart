import 'package:flutter/material.dart';
import 'package:flutter_html/rich_text_parser.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_html/flutter_html.dart';

void main() {
  testWidgets("Check that default parser does not fail on empty data",
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: "",
            useRichText: false,
          ),
        ),
      ),
    );
  });

  testWidgets("Check that RichText parser does not fail on empty data",
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: "",
            useRichText: true,
          ),
        ),
      ),
    );
  });

  //`a` tag tests

  testWidgets("Check that `a` tag is rendered by both parsers", (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: "<a href='https://github.com'>Test link</a>",
            useRichText: false,
          ),
        ),
      ),
    );

    expect(find.text("Test link"), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: "<a href='https://github.com'>Test link</a>",
            useRichText: true,
          ),
        ),
      ),
    );

    expect(find.byType(RichText), findsOneWidget);
  });

  testWidgets("Check that tapping on the `a` tag calls the callback",
      (tester) async {
    String html = "<a href='https://github.com'>Test link</a>";
    String urlTapped;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            onLinkTap: (url) {
              urlTapped = url;
            },
            useRichText: false,
          ),
        ),
      ),
    );
    await tester.tap(find.text("Test link"));
    expect(urlTapped, "https://github.com");
  });

  testWidgets(
      "Check that tapping on the `a` tag calls the callback `RichText` parser",
      (tester) async {
    String html = "<a href='https://github.com'>Test link</a>";
    String urlTapped;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            onLinkTap: (url) {
              urlTapped = url;
            },
            useRichText: true,
          ),
        ),
      ),
    );
    await tester.tap(find.byType(RichText));
    expect(urlTapped, "https://github.com");
  });

  // `abbr` tag tests
  testWidgets("Check that `abbr` tag renders", (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: "<abbr>Abbreviation</abbr>",
            useRichText: false,
          ),
        ),
      ),
    );

    expect(find.text("Abbreviation"), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: "<abbr>Abbreviation</abbr>",
            useRichText: true,
          ),
        ),
      ),
    );

    expect(find.byType(RichText), findsOneWidget);
  });

  testWidgets("Check that `acronym` tag renders", (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: "<acronym>Acronym</acronym>",
            useRichText: false,
          ),
        ),
      ),
    );

    expect(find.text("Acronym"), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: "<acronym>Acronym</acronym>",
            useRichText: true,
          ),
        ),
      ),
    );

    expect(find.byType(RichText), findsOneWidget);
  });

  testWidgets("Check that `address` tag renders", (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: "<address>Address</address>",
            useRichText: false
          ),
        ),
      ),
    );

    expect(find.text("Address"), findsOneWidget);

    //Not supported in `RichText` parser.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: "<address>Address</address>",
            useRichText: true,
          ),
        ),
      ),
    );

    expect(find.byType(RichText), findsOneWidget);
  });

  testWidgets("Check that `article` tag renders", (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: "<article>Article</article>",
            useRichText: false,
          ),
        ),
      ),
    );

    expect(find.text("Article"), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: "<article>Article</article>",
            useRichText: true,
          ),
        ),
      ),
    );

    expect(find.byType(BlockText), findsOneWidget);
  });

  testWidgets("Check that `aside` tag renders", (tester) async {
    String html = "<aside>Aside</aside>";

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: false,
          ),
        ),
      ),
    );

    expect(find.text("Aside"), findsOneWidget);

    //Not supported in `RichText` parser.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: true,
          ),
        ),
      ),
    );

    expect(find.byType(RichText), findsOneWidget);
  });

  testWidgets("Check that `b` tag renders", (tester) async {
    String html = "<b>B</b>";

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: false,
          ),
        ),
      ),
    );

    expect(find.text("B"), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: true,
          ),
        ),
      ),
    );

    expect(find.byType(RichText), findsOneWidget);
  });

  testWidgets("Check that `bdi` tag renders", (tester) async {
    String html = "<bdi>Bdi</bdi>";

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: false,
          ),
        ),
      ),
    );

    expect(find.text("Bdi"), findsOneWidget);

    //Not supported in `RichText` parser.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: true,
          ),
        ),
      ),
    );

    expect(find.byType(RichText), findsOneWidget);
  });

  testWidgets("Check that `bdo` tag renders", (tester) async {
    String html = "<bdo>Bdo</bdo>";

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: false,
          ),
        ),
      ),
    );

    expect(find.text("Bdo"), findsOneWidget);

    //Not supported in `RichText` parser.
//    await tester.pumpWidget(
//      MaterialApp(
//        home: Scaffold(
//          body: Html(
//            data: html,
//            useRichText: true,
//          ),
//        ),
//      ),
//    );
//
//    expect(find.byType(RichText), findsOneWidget);
  });

  testWidgets("Check that `big` tag renders", (tester) async {
    String html = "<big>Big</big>";

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: false,
          ),
        ),
      ),
    );

    expect(find.text("Big"), findsOneWidget);

    //Not supported in `RichText` parser.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: true,
          ),
        ),
      ),
    );

    expect(find.byType(RichText), findsOneWidget);
  });

  testWidgets("Check that `blockquote` tag renders", (tester) async {
    String html = "<blockquote>Blockquote</blockquote>";

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: false,
          ),
        ),
      ),
    );

    expect(find.text("Blockquote"), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: true,
          ),
        ),
      ),
    );

    expect(find.byType(BlockText), findsOneWidget);
  });

  testWidgets("Check that `body` tag renders", (tester) async {
    String html = "<body>Body</body>";

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: false,
          ),
        ),
      ),
    );

    expect(find.text("Body"), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: true,
          ),
        ),
      ),
    );

    expect(find.byType(BlockText), findsOneWidget);
  });

  testWidgets("Check that `br` tag renders", (tester) async {
    String html = "Text<br />broken";

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: false,
          ),
        ),
      ),
    );

    expect(find.text("Text"), findsOneWidget);
    expect(find.text("broken"), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: true,
          ),
        ),
      ),
    );

    expect(find.byType(RichText), findsOneWidget);
  });

  testWidgets("Check that `caption` tag renders", (tester) async {
    String html = "<caption>Caption</caption>";

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: false,
          ),
        ),
      ),
    );

    expect(find.text("Caption"), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: true,
          ),
        ),
      ),
    );

    expect(find.byType(RichText), findsOneWidget);
  });

  testWidgets("Check that `cite` tag renders", (tester) async {
    String html = "<cite>Cite</cite>";

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: false,
          ),
        ),
      ),
    );

    expect(find.text("Cite"), findsOneWidget);

    //Not supported in `RichText` parser.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: true,
          ),
        ),
      ),
    );

    expect(find.byType(RichText), findsOneWidget);
  });

  testWidgets("Check that `code` tag renders", (tester) async {
    String html = "<code>Code</code>";

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: false,
          ),
        ),
      ),
    );

    expect(find.text("Code"), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: true,
          ),
        ),
      ),
    );

    expect(find.byType(RichText), findsOneWidget);
  });

  testWidgets("Check that `data` tag renders", (tester) async {
    String html = "<data>Data</data>";

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: false,
          ),
        ),
      ),
    );

    expect(find.text("Data"), findsOneWidget);

    //Not supported in `RichText` parser.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: true,
          ),
        ),
      ),
    );

    expect(find.byType(RichText), findsOneWidget);
  });

  testWidgets("Check that `dd` tag renders", (tester) async {
    String html = "<dd>DD</dd>";

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: false,
          ),
        ),
      ),
    );

    expect(find.text("DD"), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: true,
          ),
        ),
      ),
    );

    expect(find.byType(RichText), findsOneWidget);
  });

  testWidgets("Check that `dfn` tag renders", (tester) async {
    String html = "<dfn>Dfn</dfn>";

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: false,
          ),
        ),
      ),
    );

    expect(find.text("Dfn"), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: true,
          ),
        ),
      ),
    );

    expect(find.byType(RichText), findsOneWidget);
  });

  testWidgets("Check that `div` tag renders", (tester) async {
    String html = "<div>Div</div>";

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: false,
          ),
        ),
      ),
    );

    expect(find.text("Div"), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: true,
          ),
        ),
      ),
    );

    expect(find.byType(BlockText), findsOneWidget);
  });

  testWidgets("Check that `dl` tag renders", (tester) async {
    String html = "<dl>Dl</dl>";

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: false,
          ),
        ),
      ),
    );

    expect(find.text("Dl"), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: true,
          ),
        ),
      ),
    );

    expect(find.byType(RichText), findsOneWidget);
  });

  testWidgets("Check that `dt` tag renders", (tester) async {
    String html = "<dt>Dt</dt>";

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: false,
          ),
        ),
      ),
    );

    expect(find.text("Dt"), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: true,
          ),
        ),
      ),
    );

    expect(find.byType(RichText), findsOneWidget);
  });

  testWidgets("Check that `em` tag renders", (tester) async {
    String html = "<em>Em</em>";

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: false,
          ),
        ),
      ),
    );

    expect(find.text("Em"), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: true,
          ),
        ),
      ),
    );

    expect(find.byType(RichText), findsOneWidget);
  });

  testWidgets("Check that `figcaption` tag renders", (tester) async {
    String html = "<figcaption>Figcaption</figcaption>";

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: false,
          ),
        ),
      ),
    );

    expect(find.text("Figcaption"), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: true,
          ),
        ),
      ),
    );

    expect(find.byType(RichText), findsOneWidget);
  });

  testWidgets("Check that `figure` tag renders", (tester) async {
    String html = "<figure>Figure</figure>";

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: false,
          ),
        ),
      ),
    );

    expect(find.text("Figure"), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: true,
          ),
        ),
      ),
    );

    expect(find.byType(RichText), findsOneWidget);
  });

  testWidgets("Check that `footer` tag renders", (tester) async {
    String html = "<b>Footer</b>";

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: false,
          ),
        ),
      ),
    );

    expect(find.text("Footer"), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: true,
          ),
        ),
      ),
    );

    expect(find.byType(BlockText), findsOneWidget);
  });

  testWidgets("Check that `h1` tag renders", (tester) async {
    String html = "<h1>h1</h1>";

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: false,
          ),
        ),
      ),
    );

    expect(find.text("h1"), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: true,
          ),
        ),
      ),
    );

    expect(find.byType(BlockText), findsOneWidget);
  });

  testWidgets("Check that `h2` tag renders", (tester) async {
    String html = "<h2>h2</h2>";

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: false,
          ),
        ),
      ),
    );

    expect(find.text("h2"), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: true,
          ),
        ),
      ),
    );

    expect(find.byType(BlockText), findsOneWidget);
  });

  testWidgets("Check that `h3` tag renders", (tester) async {
    String html = "<h3>h3</h3>";

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: false,
          ),
        ),
      ),
    );

    expect(find.text("h3"), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: true,
          ),
        ),
      ),
    );

    expect(find.byType(BlockText), findsOneWidget);
  });

  testWidgets("Check that `h4` tag renders", (tester) async {
    String html = "<h4>h4</h4>";

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: false,
          ),
        ),
      ),
    );

    expect(find.text("h4"), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: true,
          ),
        ),
      ),
    );

    expect(find.byType(BlockText), findsOneWidget);
  });

  testWidgets("Check that `h5` tag renders", (tester) async {
    String html = "<h5>h5</h5>";

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: false,
          ),
        ),
      ),
    );

    expect(find.text("h5"), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: true,
          ),
        ),
      ),
    );

    expect(find.byType(BlockText), findsOneWidget);
  });

  testWidgets("Check that `h6` tag renders", (tester) async {
    String html = "<h6>h6</h6>";

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: false,
          ),
        ),
      ),
    );

    expect(find.text("h6"), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: true,
          ),
        ),
      ),
    );

    expect(find.byType(BlockText), findsOneWidget);
  });

  testWidgets("Check that `header` tag renders", (tester) async {
    String html = "<header>header</header>";

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: false,
          ),
        ),
      ),
    );

    expect(find.text("header"), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: true,
          ),
        ),
      ),
    );

    expect(find.byType(BlockText), findsOneWidget);
  });

  testWidgets("Check that `hr` tag renders", (tester) async {
    String html = "<hr />";

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: false,
          ),
        ),
      ),
    );

    expect(find.byType(Divider), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: true,
          ),
        ),
      ),
    );

    expect(find.byType(Divider), findsOneWidget);
  });

  testWidgets("Check that `i` tag renders", (tester) async {
    String html = "<i>i</i>";

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: false,
          ),
        ),
      ),
    );

    expect(find.text("i"), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: html,
            useRichText: true,
          ),
        ),
      ),
    );

    expect(find.byType(RichText), findsOneWidget);
  });
}
