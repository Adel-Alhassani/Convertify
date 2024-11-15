import 'dart:convert';
import 'dart:ui';

import 'package:convertify/core/exception/data_exception.dart';
import 'package:convertify/core/logger.dart';
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
  }

  Future<void> storeDownloadableFilesData(
      String fileId,
      String fileName,
      String fileSize,
      String fileOutputFormat,
      String fileDownloadUrl,
      fileConvertedDate) async {
    Map<String, dynamic> data = {
      "fileId": fileId,
      "fileName": fileName,
      "fileSize": fileSize,
      "outputFormat": fileOutputFormat,
      "fileDownloadUrl": fileDownloadUrl,
      "fileConvertedDate": fileConvertedDate
    };
    List<Map<String, dynamic>> downloadableData =
        await fetchDownloadableFilesData();
    downloadableData.add(data);
    await _settingServicesController.sharedPreferences
        .setString("downloadableData", jsonEncode(downloadableData));
  }

  Future<Map<String, dynamic>> fetchConvertingFileData() async {
    Map<String, dynamic> data = <String, dynamic>{};
    if (_settingServicesController.sharedPreferences
            .getString("convertingFileData") ==
        null) {
      logger.i("Null converting file data");
      return data;
    }
    String dataJson = _settingServicesController.sharedPreferences
        .getString("convertingFileData")!;
    data = jsonDecode(dataJson);
    return data;
  }

  Future<List<Map<String, dynamic>>> fetchDownloadableFilesData() async {
    late final List<Map<String, dynamic>> data;
    if (_settingServicesController.sharedPreferences
            .getString("downloadableData") ==
        null) {
      logger.i("Null downloadable file data");
      return <Map<String, dynamic>>[];
    }
    String dataJson = _settingServicesController.sharedPreferences
        .getString("downloadableData")!;
    List<dynamic> dynamicList = jsonDecode(dataJson);
    data = dynamicList.map((e) => e as Map<String, dynamic>).toList();
    return data;
  }

  Future<String> fetchJobId() async {
    Map<String, dynamic> convertingFileData = await fetchConvertingFileData();
    String jobId = convertingFileData["jobId"];
    return jobId;
  }

  Future<void> removeConvertingFileData() async {
    await _settingServicesController.sharedPreferences
        .remove("convertingFileData");
  }

  Future<bool> deleteDownloadableFile(String fileId) async {
    final List<Map<String, dynamic>> downloadableData =
        await fetchDownloadableFilesData();
    final int fileIndex =
        downloadableData.indexWhere((file) => file['fileId'] == fileId);
    if (fileIndex == -1) {
      return false;
    }
    downloadableData.removeAt(fileIndex);
    await _settingServicesController.sharedPreferences
        .setString("downloadableData", jsonEncode(downloadableData));
    return true;
  }

  Future<void> removeAllADateFromSharedPref() async {
    return await _settingServicesController.sharedPreferences.clear()
        ? logger.i("All data removed")
        : logger.i("Data didn't removed!");
  }
}
