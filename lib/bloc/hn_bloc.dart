import 'dart:async';
import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import 'package:hnapp/json_parsing.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'hn_event.dart';
part 'hn_state.dart';

class HnBloc extends Bloc<HnEvent, HnState> {
  HashMap<int, Article> _cachedArticles = HashMap<int, Article>();

  HnBloc(HnState initialState) : super(initialState);

  // @override
  // HnState get initialState => HnState();

  @override
  Stream<HnState> mapEventToState(
    HnEvent event,
  ) async* {
    if (event is UpdatingTopArticleList) {
      yield state.copyWith(topArticles: event.articles);
    }

    if (event is UpdatingNewArticleList) {
      yield state.copyWith(newArticles: event.articles);
    }

    if (event is UpdatingLoadingState) {
      yield state.copyWith(isLoading: event.isLoading);
    }

    if (event is UpdatingStoriesType) {
      if (event.storiesType == StoriesType.newStories) {
        updateNewArticle();
      }
      if (event.storiesType == StoriesType.topStories) {
        updateTopArticle();
      }

      yield state.copyWith(storiesType: event.storiesType);
    }
  }

  Future<Article> _getArticle(int id) async {
    if (!_cachedArticles.containsKey(id)) {
      final storyUrl = "https://hacker-news.firebaseio.com/v0/item/$id.json";
      final storyRes = await http.get(storyUrl);
      if (storyRes.statusCode != 200) {
        throw HackerNewsApiError(message: "Article $id couldn't be fetched");
      }
      _cachedArticles[id] = Article.fromJsonString(storyRes.body);
    }

    return _cachedArticles[id];
  }

  Future<List<Article>> _updateArticles(List<int> ids) async {
    final futureArticles =
        ids.map((id) => _getArticle(id)).where((i) => i != null);
    final articles = await Future.wait(futureArticles);

    return articles;
  }

  Future<List<int>> _getIds(StoriesType storiesType) async {
    final partURL = storiesType == StoriesType.newStories ? "new" : "top";
    final storyUrl =
        "https://hacker-news.firebaseio.com/v0/${partURL}stories.json";
    final storyRes = await http.get(storyUrl);
    if (storyRes.statusCode != 200) {
      throw HackerNewsApiError(message: "$storiesType couldn't be fetched");
    }
    return parseStoryIds(storyRes.body).take(10).toList();
  }

  updateNewArticle() async {
    add(UpdatingLoadingState(isLoading: true));

    _updateArticles(await _getIds(StoriesType.newStories)).then((val) {
      add(UpdatingLoadingState(isLoading: false));
      add(UpdatingNewArticleList(articles: val));
    });
  }

  updateTopArticle() async {
    add(UpdatingLoadingState(isLoading: true));
    _updateArticles(await _getIds(StoriesType.topStories)).then((val) {
      add(UpdatingLoadingState(isLoading: false));
      add(UpdatingTopArticleList(articles: val));
    });
  }
}

class HackerNewsApiError extends Error {
  final String message;
  HackerNewsApiError({
    this.message,
  });
}

class PrefsState {
  final bool showWebView;
  const PrefsState(this.showWebView);
}

class PrefsBloc {
  static const showWebViewKey = "showWebView";

  final _currentPrefs = BehaviorSubject.seeded(PrefsState(false));
  final _showWebViewPref = StreamController<bool>();

  PrefsBloc() {
    _loadSharedPrefs();
    _showWebViewPref.stream.listen((event) {
      _saveNewPrefs(PrefsState(event));
    });
  }

  Stream<PrefsState> get currentPrefs => _currentPrefs.stream;
  Sink<bool> get showWebViewPref => _showWebViewPref.sink;

  void close() {
    _showWebViewPref.close();
    _currentPrefs.close();
  }

  Future<void> _loadSharedPrefs() async {
    Future.delayed(Duration(seconds: 1), () async {
      final sharedPrefs = await SharedPreferences.getInstance();
      final showWebView = sharedPrefs.getBool(showWebViewKey) ?? true;
      _currentPrefs.add(PrefsState(showWebView));
    });
  }

  Future<void> _saveNewPrefs(PrefsState newState) async {
    final sharedPrefs = await SharedPreferences.getInstance();
    await sharedPrefs.setBool(showWebViewKey, newState.showWebView);
    _currentPrefs.add(newState);
  }
}
