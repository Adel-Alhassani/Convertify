import 'dart:async';
import 'dart:convert';
import 'dart:io';
// import 'dart:io';
import 'package:convertify/view/widget/dialog/custome_dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
// import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:http/http.dart' as http;
// import 'package:socket_io_client/socket_io_client.dart' as IO;

class FileService {
  final String? apiKey = dotenv.env["API_KEY"];
  late String _downloadUrl;

  Future<Map<String, List<String>>> getValidOutputFormatsOf(
      String inputFormat) async {
    Map<String, List<String>> validOutputFormats = {};
    try {
      String apiUrl =
          "https://api.cloudconvert.com/v2/convert/formats?filter[input_format]=$inputFormat";

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
      print('Exception occurred while getting valid output formats: $e');
      CustomeDialog.showConfirmDialog(
          "error".tr, "get_valid_output_formats_error".tr, "ok".tr, () {
        Get.back();
      });
      return validOutputFormats;
    }
  }

  Future<bool> convert(
    String filePath,
    String inputFormat,
    String outputFormat,
  ) async {
    _downloadUrl = await _getFileDownloadUrlFromAPI(
        "e25e8cb0-20cb-40ca-a5ca-6559257e7f0a");
    return true;
    // API endpoint for creating a job
    try {
      final String url = 'https://api.cloudconvert.com/v2/jobs';
      //    DateTime now = DateTime.now();
      // String date =
      //     "${now.year}${now.month}${now.day}${now.hour}${now.minute}${now.second}${now.millisecond}";

      // Define the headers including your API key
      final headers = {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json'
      };

      // Step 1: Create a job with an import/upload task and a convert task
      var jobBody = jsonEncode({
        "tasks": {
          'import-a2': {
            'operation': "import/upload",
          },
          "convert-a2": {
            "operation": "convert",
            "input": "import-a2",
            "input_format": inputFormat,
            "output_format": outputFormat,
            // "filename" : "Convertify_$date.$outputFormat",
          },
          "export-a2": {
            "operation": "export/url",
            "input": "convert-a2",
          }
        }
      });

      var response =
          await http.post(Uri.parse(url), headers: headers, body: jobBody);
      print(response.statusCode);
      if (response.statusCode == 201) {
        print("Job created");
        var responseBody = jsonDecode(response.body);
        final data = responseBody['data'];

        // Extract the upload URL and parameters
        final String uploadUrl =
            responseBody['data']['tasks'][0]['result']['form']['url'];
        final Map parameters =
            responseBody['data']['tasks'][0]['result']['form']['parameters'];

        print("Upload URL: $uploadUrl");

        if (await uploadFile(uploadUrl, parameters, filePath)) {
          // Now we wait for the job to complete and download the file
          final String jobId = data['id'];
          _downloadUrl = await _getFileDownloadUrlFromAPI(jobId);
          if (_downloadUrl.isEmpty) {
            return false;
          }
          return true;
        } else {
          return false;
        }
      } else {
        print('Failed to create job: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print("Error while converting $e");

      return false;
    }
  }

  Future<bool> uploadFile(
      String uploadUrl, Map parameters, String filePath) async {
    // Create the multipart request
    try {
      final uploadRequest = http.MultipartRequest("POST", Uri.parse(uploadUrl));

      // Add the file to the request
      uploadRequest.files
          .add(await http.MultipartFile.fromPath("file", filePath));

      // Add the additional parameters to the request
      parameters.forEach((key, value) {
        uploadRequest.fields[key] = value;
      });

      // Send the upload request
      final uploadResponse = await uploadRequest.send();

      if (uploadResponse.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Failed to upload the file");
      return false;
    }
  }

  Future<String> _getFileDownloadUrlFromAPI(String jobId) async {
    try {
      final String jobStatusUrl = 'https://api.cloudconvert.com/v2/jobs/$jobId';
      final headers = {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json'
      };

      // Poll for job status
      while (true) {
        final response =
            await http.get(Uri.parse(jobStatusUrl), headers: headers);
        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          final exportTask = responseBody['data']['tasks'].firstWhere(
              (task) => task['name'] == 'export-a2',
              orElse: () => null);

          if (exportTask != null && exportTask['status'] == 'finished') {
            final String url = exportTask['result']['files'][0]['url'];
            return url;
          } else {
            print('-------- Waiting for file conversion to complete...');
            await Future.delayed(
                Duration(seconds: 1)); // Wait before polling again
          }
        } else {
          print('Failed to fetch job status: ${response.statusCode}');
          break;
        }
      }
      return "";
    } catch (e) {
      print("an error while converting $e");
      return "";
    }
  }

  String getDownloadUrl() {
    print("downlaod url is: $_downloadUrl");
    return _downloadUrl;
  }
}
