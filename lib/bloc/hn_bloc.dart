import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:hnapp/json_parsing.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

part 'hn_event.dart';
part 'hn_state.dart';

class HnBloc extends Bloc<HnEvent, HnState> {
  List<int> _topIds = [
    22767843,
    22769263,
    22756053,
    22762173,
    22750850,
    22766681
  ];

  List<int> _newIds = [
    22748247,
    22768494,
    22758218,
    22774057,
    22754461,
    22764910,    
  ];

  HnBloc() {
    _updateArticles(_topIds)
    .then((val) {
      add(UpdatingArticleList(val));
    });
  }

  @override
  HnState get initialState => HnState();

  @override
  Stream<HnState> mapEventToState(
    HnEvent event,
  ) async* {
    if (event is UpdatingArticleList) {
      yield HnState(articles: event.articles);
    }
  }

  Future<Article> _getArticle(int id) async {
    final storyUrl = "https://hacker-news.firebaseio.com/v0/item/$id.json";
    final storyRes = await http.get(storyUrl);
    if (storyRes.statusCode == 200) {
      return Article.fromJsonString(storyRes.body);
    }
    return null;
  }

  Future<List<Article>> _updateArticles(List<int> ids) async {
    final futureArticles = ids.map((id) => _getArticle(id)).where((i) => i != null);
    final articles = await Future.wait(futureArticles);

    return articles;
  }

  updateNewArticle() {
    _updateArticles(_newIds)
    .then((val) {
      add(UpdatingArticleList(val));
    });    
  }

  updateTopArticle() {
    _updateArticles(_topIds)
    .then((val) {
      add(UpdatingArticleList(val));
    });    
  }

}
