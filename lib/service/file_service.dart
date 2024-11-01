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
  // late String _downloadUrl;
  late final String _jobId;
  late final String _uploadUrl;
  late final Map _parameters;

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

  Future<void> creatJob(
    String inputFormat,
    String outputFormat,
  ) async {
    // _downloadUrl = await getFileDownloadUrl(
    //     "e25e8cb0-20cb-40ca-a5ca-6559257e7f0a");
    // return true;
    // API endpoint for creating a job
    try {
      final String url = 'https://api.cloudconvert.com/v2/jobs';

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
        _jobId = data['id'];
        _uploadUrl = data['tasks'][0]['result']['form']['url'];
        _parameters = data['tasks'][0]['result']['form']['parameters'];
        print("job id: $_jobId");
        print("Upload URL: $_uploadUrl");
      } else {
        print('Failed to create job: ${response.statusCode}');
      }
    } catch (e) {
      print("Error while converting $e");
    }
  }

  Future<bool> uploadFile(String filePath) async {
    // Create the multipart request
    try {
      final uploadRequest =
          http.MultipartRequest("POST", Uri.parse(_uploadUrl));

      // Add the file to the request
      uploadRequest.files
          .add(await http.MultipartFile.fromPath("file", filePath));

      // Add the additional parameters to the request
      _parameters.forEach((key, value) {
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

  Future<String> getFileDownloadUrl(String jobId) async {
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

  String getJobId() {
    return "a2c09548-1d63-4379-a62e-038a376aeb41";
    return _jobId;
  }

  // String getDownloadUrl() {
  //   print("downlaod url is: $_downloadUrl");
  //   return _downloadUrl;
  // }

  Future<int> getFileSize(String fileUrl) async {
    try {
      // Send a HEAD request to get only headers
      var response = await http.head(Uri.parse(fileUrl));

      if (response.statusCode == 200) {
        // Check if 'Content-Length' header exists
        if (response.headers.containsKey('content-length')) {
          // Get the file size from the 'Content-Length' header
          String? contentLength = response.headers['content-length'];
          if (contentLength != null) {
            int fileSize = int.parse(contentLength);
            print('File size: $fileSize bytes');
            return fileSize;
          } else {
            print("Content-Length found, but it's null");
            return 0;
          }
        } else {
          print('Content-Length header not found.');
          return 0;
        }
      } else {
        print(
            'Failed to fetch file headers. Status code: ${response.statusCode}');
        return 0;
      }
    } catch (e) {
      print("Error: failed to get the size of the file");
      return 0;
    }
  }
}
