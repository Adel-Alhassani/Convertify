class ConvertingFileModel {
  String? fileName;
  String? fileSize;
  String? inputFormat;
  String? outputFormat;
  String? jobId;

  ConvertingFileModel(
      {this.fileName,
      this.fileSize,
      this.inputFormat,
      this.outputFormat,
      this.jobId});

  ConvertingFileModel.fromJson(Map<String, dynamic> json) {
    fileName = json['fileName'];
    fileSize = json['fileSize'];
    inputFormat = json['inputFormat'];
    outputFormat = json['outputFormat'];
    jobId = json['jobId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fileName'] = this.fileName;
    data['fileSize'] = this.fileSize;
    data['inputFormat'] = this.inputFormat;
    data['outputFormat'] = this.outputFormat;
    data['jobId'] = this.jobId;
    return data;
  }

  setFields({
    required String? fileName,
    required String? fileSize,
    required String? inputFormat,
    required String? outputFormat,
    required String? jobId,
  }) {
    this.fileName = fileName;
    this.fileSize = fileSize;
    this.inputFormat = inputFormat;
    this.outputFormat = outputFormat;
    this.jobId = jobId;
  }

  void clear() {
    fileName = null;
    fileSize = null;
    inputFormat = null;
    outputFormat = null;
    jobId = null;
  }
}
