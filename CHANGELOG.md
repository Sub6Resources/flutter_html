## [1.0.2] - 27th Aug 2021
- Fix list overflow

## [1.0.1] - 22nd Aug 2021
- Bring back the (rough) `maxLines` property

## [1.0.0] - 22nd Aug 2021
- Complete re-write of the html renderer
- Null safety
- Addition of `details` and `summary` tags

## [0.3.1] - 8th Aug 2021
- Fix link colour in inline code blocks
- Fix long code blocks causing language autodetection to take long

## [0.3.0] - 11th Apr 2021
- Update matrix: URI schemes
- Fix small rendering bug with flutter 2
- Update dependencies

## [0.2.0] - 10th Jan 2021
- Add support for matrix: URI scheme
- Add support for `animated` URL parameter of mxc URLs
- Add borders to tables
- Make code blocks smaller if maxLines=1

## [0.1.14] - 16th Dec 2020:
- Fix assuming css color names are lowercase
- Fix too much whitespace between table and tr tags causing issues
- Properly handle links inside of `<code>` blocks

## [0.1.13] - 20th Nov 2020:
- Switch latex rendering to flutter_math

## [0.1.12] - 20th Nov 2020:
- Fix Latex widget crashing sometimes

## [0.1.11] - 16th Nov 2020:
- Fix empty code blocks

## [0.1.10] - 28th Oct 2020:
- Code blocks displayed more nicely
- Inline code also displayed more nicely

## [0.1.9] - 21st Oct 2020:
- Fix fubar

## [0.1.8] - 21st Oct 2020:
- Support data-mx-maths using CaTeX rendering
- Remove desktop fallback as cached_network_image has support for that by now

## [0.1.7] - 4th Oct 2020:
- Fix a fubar

## [0.1.6] - 4th Oct 2020:
- Support CSS colour names, e.g. `red`
- Support images on desktop

## [0.1.5] - 20th Sept 2020:
- Don't allow propagation of onTap inot spoilers, if they are hidden
- Add emoteSize property, to be able to set your own emote size

## [0.1.4] - 5th Sept 2020:
- Use matrix_link_text to properly determine links

## [0.1.3] - 4th Sept 2020:
- Use `Text.rich` instead of `RichText`
- Use `CachedNetworkImage` instead of `AdvancedNetworkImage`
- Fix lists sometimes rendering incorrectly

## [0.1.2] - 14th July 2020:
- Fix some tags incorrectly linebreaking

## [0.1.1] - 26th June 2020:
- Fixes of span tags at the start causing unwanted linebreaks
- Fixes with images not always loading properly
