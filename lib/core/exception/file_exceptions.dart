class FileFormatUnknownException implements Exception {
  final String mssg;
  FileFormatUnknownException([this.mssg = "File format is unknown!"]);

  @override
  String toString() => mssg;
}

class NullPickResultException implements Exception {
  final String mssg;
  NullPickResultException([this.mssg = "Pick file result is null!"]);

  @override
  String toString() => mssg;
}

class FileTooLargeException implements Exception {
  final int limitInMB;
  FileTooLargeException(this.limitInMB);

  @override
  String toString() => "File is larger than $limitInMB MB.";
}

/// The converted-files folder is gone or the app lost access to it (e.g.
/// after a reinstall).
class FolderUnavailableException implements Exception {
  @override
  String toString() => "The converted-files folder can't be reached.";
}

/// The file was moved or deleted outside the app.
class FileMissingException implements Exception {
  @override
  String toString() => "The file no longer exists.";
}

/// CloudConvert already deleted the result and there is no local copy.
class DownloadLinkExpiredException implements Exception {
  @override
  String toString() => "The download link has expired.";
}
