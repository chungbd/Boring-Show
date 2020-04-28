part of 'hn_bloc.dart';

enum StoriesType {
  topStories,
  newStories,  
}

class HnState {
  final List<Article> articles;
  bool isLoading;
  StoriesType storiesType;
  
  HnState({
    this.articles = const [],
    this.isLoading = false,
    this.storiesType = StoriesType.topStories,
  });

  HnState copyWith({
    List<Article> articles,
    bool isLoading,
    StoriesType storiesType,
  }) {
    return HnState(
      articles: articles ?? this.articles,
      isLoading: isLoading ?? this.isLoading,
      storiesType: storiesType ?? this.storiesType,
    );
  }
}
