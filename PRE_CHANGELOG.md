This changelog highlights changes as we work to implement version 1.0.0.


# [1.0.0-pre.1]
* BREAKING CHANGES (most of these are temporary):
  * `useRichText` now defaults to `false` (the new parser uses RichText, though)
  * `customRender` no longer does anything (just for now). 
  * `img` `alt` tags are no longer rendered.
  * `table` is no longer supported.
  * `sub` and `sup` are no longer correctly rendered.
* `HtmlParser` has been entirely rewritten. (It now uses `RichText` extensively)
* The following parameters of `Html` have been deprecated and should no longer be used:
  * `useRichText`
  * `padding`
  * `backgroundColor`
  * `defaultTextStyle`
  * `customEdgeInsets`
  * `customTextStyle`
  * `blockSpacing`
  * `linkStyle`
* The default text style now matches the app's Material `TextTheme.body1` (Fixes [#18](https://github.com/Sub6Resources/flutter_html/issues/18)).
* Fixed quite a few issues with `img`
* Added a fancy new `style` attribute (this should be used in place of the deprecated styling parameters).
* Added an even fancier new `css` attribute that takes a CSS string and applies those styles to your widgets.
 

