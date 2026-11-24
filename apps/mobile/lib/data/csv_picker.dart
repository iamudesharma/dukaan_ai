import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class PickedCsv {
  const PickedCsv({required this.filename, required this.bytes});

  final String filename;
  final List<int> bytes;
}

abstract interface class CsvPicker {
  Future<PickedCsv?> pick();
}

class FilePickerCsvPicker implements CsvPicker {
  const FilePickerCsvPicker();

  @override
  Future<PickedCsv?> pick() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return null;
    return PickedCsv(filename: file.name, bytes: bytes);
  }
}

final csvPickerProvider =
    Provider<CsvPicker>((ref) => const FilePickerCsvPicker());
