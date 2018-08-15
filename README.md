# flutter_html

A Flutter widget for rendering static html tags as Flutter widgets.

## Installing:

Add the following to your `pubspec.yaml` file:

    dependencies:
      flutter_html: ^0.1.1

## Currently Supported HTML Tags:

 * `b`
 * `body`
 * `div`
 * `em`
 * `h1` - `h6`
 * `i`
 * `p`
 * `strong`
 * `u`

Here are a list of elements that this package will never support: 

 * `script`
 * `iframe`
 
> Note: Unsupported tags will not be rendered

## Why this package?

This package is designed with simplicity in mind. Flutter currently does not support rendering of web content
into the widget tree. This package is designed to be a reasonable alternative for rendering static web content
until official support is added.

## Example Usage:

    Html(
      data: """
        <div>
          <h1>Demo Page</h1>
          <p>This is a fantastic nonexistent product that you should buy!</p>
          <h2>Pricing</h2>
          <p>Lorem ipsum <b>dolor</b> sit amet.</p>
          <h2>The Team</h2>
          <p>There isn't <i>really</i> a team...</p>
          <h2>Installation</h2>
          <p>You <u>cannot</u> install a nonexistent product!</p>
        </div>
      """,
      //Optional parameters:
      padding: EdgeInsets.all(8.0),
      backgroundColor: Colors.white70,
      defaultTextStyle: TextStyle(color: Colors.black),
    )