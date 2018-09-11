## [0.7.0] - September 10, 2018:

* Adds full support for `ul`

## [0.6.2] - September 5, 2018:

* Adds check for `img src` before trying to load it.
* Adds support for `img alt` attribute.

## [0.6.1] - September 4, 2018:

* Fixed minor typo

## [0.6.0] - September 4, 2018:

* Update README.md and example
* GitHub version 0.6.0 milestone reached

## [0.5.6] - September 4, 2018:

* Adds partial support for `center` and a `renderNewlines` property on the `Html` widget.

## [0.5.5] - September 4, 2018:

* Adds support for `acronym`, and `big`.

## [0.5.4] - August 31, 2018:

* Adds `onLinkTap` callback.

## [0.5.3] - August 25, 2018:

* Adds support for `strike`, and `tt`.

## [0.5.2] - August 25, 2018:

* Adds support for `bdi` and `bdo`

## [0.5.1] - August 25, 2018:

* Fixed issue with table rows not lining up correctly ([#4](https://github.com/Sub6Resources/flutter_html/issues/4))

## [0.5.0] - August 23, 2018:

* Major refactor that makes entire tree a Widget and eliminates the need to distinguish between inline and block elements.
* Fixed [#7](https://github.com/Sub6Resources/flutter_html/issues/7), [#9](https://github.com/Sub6Resources/flutter_html/issues/9), [#10](https://github.com/Sub6Resources/flutter_html/issues/10), and [#11](https://github.com/Sub6Resources/flutter_html/issues/11).

## [0.4.1] - August 15, 2018:

* Fixed issue with images not loading when inside of `p` tag ([#6](https://github.com/Sub6Resources/flutter_html/issues/6))

## [0.4.0] - August 15, 2018:

* Adds support for `table`, `tbody`, `tfoot`, `thead`, `tr`, `td`, `th`, and `caption`

## [0.3.1] - August 15, 2018:

* Fixed issue where `p` was not rendered with the `defaultTextStyle`.

## [0.3.0] - August 15, 2018:

* Adds support for `abbr`, `address`, `article`, `aside`, `blockquote`, `br`, `cite`, `code`, `data`, `dd`, 
`del`, `dfn`, `dl`, `dt`, `figcaption`, `figure`, `footer`, `header`, `hr`, `img`, `ins`, `kbd`, `li`,
`main`, `mark`, `nav`, `noscript`, `pre`, `q`, `rp`, `rt`, `ruby`, `s`, `samp`, `section`, `small`, `span`,
`template`, `time`, and `var`

* Adds partial support for `a`, `ol`, and `ul`

## [0.2.0] - August 14, 2018:

* Adds support for `img`.

## [0.1.1] - August 14, 2018:

* Fixed `b` to be bold, not italic...
* Adds support for `em`, and `strong`
* Adds support for a default `TextStyle`

## [0.1.0] - August 14, 2018:

* Renamed widget from `HtmlWidget` to `Html`
* Adds support for `p`, `h1`, `h2`, `h3`, `h4`, `h5`, and `h6`.

## [0.0.1] - August 14, 2018:

* Adds support for `body`, `div`, `b`, `i`, and `u`.
