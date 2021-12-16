import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets("Check that default parser does not fail on empty data",
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Html(
            data: "",
          ),
        ),
      ),
    );
  });
  testWidgets('Test new parser (hacky workaround to get BuildContext)', (WidgetTester tester) async {
    await tester.pumpWidget(
      Builder(
        builder: (BuildContext context) {
          testNewParser(context);

          // The builder function must return a widget.
          return Placeholder();
        },
      ),
    );
  });
}

void testNewParser(BuildContext context) {
  HtmlParser.parseHTML("<b>Hello, World!</b>");

  StyledElement tree = HtmlParser.lexDomTree(
    HtmlParser.parseHTML(
        "Hello! <b>Hello, World!</b><i>Hello, New World!</i>"),
    [],
    [],
    null,
    context,
    HtmlParser(
      key: null,
      htmlData: HtmlParser.parseHTML(
          "Hello! <b>Hello, World!</b><i>Hello, New World!</i>"),
      onLinkTap: null,
      onAnchorTap: null,
      onImageTap: null,
      onCssParseError: null,
      onImageError: null,
      onMathError: null,
      shrinkWrap: false,
      selectable: true,
      style: {},
      customRenders: defaultRenders,
      imageRenders: defaultImageRenders,
      tagsList: Html.tags,
      navigationDelegateForIframe: null,
      selectionControls: null,
      scrollPhysics: null,
    )
  );
  print(tree.toString());

  tree = HtmlParser.lexDomTree(
    HtmlParser.parseHTML(
        "Hello, World! <a href='https://example.com'>This is a link</a>"),
    [],
    [],
    null,
    context,
    HtmlParser(
      key: null,
      htmlData: HtmlParser.parseHTML(
          "Hello, World! <a href='https://example.com'>This is a link</a>"),
      onLinkTap: null,
      onAnchorTap: null,
      onImageTap: null,
      onCssParseError: null,
      onImageError: null,
      onMathError: null,
      shrinkWrap: false,
      selectable: true,
      style: {},
      customRenders: defaultRenders,
      imageRenders: defaultImageRenders,
      tagsList: Html.tags,
      navigationDelegateForIframe: null,
      selectionControls: null,
      scrollPhysics: null,
    )
  );
  print(tree.toString());

  tree = HtmlParser.lexDomTree(
    HtmlParser.parseHTML("<img src='https://image.example.com' />"),
    [],
    [],
    null,
    context,
    HtmlParser(
      key: null,
      htmlData: HtmlParser.parseHTML("<img src='https://image.example.com' />"),
      onLinkTap: null,
      onAnchorTap: null,
      onImageTap: null,
      onCssParseError: null,
      onImageError: null,
      onMathError: null,
      shrinkWrap: false,
      selectable: true,
      style: {},
      customRenders: defaultRenders,
      imageRenders: defaultImageRenders,
      tagsList: Html.tags,
      navigationDelegateForIframe: null,
      selectionControls: null,
      scrollPhysics: null,
    )
  );
  print(tree.toString());

  tree = HtmlParser.lexDomTree(
    HtmlParser.parseHTML(
        "<div><div><div><div><a href='link'>Link</a><div>Hello, World! <b>Bold and <i>Italic</i></b></div></div></div></div></div>"),
    [],
    [],
    null,
    context,
    HtmlParser(
      key: null,
      htmlData: HtmlParser.parseHTML(
          "<div><div><div><div><a href='link'>Link</a><div>Hello, World! <b>Bold and <i>Italic</i></b></div></div></div></div></div>"),
      onLinkTap: null,
      onAnchorTap: null,
      onImageTap: null,
      onCssParseError: null,
      onImageError: null,
      onMathError: null,
      shrinkWrap: false,
      selectable: true,
      style: {},
      customRenders: defaultRenders,
      imageRenders: defaultImageRenders,
      tagsList: Html.tags,
      navigationDelegateForIframe: null,
      selectionControls: null,
      scrollPhysics: null,
    )
  );
  print(tree.toString());

  ReplacedElement videoContentElement = parseReplacedElement(
    HtmlParser.parseHTML("""
      <video width="320" height="240" controls>
       <source src="movie.mp4" type="video/mp4">
       <source src="movie.ogg" type="video/ogg">
       Your browser does not support the video tag.
      </video>
    """).getElementsByTagName("video")[0],
    [],
    null,
  );

  expect(videoContentElement, isA<VideoContentElement>());
  if (videoContentElement is VideoContentElement) {
    expect(videoContentElement.showControls, equals(true),
        reason: "Controls isn't working");
    expect(videoContentElement.src, hasLength(2),
        reason: "Not enough sources...");
  }

  ReplacedElement audioContentElement = parseReplacedElement(
    HtmlParser.parseHTML("""
      <audio controls>
        <source src='audio.mp3' type='audio/mpeg'>
        <source src='audio.wav' type='audio/wav'>
        Your browser does not support the audio tag.
      </audio>
    """).getElementsByTagName("audio")[0],
    [],
    null,
  );
  expect(audioContentElement, isA<AudioContentElement>());
  if (audioContentElement is AudioContentElement) {
    expect(audioContentElement.showControls, equals(true),
        reason: "Controls isn't working");
    expect(audioContentElement.src, hasLength(2),
        reason: "Not enough sources...");
  }

  Style style1 = Style(
    display: Display.BLOCK,
    fontWeight: FontWeight.bold,
  );

  Style style2 = Style(
    before: "* ",
    direction: TextDirection.rtl,
    fontStyle: FontStyle.italic,
  );

  Style finalStyle = style1.merge(style2);

  expect(finalStyle.display, equals(Display.BLOCK));
  expect(finalStyle.before, equals("* "));
  expect(finalStyle.direction, equals(TextDirection.rtl));
  expect(finalStyle.fontStyle, equals(FontStyle.italic));
  expect(finalStyle.fontWeight, equals(FontWeight.bold));
}
