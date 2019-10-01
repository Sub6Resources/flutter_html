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

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Html(
            data: """
      <h1>Header 1</h1>
      <h2>Header 2</h2>
      <h3>Header 3</h3>
      <h4>Header 4</h4>
      <h5>Header 5</h5>
      <h6>Header 6</h6>
      <img src='https://example.com/image.jpg' alt='Alt Text' />
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
      <br />
      <a href='https://flutter.dev'>Flutter Website</a><br />
      <audio controls>
          <source src='https://www.w3schools.com/tags/horse.mp3'>
      </audio>
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
          <li>unordered</li>
          <li>list</li>
          </ul>
          </li>
          <li>list! Lorem ipsum dolor sit <b>amet cale aaihg aie a gama eia aai aia ia af a</b></li>
          <li><h2>Header 2</h2></li>
      </ol>
      <hr />
      <video controls>
      <source src='https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4'>
      </video>
      <iframe src='https://matthewwhitaker.me'></iframe>
  """,
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
                fontSize: 20,
//                margin: const EdgeInsets.only(top: 32),
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
    );
  }
}
