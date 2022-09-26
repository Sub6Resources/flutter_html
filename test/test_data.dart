const testData = <String, String>{
  'a': '<a>Hello, World!</a>',
  'abbr': '<abbr>HLO-WRLD</abbr>',
  'acronym': '<acronym>HW</acronym>',
  'address': '<address>123 United States, World</address>',
  'article': '<article>123 United States, World</article>',
  'aside': '<aside>This is interesting</aside>',
  'b': '<b>Hello, World!</b>',
  'bdi': '<bdi>Hello, World!</bdi>',
  'bdo': '<bdo>Hello, World!</bdo>',
  'big': '<big>Hello, World!</big>',
  'blockquote': '<blockquote>Hello, World!</blockquote>',
  'body': '<body>Hello, World!</body>',
  'br': '<span>Hello,<br />World!</span>',
  'caption': '<caption>Hello, World!</caption>',
  'center': '<center>Hello, World!</center>',
  'cite': '<cite>Hello, World!</cite>',
  'code': '<code>Hello, World!</code>',
  'data': '<data value="value">Hello, World!</data>',
  'dd': '<dd>Hello, World!</dd>',
  'del': '<del>Hello, World!</del>',
  'dfn': '<dfn>Hello, World!</dfn>',
  'div': '<div>Hello, World!</div>',
  'dl': '<dl>Hello, World!</dl>',
  'dt': '<dt>Hello, World!</dt>',
  'em': '<em>Hello, World!</em>',
  'figcaption_figure':
      '<figure><figcaption>Hello, World!</figcaption></figure>',
  'font': '<font>Hello, World!</font>',
  'footer': '<footer>Hello, World!</footer>',
  'h1': '<h1>Hello, World!</h1>',
  'h2': '<h2>Hello, World!</h2>',
  'h3': '<h3>Hello, World!</h3>',
  'h4': '<h4>Hello, World!</h4>',
  'h5': '<h5>Hello, World!</h5>',
  'h6': '<h6>Hello, World!</h6>',
  'header': '<header>Hello, World!</header>',
  'hr': '<div>Hello</div><hr /><div>World!</div>',
  'i': '<i>Hello, World!</i>',
  'img':
      '<img alt="Hello, World!" src="https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png" />',
  'img_alt': '<img alt="Hello, World!" src="" />',
  'ins': '<ins>Hello, World!</ins>',
  'kbd': '<kbd>Hello, World!</kbd>',
  'li_ul': '<ul><li>Hello</li><li>World!</li></ul>',
  'li_ol': '<ol><li>Hello</li><li>World!</li></ol>',
  'main': '<main>Hello, World!</main>',
  'mark': '<mark>Hello, World!</mark>',
  'nav': '<nav>Hello, World!</nav>',
  'noscript': '<noscript>Hello, World!</noscript>',
  'p': '<p>Hello, World!</p>',
  'p-with-inline-css-text-align-center':
      '<p style="text-align: center;">Hello, World!</p>',
  'p-with-inline-css-text-align-right':
      '<p style="text-align: right;">Hello, World!</p>',
  'p-with-inline-css-text-align-left':
      '<p style="text-align: left;">Hello, World!</p>',
  'p-with-inline-css-text-align-justify':
      '<p style="text-align: justify;">Hello, World!</p>',
  'p-with-inline-css-text-align-end':
      '<p style="text-align: end;">Hello, World!</p>',
  'p-with-inline-css-text-align-start':
      '<p style="text-align: start;">Hello, World!</p>',
  'pre': '<pre>Hello, World!</pre>',
  'q': '<q>Hello, World!</q>',
  'rp': '<ruby>漢 <rp> ㄏㄢˋ </rp></ruby>',
  'rt': '<ruby>漢 <rt> ㄏㄢˋ </rt></ruby>',
  'ruby': '<ruby>漢 <rt> ㄏㄢˋ </rt></ruby>',
  's': '<s>Hello, World!</s>',
  'samp': '<samp>Hello, World!</samp>',
  'section': '<section>Hello, World!</section>',
  'small': '<small>Hello, World!</small>',
  'span': '<span>Hello, World!</span>',
  'span-with-inline-css-color':
      '<p>Hello, <span style="color: red;">World!</span></p>',
  'span-with-inline-css-color-rgb':
      '<p>Hello, <span style="color: rgb(252, 186, 3);">World!</span></p>',
  'span-with-inline-css-color-rgba':
      '<p>Hello, <span style="color: rgba(252, 186, 3,0.5);">World!</span></p>',
  'span-with-inline-css-backgroundcolor':
      '<p>Hello, <span style="background-color: red; color: rgba(0, 0, 0,0.5);">World!</span></p>',
  'span-with-inline-css-backgroundcolor-rgb':
      '<p>Hello, <span style="background-color: rgb(252, 186, 3); color: rgba(0, 0, 0,0.5);">World!</span></p>',
  'span-with-inline-css-backgroundcolor-rgba':
      '<p>Hello, <span style="background-color: rgba(252, 186, 3,0.5); color: rgba(0, 0, 0,0.5);">World!</span></p>',
  'strike': '<strike>Hello, World!</strike>',
  'strong': '<strong>Hello, World!</strong>',
  'sub': '<sub>Hello, World!</sub>',
  'sup': '<sup>Hello, World!</sup>',
  'table':
      '<table><tr><th>Hello</th><th>World!</th></tr><tr><td>Hello</td><td>World!</td></tr></table>',
  'tbody':
      '<table><tr><th>Hello</th><th>World!</th></tr><tbody><tr><td>Hello</td><td>World!</td></tr></tbody></table>',
  'td':
      '<table><tr><th>Hello</th><th>World!</th></tr><tr><td>Hello</td><td>World!</td></tr></table>',
  'template': '<template>Hello, World!</template>',
  'tfoot':
      '<table><tr><th>Hello</th><th>World!</th></tr><tfoot><tr><td>Hello</td><td>World!</td></tr></tfoot></table>',
  'th':
      '<table><tr><th>Hello</th><th>World!</th></tr><tr><td>Hello</td><td>World!</td></tr></table>',
  'thead':
      '<table><thead><tr><th>Hello</th><th>World!</th></tr></thead><tr><td>Hello</td><td>World!</td></tr></table>',
  'time': '<time>3:00 PM</time>',
  'tr':
      '<table><tr><th>Hello</th><th>World!</th></tr><tr><td>Hello</td><td>World!</td></tr></table>',
  'tt': '<tt>Hello, World!</tt>',
  'u': '<u>Hello, World!</u>',
  'var': '<var>Hello, World!</var>',
};
