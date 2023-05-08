export 'tree/styled_element.dart';
export 'tree/interactable_element.dart';
export 'tree/replaced_element.dart';

//TODO remove
class HtmlElements {
  static const styledElements = [
    "abbr",
    "acronym",
    "address",
    "b",
    "bdi",
    "bdo",
    "big",
    "cite",
    "code",
    "data",
    "del",
    "dfn",
    "em",
    "font",
    "i",
    "ins",
    "kbd",
    "mark",
    "q",
    "rt",
    "s",
    "samp",
    "small",
    "span",
    "strike",
    "strong",
    "sub",
    "sup",
    "time",
    "tt",
    "u",
    "var",
    "wbr",

    //BLOCK ELEMENTS
    "article",
    "aside",
    "blockquote",
    "body",
    "center",
    "dd",
    "div",
    "dl",
    "dt",
    "figcaption",
    "figure",
    "footer",
    "h1",
    "h2",
    "h3",
    "h4",
    "h5",
    "h6",
    "header",
    "hr",
    "html",
    "li",
    "main",
    "nav",
    "noscript",
    "ol",
    "p",
    "pre",
    "section",
    "summary",
    "ul",
  ];

  static const blockElements = [
    "article",
    "aside",
    "blockquote",
    "body",
    "center",
    "dd",
    "div",
    "dl",
    "dt",
    "figcaption",
    "figure",
    "footer",
    "h1",
    "h2",
    "h3",
    "h4",
    "h5",
    "h6",
    "header",
    "hr",
    "html",
    "li",
    "main",
    "nav",
    "noscript",
    "ol",
    "p",
    "pre",
    "section",
    "summary",
    "ul",
  ];

  static const interactableElements = [
    "a",
  ];

  static const replacedElements = [
    "br",
    "template",
    "rp",
    "rt",
    "ruby",
  ];

  static const layoutElements = [
    "details",
  ];

  static const externalElements = [
    "audio",
    "iframe",
    "img",
    "math",
    "svg",
    "table",
    "video"
  ];

  static const replacedExternalElements = ["iframe", "img", "video", "audio"];
}
