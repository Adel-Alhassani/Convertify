import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppLocale extends Translations {
  @override
  // TODO: implement keys
  Map<String, Map<String, String>> get keys => {
        'en': {
          'convert': 'Convert',
          'download': 'Download',
          'tap_here_to_pick_file': 'Tap here to pick a file',
          'from': 'From',
          'select_output_format': 'Select output format',
          'to': 'To',
          'file_converted_successfully':
              'The file has been converted successfully.\n Click ',
          'click_to_download': ' to download it.',
          'no_internet_connection': "No Internet Connection!",
          'check_internet_connection':
              "Please check your internet connection and try again.",
          'ok': "Ok",
          'file_size_large': "File's size is large!",
          'file_size_limit':
              "The file size cannot be more than @limitSizeInMB MB",
          'error': "Error!",
          'coverting_error': 'An error occurred while converting the file!',
          'fetch_valid_output_formats_error':
              'An error occurred while trying to get the valid output formats!',
          'unknown_error': 'An unknown error occurred!',
          'format_unknown': "File format is unknown!",
          'my_files': "My Files",
          "search_in_files": "Search for file...",
          "no_converted_files": "You didn’t converted any file.",
          "file_already_downloaded": "File is already downloaded.",
          "donwloaded_complate": "Download Complete",
          "file_downloaded_successfully":
              "file downloaded successfully in:",
            "download_dir" : "@appDir",
          "downloading_error": "An error occurred while downloading the file!",
          "preparing_file": "preparing the file, please don't close the app...",
          "start_downloading": "File downloading...",
          // "delete_success": "File deleted successfully",
          "delete_failed": "File deletion failed",
          "confirm_delete": "Are you sure you want to delete this file?",
          "confirm": "Yes",
          "cancel": "No",
          "no_converting_file": "No file is being converted.",
          "no_downloadable_files": "No converted files available for download.",
          "downloadable_files_list_limit_reached":
              "Maximum downloadable files reached.\nplease delete a file and try again."
        },
        'ar': {
          'convert': 'تحويل',
          'download': 'تحميل',
          'tap_here_to_pick_file': 'اضغط هنا لإختيار ملف',
          'from': 'من',
          'select_output_format': 'اختر الصيغة',
          'to': 'إلى',
          'file_converted_successfully': 'تم تحويل الملف بنجاح.\n اضغط ',
          'click_to_download': ' لتحميل الملف.',
          'no_internet_connection': 'لا يوجد اتصال بالإنترنت!',
          'check_internet_connection':
              'يرجى التحقق من الإتصال بالإنترنت والمحاولة مرة أخرى.',
          'ok': 'حسنًا',
          'file_size_large': 'حجم الملف كبير!',
          'file_size_limit':
              'حجم الملف لا يمكن أن يتجاوز @limitSizeInMB ميجابايت',
          'error': "خطأ!",
          'coverting_error': 'حدث خطأ أثناء تحويل الملف!',
          'fetch_valid_output_formats_error':
              'حدث خطأ أثناء استرداد الصيغ المتاحة!',
          'unknown_error': 'حدث خطأ غير معروف!',
          'format_unknown': "صيغة الملف غير معروفة!",
          'my_files': "ملفاتي",
          "search_in_files": "ابحث عن ملف...",
          "no_converted_files": "لم تحوّل أي ملف.",
          "file_already_downloaded": "الملف تم تحميله بالفعل.",
          "donwloaded_complate": "اكتمل التنزيل.",
          "file_downloaded_successfully": "تم تنزيل الملف بنجاح في:",
          "download_dir": "@appDir",
          "downloading_error": "حدث خطأ أثناء تنزيل الملف!",
          "preparing_file": "الملف قيد التحضير، يرجى عدم إغلاق التطبيق...",
          "start_downloading": "جاري تنزيل الملف...",
          // "delete_success": "تم حذف الملف بنجاح",
          "delete_failed": "فشل حذف الملف",
          "confirm_delete": "هل أنت متأكد من رغبتك في حذف هذا الملف؟",
          "confirm": "تأكيد",
          "cancel": "إلغاء",
          "no_converting_file": "لا يوجد ملف قيد التحويل.",
          "no_downloadable_files": "لا توجد ملفات محولة متاحة للتنزيل.",
          "downloadable_files_list_limit_reached":
              "تم الوصول إلى الحد الأقصى للملفات القابلة للتنزيل.\nيرجى حذف ملف والمحاولة مرة أخرى."
        },
      };
}
