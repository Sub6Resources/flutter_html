import 'package:flutter_html/image_render.dart';
import 'package:flutter_html/src/utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Parse Giphy Url", () {

    test("Get Id from url", () {
      expect(_match('https://giphy.com/gifs/animated-twitter-lovethisgif-3MnkJJZjwOzja', '3MnkJJZjwOzja'), isTrue);
    });

    test("Get Id from embed url", () {
      expect(_match('https://giphy.com/embed/3MnkJJZjwOzja', '3MnkJJZjwOzja'), isTrue);
    });

    test("Get Id from media url", () {
      expect(_match('https://media0.giphy.com/media/3MnkJJZjwOzja/giphy.mp4?cid=ecf05e47myaow4rvrb8utdg2z6p2yy0qa4pe62loemhy3r0d&rid=giphy.mp4&ct=g', '3MnkJJZjwOzja'), isTrue);
    });

  });
}

_match(String url, String id) {
  return GiphyUtils.getId(url) == id;
}
