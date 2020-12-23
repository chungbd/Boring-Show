part of 'hn_bloc.dart';

enum StoriesType {
  topStories,
  newStories,
}

class HnState {
  final List<Article> topArticles;
  final List<Article> newArticles;
  bool isLoading;
  StoriesType storiesType;

  HnState({
    this.topArticles = const [],
    this.newArticles = const [],
    this.isLoading = false,
    this.storiesType = StoriesType.topStories,
  });

  HnState copyWith({
    List<Article> topArticles,
    List<Article> newArticles,
    bool isLoading,
    StoriesType storiesType,
  }) {
    return HnState(
      topArticles: topArticles ?? this.topArticles,
      newArticles: newArticles ?? this.newArticles,
      isLoading: isLoading ?? this.isLoading,
      storiesType: storiesType ?? this.storiesType,
    );
  }
}
