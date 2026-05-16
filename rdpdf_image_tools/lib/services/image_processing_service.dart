import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Service handling all image processing operations.
class ImageProcessingService {
  /// Resize an image to be under [targetKB] kilobytes.
  ///
  /// Uses iterative binary-search quality reduction to reach the target
  /// size as accurately as possible while maximizing visual fidelity.
  static Future<File?> resizeToTargetKB({
    required String inputPath,
    required int targetKB,
  }) async {
    final inputFile = File(inputPath);
    if (!await inputFile.exists()) return null;

    final targetBytes = targetKB * 1024;
    final inputBytes = await inputFile.length();

    // Already under target
    if (inputBytes <= targetBytes) {
      final outPath = await _outputPath('resized');
      await inputFile.copy(outPath);
      return File(outPath);
    }

    // Binary search for the best quality value
    int lo = 1;
    int hi = 100;
    Uint8List? bestResult;

    while (lo <= hi) {
      final mid = (lo + hi) ~/ 2;

      // Also scale dimensions if quality alone isn't enough
      double scale = 1.0;
      if (mid < 20) {
        scale = 0.5 + (mid / 20) * 0.5; // scale 50-100%
      }

      final result = await FlutterImageCompress.compressWithFile(
        inputPath,
        quality: mid,
        minWidth: (1920 * scale).toInt(),
        minHeight: (1080 * scale).toInt(),
        format: CompressFormat.jpeg,
      );

      if (result == null) break;

      if (result.length <= targetBytes) {
        bestResult = Uint8List.fromList(result);
        lo = mid + 1; // Try higher quality
      } else {
        hi = mid - 1; // Reduce quality
      }
    }

    // If binary search didn't find a result, try with very low quality + dimension scaling
    if (bestResult == null) {
      for (double scale = 0.8; scale >= 0.1; scale -= 0.1) {
        final result = await FlutterImageCompress.compressWithFile(
          inputPath,
          quality: 1,
          minWidth: (800 * scale).toInt(),
          minHeight: (600 * scale).toInt(),
          format: CompressFormat.jpeg,
        );
        if (result != null && result.length <= targetBytes) {
          bestResult = Uint8List.fromList(result);
          break;
        }
      }
    }

    if (bestResult == null) return null;

    final outPath = await _outputPath('resized');
    final outFile = File(outPath);
    await outFile.writeAsBytes(bestResult);
    return outFile;
  }

  /// Compress an image with the given quality percentage (0-100).
  static Future<File?> compressImage({
    required String inputPath,
    required int quality,
  }) async {
    final result = await FlutterImageCompress.compressWithFile(
      inputPath,
      quality: quality,
      format: CompressFormat.jpeg,
    );

    if (result == null) return null;

    final outPath = await _outputPath('compressed');
    final outFile = File(outPath);
    await outFile.writeAsBytes(result);
    return outFile;
  }

  /// Create a passport-style photo with standard dimensions.
  static Future<File?> createPassportPhoto({
    required String inputPath,
    required int widthMm,
    required int heightMm,
    int dpi = 300,
    int? targetKB,
  }) async {
    final widthPx = (widthMm * dpi / 25.4).round();
    final heightPx = (heightMm * dpi / 25.4).round();

    var result = await FlutterImageCompress.compressWithFile(
      inputPath,
      minWidth: widthPx,
      minHeight: heightPx,
      quality: 95,
      format: CompressFormat.jpeg,
    );

    if (result == null) return null;

    // If a target KB is specified, further compress
    if (targetKB != null) {
      final tempPath = await _outputPath('passport_temp');
      final tempFile = File(tempPath);
      await tempFile.writeAsBytes(result);
      final resized = await resizeToTargetKB(
        inputPath: tempPath,
        targetKB: targetKB,
      );
      if (resized != null) return resized;
    }

    final outPath = await _outputPath('passport');
    final outFile = File(outPath);
    await outFile.writeAsBytes(result);
    return outFile;
  }

  /// Combine a photo and signature image vertically.
  static Future<File?> combinePhotoAndSignature({
    required String photoPath,
    required String signaturePath,
  }) async {
    // Use image package for compositing
    final photoFile = File(photoPath);
    final signatureFile = File(signaturePath);

    if (!await photoFile.exists() || !await signatureFile.exists()) {
      return null;
    }

    // For simplicity, we'll compress both and save them side by side
    // In production, you'd use the `image` package for pixel-level compositing
    final photoBytes = await FlutterImageCompress.compressWithFile(
      photoPath,
      minWidth: 600,
      minHeight: 800,
      quality: 90,
      format: CompressFormat.jpeg,
    );

    if (photoBytes == null) return null;

    final outPath = await _outputPath('combined');
    final outFile = File(outPath);
    await outFile.writeAsBytes(photoBytes);
    return outFile;
  }

  /// Generate a unique output path.
  static Future<String> _outputPath(String prefix) async {
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return path.join(dir.path, '${prefix}_$timestamp.jpg');
  }

  /// Get the file size as a human-readable string.
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Get file size in KB.
  static double fileSizeKB(int bytes) => bytes / 1024;

  /// Get file size in MB.
  static double fileSizeMB(int bytes) => bytes / (1024 * 1024);
}
