# flutter_html_widget

A Flutter widget for rendering basic html tags as Flutter widgets.

## Installing:

Add the following to your `pubspec.yaml` file:

    dependencies:
      flutter_html_widget: ^0.0.1

## Usage:

    HtmlWidget(
      data: yourHTMLString,
      // Optional parameters
      // padding: EdgeInsetsGeometry.all(8.0),
      // backgroundColor: Colors.blue,
    )

## Supported HTML Tags:

* `b`
* `body`
* `div`
* `i`
* `u`

Here are a list of elements that this package will never support: 

* `script`

## Why this package?

This package is designed with simplicity in mind. Flutter currently does not support rendering of web content
into the widget tree. This package is designed to be a reasonable alternative for rendering static web content
until official support is added.