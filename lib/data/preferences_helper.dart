import 'dart:convert';

import 'package:convertify/service/setting_services.dart';
import 'package:convertify/utils/format_utils.dart';
import 'package:convertify/utils/generate_utils.dart';
import 'package:get/get.dart';

class PreferencesHelper {
  final SettingServices _settingServicesController = Get.find();

  Future<void> storeConvertingFileData(String name, String size,
      String extension, String outputFormat, String jobId) async {
    Map<String, String?> convertingFileData = {
      "fileName": name,
      "fileSize": size,
      "inputFormat": extension,
      "outputFormat": outputFormat,
      "jobId": jobId,
    };

    await _settingServicesController.sharedPreferences
        .setString("convertingFileData", jsonEncode(convertingFileData));
    print("set converting data to sharedPref");
  }

  Future<void> storeDownloadableFilesData(
      String outputFileSize, String fileDownloadUrl) async {
    if (outputFileSize.isEmpty || fileDownloadUrl.isEmpty) {
      print("outputFileSize or fileDownloadUrl are Empty");
      return;
    }
    String fileId = "${GenerateUtils.generateNameWithDate("Convertify")}";
    Map<String, dynamic> convertingFileData = await fetchConvertingFileData();
    String fileName = FormatUtils.changeFileExtension(
        convertingFileData["fileName"]!, convertingFileData["outputFormat"]);

    String fileSize = outputFileSize;
    String fileOutputFormat = convertingFileData["outputFormat"];
    Map<String, dynamic> data = {
      "fileId": fileId,
      "fileName": fileName,
      "fileSize": fileSize,
      "outputFormat": fileOutputFormat,
      "fileDownloadUrl": fileDownloadUrl
    };
    List<Map<String, dynamic>> downloadableData =
        await fetchDownloadableFilesData();
    downloadableData.add(data);
    await _settingServicesController.sharedPreferences
        .setString("downloadableData", jsonEncode(downloadableData));
    print("set downloadable data to sharedPref");
  }

  Future<Map<String, dynamic>> fetchConvertingFileData() async {
    Map<String, dynamic> data = <String, dynamic>{};
    if (_settingServicesController.sharedPreferences
            .getString("convertingFileData") !=
        null) {
      String dataJson = _settingServicesController.sharedPreferences
          .getString("convertingFileData")!;
      if (dataJson.isNotEmpty) {
        data = jsonDecode(dataJson);
        return data;
      } else {
        print("data of convertingFile is empty");
        return data;
      }
    }
    print("data of convertingFile is null");
    return data;
  }

  Future<List<Map<String, dynamic>>> fetchDownloadableFilesData() async {
    late final List<Map<String, dynamic>> data;
    if (_settingServicesController.sharedPreferences
            .getString("downloadableData") !=
        null) {
      String dataJson = _settingServicesController.sharedPreferences
          .getString("downloadableData")!;
      if (dataJson.isNotEmpty) {
        List<dynamic> dynamicList = jsonDecode(dataJson);
        data = dynamicList.map((e) => e as Map<String, dynamic>).toList();
        return data;
      } else {
        print("data of downloadableFile is empty");
        return <Map<String, dynamic>>[];
      }
    }
    print("data of downloadableFile is null");
    return <Map<String, dynamic>>[];
  }

  Future<String> fetchJobId() async {
    Map<String, dynamic> convertingFileData = await fetchConvertingFileData();
    String jobId = convertingFileData["jobId"];
    return jobId;
  }

  Future<void> removeConvertingFileData() async {
    if (await _settingServicesController.sharedPreferences
        .remove("convertingFileData")) {}
    print("converting data DID not removed");
  }

  Future<bool> deleteDownloadableFile(String fileId) async {
    final List<Map<String, dynamic>> downloadableData = await fetchDownloadableFilesData();
    final int fileIndex = downloadableData.indexWhere((file) => file['fileId'] == fileId);
    if (fileIndex != -1) {
      downloadableData.removeAt(fileIndex);
      await _settingServicesController.sharedPreferences
          .setString("downloadableData", jsonEncode(downloadableData));
      return true;
    }
    return false;
  }

  Future<void> removeAllADateFromSharedPref() async {
    return await _settingServicesController.sharedPreferences.clear()
        ? print("All data removed")
        : print("All data DID not removed");
  }
}
