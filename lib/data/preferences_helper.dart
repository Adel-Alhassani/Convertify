import 'dart:convert';

import 'package:convertify/core/logger.dart';
import 'package:convertify/model/converting_file_model.dart';
import 'package:convertify/model/downloadable_file_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static const _convertingKey = "convertingFileData";
  static const _downloadableKey = "downloadableData";
  static const _folderKey = "convertedFolderUri";
  static const _localeKey = "languageCode";

  final SharedPreferences _prefs;
  PreferencesHelper(this._prefs);

  // ---- In-progress conversion ----

  ConvertingFileModel? fetchConvertingFile() {
    final json = _prefs.getString(_convertingKey);
    if (json == null) return null;
    try {
      return ConvertingFileModel.fromJson(jsonDecode(json));
    } catch (e) {
      logger.e("Corrupt converting file data, clearing it: $e");
      _prefs.remove(_convertingKey);
      return null;
    }
  }

  Future<void> storeConvertingFile(ConvertingFileModel file) =>
      _prefs.setString(_convertingKey, jsonEncode(file.toJson()));

  Future<void> removeConvertingFile() => _prefs.remove(_convertingKey);

  // ---- Converted files ----

  /// Tree URI of the folder the user picked for converted files.
  String? fetchFolderUri() => _prefs.getString(_folderKey);

  Future<void> storeFolderUri(String uri) => _prefs.setString(_folderKey, uri);

  /// Converted files that aren't in the folder yet. Files in the folder are
  /// read from the folder itself.

  List<DownloadableFileModel> fetchDownloadableFiles() {
    final json = _prefs.getString(_downloadableKey);
    if (json == null) return [];
    final files = <DownloadableFileModel>[];
    for (final item in jsonDecode(json) as List) {
      try {
        files.add(DownloadableFileModel.fromJson(
            Map<String, dynamic>.from(item as Map)));
      } catch (e) {
        logger.e("Skipping unreadable file entry: $e");
      }
    }
    return files;
  }

  Future<void> storeDownloadableFiles(List<DownloadableFileModel> files) =>
      _prefs.setString(
          _downloadableKey, jsonEncode(files.map((f) => f.toJson()).toList()));

  // ---- Settings ----

  String? fetchLanguageCode() => _prefs.getString(_localeKey);

  Future<void> storeLanguageCode(String code) =>
      _prefs.setString(_localeKey, code);
}
