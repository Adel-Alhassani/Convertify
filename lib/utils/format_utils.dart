import 'dart:ui';

import 'package:convertify/controller/config_controller.dart';
import 'package:get/get.dart';

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

  static String _formatTimeAgoInEn(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inSeconds < 60) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} week${(difference.inDays / 7).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() == 1 ? '' : 's'} ago';
    } else {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() == 1 ? '' : 's'} ago';
    }
  }

  static String _formatTimeAgoInAr(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inSeconds < 60) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'} ${difference.inMinutes} قبل';
    } else if (difference.inHours < 24) {
      return '${difference.inHours == 1 ? 'ساعة' : 'ساعات'} ${difference.inHours} قبل';
    } else if (difference.inDays == 1) {
      return 'الأمس';
    } else if (difference.inDays < 7) {
      return '${difference.inDays == 1 ? 'يوم' : 'أيام'} ${difference.inDays} قبل';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor() == 1 ? 'أسبوع' : 'أسابيع'} ${(difference.inDays / 7).floor()} قبل';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor() == 1 ? 'شهر' : 'شهور'} ${(difference.inDays / 30).floor()} قبل';
    } else {
      return '${(difference.inDays / 365).floor() == 1 ? 'عام' : 'أعوام'} ${(difference.inDays / 365).floor()} قبل';
    }
  }

  static String formatTimeAgo(DateTime dateTime) {
    final ConfigController configController = Get.find();
    Locale? loacle = configController.getLocale();
    if (loacle!.languageCode == "ar") {
      return _formatTimeAgoInAr(dateTime);
    } else {
      return _formatTimeAgoInEn(dateTime);
    }
  }
}
