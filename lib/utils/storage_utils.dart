import 'dart:io';

class StorageUtils {
  static Future<String> getAppDirectory() async {
    // Get the path to the public Download directory
    final directory = Directory('/storage/emulated/0/Download/Convertify');
    try {
      // Check if the directory exists; if not, create it
      if (!await directory.exists()) {
        await directory.create(recursive: true);
        print('Folder created at: ${directory.path}');
      }
      print(directory.path);
      return directory.path;
    } catch (e) {
      print('Error creating folder: $e');
      return '';
    }
  }

  static Future<bool> isFileAlreadyDownloaded(String filName, String directory) async {
    if (directory.isNotEmpty) {
      final String filePath = "$directory/$filName";
      return await File(filePath).exists();
    }
    print("*** directory is empty");
    return false;
  }
}