import 'package:flutter/material.dart';
import 'json_parsing.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

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
  List<Article> _articles = [];
//  List<Article> _getArticles = [];

  List<int> _ids = [
    22748247,
    22768494,
    22758218,
    22774057,
    22754461,
    22764910,
    22767843,
    22769263,
    22756053,
    22762173,
    22750850,
    22766681
  ];

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
      ),
      body: RefreshIndicator(
        child: ListView(
          children: _ids.map((i) =>
            FutureBuilder<Article>(
              future: _getArticle(i),
              builder: (BuildContext context, AsyncSnapshot<Article> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return _buildItem(snapshot.data);
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator(),),
                  );
                }
              },
            )
          ).toList(),
        ),
        onRefresh: () async {
          await Future.delayed(Duration(seconds: 1));
          setState(() {
            _articles.removeAt(0);
          });

        },
      ),

//      floatingActionButton: FloatingActionButton(
//        onPressed: _incrementCounter,
//        tooltip: 'Increment',
//        child: Icon(Icons.add),
//      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<Article> _getArticle(int id) async {
    final storyUrl = "https://hacker-news.firebaseio.com/v0/item/${id}.json";
    final storyRes = await http.get(storyUrl);
    if (storyRes.statusCode == 200) {
      return Article.fromJsonString(storyRes.body);
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
                Text("${article.kids.length} comments"),
                IconButton(icon: Icon(Icons.launch), onPressed: () {

                })
              ],
            )
          ],
        title: Text(article.title, style: TextStyle(fontSize: 20),),
      ),
    );
  }
}
