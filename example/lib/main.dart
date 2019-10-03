import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/style.dart';

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
      home: new MyHomePage(title: 'flutter_html Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

const htmlData = """
<p id='whitespace'>
      These two lines should have an identical length:<br /><br />
      
            The     quick   <b> brown </b><u><i> fox </i></u> jumped over   the 
             lazy  
             
             
             
             
             dog.<br />
            The quick brown fox jumped over the lazy dog.
      </p>
      <table>
      <tr><th>One</th><th>Two</th><th>Three</th></tr>
      <tr><td>Data</td><td>Data</td><td>Data</td></tr>
      <tr><td>Data</td><td>Data</td><td>Data</td></tr>
      <tr><td>Data</td><td>Data</td><td>Data</td></tr>
      <tfoot>
      <tr><td>Data</td><td>Data</td><td>Data</td></tr>
      </tfoot>
      </table>
      <flutter></flutter>
      <svg id='svg1' viewBox='0 0 100 100' xmlns='http://www.w3.org/2000/svg'>
            <circle r="32" cx="35" cy="65" fill="#F00" opacity="0.5"/>
            <circle r="32" cx="65" cy="65" fill="#0F0" opacity="0.5"/>
            <circle r="32" cx="50" cy="35" fill="#00F" opacity="0.5"/>
      </svg>
      <ol>
            <li>This</li>
            <li><p>is</p></li>
            <li>an</li>
            <li>
            ordered
            <ul>
            <li>With<br /><br />...</li>
            <li>a</li>
            <li>nested</li>
            <li>unordered
            <ol>
            <li>With a nested</li>
            <li>ordered list.</li>
            </ol>
            </li>
            <li>list</li>
            </ul>
            </li>
            <li>list! Lorem ipsum dolor sit <b>amet cale aaihg aie a gama eia aai aia ia af a</b></li>
            <li><h2>Header 2</h2></li>
            <h2><li>Header 2</li></h2>
      </ol>
""";

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: SafeArea(
        child: Row(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Html(
                  data: htmlData,
                  //Optional parameters:
                  style: {
                    "html": Style(
                      backgroundColor: Colors.black,
                      color: Colors.white,
                    ),
                    "a": Style(
                      color: Colors.red,
                    ),
                    "li": Style(
//              backgroundColor: Colors.red,
//                fontSize: 20,
//                margin: const EdgeInsets.only(top: 32),
                    ),
                    "h1, h3, h5": Style(
//                backgroundColor: Colors.deepPurple,
//                alignment: Alignment.center,
                    ),
                    "#whitespace": Style(
                      backgroundColor: Colors.purple,
                    ),
                  },
                  customRender: {
                    "flutter": (RenderContext context, Widget child, attributes) {
                      return FlutterLogo(
                        style: (attributes['horizontal'] != null)? FlutterLogoStyle.horizontal: FlutterLogoStyle.markOnly,
                        textColor: context.style.color,
                        size: context.style.fontSize * 5,
                      );
                    }
                  },
                  onLinkTap: (url) {
                    print("Opening $url...");
                  },
                  onImageTap: (src) {
                    print(src);
                  },
                ),
              ),
            ),
            Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    HtmlParser.cleanTree(HtmlParser.applyCSS(HtmlParser.lexDomTree(HtmlParser.parseHTML(htmlData), [], []), null)).toString(),
                    style: TextStyle(fontFamily: 'monospace'),
                  ),
                ),
            )
          ],
        ),
      ),
    );
  }
}
