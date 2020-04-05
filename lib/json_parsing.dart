import 'package:built_value/built_value.dart';

part 'json_parsing.g.dart';

abstract class Article implements Built<Article, ArticleBuilder> {
  int get id;

  Article._();
  factory Article([void Function(ArticleBuilder) updates]) = _$Article;
}