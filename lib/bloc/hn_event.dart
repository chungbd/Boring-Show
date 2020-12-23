part of 'hn_bloc.dart';

@immutable
abstract class HnEvent {}

class UpdatingTopArticleList extends HnEvent {
  final List<Article> articles;
  UpdatingTopArticleList({
    this.articles,
  });
}

class UpdatingNewArticleList extends HnEvent {
  final List<Article> articles;
  UpdatingNewArticleList({
    this.articles,
  });
}

class UpdatingLoadingState extends HnEvent {
  final bool isLoading;
  UpdatingLoadingState({
    this.isLoading,
  });
}

class UpdatingStoriesType extends HnEvent {
  final StoriesType storiesType;
  UpdatingStoriesType({
    this.storiesType,
  });
}
