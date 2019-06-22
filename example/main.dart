import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: SingleChildScrollView(
          child: Html(
            data: """
    <div>
      <div id="header_set">
      <h1>Header 1</h1>
      <h2>Header 2</h2>
      <h3>Header 3</h3>
      <h4>Header 4</h4>
      <h5>Header 5</h5>
      <h6>Header 6</h6>
      <hr />
      Below hr
      <b>Bold</b>
      </div>
      <h1>Demo Page</h1>
      <p>This is a <u>fantastic</u> nonexistent product that you should really really really consider buying!</p>
      <a href="https://github.com">https://github.com</a><br />
      <br />
      <h2>Pricing</h2>
      <p>Lorem ipsum <b>dolor</b> sit amet.</p>
      <center>
        This is some center text... <abbr>ABBR</abbr> and <acronym>ACRONYM</acronym>
      </center>
      <h2>The Team</h2>
      <p>There isn't <i>really</i> a team...</p>
      <h2>Installation</h2>
      <p>You <u>cannot</u> install a nonexistent product!</p>
      <h2>Don't ask me to find <em>x</em> in</h2>
      <p>log<sub>2</sub>(<em>x</em><sup>2</sup> - 6<em>x</em>) = 3 + log<sub>2</sub>(1 - <em>x</em>)</p>
      <div id="bdi_test">
        <h3><code>bdi</code> and <code>bdo</code> Test:</h3>
        <p>
        In the example below, usernames are shown along with the number of points in a contest.
        If the bdi element is not supported in the browser, the username of the Arabic user would confuse the text (the bidirectional algorithm would put the colon and the number "90" next to the word "User" rather than next to the word "points").
        </p>
        
        <ul>
         <li>User <bdi>hrefs</bdi>: 60 points</li>
         <li>User <bdi>jdoe</bdi>: 80 points</li>
         <li>User <bdi>إيان</bdi>: 90 points</li>
         <bdo dir="rtl">Swapped!</bdo>
         <bdo dir="ltr">This text will go left to right!</bdo>
         <bdo dir="rtl">With bdi: User <bdi>إيان</bdi>: 90 points</bdo>
         <bdo dir="rtl">Without bdi: User إيان: 90 points</bdo>
         <bdo dir="ltr">ltr w/ bdi: User <bdi>إيان</bdi>: 90 points</bdo>
         <bdo dir="ltr">ltr w/o bdi: User إيان: 90 points</bdo>
        </ul>
      </div>
            <div>
              <table>
              <caption>This is the table's caption</caption>
                <tr><th>Head 1<sup>*</sup></th><th>Head 2</th><th>Head 3</th></tr>
                <tr><td>Data 1</td><td>Long Data 2</td><td>Really, realllllly, long data 3</td></tr>
                <tr><td>Data 1</td><td>Long <b>Data</b> 2</td><td>Really, realllllly, long data 3</td></tr>
                <tr><td>Data 1</td><td>Long Data 2</td><td>Really, realllllly, long data 3</td></tr>
                <tr><td>Different 1</td><td>Different reallllllly long 2</td><td>Diff 3</td></tr>
                <tr><td colspan="2">This spans 2 columns</td><td>Normal td</td></tr>
                <tfoot>
                <tr><td>In foot 1</td><td>In foot 2</td><td>In foot long 2</td></tr>
                </tfoot>
              </table>
            </div>
            <div>Nested div</div>
            <div>
            <pre>
            jQuery("#monkey");
            </pre>
            <br />
            <p><q>This is a fancy quote</q></p>
            <br />
            <br />
            Second nested div<br />
            <figure>
            <img src="https://assets-cdn.github.com/images/modules/logos_page/GitHub-Mark.png" />
            <figcaption>Available on GitHub</figcaption>
            </figure>
            </div>
            <div>Third nested div</div>
          </div>
          <h1>Second header</h1>
          <h1>Third header</h1>
          <div>Fourth div</div>
  """,
            //Optional parameters:
            padding: EdgeInsets.all(8.0),
            linkStyle: const TextStyle(
              color: Colors.redAccent,
              decorationColor: Colors.redAccent,
              decoration: TextDecoration.underline,
            ),
            onLinkTap: (url) {
              print("Opening $url...");
            },
            onImageTap: (src) {
              print(src);
            },
            //Must have useRichText set to false for this to work
            customRender: (node, children) {
              if (node is dom.Element) {
                switch (node.localName) {
                  case "custom_tag":
                    return Column(children: children);
                }
              }
              return null;
            },
            customTextAlign: (dom.Node node) {
              if (node is dom.Element) {
                switch (node.localName) {
                  case "p":
                    return TextAlign.justify;
                }
              }
              return null;
            },
            customTextStyle: (dom.Node node, TextStyle baseStyle) {
              if (node is dom.Element) {
                switch (node.localName) {
                  case "p":
                    return baseStyle.merge(TextStyle(height: 2, fontSize: 20));
                }
              }
              return baseStyle;
            },
          ),
        ),
      ),
    );
  }
}
