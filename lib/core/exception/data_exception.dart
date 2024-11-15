class EmptyDataStorageException implements Exception {
  final String mssg;
  EmptyDataStorageException([this.mssg = "Faild to store empty data!"]);
  @override
  String toString() => mssg;
}
class NullDataException implements Exception {
  final String mssg;
  NullDataException([this.mssg = "Null data!"]);
  @override
  String toString() => mssg;
}
