import 'package:convertify/core/theme/app_colors.dart';

/// Static knowledge about file formats that CloudConvert doesn't provide:
/// badge colours, short descriptions and suggestions.
class FormatInfo {
  static const _documents = {
    "doc", "docx", "odt", "rtf", "txt", "md", "html", "htm", "pages", "tex",
  };
  static const _spreadsheets = {"xls", "xlsx", "ods", "csv", "numbers"};
  static const _presentations = {"ppt", "pptx", "odp", "key"};
  static const _images = {
    "jpg", "jpeg", "png", "webp", "gif", "bmp", "tiff", "tif", "heic",
    "heif", "svg", "ico", "avif", "raw", "psd",
  };
  static const _audio = {"mp3", "wav", "aac", "flac", "ogg", "m4a", "wma", "opus"};
  static const _video = {"mp4", "mov", "avi", "mkv", "webm", "wmv", "flv", "3gp", "m4v"};
  static const _ebooks = {"epub", "mobi", "azw3", "fb2"};
  static const _archives = {"zip", "rar", "7z", "tar", "gz"};

  /// Description keys, translated via GetX (`format_desc_pdf`, ...).
  static const _described = {
    "pdf", "docx", "doc", "odt", "txt", "rtf", "html", "md", "jpg", "png",
    "webp", "heic", "gif", "svg", "mp3", "wav", "m4a", "mp4", "mov", "webm",
    "epub", "xlsx", "csv", "pptx", "zip",
  };

  /// The most common targets per input type, shown first in the sheet.
  static const _suggestions = <String, List<String>>{
    "doc": ["pdf", "docx", "txt"],
    "docx": ["pdf", "odt", "txt"],
    "odt": ["pdf", "docx", "txt"],
    "rtf": ["pdf", "docx", "txt"],
    "txt": ["pdf", "docx", "html"],
    "pages": ["pdf", "docx", "txt"],
    "xls": ["xlsx", "pdf", "csv"],
    "xlsx": ["pdf", "csv", "ods"],
    "csv": ["xlsx", "pdf", "ods"],
    "ppt": ["pptx", "pdf", "jpg"],
    "pptx": ["pdf", "jpg", "png"],
    "pdf": ["docx", "jpg", "txt"],
    "heic": ["jpg", "png", "webp"],
    "heif": ["jpg", "png", "webp"],
    "jpg": ["png", "webp", "pdf"],
    "jpeg": ["png", "webp", "pdf"],
    "png": ["jpg", "webp", "pdf"],
    "webp": ["jpg", "png", "gif"],
    "gif": ["mp4", "png", "webp"],
    "svg": ["png", "jpg", "pdf"],
    "mp4": ["mp3", "gif", "webm"],
    "mov": ["mp4", "mp3", "gif"],
    "mkv": ["mp4", "mp3", "webm"],
    "webm": ["mp4", "mp3", "gif"],
    "wav": ["mp3", "m4a", "flac"],
    "m4a": ["mp3", "wav", "aac"],
    "flac": ["mp3", "wav", "m4a"],
    "mp3": ["wav", "m4a", "ogg"],
    "epub": ["pdf", "mobi", "azw3"],
    "mobi": ["epub", "pdf", "azw3"],
  };

  /// Shortcuts on the home screen: (from, to).
  static const popularConversions = [
    ("docx", "pdf"),
    ("heic", "jpg"),
    ("mp4", "mp3"),
    ("png", "webp"),
  ];

  static BadgeColors badgeFor(String format, AppColors c) {
    final f = format.toLowerCase();
    if (f == "pdf") return c.badgeRed;
    if (_documents.contains(f) || _presentations.contains(f)) {
      return c.badgeBlue;
    }
    if (_spreadsheets.contains(f) || _images.contains(f)) return c.badgeGreen;
    if (_audio.contains(f)) return c.badgeOrange;
    if (_video.contains(f) || _ebooks.contains(f)) return c.badgePurple;
    if (_archives.contains(f)) return c.badgeGray;
    return c.badgeGray;
  }

  /// Translation key for a one-line description, or null if we have none.
  static String? descriptionKey(String format) {
    final f = format.toLowerCase();
    return _described.contains(f) ? "format_desc_$f" : null;
  }

  /// Up to three suggested targets that are actually available.
  static List<String> suggestionsFor(
      String input, Iterable<String> available) {
    final set = available.toSet();
    final preferred = _suggestions[input.toLowerCase()] ?? const [];
    final picked = preferred.where(set.contains).toList();
    if (picked.length < 3 && set.contains("pdf") && !picked.contains("pdf")) {
      picked.add("pdf");
    }
    return picked.take(3).toList();
  }

  /// CloudConvert group names -> translation keys for the category tabs.
  static String groupLabelKey(String group) => "group_${group.toLowerCase()}";
}
