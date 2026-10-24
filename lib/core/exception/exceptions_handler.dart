import 'package:convertify/core/exception/file_exceptions.dart';
import 'package:convertify/core/exception/network_exceptions.dart';
import 'package:convertify/core/logger.dart';
import 'package:convertify/core/shared/app_dialogs.dart';
import 'package:get/get.dart';

/// A user-facing description of a failure, already translated.
class AppError {
  final String title;
  final String message;
  const AppError(this.title, this.message);
}

class ExceptionsHandler {
  /// Maps any thrown object to a title + message the UI can show inline.
  static AppError describe(Object e) {
    switch (e) {
      case NoInternetConnectionException():
        return AppError(
            "no_internet_connection".tr, "check_internet_connection".tr);
      case FileTooLargeException(:final limitInMB):
        return AppError("file_size_large".tr,
            "file_size_limit".trParams({"limitSizeInMB": "$limitInMB"}));
      case FolderUnavailableException():
        return AppError("folder_unavailable_title".tr, "folder_unavailable".tr);
      case FileMissingException():
        return AppError("file_missing_title".tr, "file_missing".tr);
      case DownloadLinkExpiredException():
        return AppError("no_longer_available".tr, "link_expired".tr);
      case FileFormatUnknownException():
        return AppError("error".tr, "format_unknown".tr);
      case ValidOutputFormatsFetchException():
        return AppError("error".tr, "fetch_valid_output_formats_error".tr);
      case UploadFileException():
        return AppError("upload_failed_title".tr, "upload_failed_body".tr);
      case ConversionFailedException():
        return AppError("convert_failed_title".tr, "coverting_error".tr);
      case ConversionTimeoutException():
        return AppError("convert_failed_title".tr, "convert_timeout".tr);
      case DownloadFileException():
        return AppError("error".tr, "downloading_error".tr);
      default:
        return AppError("error".tr, "unknown_error".tr);
    }
  }

  /// For failures outside the convert flow: log and show a dialog.
  /// Cancelled picks and user cancellations are silent.
  static void handle(Object e, [String context = ""]) {
    if (e is NullPickResultException || e is OperationCancelledException) {
      logger.i(e);
      return;
    }
    logger.e(context.isEmpty ? e : "$context: $e");
    final error = describe(e);
    AppDialogs.showMessage(error.title, error.message);
  }
}
