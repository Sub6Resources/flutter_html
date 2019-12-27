This changelog highlights changes as we work to implement version 1.0.0.


# [1.0.0-pre.1]
* BREAKING CHANGES (see the [Migration Guide](https://github.com/Sub6Resources/flutter_html/wiki/1.0.0-Migration-Guide) for a full overview of breaking changes.):
  * The default parser has been completely rewritten and the RichText parser has been deprecated.
  * `useRichText` now defaults to `false` (the new parser uses RichText, though)
  * `customRender` now works for the default parser.
* Adds support for `<audio>`, `<video>`, `<iframe>`, `<svg>`, `<ruby>`, `<rt>`, `<rp>`, `<sub>`, and `<sup>`
* Adds support for over 20 CSS attributes.
* Fixes 22 issues (see the list at [#122](https://github.com/Sub6Resources/flutter_html/pull/122))
* The following parameters of `Html` have been deprecated and should no longer be used:
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
* The default text style now matches the app's Material `TextTheme.body1` (Fixes [#18](https://github.com/Sub6Resources/flutter_html/issues/18)).
* Fixed quite a few issues with `img`
* Added a fancy new `style` attribute (this should be used in place of the deprecated styling parameters).
 

