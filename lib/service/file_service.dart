import 'dart:convert';

import 'package:http/http.dart' as http;

class FileService {
  static Future<Map<String, List<String>>> getValidOutputFormatsOf(String InputFormat) async {
    Map<String, List<String>> validOutputFormats = {};
    try {
      String apiUrl =
          "https://api.cloudconvert.com/v2/convert/formats?filter[input_format]=$InputFormat";

      var res = await http.get(Uri.parse(apiUrl));
      if (res.statusCode == 200) {
        var resBody = jsonDecode(res.body);
        for (var map in resBody["data"]) {
          String group = map["meta"]["group"];
          validOutputFormats
              .putIfAbsent(group, () => [])
              .add(map["output_format"]);
        }
        return validOutputFormats;
      } else {
        print(res.statusCode);
        return validOutputFormats;
      }
    } catch (e) {
      print('Exception occurred: $e');
      return validOutputFormats;
    }
  }
}
