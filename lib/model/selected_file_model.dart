import 'package:convertify/utils/format_utils.dart';

/// The file the user picked, before it is uploaded.
class SelectedFileModel {
  final String path;
  final String name;
  final int sizeBytes;
  final String extension;

  const SelectedFileModel({
    required this.path,
    required this.name,
    required this.sizeBytes,
    required this.extension,
  });

  String get size => FormatUtils.formatFileSizeWithUnits(sizeBytes);
}
