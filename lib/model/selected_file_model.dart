import 'dart:io';

import 'package:convertify/core/exception/file_exceptions.dart';
import 'package:convertify/core/logger.dart';
import 'package:convertify/service/file_service.dart';
import 'package:convertify/utils/format_utils.dart';
import 'package:get/get.dart';

class SelectedFileModel {
  String? _path;
  String? _name;
  String? _size;
  String? _extension;

  void setPath(String? path) {
    _path = path;
  }

  void setName(String? name) {
    _name = name;
  }

  void setSize(int size) {
    _size = FormatUtils.formatFileSizeWithUnits(size);
  }

  void setExtension(String? extension) {
    try {
      if (extension == null) throw FileFormatUnknownException;
      _extension = extension;
    } on Exception catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  void set(String? path, String? name, int size, String? extension) {
    try {
      setPath(path);
      setName(name);
      setSize(size);
      setExtension(extension);
    } on Exception catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  String? get path => _path;
  String? get name => _name;
  String? get size => _size;
  String? get extension => _extension;
}
