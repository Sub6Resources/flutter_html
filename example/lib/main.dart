import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/image_render.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: new MyHomePage(title: 'flutter_html Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

const htmlData = r"""
      <h1>Header 1</h1>
      <h2>Header 2</h2>
      <h3>Header 3</h3>
      <h4>Header 4</h4>
      <h5>Header 5</h5>
      <h6>Header 6</h6>
      <h3>Ruby Support:</h3>
      <p>
        <ruby>
          漢<rt>かん</rt>
          字<rt>じ</rt>
        </ruby>
        &nbsp;is Japanese Kanji.
      </p>
      <h3>Support for <code>sub</code>/<code>sup</code></h3>
      Solve for <var>x<sub>n</sub></var>: log<sub>2</sub>(<var>x</var><sup>2</sup>+<var>n</var>) = 9<sup>3</sup>
      <p>One of the most <span>common</span> equations in all of physics is <br /><var>E</var>=<var>m</var><var>c</var><sup>2</sup>.</p>
      <h3>Inline Styles:</h3>
      <p>The should be <span style='color: blue;'>BLUE style='color: blue;'</span></p>
      <p>The should be <span style='color: red;'>RED style='color: red;'</span></p>
      <p>The should be <span style='color: rgba(0, 0, 0, 0.10);'>BLACK with 10% alpha style='color: rgba(0, 0, 0, 0.10);</span></p>
      <p>The should be <span style='color: rgb(0, 97, 0);'>GREEN style='color: rgb(0, 97, 0);</span></p>
      <p>The should be <span style='background-color: red; color: rgb(0, 97, 0);'>GREEN style='color: rgb(0, 97, 0);</span></p>
      <p style="text-align: center;"><span style="color: rgba(0, 0, 0, 0.95);">blasdafjklasdlkjfkl</span></p>
      <p style="text-align: right;"><span style="color: rgba(0, 0, 0, 0.95);">blasdafjklasdlkjfkl</span></p>
      <p style="text-align: justify;"><span style="color: rgba(0, 0, 0, 0.95);">blasdafjklasdlkjfkl</span></p>
      <p style="text-align: center;"><span style="color: rgba(0, 0, 0, 0.95);">blasdafjklasdlkjfkl</span></p>
      <h3>Table support (with custom styling!):</h3>
      <p>
      <q>Famous quote...</q>
      </p>
      <table>
      <colgroup>
        <col width="50%" />
        <col span="2" width="25%" />
      </colgroup>
      <thead>
      <tr><th>One</th><th>Two</th><th>Three</th></tr>
      </thead>
      <tbody>
      <tr>
        <td rowspan='2'>Rowspan\nRowspan\nRowspan\nRowspan\nRowspan\nRowspan\nRowspan\nRowspan\nRowspan\nRowspan</td><td>Data</td><td>Data</td>
      </tr>
      <tr>
        <td colspan="2"><img alt='Google' src='https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png' /></td>
      </tr>
      </tbody>
      <tfoot>
      <tr><td>fData</td><td>fData</td><td>fData</td></tr>
      </tfoot>
      </table>
      <h3>Custom Element Support (inline: <bird></bird> and as block):</h3>
      <flutter></flutter>
      <flutter horizontal></flutter>
      <h3>SVG support:</h3>
      <svg id='svg1' viewBox='0 0 100 100' xmlns='http://www.w3.org/2000/svg'>
            <circle r="32" cx="35" cy="65" fill="#F00" opacity="0.5"/>
            <circle r="32" cx="65" cy="65" fill="#0F0" opacity="0.5"/>
            <circle r="32" cx="50" cy="35" fill="#00F" opacity="0.5"/>
      </svg>
      <h3>List support:</h3>
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
            <li>list! Lorem ipsum dolor sit amet.</li>
            <li><h2>Header 2</h2></li>
            <h2><li>Header 2</li></h2>
      </ol>
      <h3>Link support:</h3>
      <p>
        Linking to <a href='https://github.com'>websites</a> has never been easier.
      </p>
      <h3>Image support:</h3>
      <h3>Network png</h3>
      <img alt='Google' src='https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png' />
      <h3>Network svg</h3>
      <img src='https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/android.svg' />
      <h3>Local asset png</h3>
      <img src='asset:assets/html5.png' width='100' />
      <h3>Local asset svg</h3>
      <img src='asset:assets/mac.svg' width='100' />
      <h3>Base64</h3>
      <img alt='Red dot' src='data:image/png;base64, iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg==' />
      <h3>Custom source matcher (relative paths)</h3>
      <img src='/wikipedia/commons/thumb/e/ef/Octicons-logo-github.svg/200px-Octicons-logo-github.svg.png' />
      <h3>Custom image render (flutter.dev)</h3>
      <img src='https://flutter.dev/images/flutter-mono-81x100.png' />
      <h3>No image source</h3>
      <img alt='No source' />
      <img alt='Empty source' src='' />
      <h3>Broken network image</h3>
      <img alt='Broken image' src='https://www.notgoogle.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png' />
      <h3>MathML Support:</h3>
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
        <mi>&dd;</mi><mi>x</mi>
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
      <h3>Tex Support with the custom tex tag:</h3>
      <tex>i\hbar\frac{\partial}{\partial t}\Psi(\vec x,t) = -\frac{\hbar}{2m}\nabla^2\Psi(\vec x,t)+ V(\vec x)\Psi(\vec x,t)</tex>
""";

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('flutter_html Example'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Html(
          data: """
            <style type="text/css">table { border:1px solid #B96F00; margin-top:10px; margin-bottom:10px; background-color:white; }
        td { border:1px solid #B96F00; font-size: 12pt; padding:1 3 1 5; }
</style>
<div class="Lorem Ipsum" style="text-align: center;">Lorem Ipsum<br />
Lorem Ipsum<br />
Lorem Ipsum<br />
&nbsp;<br />
Lorem Ipsum</div>

<div style="text-align: center;"></div>
&nbsp;&nbsp;

<div style="text-align: justify;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Lorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem Ipsum<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Lorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem Ipsum,<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Lorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem Ipsum;<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Lorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem Ipsum;<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Lorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem Ipsum;<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Lorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem Ipsum.<br />
<br />
Lorem Ipsum</div>

<table>
	<tbody>
		<tr>
			<td rowspan="3" style="text-align: justify;">Lorem Ipsum<br />
			NO</td>
			<td colspan="6" nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
		</tr>
		<tr>
			<td colspan="2" nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" rowspan="2" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" rowspan="2" style="text-align: justify;">Lorem Ipsum</td>
			<td rowspan="2" style="text-align: justify;">Lorem Ipsum <br />
			</td>
			<td rowspan="2" style="text-align: justify;">Lorem Ipsum</td>
		</tr>
		<tr>
			<td style="text-align: justify;">Lorem Ipsum</td>
			<td style="text-align: justify;">Lorem Ipsum</td>
		</tr>
		<tr>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td style="text-align: justify;">Lorem Ipsum</td>
		</tr>
		<tr>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">14.01.2021</td>
			<td nowrap="nowrap" style="text-align: justify;">260</td>
			<td style="text-align: justify;">Lorem Ipsum</td>
		</tr>
		<tr>
			<td nowrap="nowrap" style="text-align: justify;">3</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">11.01.2021</td>
			<td nowrap="nowrap" style="text-align: justify;">200,00</td>
			<td style="text-align: justify;">Lorem Ipsum</td>
		</tr>
		<tr>
			<td nowrap="nowrap" style="text-align: justify;">4</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">11.01.2021</td>
			<td nowrap="nowrap" style="text-align: justify;">648,00</td>
			<td style="text-align: justify;">Lorem Ipsum</td>
		</tr>
		<tr>
			<td nowrap="nowrap" style="text-align: justify;">5</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">09.09.2020</td>
			<td nowrap="nowrap" style="text-align: justify;">300,00</td>
			<td style="text-align: justify;">Lorem Ipsum</td>
		</tr>
		<tr>
			<td nowrap="nowrap" style="text-align: justify;">6</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum Lorem Ipsum Lorem IpsumLorem Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">-</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">15.11.2019</td>
			<td nowrap="nowrap" style="text-align: justify;">16.262,33</td>
			<td style="text-align: justify;">Lorem IpsumLorem Ipsum</td>
		</tr>
		<tr>
			<td nowrap="nowrap" style="text-align: justify;">7</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">11.01.2021</td>
			<td nowrap="nowrap" style="text-align: justify;">100,00</td>
			<td style="text-align: justify;">Lorem Ipsum</td>
		</tr>
		<tr>
			<td nowrap="nowrap" style="text-align: justify;">8</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">11.01.2021</td>
			<td nowrap="nowrap" style="text-align: justify;">760,00</td>
			<td style="text-align: justify;">Lorem Ipsum</td>
		</tr>
		<tr>
			<td nowrap="nowrap" style="text-align: justify;">9</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">11.01.2021</td>
			<td nowrap="nowrap" style="text-align: justify;">380,00</td>
			<td style="text-align: justify;">Lorem Ipsum</td>
		</tr>
		<tr>
			<td nowrap="nowrap" style="text-align: justify;">10</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum Lorem Ipsum Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">11.01.2021</td>
			<td nowrap="nowrap" style="text-align: justify;">320,00</td>
			<td style="text-align: justify;">Lorem Ipsum</td>
		</tr>
		<tr>
			<td nowrap="nowrap" style="text-align: justify;">11</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum Lorem Ipsum Lorem Ipsum.</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">17.02.2020</td>
			<td nowrap="nowrap" style="text-align: justify;">10.029.107,40</td>
			<td style="text-align: justify;">Lorem IpsumLorem Ipsum.</td>
		</tr>
		<tr>
			<td nowrap="nowrap" style="text-align: justify;">112</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum Lorem Ipsum Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">11.01.2021</td>
			<td nowrap="nowrap" style="text-align: justify;">220,00</td>
			<td style="text-align: justify;">Lorem Ipsum</td>
		</tr>
	</tbody>
</table>

<div style="text-align: justify;">&nbsp;<br />
Lorem Ipsum</div>

<table>
	<tbody>
		<tr>
			<td nowrap="nowrap" rowspan="3" style="text-align: justify;">Lorem Ipsum Lorem Ipsum</td>
			<td colspan="6" nowrap="nowrap" style="text-align: justify;">Lorem Ipsum Lorem Ipsum / Lorem Ipsum Lorem Ipsum Lorem Ipsum</td>
		</tr>
		<tr>
			<td colspan="2" nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" rowspan="2" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" rowspan="2" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" rowspan="2" style="text-align: justify;">Lorem Ipsum Lorem Ipsum<br />
			(TL)</td>
			<td rowspan="2" style="text-align: justify;">Lorem Ipsum</td>
		</tr>
		<tr>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum/Lorem Ipsum - Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum/Lorem Ipsum/<br />
			Lorem Ipsum</td>
		</tr>
		<tr>
			<td nowrap="nowrap" style="text-align: justify;">1</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum Lorem Ipsum Lorem Ipsum<br />
			Lorem Ipsum Lorem Ipsum. Lorem Ipsum. Lorem Ipsum. Lorem Ipsum.</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">02.10.2020</td>
			<td nowrap="nowrap" style="text-align: justify;">318</td>
			<td style="text-align: justify;">Lorem Ipsum Lorem Ipsum Lorem Ipsum</td>
		</tr>
		<tr>
			<td nowrap="nowrap" style="text-align: justify;">2</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum Lorem Ipsum Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">_</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum<br />
			Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">17.09.2020 25.09.2020</td>
			<td nowrap="nowrap" style="text-align: justify;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 520</td>
			<td style="text-align: justify;">Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum</td>
		</tr>
		<tr>
			<td nowrap="nowrap" style="text-align: justify;">3</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">_</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">17.01.2019</td>
			<td nowrap="nowrap" style="text-align: justify;">136.402,64</td>
			<td style="text-align: justify;">Lorem Ipsum Lorem Ipsum Lorem Ipsum</td>
		</tr>
		<tr>
			<td nowrap="nowrap" style="text-align: justify;">4</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum Lorem Ipsum Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">_</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">17.01.2019</td>
			<td nowrap="nowrap" style="text-align: justify;">55.745,56</td>
			<td style="text-align: justify;">Lorem Ipsum Lorem Ipsum Lorem Ipsum</td>
		</tr>
		<tr>
			<td nowrap="nowrap" style="text-align: justify;">5</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum Lorem Ipsum Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">Lorem Ipsum</td>
			<td nowrap="nowrap" style="text-align: justify;">09.01.2020</td>
			<td nowrap="nowrap" style="text-align: justify;">584.589,34</td>
			<td style="text-align: justify;">Lorem Ipsum/Lorem Ipsum Lorem Ipsum</td>
		</tr>
	</tbody>
</table>

<div style="text-align: justify;">&nbsp;<br />
&nbsp;<br />
&nbsp;
<style type="text/css">.Lorem Ipsum {
  text-align:center;
  font-size:16pt !important;
  column-span:all;
  font-weight:bold;
  }
</style>
</div>
          """,
          //Optional parameters:
          customImageRenders: {
            networkSourceMatcher(domains: ["flutter.dev"]):
                (context, attributes, element) {
              return FlutterLogo(size: 36);
            },
            networkSourceMatcher(domains: ["mydomain.com"]): networkImageRender(
              headers: {"Custom-Header": "some-value"},
              altWidget: (alt) => Text(alt ?? ""),
              loadingWidget: () => Text("Loading..."),
            ),
            // On relative paths starting with /wiki, prefix with a base url
            (attr, _) => attr["src"] != null && attr["src"]!.startsWith("/wiki"):
                networkImageRender(
                    mapUrl: (url) => "https://upload.wikimedia.org" + url!),
            // Custom placeholder image for broken links
            networkSourceMatcher(): networkImageRender(altWidget: (_) => FlutterLogo()),
          },
          onLinkTap: (url, _, __, ___) {
            print("Opening $url...");
          },
          onImageTap: (src, _, __, ___) {
            print(src);
          },
          onImageError: (exception, stackTrace) {
            print(exception);
          },
        ),
      ),
    );
  }
}
