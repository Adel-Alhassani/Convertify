class NoInternetConnectionException implements Exception {
  final String mssg;
  NoInternetConnectionException(
      [this.mssg = "There is no internet connection!"]);

  @override
  String toString() => mssg;
}

class ValidOutputFormatsFetchException implements Exception {
  final int? statusCode;
  ValidOutputFormatsFetchException(this.statusCode);

  @override
  String toString() =>
      "Unable to retrieve valid output formats. Status code: $statusCode";
}

class CreateJobException implements Exception {
  final int? statusCode;
  CreateJobException(this.statusCode);

  @override
  String toString() => "Unable to create a job. Status code: $statusCode";
}

class UploadFileException implements Exception {
  final int? statusCode;

  /// Bytes sent before the failure, so the UI can say how far it got.
  final int sentBytes;
  UploadFileException(this.statusCode, {this.sentBytes = 0});

  @override
  String toString() =>
      "Unable to upload the file. Status code: $statusCode, sent: $sentBytes";
}

class ConversionFailedException implements Exception {
  final String? reason;
  ConversionFailedException([this.reason]);

  @override
  String toString() => "Conversion failed: ${reason ?? 'unknown reason'}";
}

class ConversionTimeoutException implements Exception {
  @override
  String toString() => "Conversion did not finish in time.";
}

class JobStatusException implements Exception {
  final int? statusCode;
  JobStatusException(this.statusCode);

  @override
  String toString() => "Unable to fetch job status. Status code: $statusCode";
}

class DownloadFileException implements Exception {
  final int? statusCode;
  DownloadFileException(this.statusCode);

  @override
  String toString() => "Unable to download the file. Status code: $statusCode";
}

/// Thrown when the user cancels an upload or a conversion.
class OperationCancelledException implements Exception {
  @override
  String toString() => "Operation cancelled by the user.";
}
