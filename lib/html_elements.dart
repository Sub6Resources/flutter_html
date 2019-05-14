export 'styled_element.dart';
export 'interactable_element.dart';
export 'block_element.dart';
export 'content_element.dart';

const STYLED_ELEMENTS = [
  "abbr",
  "acronym",
  "address",
  "b",
  "i",
  "span",
  "u",
];

const INTERACTABLE_ELEMENTS = [
  "a",
];

const BLOCK_ELEMENTS = [
  "body",
  "div",
  "footer",
  "h1",
  "h2",
  "h3",
  "h4",
  "h5",
  "h6",
  "header",
  "html",
  "li",
  "ol",
  "p",
  "ul",
];

const CONTENT_ELEMENTS = [
  "head",
  "img",
];

enum ElementType {
  CONTENT,
  STYLED,
  BLOCK,
  INTERACTABLE,
}

/**
  Here is a list of elements which are not currently supported (but have planned support):
    a         - i [x]
    abbr      - s [x]
    acronym   - s [x]
    address   - s [ ]
    audio     - c [ ]
    article   - b [ ]
    aside     - b [ ]
    b         - s [x]
    bdi       - s [ ]
    bdo       - s [ ]
    big       - s [ ]
    blockquote- b [ ]
    body      - b [x]
    br        - b [ ]
    caption   - b [ ]
    center    - b [ ]
    cite      - s [ ]
    code      - s [ ]
    data      - s [ ]
    dd        - c [ ]
    del       - s [ ]
    details   - b [ ]
    dfn       - s [ ]
    div       - b [x]
    dl        -   [ ]
    dt        -   [ ]
    em        -   [ ]
    figcaption-   [ ]
    figure    -   [ ]
    font      -   [ ]
    footer    - b [x]
    h1        - b [x]
    h2        - b [x]
    h3        - b [x]
    h4        - b [x]
    h5        - b [x]
    h6        - b [x]
    header    - b [x]
    hr        - c?[ ]
    html      - b [x]
    i         - s [x]
    img       - c [x]
    ins       - s [ ]
    kbd       -   [ ]
    li        - b [x]
    main      -   [ ]
    mark      -   [ ]
    nav       -   [ ]
    noscript  - b [ ]
    ol        - b [x]
    p         - b [x]
    pre       - s [ ]
    q         -   [ ]
    rp        -   [ ]
    rt        -   [ ]
    ruby      -   [ ]
    s         -   [ ]
    samp      -   [ ]
    section   -   [ ]
    small     - s [ ]
    source    -   [ ]
    span      - s [x]
    strike    - s [ ]
    strong    - s [ ]
    sub       - s [ ]
    summary   - b [ ]
    sup       - s [ ]
    svg       - c [ ]
    table     - b [ ]
    tbody     - b [ ]
    td        -   [ ]
    template  -   [ ]
    tfoot     - b [ ]
    th        -   [ ]
    thead     - b [ ]
    time      -   [ ]
    tr        - b [ ]
    track     -   [ ]
    tt        -   [ ]
    u         - s [x]
    ul        - b [x]
    var       -   [ ]
    video     - c [ ]
    wbr       -   [ ]
 */