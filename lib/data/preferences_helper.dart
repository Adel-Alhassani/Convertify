import 'dart:convert';
import 'dart:ui';

import 'package:convertify/core/logger.dart';
import 'package:convertify/model/converting_file_model.dart';
import 'package:convertify/model/downloadable_file_model.dart';
import 'package:convertify/service/setting_services.dart';
import 'package:get/get.dart';

class PreferencesHelper {
  final SettingServices _settingServicesController = Get.find();
  Future<void> storeConvertingFileData(String name, String size,
      String extension, String outputFormat, String jobId) async {
    ConvertingFileModel convertingFileModel = ConvertingFileModel(
      fileName: name,
      fileSize: size,
      inputFormat: extension,
      outputFormat: outputFormat,
      jobId: jobId,
    );
    await _settingServicesController.sharedPreferences
        .setString("convertingFileData", jsonEncode(convertingFileModel));
  }

  Future<void> storeDownloadableFilesData(
      String fileId,
      String fileName,
      String fileSize,
      String fileOutputFormat,
      String fileDownloadUrl,
      fileConvertedDate) async {
    DownloadableFileModel downloadableFileModel = DownloadableFileModel(
        fileId: fileId,
        fileName: fileName,
        fileSize: fileSize,
        fileOutputFormat: fileOutputFormat,
        fileDownloadUrl: fileDownloadUrl,
        fileConvertedDate: fileConvertedDate);
    List<DownloadableFileModel> downloadableData =
        await fetchDownloadableFilesData();
    downloadableData.add(downloadableFileModel);
    await _settingServicesController.sharedPreferences
        .setString("downloadableData", jsonEncode(downloadableData));
  }

  Future<ConvertingFileModel> fetchConvertingFileData() async {
    ConvertingFileModel data = ConvertingFileModel();
    if (_settingServicesController.sharedPreferences
            .getString("convertingFileData") ==
        null) {
      logger.i("Null converting file data");
      return data;
    }
    String dataJson = _settingServicesController.sharedPreferences
        .getString("convertingFileData")!;
    Map<String, dynamic> dataMap = jsonDecode(dataJson);
    data = ConvertingFileModel.fromJson(dataMap);
    return data;
  }

  Future<List<DownloadableFileModel>> fetchDownloadableFilesData() async {
    late final List<DownloadableFileModel> data;
    if (_settingServicesController.sharedPreferences
            .getString("downloadableData") ==
        null) {
      logger.i("Null downloadable file data");
      return <DownloadableFileModel>[];
    }
    String dataJson = _settingServicesController.sharedPreferences
        .getString("downloadableData")!;
    List<dynamic> dynamicList = jsonDecode(dataJson);
    data = dynamicList
        .map((file) => DownloadableFileModel.fromJson(file))
        .toList();
    return data;
  }

  Future<String> fetchJobId() async {
    ConvertingFileModel convertingFileData = await fetchConvertingFileData();
    String jobId = convertingFileData.jobId!;
    return jobId;
  }

  Future<void> removeConvertingFileData() async {
    await _settingServicesController.sharedPreferences
        .remove("convertingFileData");
  }

  Future<bool> deleteDownloadableFile(String fileId) async {
    final List<DownloadableFileModel> downloadableFilesData =
        await fetchDownloadableFilesData();
    final int fileIndex =
        downloadableFilesData.indexWhere((file) => file.fileId == fileId);
    if (fileIndex == -1) {
      return false;
    }
    downloadableFilesData.removeAt(fileIndex);
    await _settingServicesController.sharedPreferences
        .setString("downloadableData", jsonEncode(downloadableFilesData));
    return true;
  }

  Future<void> removeAllADateFromSharedPref() async {
    return await _settingServicesController.sharedPreferences.clear()
        ? logger.i("All data removed")
        : logger.i("Data didn't removed!");
  }
}
