part of 'hn_bloc.dart';

@immutable
abstract class HnEvent {}

class UpdatingArticleList extends HnEvent {
  final List<Article> articles;
  UpdatingArticleList(this.articles);
}