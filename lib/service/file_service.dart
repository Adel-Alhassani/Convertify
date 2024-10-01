import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class FileService {
  final String apiKey =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiM2RiYzJiNmI1M2JiOTVjZDk0YWM2YmMxMGFmMDIwYzI3YWFiMjBhZDMyMGY1MWM1YzhjMzkxMmJmNTQwODZkOTEyMGNlNTk2NGE4OThlMjMiLCJpYXQiOjE3MjQxNjI1MDMuNTA1MzA1LCJuYmYiOjE3MjQxNjI1MDMuNTA1MzA2LCJleHAiOjQ4Nzk4MzYxMDMuNTAwMDg4LCJzdWIiOiI2OTMzNTIxMyIsInNjb3BlcyI6WyJ1c2VyLnJlYWQiLCJ1c2VyLndyaXRlIiwidGFzay5yZWFkIiwidGFzay53cml0ZSIsIndlYmhvb2sucmVhZCIsIndlYmhvb2sud3JpdGUiLCJwcmVzZXQucmVhZCIsInByZXNldC53cml0ZSJdfQ.fQQK3-XOCTWDtKIzxJ6jbpGunNEHnqQbJN9K8kT5moiiJvFePqtdMOeT65QMly96ZK7Jbw9Fm3aq5847UDlHFBv-VGQoY0FyX5lOk10yhZFHFQsQ9C6NaoLI7VEWEjG8FHceu_mDN-A7wU8nfi7_z39qvoeRwJptitoIuKCDSnpPYBcXrxJnuMdCf0CQUHoqHrhrBmCfqclWR_ZlV-3yktnTtck5VNS-chgJLhHUdDyDHynKeUcs2dlft7CZdPaz70E9HWIiDQHbWZmX9RbWCoB7tDBDe2OSdMUfohU-JZWqs2XgVK9LxKfkJyqi-RIaXellfmYCPG8qO81hlN1aObIQsHOm9xfNg0zLvTBz3hFlzAklwklGI-mW-VJWHbpY3lZvXz5wZ_pgzqkiumm8B9tn2W7SnSS775hoF_vHJKoRbd6-UoatsFQLP6yaqm3MXANKhJ7x1NS_U1zj5W8yrXaHFfAgEVmkoEW-Ohv_e23EBWP9lOLVfQorltLhiBr9WU1n1cuGTzgTxRJUPUX0Bo84QCzfSQTrZvOGVGOOjH6wJqKysQ2rDKZwXrO-1FIRpsHgTBqVr2cqhkP7AHi04ucJGe6WRfKnFNDQM_c0MUh_qJy-dzavooXTqkW4hCmSbCKO7gmeFTkxKj1uRiZQsmBEWkT78_prF6SjWArmOto';
  late String _downloadUrl;
  Future<Map<String, List<String>>> getValidOutputFormatsOf(
      String InputFormat) async {
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

  Future<void> convert(
    String filePath,
    String inputFormat,
    String outputFormat,
  ) async {
    // API endpoint for creating a job
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
      } else {
        // do somthin
      }
    } else {
      print('Failed to create job: ${response.statusCode}');
    }
  }

  Future<bool> uploadFile(
      String uploadUrl, Map parameters, String filePath) async {
    // Create the multipart request
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
  }

  Future<String> _getFileDownloadUrlFromAPI(String jobId) async {
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
  }

  String getDownloadUrl() {
    print("downlaod url is: $_downloadUrl");
    return _downloadUrl;
  }
}
