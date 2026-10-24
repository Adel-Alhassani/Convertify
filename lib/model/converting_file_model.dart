/// The conversion in progress, persisted so it can resume after the app is
/// killed.
class ConvertingFileModel {
  final String fileName;
  final String fileSize;
  final String inputFormat;
  final String outputFormat;
  final String jobId;

  const ConvertingFileModel({
    required this.fileName,
    required this.fileSize,
    required this.inputFormat,
    required this.outputFormat,
    required this.jobId,
  });

  factory ConvertingFileModel.fromJson(Map<String, dynamic> json) {
    return ConvertingFileModel(
      fileName: json['fileName'] as String,
      fileSize: (json['fileSize'] ?? '') as String,
      inputFormat: json['inputFormat'] as String,
      outputFormat: json['outputFormat'] as String,
      jobId: json['jobId'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'fileName': fileName,
        'fileSize': fileSize,
        'inputFormat': inputFormat,
        'outputFormat': outputFormat,
        'jobId': jobId,
      };
}
