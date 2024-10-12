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
        },

      };
}
