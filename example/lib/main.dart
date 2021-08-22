import 'package:flutter/material.dart';
import 'package:flutter_matrix_html/flutter_html.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.red,
          ),
        ),
        child: SingleChildScrollView(
          child: Html(
            data:
                """
<p> whiespace thingy</p>
<p>more thingy</p>
<p>
Hello <b>Wo</b><i>rl</i>d<br>nyaaa <a href="https://example.org/meow">link<br>break</a>

https://example.org meow <sub>low</sub> <sup> high</sup>
<br>
<span data-mx-spoiler="heya">hmm https://example.org how are you?</span>
<br>
<font color="red">red text</font>
hmm <font color="red"> red</font><font color="green"> green</font>
</p>
<p>
inside paragraph <b>inside bold<h1>heading</h1>bold</b>paragraph
</p>
<blockquote>
<ol start="1">
  <li>fox</li>
  <li>floof</li>
  <li>tail<br>floof</li>
  <li>pawsies
    <ol>
      <li>cute</li>
      <li>adorable</li>
    </ol>
  </li>
</ol>
<ol start="10">
  <li>fox</li>
  <li>floof</li>
  <li>tail<br>floof</li>
  <li>pawsies
    <ol>
      <li>cute</li>
      <li>adorable</li>
    </ol>
  </li>
</ol>
<ol start="100">
  <li>fox</li>
  <li>floof</li>
  <li>tail<br>floof</li>
  <li>pawsies
    <ol>
      <li>cute</li>
      <li>adorable</li>
    </ol>
  </li>
</ol>
</blockquote>
<h1>The caption element</h1>
<table>
  <caption>Monthly savings</caption>
  <tr>
    <th>Month</th>
    <th>Savings</th>
  </tr>
  <tr>
    <td>January</td>
    <td>\$100</td>
  </tr>
  <tr>
    <td>February</td>
    <td>\$50</td>
  </tr>
</table>
<p>paragraph</p>
<hr>
<p>more paragraph</p>

<details>
  <summary>System Requirements</summary>
  <p>Requires a computer running an operating system. The computer
  must have some memory and ideally some kind of long-term storage.
  An input device as well as some form of output device is
  recommended.</p>
</details>

<pre><code class=\"language-dart\">    if (parseContext.condenseWhitespace) {
      finalText = _condenseHtmlWhitespace(node.text);
      // TODO: figure out how to access before and after to condense around the tag borders
    }
</code></pre>

<code>inline code</code>
            """,
            onLinkTap: (url) => print('clicked on url $url'),
            linkStyle: TextStyle(decoration: TextDecoration.underline),
            shrinkToFit: true,
          ),
        ),
      ),
    );
  }
}
