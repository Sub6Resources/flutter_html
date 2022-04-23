# flutter_html_iframe

Iframe widget for flutter_html.

This package renders iframes using the [`webview_flutter`](https://pub.dev/packages/webview_flutter) plugin. 

When rendering iframes, the package considers the width, height, and sandbox attributes. 

Sandbox controls the JavaScript mode of the webview - a value of `null` or `allow-scripts` will set `javascriptMode: JavascriptMode.unrestricted`, otherwise it will set `javascriptMode: JavascriptMode.disabled`.

#### Registering the `CustomRender`:

```dart
Widget html = Html(
  customRenders: {
    iframeMatcher(): iframeRender(),
  }
);
```
You can set the `navigationDelegate` of the webview with the `navigationDelegate` property on `iframeRender`. This allows you to block or allow the loading of certain URLs.

#### `NavigationDelegate` example:

```dart
Widget html = Html(
  customRenders: {
    iframeMatcher(): iframeRender(navigationDelegate: (NavigationRequest request) {
      if (request.url.contains("google.com/images")) {
        return NavigationDecision.prevent;
      } else {
        return NavigationDecision.navigate;
      }
    }),
  }
);
```
