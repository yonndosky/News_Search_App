import 'package:flutter/material.dart';
import 'package:news_search_app/search_factory.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main(List<String> args) => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SearchPhoto(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SearchPhoto extends StatefulWidget {
  const SearchPhoto({super.key});

  @override
  State<SearchPhoto> createState() => _SearchPhotoState();
}

class _SearchPhotoState extends State<SearchPhoto> {
  String introduction = '''
    應用程式使用流程:
      1.輸入關鍵字
      2.透過爬蟲抓取資訊(google新聞)
      3.回傳資料
      4.點擊有興趣的新聞
      5.在應用程式內嵌入該網站內容
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用關鍵字查詢新聞'),
        actions: [
          IconButton(
            onPressed: () async {
              showSearch(context: context, delegate: CustomSearchDelegate());
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Center(
        child: Text(
          introduction,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  List<String> searchTerms = ['財經', '體育', '教育', '國際', '商業', '娛樂', '科技'];
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () => close(context, null),
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> macthQuery = [];
    for (String keyword in searchTerms) {
      bool isInSearchTerms =
          keyword.toLowerCase().contains(query.toLowerCase());
      if (isInSearchTerms) {
        macthQuery.add(keyword);
      }
    }
    return ListView.builder(
      itemCount: macthQuery.length,
      itemBuilder: (context, index) {
        String result = macthQuery[index];
        return ListTile(
          title: Text(result),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultPage(keyword: result),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> macthQuery = [];
    for (String keyword in searchTerms) {
      bool isInSearchTerms =
          keyword.toLowerCase().contains(query.toLowerCase());
      if (isInSearchTerms) {
        macthQuery.add(keyword);
      }
    }
    return ListView.builder(
      itemCount: macthQuery.length,
      itemBuilder: (context, index) {
        String result = macthQuery[index];
        return ListTile(
          title: Text(result),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultPage(keyword: result),
            ),
          ),
        );
      },
    );
  }
}

class ResultPage extends StatefulWidget {
  const ResultPage({super.key, required this.keyword});

  final String keyword;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('關鍵字:${widget.keyword}')),
      body: FutureBuilder(
        future: searchNews(widget.keyword),
        builder: (context, snapshot) {
          Widget build = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SizedBox(
                    width: 75, height: 75, child: CircularProgressIndicator()),
                SizedBox(height: 50),
                Text('尋找中...', style: TextStyle(fontSize: 20))
              ],
            ),
          );
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              List<Map<String, dynamic>> data =
                  snapshot.data as List<Map<String, dynamic>>;
              build = ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('${data[index]['title']}'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewContent(
                          title: data[index]['title'],
                          url: data[index]['href'],
                        ),
                      ),
                    ),
                  );
                },
              );
              break;
            default:
          }
          return build;
        },
      ),
    );
  }
}

class NewContent extends StatefulWidget {
  const NewContent({super.key, required this.url, required this.title});
  final String url, title;

  @override
  State<NewContent> createState() => _NewContentState();
}

class _NewContentState extends State<NewContent> {
  late WebViewController controller;
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://news.google.com/${widget.url}'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: WebViewWidget(controller: controller),
    );
  }
}
