import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:hnapp/serializers.dart';

part 'json_parsing.g.dart';

abstract class Article implements Built<Article, ArticleBuilder> {
  int get id;

  @nullable
  String get by;

  int get descendants;

  @nullable
  BuiltList<int> get kids;

  int get score;

  int get time;

  String get title;

  String get type;

  String get url;

  Article._();
  factory Article([void Function(ArticleBuilder) updates]) = _$Article;

  static Serializer<Article> get serializer => _$articleSerializer;

  static Article fromJson(Map<String, dynamic> json) {
    return standardJsonPlugin.deserializeWith(serializer, json);
  }

  static Article fromJsonString(String jsonStr) {
    final json = jsonDecode(jsonStr);
    return fromJson(json);
  }
}