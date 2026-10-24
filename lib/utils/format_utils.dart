import 'package:get/get.dart';

class FormatUtils {
  static String formatFileSizeWithUnits(int bytes) {
    if (bytes <= 0) return "0 B";
    const int kb = 1024;
    const int mb = 1024 * kb;
    const int gb = 1024 * mb;
    if (bytes < kb) return "$bytes B";
    if (bytes < mb) return "${_trim(bytes / kb)} KB";
    if (bytes < gb) return "${_trim(bytes / mb)} MB";
    return "${_trim(bytes / gb)} GB";
  }

  /// 1.0 -> "1", 1.25 -> "1.3", 12.5 -> "13"
  static String _trim(double value) {
    if (value >= 10) return value.round().toString();
    final fixed = value.toStringAsFixed(1);
    return fixed.endsWith(".0") ? fixed.substring(0, fixed.length - 2) : fixed;
  }

  /// "report.final.docx" + "pdf" -> "report.final.pdf".
  /// A name without an extension just gets one appended.
  static String changeFileExtension(String fileName, String outputExtension) {
    final dot = fileName.lastIndexOf('.');
    final base = dot > 0 ? fileName.substring(0, dot) : fileName;
    return "$base.${outputExtension.toLowerCase()}";
  }

  /// Extension of [fileName] in lower case, or null when it has none.
  static String? extensionOf(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot <= 0 || dot == fileName.length - 1) return null;
    return fileName.substring(dot + 1).toLowerCase();
  }

  /// "now", "5 min ago", "3h ago", "yesterday", "4 days ago" — translated.
  static String formatTimeAgo(DateTime dateTime, {DateTime? now}) {
    final diff = (now ?? DateTime.now()).difference(dateTime);
    if (diff.inMinutes < 1) return "time_now".tr;
    if (diff.inMinutes < 60) {
      return "time_minutes_ago".trParams({"n": "${diff.inMinutes}"});
    }
    if (diff.inHours < 24) {
      return "time_hours_ago".trParams({"n": "${diff.inHours}"});
    }
    if (diff.inDays == 1) return "time_yesterday".tr;
    return "time_days_ago".trParams({"n": "${diff.inDays}"});
  }

  /// Trims long names in the middle so the extension stays visible.
  static String formatFileName(String name, int maxLength) {
    if (name.length <= maxLength) return name;
    final keepEnd = (maxLength / 3).floor();
    final keepStart = maxLength - keepEnd - 1;
    return "${name.substring(0, keepStart)}…${name.substring(name.length - keepEnd)}";
  }
}
