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
      return 'قبل ${difference.inMinutes} ${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
    } else if (difference.inHours < 24) {
      return 'قبل ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}';
    } else if (difference.inDays == 1) {
      return 'الأمس';
    } else if (difference.inDays < 7) {
      return 'قبل ${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'}';
    } else if (difference.inDays < 30) {
      return 'قبل ${(difference.inDays / 7).floor()} ${(difference.inDays / 7).floor() == 1 ? 'أسبوع' : 'أسابيع'}';
    } else if (difference.inDays < 365) {
      return 'قبل ${(difference.inDays / 30).floor()} ${(difference.inDays / 30).floor() == 1 ? 'شهر' : 'شهور'}';
    } else {
      return 'قبل ${(difference.inDays / 365).floor()} ${(difference.inDays / 365).floor() == 1 ? 'عام' : 'أعوام'}';
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

  static String _formatExpireTimeAr(String expireDate) {
    return "يحذف بعد $expireDate س ";
  }

  static String _formatExpireTimeEn(String expireDate) {
    return "Expire in $expireDate\h";
  }

  static String formatExpireTimeToHours(DateTime expireDate) {
    final difference = expireDate.difference(DateTime.now());
    return "${difference.inHours}";
  }

  static String formatExpireTimeBasedOnLanguage(String expireDate) {
    final ConfigController configController = Get.find();
    Locale? loacle = configController.getLocale();
    if (loacle!.languageCode == "ar") {
      return _formatExpireTimeAr(expireDate);
    } else {
      return _formatExpireTimeEn(expireDate);
    }
  }
}
