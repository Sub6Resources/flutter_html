import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_all/flutter_html_all.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(title: 'flutter_html Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

const htmlData = r"""
<p id='top'><a href='#bottom'>Scroll to bottom</a></p>
      <h1>Header 1</h1>
      <h2>Header 2</h2>
      <h3>Header 3</h3>
      <h4>Header 4</h4>
      <h5>Header 5</h5>
      <h6>Header 6</h6>
      
      <h2>Inline Styles:</h2>
      <p>The should be <span style='color: blue;'>BLUE style='color: blue;'</span></p>
      <p>The should be <span style='color: red;'>RED style='color: red;'</span></p>
      <p>The should be <span style='color: rgba(0, 0, 0, 0.10);'>BLACK with 10% alpha style='color: rgba(0, 0, 0, 0.10);</span></p>
      <p>The should be <span style='color: rgb(0, 97, 0);'>GREEN style='color: rgb(0, 97, 0);</span></p>
      <p>The should be <span style='background-color: red; color: rgb(0, 97, 0);'>GREEN style='color: rgb(0, 97, 0);</span></p>
      
      <h2>Text Alignment</h2>
      <p style="text-align: center;"><span style="color: rgba(0, 0, 0, 0.95);">Center Aligned Text</span></p>
      <p style="text-align: right;"><span style="color: rgba(0, 0, 0, 0.95);">Right Aligned Text</span></p>
      <p style="text-align: justify;"><span style="color: rgba(0, 0, 0, 0.95);">Justified Text</span></p>
      <p style="text-align: center;"><span style="color: rgba(0, 0, 0, 0.95);">Center Aligned Text</span></p>
      
      <h2>Margins</h2>
      <div style="width: 350px; height: 20px; text-align: center; background-color: #ff9999;">Default Div (width 350px height 20px)</div>
      <div style="width: 350px; height: 20px; text-align: center; background-color: #ffff99; margin-left: 3em;">margin-left: 3em</div>
      <div style="width: 350px; height: 20px; text-align: center; background-color: #99ff99; margin: auto;">margin: auto</div>
      <div style="width: 350px; height: 20px; text-align: center; background-color: #ff99ff; margin: 15px auto;">margin: 15px auto</div>
      <div style="width: 350px; height: 20px; text-align: center; background-color: #9999ff; margin-left: auto;">margin-left: auto</div>
      <div style="width: 350px; height: 20px; text-align: center; background-color: #99ffff; margin-right: auto;">margin-right: auto</div>
      <div style="width: 350px; height: 20px; text-align: center; background-color: #999999; margin-left: auto; margin-right: 3em;">margin-left: auto; margin-right: 3em</div>
      
      <h4>Margin Auto on Image</h4>
      <p>display:inline-block; margin: auto; (should not center):</p>
      <img alt='' style="margin: auto;" width="100" src="https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png">
      <p>display:block margin: auto; (should center):</p>
      <img alt='' style="display: block; margin: auto;" width="100" src="https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png">
      
      <h2>Support for <code>sub</code>/<code>sup</code></h2>
      Solve for <var>x<sub>n</sub></var>: log<sub>2</sub>(<var>x</var><sup>2</sup>+<var>n</var>) = 9<sup>3</sup>
      <p>One of the most <span>common</span> equations in all of physics is <br /><var>E</var>=<var>m</var><var>c</var><sup>2</sup>.</p>
      
      <h2>Ruby Support:</h2>
      <p>
        <ruby>
          漢<rt>かん</rt>
          字<rt>じ</rt>
        </ruby>
        &nbsp;is Japanese Kanji.
      </p>
      
      <h2>Support for maxLines:</h2>
      <h5>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec vestibulum sapien feugiat lorem tempor, id porta orci elementum. Fusce sed justo id arcu egestas congue. Fusce tincidunt lacus ipsum, in imperdiet felis ultricies eu. In ullamcorper risus felis, ac maximus dui bibendum vel. Integer ligula tortor, facilisis eu mauris ut, ultrices hendrerit ex. Donec scelerisque massa consequat, eleifend mauris eu, mollis dui. Donec placerat augue tortor, et tincidunt quam tempus non. Quisque sagittis enim nisi, eu condimentum lacus egestas ac. Nam facilisis luctus ipsum, at aliquam urna fermentum a. Quisque tortor dui, faucibus in ante eget, pellentesque mattis nibh. In augue dolor, euismod vitae eleifend nec, tempus vel urna. Donec vitae augue accumsan ligula fringilla ultrices et vel ex.</h5>
      
     
      <h2>Table support (With custom styling!):</h2>
      <table>
      <colgroup>
        <col width="200" />
        <col span="2" width="150" />
      </colgroup>
      <thead>
      <tr><th>One</th><th>Two</th><th>Three</th></tr>
      </thead>
      <tbody>
      <tr>
        <td rowspan='2'>Rowspan<br>Rowspan<br>Rowspan<br>Rowspan<br>Rowspan<br>Rowspan<br>Rowspan<br>Rowspan<br>Rowspan<br>Rowspan<br>Rowspan<br>Rowspan<br>Rowspan<br>Rowspan</td><td>Data</td><td>Data</td>
      </tr>
      <tr>
        <td colspan="2"><img width="175" alt='xkcd' src='https://imgs.xkcd.com/comics/commemorative_plaque.png' /></td>
      </tr>
      </tbody>
      <tfoot>
      <tr><td>fData</td><td>fData</td><td>fData</td></tr>
      </tfoot>
      </table>
      
      <h2>List support:</h2>
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
            <ol style="list-style-type: lower-alpha;" start="5">
            <li>With a nested</li>
            <li>ordered list</li>
            <li>with a lower alpha list style</li>
            <li>starting at letter e</li>
            </ol>
            </li>
            <li>list</li>
            </ul>
            </li>
            <li>list! Lorem ipsum dolor sit amet.</li>
            <li><h2>Header 2</h2></li>
            <h2><li>Header 2</li></h2>
      </ol>
      
      <h2>Link support:</h2>
      <p>
        Linking to <a href='https://github.com'>websites</a> has never been easier.
      </p>
      
      <h2>Image support:</h2>
      
      <table class="second-table">
      <tr><td>Network png</td><td><img width="200" alt='xkcd' src='https://imgs.xkcd.com/comics/commemorative_plaque.png' /></td></tr>
      <tr><td>Local asset png</td><td><img src='asset:assets/html5.png' width='100' /></td></tr>
      <tr><td>Local asset svg</td><td><img src='asset:assets/mac.svg' width='100' /></td></tr>
      <tr><td>Data uri (with base64 support)</td>
      <td><img alt='Red dot (png)' src='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg==' />
      <img alt='Green dot (base64 svg)' src='data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPHN2ZyB2aWV3Qm94PSIwIDAgMzAgMjAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxjaXJjbGUgY3g9IjE1IiBjeT0iMTAiIHI9IjEwIiBmaWxsPSJncmVlbiIvPgo8L3N2Zz4=' />
      <img alt='Green dot (plain svg)' src='data:image/svg+xml,%3C?xml version="1.0" encoding="UTF-8"?%3E%3Csvg viewBox="0 0 30 20" xmlns="http://www.w3.org/2000/svg"%3E%3Ccircle cx="15" cy="10" r="10" fill="yellow"/%3E%3C/svg%3E' />
      </td></tr>
      <tr><td>Custom image render</td><td><img src='https://flutter.dev/images/flutter-mono-81x100.png' /></td></tr>
      <tr><td>Broken network image</td><td><img alt='Broken network image alt text' src='https://www.example.com/image.png' /></td></tr>
      </table>
      
      <h2 id='middle'>SVG support:</h2>
      <svg id='svg1' viewBox='0 0 100 100' xmlns='http://www.w3.org/2000/svg'>
            <circle r="32" cx="35" cy="65" fill="#F00" opacity="0.5"/>
            <circle r="32" cx="65" cy="65" fill="#0F0" opacity="0.5"/>
            <circle r="32" cx="50" cy="35" fill="#00F" opacity="0.5"/>
      </svg>
      
      <h2>Custom Element Support:</h2>
      Inline: &lt;bird&gt;&lt;/bird&gt; becomes: <bird></bird>.
      <br />
      
      Block: &lt;flutter&gt;&lt;/flutter&gt; becomes:
      <flutter></flutter>
      and &lt;flutter horizontal&gt;&lt;/flutter&gt; becomes:
      <flutter horizontal></flutter>
      
      <h2>MathML Support:</h2>
      <math>
      <mrow>
        <mi>x</mi>
        <mo>=</mo>
        <mfrac>
          <mrow>
            <mrow>
              <mo>-</mo>
              <mi>b</mi>
            </mrow>
            <mo>&PlusMinus;</mo>
            <msqrt>
              <mrow>
                <msup>
                  <mi>b</mi>
                  <mn>2</mn>
                </msup>
                <mo>-</mo>
                <mrow>
                  <mn>4</mn>
                  <mo>&InvisibleTimes;</mo>
                  <mi>a</mi>
                  <mo>&InvisibleTimes;</mo>
                  <mi>c</mi>
                </mrow>
              </mrow>
            </msqrt>
          </mrow>
          <mrow>
            <mn>2</mn>
            <mo>&InvisibleTimes;</mo>
            <mi>a</mi>
          </mrow>
        </mfrac>
      </mrow>
      </math>
      <math>
        <munderover >
          <mo> &int; </mo>
          <mn> 0 </mn>
          <mi> 5 </mi>
        </munderover>
        <msup>
          <mi>x</mi>
          <mn>2</mn>
       </msup>
        <mo>&sdot;</mo>
        <mi>d</mi><mi>x</mi>
        <mo>=</mo>
        <mo>[</mo>
        <mfrac>
          <mn>1</mn>
          <mi>3</mi>
       </mfrac>
       <msup>
          <mi>x</mi>
          <mn>3</mn>
       </msup>
       <msubsup>
          <mo>]</mo>
          <mn>0</mn>
          <mn>5</mn>
       </msubsup>
       <mo>=</mo>
       <mfrac>
          <mn>125</mn>
          <mi>3</mi>
       </mfrac>
       <mo>-</mo>
       <mn>0</mn>
       <mo>=</mo>
       <mfrac>
          <mn>125</mn>
          <mi>3</mi>
       </mfrac>
      </math>
      <br />
      <math>
        <msup>
          <mo>sin</mo>
          <mn>2</mn>
        </msup>
        <mo>&theta;</mo>
        <mo>+</mo>
        <msup>
          <mo>cos</mo>
          <mn>2</mn>
        </msup>
        <mo>&theta;</mo>
        <mo>=</mo>
        <mn>1</mn>
      </math>
      
      <h2>Tex Support with the custom tex tag:</h2>
      <tex>i\hbar\frac{\partial}{\partial t}\Psi(\vec x,t) = -\frac{\hbar}{2m}\nabla^2\Psi(\vec x,t)+ V(\vec x)\Psi(\vec x,t)</tex>
      <p id='bottom'><a href='#top'>Scroll to top</a></p>
""";

final staticAnchorKey = GlobalKey();

class MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('flutter_html Example'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.arrow_downward),
        onPressed: () {
          final anchorContext =
              AnchorKey.forId(staticAnchorKey, "bottom")?.currentContext;
          if (anchorContext != null) {
            Scrollable.ensureVisible(anchorContext);
          }
        },
      ),
      body: SingleChildScrollView(
        child: Html(
          anchorKey: staticAnchorKey,
          data: htmlData,
          style: {
            "table": Style(
              backgroundColor: const Color.fromARGB(0x50, 0xee, 0xee, 0xee),
            ),
            "th": Style(
              padding: const EdgeInsets.all(6),
              backgroundColor: Colors.grey,
            ),
            "td": Style(
              padding: const EdgeInsets.all(6),
              border: const Border(bottom: BorderSide(color: Colors.grey)),
            ),
            'h5': Style(maxLines: 2, textOverflow: TextOverflow.ellipsis),
            'flutter': Style(
              display: Display.block,
              fontSize: FontSize(5, Unit.em),
            ),
            ".second-table": Style(
              backgroundColor: Colors.transparent,
            ),
            ".second-table tr td:first-child": Style(
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.end,
            ),
          },
          extensions: [
            TagExtension(
              tagsToExtend: {"tex"},
              builder: (context) => Math.tex(
                context.innerHtml,
                mathStyle: MathStyle.display,
                textStyle: context.styledElement?.style.generateTextStyle(),
                onErrorFallback: (FlutterMathException e) {
                  return Text(e.message);
                },
              ),
            ),
            TagExtension.inline(
              tagsToExtend: {"bird"},
              child: const TextSpan(text: "🐦"),
            ),
            TagExtension(
              tagsToExtend: {"flutter"},
              builder: (context) => CssBoxWidget(
                style: context.styledElement!.style,
                child: FlutterLogo(
                  style: context.attributes['horizontal'] != null
                      ? FlutterLogoStyle.horizontal
                      : FlutterLogoStyle.markOnly,
                  textColor: context.styledElement!.style.color!,
                  size: context.styledElement!.style.fontSize!.value,
                ),
              ),
            ),
            ImageExtension(
              handleAssetImages: false,
              handleDataImages: false,
              networkDomains: {"flutter.dev"},
              child: const FlutterLogo(size: 36),
            ),
            ImageExtension(
              handleAssetImages: false,
              handleDataImages: false,
              networkDomains: {"mydomain.com"},
              networkHeaders: {"Custom-Header": "some-value"},
            ),
            const MathHtmlExtension(),
            const AudioHtmlExtension(),
            const VideoHtmlExtension(),
            const IframeHtmlExtension(),
            const TableHtmlExtension(),
            const SvgHtmlExtension(),
          ],
          onLinkTap: (url, _, __) {
            debugPrint("Opening $url...");
          },
          onCssParseError: (css, messages) {
            debugPrint("css that errored: $css");
            debugPrint("error messages:");
            for (var element in messages) {
              debugPrint(element.toString());
            }
            return '';
          },
        ),
      ),
    );
  }
}
