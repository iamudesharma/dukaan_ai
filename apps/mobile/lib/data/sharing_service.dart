import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class AppShareService {
  Future<void> shareText(String text);
  Future<void> shareFile({
    required String filename,
    required List<int> bytes,
    required String mimeType,
  });
}

class SharePlusAppShareService implements AppShareService {
  const SharePlusAppShareService();

  @override
  Future<void> shareText(String text) async {
    await SharePlus.instance.share(ShareParams(text: text));
  }

  @override
  Future<void> shareFile({
    required String filename,
    required List<int> bytes,
    required String mimeType,
  }) async {
    if (bytes.isEmpty) {
      throw ArgumentError.value(bytes, 'bytes', 'File is empty.');
    }
    final directory = await getTemporaryDirectory();
    final safeName = _safeFilename(filename);
    final file = File('${directory.path}/$safeName');
    await file.writeAsBytes(bytes, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: mimeType, name: safeName)],
        fileNameOverrides: [safeName],
      ),
    );
  }

  static String _safeFilename(String value) {
    final base = value.replaceAll('\\', '/').split('/').last;
    final safe = base
        .replaceAll(RegExp(r'[\x00-\x1f\x7f]'), '_')
        .replaceAll(RegExp(r'[^A-Za-z0-9._ -]'), '_')
        .replaceAll(RegExp(r'\.{2,}'), '_')
        .trim()
        .replaceAll(RegExp(r'^[. ]+|[. ]+$'), '');
    return safe.isEmpty ? 'dukaan-file' : safe;
  }
}

final appShareServiceProvider = Provider<AppShareService>(
  (ref) => const SharePlusAppShareService(),
);
