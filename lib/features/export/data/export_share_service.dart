import 'dart:convert';

import 'package:share_plus/share_plus.dart';

class ExportShareService {
  static Future<void> shareTextFile({
    required String fileName,
    required String mimeType,
    required String contents,
  }) async {
    final file = XFile.fromData(
      utf8.encode(contents),
      mimeType: mimeType,
      name: fileName,
    );
    await Share.shareXFiles(
      [file],
      subject: 'Dreaming export',
      text: 'Local Dreaming journal export from this device.',
      fileNameOverrides: [fileName],
    );
  }
}
