# flutter_matrix_html
[![pub package](https://img.shields.io/pub/v/flutter_matrix_html.svg)](https://pub.dev/packages/flutter_matrix_html)


A Flutter widget for rendering matrix-flavoured html tags as flutter widgets.

## Installing:

Add the following to your `pubspec.yaml` file:

    dependencies:
      flutter_matrix_html: ^1.0.0

## Currently Supported HTML Tags:
`b`, `strong`, `i`, `em`, `br`, `tt`, `code`, `ins`, `u`, `sub`, `sup`, `del`, `s`, `strike`, `span`, `font`, `a`, `img`, `table`, `thead`, `tbody`, `tfoot`, `th`, `td`, `caption`, `ul`, `ol`, `li`, `div`, `p`, `h1`, `h2`, `h3`, `h4`, `h5`, `h6`, `pre`, `blockquote`, `hr`, `details`, `summary`

Additionally:
 - `mx-reply` is stripped
 - Spoilers (including reason)
 - Inline and Block LaTeX
 - Pills for `a` tags starting with `https://matrix.to/#/` *and* the `matrix:` URI
 - Various ways of setting the text colour and background colour are supported

## Example Usage:

    Html(
      data: """
        <!--For a much more extensive example, look at example/main.dart-->
        <div>
          <h1>Demo Page</h1>
          <p>This is a fantastic nonexistent product that you should buy!</p>
          <h2>Pricing</h2>
          <p>Lorem ipsum <b>dolor</b> sit amet.</p>
          <h2>The Team</h2>
          <p>There isn't <i>really</i> a team...</p>
          <h2>Installation</h2>
          <p>You <u>cannot</u> install a nonexistent product!</p>
          <!--You can pretty much put any html in here!-->
        </div>
      """,
      //Optional parameters:
      padding: EdgeInsets.all(8.0),
      backgroundColor: Colors.white70,
      defaultTextStyle: TextStyle(fontFamily: 'serif'),
      linkStyle: const TextStyle(
        color: Colors.redAccent,
      ),
      onLinkTap: (url) {
        // open url in a webview
      },
      onImageTap: (src) {
        // Display the image in large form.
      },
    )
