import 'dart:convert';

import 'package:convertify/service/setting_services.dart';
import 'package:convertify/utils/format_utils.dart';
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

  Future<void> storeDownloadableFileData(
      String outputFileSize, String fileDownloadUrl) async {
    if (outputFileSize.isEmpty || fileDownloadUrl.isEmpty) {
      print("outputFileSize or fileDownloadUrl are Empty");
      return;
    }
    Map<String, dynamic> convertingFileData = await fetchConvertingFileData();
    String fileName = FormatUtils.changeFileExtension(
        convertingFileData["fileName"]!, convertingFileData["outputFormat"]);
    //     "${GenerateUtils.generateNameWithDate("Convertify")}.$outputFormat";

    String fileSize = outputFileSize;
    String fileOutputFormat = convertingFileData["outputFormat"];
    Map<String, String> data = {
      "fileName": fileName,
      "fileSize": fileSize,
      "outputFormat": fileOutputFormat,
      "fileDownloadUrl": fileDownloadUrl
    };
    // downloadableFile.value = data;
    await _settingServicesController.sharedPreferences
        .setString("downloadableData", jsonEncode(data));
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

  Future<Map<String, dynamic>> fetchDownloadableFileData() async {
    Map<String, dynamic> data = <String, dynamic>{};
    if (_settingServicesController.sharedPreferences
            .getString("downloadableData") !=
        null) {
      String dataJson = _settingServicesController.sharedPreferences
          .getString("downloadableData")!;
      if (dataJson.isNotEmpty) {
        data = jsonDecode(dataJson);
        return data;
      } else {
        print("data of downloadableFile is empty");
        return data;
      }
    }
    print("data of downloadableFile is null");
    return data;
  }

  Future<String> getJobId() async {
    Map<String, dynamic> convertingFileData = await fetchConvertingFileData();
    String jobId = convertingFileData["jobId"];
    return jobId;
  }

  Future<void> removeConvertingFileData() async {
    if (await _settingServicesController.sharedPreferences
        .remove("convertingFileData")) {
      // convertingFile.clear();
      print("converting data removed");
    }
    print("converting data DID not removed");
  }

  Future<void> _removeAllADateFromSharedPref() async {
    return await _settingServicesController.sharedPreferences.clear()
        ? print("All data removed")
        : print("All data DID not removed");
  }
}
