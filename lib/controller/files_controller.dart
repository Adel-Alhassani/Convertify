import 'dart:async';
import 'dart:io';

import 'package:convertify/core/exception/exceptions_handler.dart';
import 'package:convertify/core/exception/file_exceptions.dart';
import 'package:convertify/core/logger.dart';
import 'package:convertify/core/shared/app_dialogs.dart';
import 'package:convertify/data/preferences_helper.dart';
import 'package:convertify/model/downloadable_file_model.dart';
import 'package:convertify/service/file_service.dart';
import 'package:convertify/service/folder_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

/// Converted files. They are kept in a folder the user picks once (normally
/// Download/Convertify), so they stay until deleted and show up in file
/// managers. The list is read from that folder, plus any results that
/// haven't been copied in yet.
class FilesController extends GetxController with WidgetsBindingObserver {
  FilesController(
      {required PreferencesHelper prefs,
      FileService? service,
      FolderStorage? storage})
      : _prefs = prefs,
        _service = service ?? FileService(),
        _storage = storage ?? FolderStorage();

  final PreferencesHelper _prefs;
  final FileService _service;
  final FolderStorage _storage;

  /// Newest first.
  final RxList<DownloadableFileModel> files = <DownloadableFileModel>[].obs;
  final RxString query = "".obs;

  /// False until the user picks a folder, and again after a reinstall.
  final RxBool hasFolder = false.obs;

  /// Download progress (0–1) per file id while a result is copied in.
  final RxMap<String, double> downloadProgress = <String, double>{}.obs;

  /// Not in the folder yet. Stored in preferences.
  final List<DownloadableFileModel> _pending = [];

  /// Read from the folder.
  List<DownloadableFileModel> _inFolder = [];

  /// Pending id -> id in the folder, so a screen holding the old model can
  /// find the file after it moves.
  final Map<String, String> _movedTo = {};

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    for (final f in _prefs.fetchDownloadableFiles()) {
      final cached = f.localPath;
      final keep = cached != null && File(cached).existsSync();
      _pending.add(keep ? f : f.withoutLocalPath());
    }
    _publish();
    reload().then((_) => _moveAllIntoFolder());
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  /// Files may have been deleted or renamed in a file manager meanwhile.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) reload();
  }

  DownloadableFileModel? get mostRecent => files.isEmpty ? null : files.first;

  /// The live copy of a file, following it into the folder once it moves.
  DownloadableFileModel? find(String fileId) {
    final id = _movedTo[fileId] ?? fileId;
    return files.firstWhereOrNull((f) => f.fileId == id);
  }

  /// Gone from CloudConvert and never copied in.
  bool isUnavailable(DownloadableFileModel f) =>
      !f.isInFolder && f.localPath == null && f.isLinkExpired;

  int get totalBytes =>
      _inFolder.fold(0, (sum, f) => sum + (f.sizeBytes ?? 0));

  List<DownloadableFileModel> get visibleFiles {
    final q = query.value.trim().toLowerCase();
    if (q.isEmpty) return files;
    return files.where((f) => f.fileName.toLowerCase().contains(q)).toList();
  }

  /// Re-reads the folder.
  Future<void> reload() async {
    final tree = _prefs.fetchFolderUri();
    var listed = <DownloadableFileModel>[];
    var ok = false;
    if (tree != null) {
      try {
        if (await _storage.hasAccess(tree)) {
          listed = (await _storage.list(tree))
              .map(DownloadableFileModel.fromFolder)
              .toList();
          ok = true;
        }
      } catch (e) {
        logger.w("Could not read the files folder: $e");
      }
    }
    _inFolder = listed;
    hasFolder.value = ok;
    _publish();
  }

  /// Opens the system folder picker. Also how files come back after a
  /// reinstall: picking the same folder lists them again.
  Future<bool> chooseFolder() async {
    final ok = await _pickFolder();
    if (ok) unawaited(_moveAllIntoFolder());
    return ok;
  }

  /// Explains why, then opens the picker. True when there is a folder.
  Future<bool> ensureFolder() async {
    if (hasFolder.value) return true;
    final ok = await _explainAndPick();
    if (ok) unawaited(_moveAllIntoFolder());
    return ok;
  }

  /// A new result from CloudConvert. Copied into the folder in the background;
  /// screens show [downloadProgress] meanwhile.
  Future<void> add(DownloadableFileModel file) async {
    _pending.insert(0, file);
    _publish();
    await _persist();
    if (hasFolder.value) unawaited(saveToFolder(file));
  }

  /// Copies a pending file into the folder, asking for one first if needed.
  Future<void> saveToFolder(DownloadableFileModel file) async {
    try {
      await _copyIntoFolder(file);
    } catch (e) {
      ExceptionsHandler.handle(e, "Failed to save the file");
    }
  }

  Future<void> delete(DownloadableFileModel file) async {
    try {
      final uri = file.uri;
      if (uri != null) await _storage.delete(uri);
    } catch (e) {
      ExceptionsHandler.handle(e, "Failed to delete the file");
      return;
    }
    if (file.isInFolder) {
      _inFolder.removeWhere((f) => f.fileId == file.fileId);
    } else {
      _pending.removeWhere((f) => f.fileId == file.fileId);
      await _deleteCache(file.localPath);
      await _persist();
    }
    _publish();
  }

  Future<void> share(DownloadableFileModel file) async {
    try {
      final saved = await _inFolderOrCopy(file);
      if (saved == null) return;
      await _storage.share(saved.uri!, saved.fileName);
    } on FileMissingException catch (e) {
      ExceptionsHandler.handle(e);
      await reload();
    } catch (e) {
      ExceptionsHandler.handle(e, "Failed to share the file");
    }
  }

  Future<void> open(DownloadableFileModel file) async {
    try {
      final saved = await _inFolderOrCopy(file);
      if (saved == null) return;
      switch (await _storage.open(saved.uri!, saved.fileName)) {
        case OpenResult.done:
          break;
        case OpenResult.noApp:
          AppDialogs.showMessage("error".tr, "no_app_to_open".tr);
        case OpenResult.missing:
          ExceptionsHandler.handle(FileMissingException());
          await reload();
      }
    } catch (e) {
      ExceptionsHandler.handle(e, "Failed to open the file");
    }
  }

  // ---- internals ----

  Future<DownloadableFileModel?> _inFolderOrCopy(
      DownloadableFileModel file) async {
    if (file.isInFolder) return file;
    return _copyIntoFolder(file);
  }

  /// Returns the file in the folder, or null when the user didn't pick one.
  Future<DownloadableFileModel?> _copyIntoFolder(DownloadableFileModel file,
      {bool ask = true}) async {
    if (file.isInFolder) return file;
    var picked = false;
    if (!hasFolder.value) {
      if (!ask || !await _explainAndPick()) return null;
      picked = true;
    }
    if (downloadProgress.containsKey(file.fileId)) return null;
    final tree = _prefs.fetchFolderUri()!;

    downloadProgress[file.fileId] = 0;
    String? temp;
    try {
      var source = file.localPath;
      if (source == null || !await File(source).exists()) {
        final url = file.fileDownloadUrl;
        if (url == null || file.isLinkExpired) {
          throw DownloadLinkExpiredException();
        }
        final dir = Directory(
            "${(await getTemporaryDirectory()).path}/incoming/${file.fileId}");
        await dir.create(recursive: true);
        source = temp = "${dir.path}/${file.fileName}";
        await _service.downloadFile(url, source,
            onProgress: (p) => downloadProgress[file.fileId] = p);
      }

      final saved = DownloadableFileModel.fromFolder(
          await _storage.write(tree, file.fileName, source));
      _pending.removeWhere((f) => f.fileId == file.fileId);
      _inFolder.add(saved);
      _movedTo[file.fileId] = saved.fileId;
      _publish();
      await _persist();
      await _deleteCache(file.localPath);
      // The rest wait until this one is done so it isn't copied twice.
      if (picked) unawaited(_moveAllIntoFolder());
      return saved;
    } on FolderUnavailableException {
      await reload();
      rethrow;
    } finally {
      downloadProgress.remove(file.fileId);
      await _deleteCache(temp);
    }
  }

  Future<bool> _explainAndPick() async {
    final ok = await AppDialogs.confirm(
      title: "choose_folder_title".tr,
      message: "choose_folder_body".tr,
      confirmLabel: "choose_folder".tr,
    );
    return ok && await _pickFolder();
  }

  Future<bool> _pickFolder() async {
    try {
      final tree = await _storage.pickFolder();
      if (tree == null) return false; // user backed out
      await _prefs.storeFolderUri(tree);
      await reload();
      return hasFolder.value;
    } catch (e) {
      ExceptionsHandler.handle(e, "Failed to choose a folder");
      return false;
    }
  }

  /// After picking a folder or starting the app: copies in whatever is still
  /// pending (results from a run whose download failed, or files from 1.x).
  Future<void> _moveAllIntoFolder() async {
    if (!hasFolder.value) return;
    for (final f in List.of(_pending)) {
      if (isUnavailable(f)) continue;
      try {
        await _copyIntoFolder(f, ask: false);
      } catch (e) {
        logger.w("Could not move ${f.fileName} into the folder: $e");
      }
    }
  }

  void _publish() {
    files.assignAll([..._pending, ..._inFolder]
      ..sort((a, b) => b.convertedAt.compareTo(a.convertedAt)));
  }

  Future<void> _deleteCache(String? path) async {
    if (path == null) return;
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (e) {
      logger.w("Could not delete cached copy $path: $e");
    }
  }

  Future<void> _persist() => _prefs.storeDownloadableFiles(_pending);
}
