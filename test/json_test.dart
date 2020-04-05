import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hnapp/json_parsing.dart';
import 'package:http/http.dart' as http;


void main () {
  test("parses topstories.json", () {
    
  });

  test("parses item.json over a network", () async {
    final url = "https://hacker-news.firebaseio.com/v0/beststories.json";
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final idList = jsonDecode(response.body);
      if (idList.isNotEmpty) {
        final storyUrl = "https://hacker-news.firebaseio.com/v0/item/${idList[0]}.json";
        final storyRes = await http.get(storyUrl);
        if (storyRes.statusCode == 200) {
          expect(Article.fromJsonString(storyRes.body).type, "story");
        }

      }
    }

  });
}
