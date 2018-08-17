# flutter_html

A Flutter widget for rendering static html tags as Flutter widgets. (Will render over 60 different html tags!)

## Installing:

Add the following to your `pubspec.yaml` file:

    dependencies:
      flutter_html: ^0.4.1

## Currently Supported HTML Tags:

 * `abbr`
 * `address`
 * `article`
 * `aside`
 * `b`
 * `blockquote`
 * `body`
 * `br`
 * `caption`
 * `cite`
 * `code`
 * `data`
 * `dd`
 * `del`
 * `dfn`
 * `div`
 * `dl`
 * `dt`
 * `em`
 * `figcaption`
 * `figure`
 * `footer`
 * `h1`
 * `h2`
 * `h3`
 * `h4`
 * `h5`
 * `h6`
 * `header`
 * `hr`
 * `i`
 * `img`
 * `ins`
 * `kbd`
 * `li`
 * `main`
 * `mark`
 * `nav`
 * `noscript`
 * `p`
 * `pre`
 * `q`
 * `rp`
 * `rt`
 * `ruby`
 * `s`
 * `samp`
 * `section`
 * `small`
 * `span`
 * `strong`
 * `table`
 * `tbody`
 * `td`
 * `template`
 * `tfoot`
 * `th`
 * `thead`
 * `time`
 * `tr`
 * `u`
 * `var`
 
### Partially supported elements:
> These are common elements that aren't yet fully supported, but won't be ignored and will still render.

 * `a`
 * `ol` 
 * `ul`
 
### List of _planned_ supported elements:
> These are elements that are planned, but present a specific challenge that makes them somewhat difficult to implement.

 * `audio`
 * `bdi`
 * `bdo`
 * `details`
 * `source`
 * `sub`
 * `summary`
 * `sup`
 * `svg`
 * `track`
 * `video`
 * `wbr`

### Here are a list of elements that I don't plan on implementing:

> Feel free to open an issue if you have a good reason and feel like you can convince me to implement
 them. A _well written_ and _complete_ pull request implementing one of these is always welcome,
 though I cannot promise I will merge them.

> Note: These unsupported tags will just be ignored.

 * `acronym` (deprecated, use `abbr` instead)
 * `applet` (deprecated)
 * `area`
 * `base` (`head` elements are not rendered)
 * `basefont` (deprecated, use defaultTextStyle on `Html` widget instead)
 * `big` (deprecated)
 * `button`
 * `canvas`
 * `col`
 * `colgroup`
 * `datalist`
 * `dialog`
 * `dir` (deprecated)
 * `embed`
 * `font` (deprecated)
 * `fieldset` (`form` elements are outside the scope of this package)
 * `form` (`form`s are outside the scope of this package)
 * `frame` (deprecated)
 * `frameset` (deprecated)
 * `head` (`head` elements are not rendered)
 * `iframe`
 * `input` (`form` elements are outside the scope of this package)
 * `label` (`form` elements are outside the scope of this package)
 * `legend` (`form` elements are outside the scope of this package)
 * `link` (`head` elements are not rendered)
 * `map`
 * `meta` (`head` elements are not rendered)
 * `meter` (outside the scope for now; maybe later)
 * `noframe` (deprecated)
 * `object`
 * `optgroup` (`form` elements are outside the scope of this package)
 * `option` (`form` elements are outside the scope of this package)
 * `output`
 * `param`
 * `picture`
 * `progress`
 * `script`
 * `select` (`form` elements are outside the scope of this package)
 * `strike` (deprecated)
 * `style`
 * `textarea` (`form` elements are outside the scope of this package)
 * `title` (`head` elements are not rendered)
 * `tt` (deprecated)
 

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
      onLinkTap: (url) {
        // open url in a webview
      }
    )