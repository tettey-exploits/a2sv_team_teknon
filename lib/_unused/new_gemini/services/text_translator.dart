import 'dart:convert';
import 'package:http/http.dart' as http;

class TextTranslator{
  static const BASE_URL = 'https://translation-api.ghananlp.org/v1/translate';
  final String apiKey;

  TextTranslator(this.apiKey);

  Future<String> translateText(String text, {String? targetLanguage}) async {
    final http.Response response;
    if (targetLanguage == "English") {
      response = await http.post(
          Uri.parse(BASE_URL),
          headers: {"Content-Type": "application/json",
            "Cache-Control": "no-cache",
            "Ocp-Apim-Subscription-Key": apiKey
          },
          body: jsonEncode({
            "in": text,
            "lang": "tw-en"
          })
      );
    } else {
      response = await http.post(
          Uri.parse(BASE_URL),
          headers: {"Content-Type": "application/json",
            "Cache-Control": "no-cache",
            "Ocp-Apim-Subscription-Key": apiKey
          },
          body: jsonEncode({
            "in": text,
            "lang": "en-tw"
          })
      );
    }


    if(response.statusCode == 200){
      return jsonDecode(response.body);
    } else {
      return response.statusCode.toString();
    }
  }
}