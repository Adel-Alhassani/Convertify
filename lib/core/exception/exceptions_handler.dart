import 'dart:io';

import 'package:convertify/core/exception/data_exception.dart';
import 'package:convertify/core/exception/file_exceptions.dart';
import 'package:convertify/core/exception/network_exceptions.dart';
import 'package:convertify/core/logger.dart';
import 'package:convertify/view/widget/dialog/custome_dialog.dart';

class ExceptionsHandler {
  static void handle(Exception e, String unknownExceptionMssg) {
    switch (e) {
      case NoInternetConnectionException():
        CustomeDialog.showNoInternetConnectionDialog();
        logger.e(e);
        break;

      case NullPickResultException():
        logger.i(e);
        break;

      case EmptyDataStorageException():
      case NullDataException():
        CustomeDialog.showUnknownErrorDialog();
        logger.e(e);
        break;

      case FileFormatUnknownException():
        CustomeDialog.showFormatErrorDialog();
        logger.e(e);
        break;

      case ValidOutputFormatsFetchException():
      case ValidOutputFormatsSocketException():
        CustomeDialog.showFetchValidFormatErrorDialog();
        logger.e(e);
        break;

      default:
        CustomeDialog.showUnknownErrorDialog();
        logger.e("$unknownExceptionMssg: $e");
        break;
    }
  }
}
