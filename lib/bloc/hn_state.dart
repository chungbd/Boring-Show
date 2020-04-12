part of 'hn_bloc.dart';

class HnState {
  final List<Article> articles;
  bool isLoading;
  
  HnState({
    this.articles = const [],
    this.isLoading = false,
  });

  HnState copyWith({
    List<Article> articles,
    bool isLoading,
  }) {
    return HnState(
      articles: articles ?? this.articles,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}