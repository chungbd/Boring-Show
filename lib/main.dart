import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:hnapp/bloc/hn_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'json_parsing.dart';

void main() {
  var blocProvider = BlocProvider(
    create: (context) => HnBloc(HnState()),
    child: MyApp(),
  );
  runApp(blocProvider);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  List<Article> _articles = [];

  @override
  void initState() {
    super.initState();
    _updateStoriesAtIndex(_selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        elevation: 0.0,
        leading: LoadingWidget(),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              var result =
                  await showSearch(context: context, delegate: ArticleSearch());
              if (result != null) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HackerNewWebPage(
                              url: result.url,
                            )));
              }
            },
          )
        ],
      ),
      body: RefreshIndicator(
        child: BlocBuilder<HnBloc, HnState>(
          builder: (context, state) {
            return ListView(
              children: state.articles.map((i) => _buildItem(i)).toList(),
            );
          },
        ),
        onRefresh: () async {
          await Future.delayed(Duration(seconds: 1));
          setState(() {
            _articles.removeAt(0);
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            label: 'Top Stories',
            icon: Icon(Icons.arrow_drop_up),
          ),
          BottomNavigationBarItem(
            label: 'New Stories',
            icon: Icon(Icons.new_releases),
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    _updateStoriesAtIndex(index);
  }

  _updateStoriesAtIndex(int index) {
    // ignore: close_sinks
    final bloc = BlocProvider.of<HnBloc>(context);

    if (index == 0) {
      bloc.add(UpdatingStoriesType(storiesType: StoriesType.topStories));
    } else {
      bloc.add(UpdatingStoriesType(storiesType: StoriesType.newStories));
    }
  }

  Widget _buildItem(Article article) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ExpansionTile(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text("${article.descendants} comments"),
              IconButton(
                  icon: Icon(Icons.launch),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HackerNewWebPage(
                                  url: article.url,
                                )));
                  })
            ],
          ),
          Container(
            height: 200,
            child: WebView(
              initialUrl: article.url,
              javascriptMode: JavascriptMode.unrestricted,
              gestureRecognizers: Set()
                ..add(Factory<VerticalDragGestureRecognizer>(
                    () => VerticalDragGestureRecognizer())),
            ),
          )
        ],
        title: Text(
          article.title,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

class LoadingWidget extends StatefulWidget {
  const LoadingWidget({
    Key key,
  }) : super(key: key);

  @override
  _LoadingWidgetState createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HnBloc, HnState>(
      builder: (context, state) {
        // if (state.isLoading) {
        _controller.forward().then((f) {
          _controller.reverse();
        });
        // _controller.reverse();
        return FadeTransition(
          child: Icon(FontAwesomeIcons.hackerNews),
          opacity: Tween(begin: 0.5, end: 1.0).animate(
              CurvedAnimation(curve: Curves.easeIn, parent: _controller)),
        );
        // }
        // return Container();
      },
    );
  }
}

class ArticleSearch extends SearchDelegate<Article> {
  final List<Article> articles;
  ArticleSearch({
    this.articles,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return BlocBuilder<HnBloc, HnState>(
      builder: (context, state) {
        final results = state.articles.where((element) {
          return element.title.toLowerCase().contains(query);
        });

        return ListView(
          children: results
              .map<Widget>((e) => ListTile(
                    title: Text(e.title),
                    leading: Icon(Icons.book),
                    onTap: () {
                      close(context, e);
                    },
                  ))
              .toList(),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return BlocBuilder<HnBloc, HnState>(
      builder: (context, state) {
        final results = state.articles.where((element) {
          return element.title.toLowerCase().contains(query);
        });

        return ListView(
          children: results
              .map<Widget>((e) => ListTile(
                    title: Text(e.title),
                    leading: Icon(Icons.book),
                    onTap: () {
                      query = e.title;
                    },
                  ))
              .toList(),
        );
      },
    );
  }
}

class HackerNewWebPage extends StatelessWidget {
  const HackerNewWebPage({Key key, this.url}) : super(key: key);

  final String url;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Web Page"),
      ),
      body: WebView(
        initialUrl: url,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
