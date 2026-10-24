import 'package:convertify/core/constant/format_info.dart';
import 'package:convertify/core/theme/app_colors.dart';
import 'package:convertify/model/downloadable_file_model.dart';
import 'package:convertify/service/folder_storage.dart';
import 'package:convertify/utils/format_utils.dart';
import 'package:convertify/utils/generate_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormatUtils.changeFileExtension', () {
    test('replaces only the last extension', () {
      expect(FormatUtils.changeFileExtension('report.final.docx', 'pdf'),
          'report.final.pdf');
    });
    test('appends when the name has no extension', () {
      expect(FormatUtils.changeFileExtension('README', 'txt'), 'README.txt');
    });
    test('keeps dotfiles intact', () {
      expect(FormatUtils.changeFileExtension('.env', 'txt'), '.env.txt');
    });
    test('lower-cases the new extension', () {
      expect(FormatUtils.changeFileExtension('a.png', 'JPG'), 'a.jpg');
    });
  });

  group('FormatUtils.extensionOf', () {
    test('returns the lower-case extension', () {
      expect(FormatUtils.extensionOf('Photo.HEIC'), 'heic');
    });
    test('returns null without one', () {
      expect(FormatUtils.extensionOf('Makefile'), isNull);
      expect(FormatUtils.extensionOf('trailing.'), isNull);
    });
  });

  group('FormatUtils.formatFileSizeWithUnits', () {
    test('picks sensible units and precision', () {
      expect(FormatUtils.formatFileSizeWithUnits(0), '0 B');
      expect(FormatUtils.formatFileSizeWithUnits(512), '512 B');
      expect(FormatUtils.formatFileSizeWithUnits(1024), '1 KB');
      expect(FormatUtils.formatFileSizeWithUnits(1536), '1.5 KB');
      expect(FormatUtils.formatFileSizeWithUnits(2516582), '2.4 MB');
      expect(FormatUtils.formatFileSizeWithUnits(31457280), '30 MB');
    });
  });

  group('FormatUtils.formatFileName', () {
    test('keeps the extension visible when trimming', () {
      final out = FormatUtils.formatFileName(
          'a-very-long-project-proposal-final-v2.docx', 20);
      expect(out.length, 20);
      expect(out.endsWith('.docx'), isTrue);
    });
  });

  group('GenerateUtils.generateIdWithDate', () {
    test('zero-pads so Jan 11 and Nov 1 differ', () {
      final jan11 = GenerateUtils.generateIdWithDate('C',
          now: DateTime(2026, 1, 11, 1, 2, 3, 4));
      final nov1 = GenerateUtils.generateIdWithDate('C',
          now: DateTime(2026, 11, 1, 1, 2, 3, 4));
      expect(jan11.startsWith('C_20260111_010203_004_'), isTrue);
      expect(nov1.startsWith('C_20261101_010203_004_'), isTrue);
    });
    test('is unique within the same millisecond', () {
      final t = DateTime(2026, 1, 1);
      expect(GenerateUtils.generateIdWithDate('C', now: t),
          isNot(GenerateUtils.generateIdWithDate('C', now: t)));
    });
  });

  group('FormatInfo', () {
    test('suggests only formats that are available', () {
      expect(FormatInfo.suggestionsFor('docx', ['pdf', 'txt', 'html']),
          ['pdf', 'txt']);
    });
    test('falls back to PDF for unknown inputs', () {
      expect(FormatInfo.suggestionsFor('xyz', ['pdf', 'png']), ['pdf']);
    });
    test('PDF badges are red, images green', () {
      const c = AppColors.light;
      expect(FormatInfo.badgeFor('pdf', c), same(c.badgeRed));
      expect(FormatInfo.badgeFor('PNG', c), same(c.badgeGreen));
    });
  });

  group('DownloadableFileModel', () {
    test('reads data stored by version 1.0 as a pending file', () {
      final model = DownloadableFileModel.fromJson({
        'fileId': 'Convertify_2025112',
        'fileName': 'report.pdf',
        'fileSize': '1.20 MB',
        'outputFormat': 'pdf',
        'fileDownloadUrl': 'https://example.com/f',
        // 1.0 stored DateTime.toString(), not ISO 8601.
        'fileConvertedDate': '2025-01-12 10:20:30.123456',
        'fileExpireDate': '2025-01-13 10:20:30.123456',
        'savedToDevice': true, // 1.x field, ignored now
      });
      expect(model.fileOutputFormat, 'pdf');
      expect(model.isInFolder, isFalse);
      expect(model.isLinkExpired, isTrue);
      expect(model.linkExpiresAt!.difference(model.convertedAt).inHours, 24);
    });

    test('round-trips through JSON', () {
      final original = DownloadableFileModel(
        fileId: 'id',
        fileName: 'a.pdf',
        fileSize: '1 MB',
        fileOutputFormat: 'pdf',
        fileDownloadUrl: 'https://example.com/a',
        convertedAt: DateTime(2026, 10, 24, 12),
        linkExpiresAt: DateTime(2026, 10, 25, 12),
        localPath: '/tmp/a.pdf',
      );
      final copy = DownloadableFileModel.fromJson(original.toJson());
      expect(copy.localPath, '/tmp/a.pdf');
      expect(copy.fileDownloadUrl, 'https://example.com/a');
      expect(copy.linkExpiresAt, original.linkExpiresAt);
      expect(copy.withoutLocalPath().localPath, isNull);
    });

    test('builds a file from a folder entry', () {
      final model = DownloadableFileModel.fromFolder(FolderEntry(
        uri: 'content://docs/tree/x/document/x%2FReport.PDF',
        name: 'Report.PDF',
        sizeBytes: 1536,
        modified: DateTime(2026, 10, 24, 9),
      ));
      expect(model.isInFolder, isTrue);
      expect(model.fileId, model.uri);
      expect(model.fileOutputFormat, 'pdf');
      expect(model.fileSize, '1.5 KB');
      expect(model.convertedAt, DateTime(2026, 10, 24, 9));
      expect(model.isLinkExpired, isFalse);
    });
  });

  group('FolderEntry.fromMap', () {
    test('reads what MainActivity sends, with optional fields', () {
      final full = FolderEntry.fromMap({
        'uri': 'content://a',
        'name': 'a.png',
        'size': 10,
        'modified': DateTime(2026, 1, 2).millisecondsSinceEpoch,
      });
      expect(full.sizeBytes, 10);
      expect(full.modified, DateTime(2026, 1, 2));

      final bare = FolderEntry.fromMap(
          {'uri': 'content://b', 'name': 'b', 'size': null, 'modified': null});
      expect(bare.sizeBytes, isNull);
      expect(bare.modified, isNull);
    });
  });
}
