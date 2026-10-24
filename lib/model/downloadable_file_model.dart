import 'package:convertify/service/folder_storage.dart';
import 'package:convertify/utils/format_utils.dart';

/// A converted file. Once [uri] is set it lives in the user's folder and stays
/// until they delete it. Until then it only exists on CloudConvert (and maybe
/// in the 1.x cache at [localPath]) and has to be copied in before
/// [linkExpiresAt].
class DownloadableFileModel {
  final String fileId;
  final String fileName;
  final String fileSize;
  final int? sizeBytes;
  final String fileOutputFormat;
  final DateTime convertedAt;

  /// content:// URI of the file in the folder.
  final String? uri;

  final String? fileDownloadUrl;
  final DateTime? linkExpiresAt;

  /// Cached copy from 1.x, used once to move older files into the folder.
  final String? localPath;

  const DownloadableFileModel({
    required this.fileId,
    required this.fileName,
    required this.fileSize,
    required this.fileOutputFormat,
    required this.convertedAt,
    this.sizeBytes,
    this.uri,
    this.fileDownloadUrl,
    this.linkExpiresAt,
    this.localPath,
  });

  /// A file found in the folder. Its URI doubles as its id.
  factory DownloadableFileModel.fromFolder(FolderEntry entry) {
    return DownloadableFileModel(
      fileId: entry.uri,
      fileName: entry.name,
      fileSize: entry.sizeBytes == null
          ? ""
          : FormatUtils.formatFileSizeWithUnits(entry.sizeBytes!),
      sizeBytes: entry.sizeBytes,
      fileOutputFormat: FormatUtils.extensionOf(entry.name) ?? "",
      convertedAt: entry.modified ?? DateTime.now(),
      uri: entry.uri,
    );
  }

  bool get isInFolder => uri != null;

  bool get isLinkExpired =>
      linkExpiresAt != null && DateTime.now().isAfter(linkExpiresAt!);

  DownloadableFileModel withoutLocalPath() => DownloadableFileModel(
        fileId: fileId,
        fileName: fileName,
        fileSize: fileSize,
        sizeBytes: sizeBytes,
        fileOutputFormat: fileOutputFormat,
        convertedAt: convertedAt,
        uri: uri,
        fileDownloadUrl: fileDownloadUrl,
        linkExpiresAt: linkExpiresAt,
      );

  // Only files not yet in the folder are stored. Keys match the 1.0 format so
  // files stored by older versions still load (and get moved into the folder).
  factory DownloadableFileModel.fromJson(Map<String, dynamic> json) {
    final expires = json['fileExpireDate'] as String?;
    return DownloadableFileModel(
      fileId: json['fileId'] as String,
      fileName: json['fileName'] as String,
      fileSize: (json['fileSize'] ?? '') as String,
      fileOutputFormat: (json['outputFormat'] ?? '') as String,
      fileDownloadUrl: json['fileDownloadUrl'] as String?,
      convertedAt: DateTime.parse(json['fileConvertedDate'] as String),
      linkExpiresAt: expires == null ? null : DateTime.parse(expires),
      localPath: json['localPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'fileId': fileId,
        'fileName': fileName,
        'fileSize': fileSize,
        'outputFormat': fileOutputFormat,
        'fileDownloadUrl': fileDownloadUrl,
        'fileConvertedDate': convertedAt.toIso8601String(),
        'fileExpireDate': linkExpiresAt?.toIso8601String(),
        'localPath': localPath,
      };
}
