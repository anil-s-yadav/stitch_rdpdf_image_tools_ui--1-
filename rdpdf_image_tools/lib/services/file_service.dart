import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Service for saving and sharing files.
class FileService {
  /// Save a file to the app's documents directory.
  static Future<File> saveToDocuments(File file, {String? fileName}) async {
    final dir = await getApplicationDocumentsDirectory();
    final name = fileName ?? path.basename(file.path);
    final destPath = path.join(dir.path, name);
    return await file.copy(destPath);
  }

  /// Share a file using the system share sheet.
  static Future<void> shareFile(String filePath, {String? subject}) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: subject,
    );
  }

  /// Get file info (size, name, etc.)
  static Future<Map<String, dynamic>> getFileInfo(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return {};

    final stat = await file.stat();
    return {
      'name': path.basename(filePath),
      'extension': path.extension(filePath).replaceFirst('.', '').toUpperCase(),
      'size': stat.size,
      'modified': stat.modified,
    };
  }
}
