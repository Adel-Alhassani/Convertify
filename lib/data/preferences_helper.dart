import 'dart:convert';
import 'dart:ffi';
import 'dart:ui';

import 'package:convertify/core/logger.dart';
import 'package:convertify/model/converting_file_model.dart';
import 'package:convertify/model/downloadable_file_model.dart';
import 'package:convertify/service/setting_services.dart';
import 'package:get/get.dart';

class PreferencesHelper {
  final SettingServices _settingServicesController = Get.find();

  bool _isConvertingFileDataExist() {
    if (_settingServicesController.sharedPreferences
            .getString("convertingFileData") !=
        null) {
      return true;
    }
    return false;
  }

  bool _isDownloadableFilesDataExist() {
    if (_settingServicesController.sharedPreferences
            .getString("downloadableData") !=
        null) {
      return true;
    }
    return false;
  }

  Future<void> storeConvertingFileData(String name, String size,
      String extension, String outputFormat, String jobId) async {
    try {
      ConvertingFileModel convertingFileModel = ConvertingFileModel(
        fileName: name,
        fileSize: size,
        inputFormat: extension,
        outputFormat: outputFormat,
        jobId: jobId,
      );
      await _settingServicesController.sharedPreferences
          .setString("convertingFileData", jsonEncode(convertingFileModel));
    } on Exception catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  Future<void> storeDownloadableFilesData(
    String fileId,
    String fileName,
    String fileSize,
    String fileOutputFormat,
    String fileDownloadUrl,
    String fileConvertedDate,
    String fileExpireDate,
  ) async {
    try {
      DownloadableFileModel downloadableFileModel = DownloadableFileModel(
          fileId: fileId,
          fileName: fileName,
          fileSize: fileSize,
          fileOutputFormat: fileOutputFormat,
          fileDownloadUrl: fileDownloadUrl,
          fileConvertedDate: fileConvertedDate,
          fileExpireDate: fileExpireDate);
      List<DownloadableFileModel>? downloadableData =
          fetchDownloadableFilesData();
      if (downloadableData == null) {
        downloadableData = <DownloadableFileModel>[];
        downloadableData.add(downloadableFileModel);
      } else {
        downloadableData.add(downloadableFileModel);
      }
      await _settingServicesController.sharedPreferences
          .setString("downloadableData", jsonEncode(downloadableData));
    } on Exception catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  ConvertingFileModel? fetchConvertingFileData() {
    if (!_isConvertingFileDataExist()) {
      return null;
    }
    String dataJson = _settingServicesController.sharedPreferences
        .getString("convertingFileData")!;
    Map<String, dynamic> dataMap = jsonDecode(dataJson);
    ConvertingFileModel data = ConvertingFileModel.fromJson(dataMap);
    return data;
  }

  List<DownloadableFileModel>? fetchDownloadableFilesData() {
    if (!_isDownloadableFilesDataExist()) {
      return null;
    }
    String dataJson = _settingServicesController.sharedPreferences
        .getString("downloadableData")!;
    List<dynamic> dynamicList = jsonDecode(dataJson);
    List<DownloadableFileModel> data = dynamicList
        .map((file) => DownloadableFileModel.fromJson(file))
        .toList();
    return data;
  }

  String fetchJobId() {
    ConvertingFileModel convertingFileData = fetchConvertingFileData()!;
    String jobId = convertingFileData.jobId!;
    return jobId;
  }

  Future<void> removeConvertingFileData() async {
    try {
      await _settingServicesController.sharedPreferences
          .remove("convertingFileData");
    } on Exception catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  Future<bool> deleteDownloadableFile(String fileId) async {
    try {
      final List<DownloadableFileModel>? downloadableFilesData =
          fetchDownloadableFilesData();
      final int fileIndex =
          downloadableFilesData!.indexWhere((file) => file.fileId == fileId);
      if (fileIndex == -1) {
        return false;
      }
      downloadableFilesData.removeAt(fileIndex);
      await _settingServicesController.sharedPreferences
          .setString("downloadableData", jsonEncode(downloadableFilesData));
      return true;
    } on Exception catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  Future<void> removeAllADateFromSharedPref() async {
    try {
      return await _settingServicesController.sharedPreferences.clear()
          ? logger.i("All data removed")
          : logger.i("Data didn't removed!");
    } on Exception catch (e) {
      logger.e(e);
      rethrow;
    }
  }
}
