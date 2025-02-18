class DownloadableFileModel {
  String? fileId;
  String? fileName;
  String? fileSize;
  String? fileOutputFormat;
  String? fileDownloadUrl;
  String? fileConvertedDate;
  String? fileExpireDate;

  DownloadableFileModel(
      {this.fileId,
      this.fileName,
      this.fileSize,
      this.fileOutputFormat,
      this.fileDownloadUrl,
      this.fileConvertedDate,
      this.fileExpireDate});

  DownloadableFileModel.fromJson(Map<String, dynamic> json) {
    fileId = json['fileId'];
    fileName = json['fileName'];
    fileSize = json['fileSize'];
    fileOutputFormat = json['outputFormat'];
    fileDownloadUrl = json['fileDownloadUrl'];
    fileConvertedDate = json['fileConvertedDate'];
    fileExpireDate = json['fileExpireDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fileId'] = this.fileId;
    data['fileName'] = this.fileName;
    data['fileSize'] = this.fileSize;
    data['outputFormat'] = this.fileOutputFormat;
    data['fileDownloadUrl'] = this.fileDownloadUrl;
    data['fileConvertedDate'] = this.fileConvertedDate;
    data['fileExpireDate'] = this.fileExpireDate; 
    return data;
  }
}
