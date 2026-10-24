import 'package:convertify/core/exception/file_exceptions.dart';
import 'package:flutter/services.dart';

/// One file in the converted-files folder.
class FolderEntry {
  final String uri;
  final String name;
  final int? sizeBytes;
  final DateTime? modified;

  const FolderEntry(
      {required this.uri, required this.name, this.sizeBytes, this.modified});

  factory FolderEntry.fromMap(Map map) {
    final modified = map['modified'] as int?;
    return FolderEntry(
      uri: map['uri'] as String,
      name: map['name'] as String,
      sizeBytes: map['size'] as int?,
      modified:
          modified == null ? null : DateTime.fromMillisecondsSinceEpoch(modified),
    );
  }
}

enum OpenResult { done, noApp, missing }

/// The folder the user picked for converted files (Storage Access Framework,
/// implemented in MainActivity.kt). Files there show up in file managers and
/// stay after a reinstall. No storage permission needed.
class FolderStorage {
  static const _channel = MethodChannel("convertify/storage");

  /// Opens the system folder picker. Returns the folder's tree URI, or null
  /// when the user backed out.
  Future<String?> pickFolder() => _call<String>("pickFolder");

  /// False after a reinstall, or when the folder was deleted.
  Future<bool> hasAccess(String treeUri) async =>
      await _call<bool>("hasAccess", {"treeUri": treeUri}) ?? false;

  Future<List<FolderEntry>> list(String treeUri) async {
    final raw = await _call<List>("list", {"treeUri": treeUri}) ?? const [];
    return [for (final item in raw) FolderEntry.fromMap(item as Map)];
  }

  /// Copies [sourcePath] into the folder as [name]. The returned entry has the
  /// final name, which differs when a file with that name already exists.
  Future<FolderEntry> write(String treeUri, String name, String sourcePath) async {
    final raw = await _call<Map>("write",
        {"treeUri": treeUri, "name": name, "sourcePath": sourcePath});
    return FolderEntry.fromMap(raw!);
  }

  Future<void> delete(String uri) => _call<bool>("delete", {"uri": uri});

  Future<OpenResult> open(String uri, String name) async {
    final result = await _call<String>("open", {"uri": uri, "name": name});
    return switch (result) {
      "done" => OpenResult.done,
      "missing" => OpenResult.missing,
      _ => OpenResult.noApp,
    };
  }

  Future<void> share(String uri, String name) =>
      _call<void>("share", {"uri": uri, "name": name});

  Future<T?> _call<T>(String method, [Map<String, Object?>? args]) async {
    try {
      return await _channel.invokeMethod<T>(method, args);
    } on PlatformException catch (e) {
      throw switch (e.code) {
        "folder_unavailable" => FolderUnavailableException(),
        "missing" => FileMissingException(),
        _ => e,
      };
    }
  }
}
