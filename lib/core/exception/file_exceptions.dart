
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
