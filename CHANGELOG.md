## [2.2.1] - December 8, 2021:
* Allow styling on ruby tags
* Allow width/height/alignment styling on table/tr/td tags
* Prevent images causing rebuilding and leaking memory
* Fixes display of list items on iOS with font weights below 400
* Prevent crash on negative margins or paddings

## [2.2.0] - November 29, 2021:
* Explicitly declare multiplatform support
* Extended and fixed list-style (marker) support
* Basic support for height/width css properties
* Support changing scroll physics of SelectableText.rich
* Support text transform css property
* Bumped minimum flutter_math_fork version for Flutter 2.5 compatibility
* Fix styling of iframes
* Fix nested font tag application
* Fix whitespace rendering between list items
* Prevent crash on empty <table> tag and tables with both colspan/rowspan
* Prevent crash on use of negative margins in css

## [2.1.5] - October 7, 2021:
* Ignore unsupported custom style selectors when using fromCss
* Fix SVG tag usage inside tables
* Properly fix regression in usage of line breaks

## [2.1.4] - October 3, 2021:
* Fix regression in usage of line breaks in body being stripped

## [2.1.3] - October 1, 2021:
* Update minimum versions of dependencies for Flutter 2.5 compatibility
* Extended and fixed support for css shadow
* Fix block tags with explicit whitespace from being stripped

## [2.1.2] - September 2, 2021:
* Allow setting selectionControls with SelectableHtml
* Fix onLinkTap not working with SelectableHtml
* Don't crash when parsing unsupported :hover
* Prevent endless loading when using animated images

## [2.1.1] - July 28, 2021:
* Stable release with all 2.1.1-preview.X changes

## [2.1.1-preview.0] - July 27, 2021:
* Improves hr tag support
* Fixes a leading whitespace issue
* Fixes some crashes with CSS parsing

## [2.1.0] - June 3, 2021:
* SelectableHtml widget (supporting a subset of tags) which allow text selection
* Fixed shrinkWrap to actually shrink the horizontal space
* Support style tags to apply styling from inline css
* Support applying styles from Flutter themes
* Mouse hover on links when using Flutter Web
* Allow custom anchor link tap implementations
* Support additional list styling options
* Fix several minor whitespace issues in text flow
* Fixed specific colspan/rowspan usages in tables
* Fixed whitespace issues around images
* Swallow duplicate ids to prevent crashing the widget
* Fixes crashing tap detection when using both link and image taps
* Updates external dependencies
* Raised minimum Flutter version to 2.2.0

## [2.0.0] - April 29, 2021:
* Stable release with all 2.0.0-nullsafety.X changes

## [2.0.0-nullsafety.1] - April 29, 2021:
* Support basic MathML
* Support inner links
* Supply full context tree to custom render
* Include or exclude specific tags via `tagsList` parameter
* Fixed lists not rendering correctly
* Fixes for colspans in tables
* Fixed various exceptions when using inline styles
* Fixed text decoration not cascading between parent and child
* [BREAKING] support whitelisting tags
   * See the README for details on how to migrate `blacklistedElements` (deprecated) to `tagsList`
*  Fixed `failed assertion` error when tap-scrolling on any link
* Updated dependencies

## [2.0.0-nullsafety.0] - March 5, 2021:
* Nullsafety support
* Official Flutter Web support
* New features & fixes for lists:
   * Support start attribute (e.g. `start="5";`)
   * Support RTL direction
   * Support setting padding - you can remove the starting padding if you choose
   * Fixed unknown character box on iOS when font-weight is below w400
* Upgraded link functions to provide more granular control
* Fixed errors in text-decoration parsing
* Fixed `<audio>` on iOS ("_duration called on null" exception)
* Updated dependencies

## [1.3.0] - February 16, 2021:
* New image loading API
* Image loading with request headers, from relative paths and custom loading widget
* SVG image support from network or local assets
* Support for `<details>`/`<summary>` tags
* Allow returning spans from custom tag renders
* Inline font styling
* Content-based table column sizing
* Respect iframe sandbox attribute
* Fixed text flow and styling when using tags inside `<a>` links
* Fixed issue where `shrinkWrap` property would not constrain the widget to take up the space it needs
  * See the [Notes](https://github.com/Sub6Resources/flutter_html#notes) for an example usage with `shrinkWrap`
* Fixed issue where iframes would not update when their `src`s changed in the HTML data
* Updated dependencies for Flutter 1.26+

## [1.2.0] - January 14, 2021:
* Support irregular table sizes
* Allow for returning `null` from a customRender function to disable the widget

## [1.1.1] - November 22, 2020:
* Update dependencies

## [1.1.0] - November 22, 2020:
* Add support for inline styles
* Update dependencies

## [1.0.2] - August 8, 2020:
* Fix text scaling issues
* Update dependencies

## [1.0.1] - August 8, 2020:
* Fixed flutter_svg: ^0.18.0

# [1.0.0]
* BREAKING CHANGES (see the [Migration Guide](https://github.com/Sub6Resources/flutter_html/wiki/1.0.0-Migration-Guide) for a full overview of breaking changes.):
  * The default parser has been completely rewritten and the RichText parser has been removed.
  * `useRichText` no longer is necessary (The new parser uses RichText under the hood)
  * `customRender` now works for the default parser.
* Adds support for `<audio>`, `<video>`, `<iframe>`, `<svg>`, `<ruby>`, `<rt>`, `<rp>`, `<sub>`, and `<sup>`
* Adds support for over 20 CSS attributes when using the `style` parameter.
* Fixes many many issues (see the list at [#122](https://github.com/Sub6Resources/flutter_html/pull/122))
* The following parameters of `Html` have been removed and should no longer be used (see the migration guide):
  * `useRichText`
  * `padding`
  * `backgroundColor`
  * `defaultTextStyle`
  * `renderNewlines`
  * `customEdgeInsets`
  * `customTextStyle`
  * `blockSpacing`
  * `customTextAlign`
  * `linkStyle`
  * `imageProperties`
  * `showImages`
* The default text style now matches the app's Material `TextTheme.bodyText2` (Fixes [#18](https://github.com/Sub6Resources/flutter_html/issues/18)).
* Requires Flutter v1.17.0 or greater
* Fixed quite a few issues with `img`
* Added a fancy new `style` attribute (this should be used in place of the deprecated styling parameters).

## [1.0.0-pre.1] - December 27, 2019

* For a list of pre-release changes, including several BREAKING CHANGES, see release notes for 1.0.0 above.

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
