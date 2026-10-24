import 'package:convertify/core/exception/file_exceptions.dart';
import 'package:file_picker/file_picker.dart';

class FileUtils {
  /// Opens the system picker. Throws [NullPickResultException] if the user
  /// backs out. [allowedExtensions] narrows the picker (used by the
  /// "popular conversions" shortcuts).
  static Future<PlatformFile> pickFile({List<String>? allowedExtensions}) async {
    final FilePickerResult? result = allowedExtensions == null
        ? await FilePicker.platform.pickFiles()
        : await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: allowedExtensions,
          );
    if (result == null || result.files.isEmpty) {
      throw NullPickResultException();
    }
    return result.files.single;
  }
}
