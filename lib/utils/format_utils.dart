class FormatUtils {
  static String formatFileSizeWithUnits(int bytes) {
    if (bytes <= 0) return "0 B";

    const int kb = 1024;
    const int mb = 1024 * kb;
    const int gb = 1024 * mb;

    if (bytes < kb) {
      return "$bytes B";
    } else if (bytes < mb) {
      return "${(bytes / kb).toStringAsFixed(2)} KB";
    } else if (bytes < gb) {
      return "${(bytes / mb).toStringAsFixed(2)} MB";
    } else {
      return "${(bytes / gb).toStringAsFixed(2)} GB";
    }
  }

  static double formatFileSize(double bytes) {
    if (bytes <= 0) return 0;

    const int kb = 1024;
    const int mb = 1024 * kb;
    const int gb = 1024 * mb;

    if (bytes < kb) {
      return bytes;
    } else if (bytes < mb) {
      return (bytes / kb);
    } else if (bytes < gb) {
      return (bytes / mb);
    } else {
      return (bytes / gb);
    }
  }

  static String formatFileName(String name, int lengthLimit) {
    if (name.length <= lengthLimit) {
      return name;
    } else {
      return "${name.substring(0, lengthLimit)}...";
    }
  }

  static String changeFileExtension(String fileName, String outputExtension) {
    int formatLength = 0;
    for (int i = fileName.length - 1; i > 0; i--) {
      if (fileName[i] == ".") {
        break;
      }
      formatLength++;
    }
    formatLength++;
    String newName =
        "${fileName.substring(0, fileName.length - formatLength)}.$outputExtension";
    return newName;
  }
}
