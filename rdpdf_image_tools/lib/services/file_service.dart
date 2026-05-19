import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported output formats for image processing.
enum OutputFormat { png, jpeg, pdf }

/// Metadata for a saved file, persisted via SharedPreferences.
class SavedFileMeta {
  final String filePath;
  final String name;
  final String toolName;
  final String format;
  final int sizeBytes;
  final DateTime savedAt;

  SavedFileMeta({
    required this.filePath,
    required this.name,
    required this.toolName,
    required this.format,
    required this.sizeBytes,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
    'filePath': filePath,
    'name': name,
    'toolName': toolName,
    'format': format,
    'sizeBytes': sizeBytes,
    'savedAt': savedAt.toIso8601String(),
  };

  factory SavedFileMeta.fromJson(Map<String, dynamic> json) => SavedFileMeta(
    filePath: json['filePath'] as String,
    name: json['name'] as String,
    toolName: json['toolName'] as String? ?? '',
    format: json['format'] as String? ?? '',
    sizeBytes: json['sizeBytes'] as int? ?? 0,
    savedAt: DateTime.tryParse(json['savedAt'] as String? ?? '') ?? DateTime.now(),
  );

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(savedAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${savedAt.day}/${savedAt.month}/${savedAt.year}';
  }

  /// Category based on format extension, file name, and tool name.
  String get category {
    final ext = path.extension(filePath).toLowerCase();
    if (ext == '.pdf') return 'pdf';
    final lowerName = name.toLowerCase();
    final lowerTool = toolName.toLowerCase();
    if (lowerName.contains('sign') ||
        lowerName.contains('sig') ||
        lowerTool.contains('signature')) {
      return 'signature';
    }
    return 'image';
  }
}

/// Service for saving, tracking, and sharing files.
class FileService {
  static const _prefsKey = 'saved_files_v1';

  /// Get the RedImage output directory on device storage.
  static Future<Directory> get _outputDir async {
    // On Android, use /storage/emulated/0/Download/RedImage
    // On other platforms, fallback to app documents
    if (Platform.isAndroid) {
      final dir = Directory('/storage/emulated/0/Download/RedImage');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir;
    }
    // Fallback for iOS / desktop
    final dir = Directory(
      path.join(
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '.',
        'Downloads',
        'RedImage',
      ),
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Save a processed file to Downloads/RedImage/ and record it in SharedPreferences.
  ///
  /// If [outputFormat] is provided, the image will be converted to that format
  /// before saving (PNG, JPEG, or PDF).
  static Future<File> saveToRedImage(
    File file, {
    String? fileName,
    String toolName = '',
    OutputFormat? outputFormat,
  }) async {
    final dir = await _outputDir;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final baseName = fileName ??
        path.basenameWithoutExtension(file.path);

    // Determine target extension
    String ext;
    if (outputFormat != null) {
      switch (outputFormat) {
        case OutputFormat.png:
          ext = '.png';
        case OutputFormat.jpeg:
          ext = '.jpg';
        case OutputFormat.pdf:
          ext = '.pdf';
      }
    } else {
      ext = path.extension(file.path);
      if (ext.isEmpty) ext = '.png';
    }

    final destName = '${baseName}_$timestamp$ext';
    final destPath = path.join(dir.path, destName);

    File savedFile;

    // Convert format if needed
    final sourceExt = path.extension(file.path).toLowerCase();
    final isSourceImage = ['.jpg', '.jpeg', '.png', '.webp', '.bmp']
        .contains(sourceExt);

    if (outputFormat == OutputFormat.pdf && isSourceImage) {
      // Convert image → PDF
      savedFile = await _imageToPdf(file, destPath);
    } else if (outputFormat == OutputFormat.png && sourceExt != '.png' && isSourceImage) {
      // Convert → PNG
      final result = await FlutterImageCompress.compressWithFile(
        file.path,
        quality: 100,
        format: CompressFormat.png,
      );
      savedFile = File(destPath);
      if (result != null) {
        await savedFile.writeAsBytes(result);
      } else {
        savedFile = await file.copy(destPath);
      }
    } else if (outputFormat == OutputFormat.jpeg && sourceExt != '.jpg' &&
        sourceExt != '.jpeg' && isSourceImage) {
      // Convert → JPEG
      final result = await FlutterImageCompress.compressWithFile(
        file.path,
        quality: 95,
        format: CompressFormat.jpeg,
      );
      savedFile = File(destPath);
      if (result != null) {
        await savedFile.writeAsBytes(result);
      } else {
        savedFile = await file.copy(destPath);
      }
    } else {
      // No conversion needed, just copy
      savedFile = await file.copy(destPath);
    }

    // Record in SharedPreferences
    final meta = SavedFileMeta(
      filePath: savedFile.path,
      name: destName,
      toolName: toolName,
      format: ext.replaceFirst('.', '').toUpperCase(),
      sizeBytes: await savedFile.length(),
      savedAt: DateTime.now(),
    );
    await _addRecord(meta);

    return savedFile;
  }

  /// Convert an image file to a single-page PDF.
  static Future<File> _imageToPdf(File imageFile, String destPath) async {
    final pdf = pw.Document();
    final imageBytes = await imageFile.readAsBytes();
    final image = pw.MemoryImage(imageBytes);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (context) => pw.Center(
          child: pw.Image(image, fit: pw.BoxFit.contain),
        ),
      ),
    );

    final outFile = File(destPath);
    await outFile.writeAsBytes(await pdf.save());
    return outFile;
  }

  /// Get all saved file records from SharedPreferences.
  static Future<List<SavedFileMeta>> getSavedFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_prefsKey) ?? [];
    final files = <SavedFileMeta>[];

    for (final jsonStr in jsonList) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        final meta = SavedFileMeta.fromJson(map);
        // Only include files that still exist on disk
        if (File(meta.filePath).existsSync()) {
          files.add(meta);
        }
      } catch (_) {
        // Skip corrupted entries
      }
    }

    // Sort newest first
    files.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return files;
  }

  /// Add a file record to SharedPreferences.
  static Future<void> _addRecord(SavedFileMeta meta) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_prefsKey) ?? [];
    jsonList.add(jsonEncode(meta.toJson()));
    await prefs.setStringList(_prefsKey, jsonList);
  }

  /// Remove a file record from SharedPreferences and delete from disk.
  static Future<void> deleteFile(String filePath) async {
    // Delete from disk
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }

    // Remove from prefs
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_prefsKey) ?? [];
    jsonList.removeWhere((jsonStr) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        return map['filePath'] == filePath;
      } catch (_) {
        return false;
      }
    });
    await prefs.setStringList(_prefsKey, jsonList);
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
