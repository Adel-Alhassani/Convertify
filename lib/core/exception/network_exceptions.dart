
class NoInternetConnectionException implements Exception {
  final String mssg;
  NoInternetConnectionException([this.mssg = "There is no internet connection!"]);

  @override
  String toString() => mssg;
}

class ValidOutputFormatsFetchException implements Exception {
  final int statusCode;
  ValidOutputFormatsFetchException(this.statusCode);
  String getMssg() =>
      "Unable to retrieve valid output formats. Status code: $statusCode";
  @override
  String toString() => getMssg();
}

class ValidOutputFormatsSocketException implements Exception {
  final String mssg;
  ValidOutputFormatsSocketException([this.mssg = "Invalid URL used for fetching valid output formats!"]);
  @override
  String toString() => mssg;
}


class CreateJobException implements Exception {
  final int statusCode;
  CreateJobException(this.statusCode);
  String getMssg() => "Unable to create a job. Status code: $statusCode";
  @override
  String toString() => getMssg();
}

class CreateJobSocketException implements Exception {
  final String mssg;
  CreateJobSocketException(
      [this.mssg = "Invalid URL used for creating a job!"]);

  @override
  String toString() => mssg;
}

class UploadFileException implements Exception {
  final int statusCode;
  UploadFileException(this.statusCode);
  String getMssg() => "Unable to upload the file. Status code: $statusCode";
  @override
  String toString() => getMssg();
}

class UploadFileSocketException implements Exception {
  final String mssg;
  UploadFileSocketException(
      [this.mssg = "Invalid URL used for uploading the file!"]);

  @override
  String toString() => mssg;
}

class FetchFileDownloadUrlException implements Exception {
  final int statusCode;
  FetchFileDownloadUrlException(this.statusCode);
  String getMssg() => "Unable to fetch job status. Status code: $statusCode";
  @override
  String toString() => getMssg();
}

class FetchFileDownloadUrlSocketException implements Exception {
  final String mssg;
  FetchFileDownloadUrlSocketException(
      [this.mssg = "Invalid URL used for fetching file download URL!"]);

  @override
  String toString() => mssg;
}

class FetchFileSizeException implements Exception {
  final int statusCode;
  FetchFileSizeException(this.statusCode);
  String getMssg() => "Unable to fetch file size. Status code: $statusCode!";
  @override
  String toString() => getMssg();
}

class FetchFileSizeSocketException implements Exception {
  final String mssg;
  FetchFileSizeSocketException(
      [this.mssg = "Invalid URL used fetching file size!"]);

  @override
  String toString() => mssg;
}



