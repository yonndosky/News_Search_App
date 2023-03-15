import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'dart:developer' as developer;

Map<String, String> header = {
  'accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
  'accept-encoding': 'gzip, deflate, br',
  'accept-language': 'ja',
  'cache-control': 'max-age=0',
  'cookie': '_gid=GA1.2.654071847.1678787602; _hjFirstSeen=1; _hjSession_171201=eyJpZCI6Ijg0MDdlZjBiLTExNTMtNGM3Zi1hNTNhLWM3NTVhNTliMjc5NiIsImNyZWF0ZWQiOjE2Nzg3ODc2MDIzMzEsImluU2FtcGxlIjpmYWxzZX0=; _hjAbsoluteSessionInProgress=1; _fbp=fb.1.1678787608035.962282643; _hjSessionUser_171201=eyJpZCI6ImRlYTBmZjkzLTQ5MTEtNTBmZi05YTkwLWZkZDQxZjE3NjI1ZiIsImNyZWF0ZWQiOjE2Nzg3ODc2MDIzMjUsImV4aXN0aW5nIjp0cnVlfQ==; ab.storage.deviceId.5791d6db-4410-4ace-8814-12c903a548ba=%7B%22g%22%3A%22e6fb5e67-3d89-638b-84f5-582a0ee9756f%22%2C%22c%22%3A1678787646235%2C%22l%22%3A1678787646235%7D; locale=ja-JP; ab.storage.sessionId.5791d6db-4410-4ace-8814-12c903a548ba=%7B%22g%22%3A%22e380296c-8734-d306-5ceb-127089c044a4%22%2C%22e%22%3A1678789553271%2C%22c%22%3A1678787646234%2C%22l%22%3A1678787753271%7D; _sp_ses.9ec1=*; country-code=TW; _hjIncludedInSessionSample_171201=0; __cf_bm=NyT5d.ittIOAFgQFj7OvE.5WVlk4QXCVaK8IfqGVnxs-1678790087-0-AThZNIGSssH/TzcOqxxn4trDHuZlWbPz5t5kCY4MwCSv5Dlrq7rjMZEV5clIQj1JwCz3ZarTaLxL8oJ5FmsZs7meNKgwipGySd2v7tV8w45ZVzQ3+El5miJnEayXgbavOp9F/9rLWyHmLbsLDt7Of7Hqdwj81C1ZapBBKNtbx//w; _sp_id.9ec1=ef2a2386-1883-42d1-8850-76911e958644.1678787642.2.1678790136.1678788144.30b4cb50-f405-4002-aec1-dd0ce495fd34.37b78588-c1e5-4271-998f-1fb5c31eb4f2.ceccac3e-3559-40c9-80e7-21b5ae5a9640.1678790086180.2; OptanonConsent=isGpcEnabled=0&datestamp=Tue+Mar+14+2023+18%3A35%3A35+GMT%2B0800+(GMT%2B08%3A00)&version=202301.1.0&isIABGlobal=false&hosts=&landingPath=NotLandingPage&groups=C0001%3A1%2CC0002%3A1%2CC0003%3A1&AwaitingReconsent=false; _ga=GA1.1.223682300.1678787602; _ga_8JE65Q40S6=GS1.1.1678790086.2.1.1678790136.0.0.0',
  'sec-ch-ua': '"Google Chrome";v="111", "Not(A:Brand";v="8", "Chromium";v="111"',
  'sec-ch-ua-mobile': '?0',
  'sec-ch-ua-platform': '"Windows"',
  'sec-fetch-dest': 'document',
  'sec-fetch-mode': 'navigate',
  'sec-fetch-site': 'same-origin',
  'sec-fetch-user': '?1',
  'upgrade-insecure-requests': '1',
  'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Safari/537.36'
};

Future<String> requestData(String keyword) async {
  //https://news.google.com/search?q=K&hl=zh-TW&gl=TW&ceid=TW%3Azh-H
  Map<String,String> queryStringParameters =
  {
    'q':keyword,
    'hl':'zh-TW',
    'gl':'TW',
    'ceid':'TW%3Azh-H',
  };
  Uri url =Uri.https('news.google.com', '/search',queryStringParameters);
  http.Response response = await http.get(url, headers: header);
  developer.log(response.statusCode.toString());
  switch (response.statusCode) {
    case 200:
      return response.body;
    default:
      return '<html>error! status:${response.statusCode}</html>';
  }
}

Future<List<Map<String, dynamic>>> searchNews(String keyword) async{
  var html = await requestData(keyword);
  Document document = parse(html);

  String path = '#yDmH0d > c-wiz > div > div.FVeGwb.CVnAc.Haq2Hf.bWfURe > div.ajwQHc.BL5WZb.RELBvb > div > main > c-wiz > div.lBwEZb.BL5WZb.GndZbb > div > div > article > h3 >a';
  List<Element> images = document.querySelectorAll(path);
  List<Map<String,dynamic>> answer =[];

  if(images.isNotEmpty){
    answer = List.generate(images.length, (index){
      developer.log(images[index].text);
      return {
        'title':images[index].text,
        'href':images[index].attributes['href']
        };
    });
  }
  return answer;
}
