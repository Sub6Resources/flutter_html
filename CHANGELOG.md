## [1.0.0-pre.1] - December 27, 2019

* For a list of pre-release changes, including several BREAKING CHANGES, see [the pre-release changelog](https://github.com/Sub6Resources/flutter_html/blob/new-parser/PRE_CHANGELOG.md#100-pre1)

## [0.11.1] - December 14, 2019:

* Add support for `AssetImage`s using the `asset:` prefix ([#162](https://github.com/Sub6Resources/flutter_html/pull/162)).

## [0.11.0] - September 10, 2019:

* Make it so `width=100%` doesn't throw error. Fixes [#118](https://github.com/Sub6Resources/flutter_html/issues/118).
* You can now set width and/or height in `ImageProperties` to negative to ignore the `width` and/or `height` values from the html. Fixes [#97](https://github.com/Sub6Resources/flutter_html/issues/97)
* The `img` `alt` property now renders correctly when the image fails to load and with the correct style. Fixes [#96](https://github.com/Sub6Resources/flutter_html/issues/96)
* Add partial support for `sub` tag.
* Add new option: `shrinkToFit` ([#148](https://github.com/Sub6Resources/flutter_html/pull/148)). Fixes [#75](https://github.com/Sub6Resources/flutter_html/issues/75).

## [0.10.4] - June 22, 2019:

* Add support for `customTextStyle` to block and specialty HTML elements.

## [0.10.3] - June 20, 2019:

* Add `src` to the `onImageTap` callback ([#93](https://github.com/Sub6Resources/flutter_html/pull/93))

## [0.10.2] - June 19, 2019:

* Add `customTextAlign` property ([#112](https://github.com/Sub6Resources/flutter_html/pull/112))
* Use `tryParse` instead of `parse` for image width and height attributes so that `%` values are ignored safely. Fixes [#98](https://github.com/Sub6Resources/flutter_html/issues/98)

## [0.10.1] - May 20, 2019:

* Image properties and onImageTap for the richTextParser, plus some fixes ([#90](https://github.com/Sub6Resources/flutter_html/pull/90))
* Hotfix 1 (June 6, 2019): Fixes [#100](https://github.com/Sub6Resources/flutter_html/issues/100)

## [0.10.0] - May 18, 2019:

* **BREAKING:** `useRichText` now defaults to `true`
* Support for `aside`, `bdi`, `big`, `cite`, `data`, `ins`, `kbd`, `mark`, `nav`, `noscript`, `q`, `rp`, `rt`, `ruby`, `s`, `samp`, `strike`, `template`, `time`, `tt`, and `var` added to `RichText` parser.

## [0.9.9] - May 17, 2019:

* Fixes extra padding issue ([#87](https://github.com/Sub6Resources/flutter_html/issues/87))

## [0.9.8] - May 14, 2019:

* Add support for `address` tag in `RichText` parser.

## [0.9.7] - May 13, 2019:
* Added onImageError callback
* Added custom textstyle and edgeinsets callback ([#72](https://github.com/Sub6Resources/flutter_html/pull/72))
* Update dependency versions ([#84](https://github.com/Sub6Resources/flutter_html/issues/84))
* Fixes [#82](https://github.com/Sub6Resources/flutter_html/issues/82) and [#86](https://github.com/Sub6Resources/flutter_html/issues/86)

## [0.9.6] - March 11, 2019:

* Fix whitespace issue. ([#59](https://github.com/Sub6Resources/flutter_html/issues/59))

## [0.9.5] - March 11, 2019:

* Add support for `span` in `RichText` parser. ([#61](https://github.com/Sub6Resources/flutter_html/issues/61))
* Adds `linkStyle` attribute. ([#70](https://github.com/Sub6Resources/flutter_html/pull/70))
* Adds tests for `header`, `hr`, and `i` ([#62](https://github.com/Sub6Resources/flutter_html/issues/62))

## [0.9.4] - February 5, 2019:

* Fixes `table` error in `RichText` parser. ([#58](https://github.com/Sub6Resources/flutter_html/issues/58))

## [0.9.3] - January 31, 2019:

* Adds support for base64 encoded images

## [0.9.2] - January 31, 2019:

* Adds partial support for deprecated `font` tag.

## [0.9.1] - January 31, 2019:

* Adds full support for `sub` and `sup`. ([#46](https://github.com/Sub6Resources/flutter_html/pull/46))
* Fixes weak warning caught by Pub analysis ([#54](https://github.com/Sub6Resources/flutter_html/issues/54))

## [0.9.0] - January 31, 2019:

* Adds an alternate `RichText` parser and `useRichText` parameter. ([#37](https://github.com/Sub6Resources/flutter_html/pull/37))

## [0.8.2] - November 1, 2018:

* Removes debug prints.

## [0.8.1] - October 19, 2018:

* Adds `typedef` for `onLinkTap` function.

## [0.8.0] - October 18, 2018:

* Adds custom tag callback
* Logging no longer shows up in production.

## [0.7.1] - September 11, 2018:

* Fixes issue with text nodes that contain only a space. ([#24](https://github.com/Sub6Resources/flutter_html/issues/24))
* Fixes typo in README.md from 0.7.0.

## [0.7.0] - September 10, 2018:

* Adds full support for `ul` and `ol`

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
