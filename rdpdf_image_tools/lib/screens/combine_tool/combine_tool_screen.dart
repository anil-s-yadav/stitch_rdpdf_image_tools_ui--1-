import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../services/image_processing_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

/// Combine Photo & Signature screen matching pro_combine_tool_v2 design.
class CombineToolScreen extends StatefulWidget {
  const CombineToolScreen({super.key});

  @override
  State<CombineToolScreen> createState() => _CombineToolScreenState();
}

class _CombineToolScreenState extends State<CombineToolScreen> {
  File? _photo;
  File? _signature;
  bool _isGenerating = false;

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile != null) setState(() => _photo = File(xFile.path));
  }

  Future<void> _pickSignature() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile != null) setState(() => _signature = File(xFile.path));
  }

  Future<void> _generateCombined() async {
    if (_photo == null || _signature == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload both photo and signature')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      // Combine images using the image package approach:
      // Load both images, draw photo on top, signature below
      final photoBytes = await _photo!.readAsBytes();
      final sigBytes = await _signature!.readAsBytes();

      final photoCodec = await ui.instantiateImageCodec(photoBytes);
      final photoFrame = await photoCodec.getNextFrame();
      final photoImg = photoFrame.image;

      final sigCodec = await ui.instantiateImageCodec(sigBytes);
      final sigFrame = await sigCodec.getNextFrame();
      final sigImg = sigFrame.image;

      // Canvas: photo width, photo height + signature height
      final canvasWidth = photoImg.width;
      final sigScaleW = canvasWidth / sigImg.width;
      final scaledSigH = (sigImg.height * sigScaleW).round();
      final canvasHeight = photoImg.height + scaledSigH;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // White background
      canvas.drawRect(
        Rect.fromLTWH(0, 0, canvasWidth.toDouble(), canvasHeight.toDouble()),
        Paint()..color = Colors.white,
      );

      // Draw photo
      canvas.drawImage(photoImg, Offset.zero, Paint());

      // Draw signature scaled below photo
      final sigRect = Rect.fromLTWH(
        0,
        photoImg.height.toDouble(),
        canvasWidth.toDouble(),
        scaledSigH.toDouble(),
      );
      canvas.drawImageRect(
        sigImg,
        Rect.fromLTWH(0, 0, sigImg.width.toDouble(), sigImg.height.toDouble()),
        sigRect,
        Paint(),
      );

      final picture = recorder.endRecording();
      final combinedImg = await picture.toImage(canvasWidth, canvasHeight);
      final byteData = await combinedImg.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null) {
        final dir = await getTemporaryDirectory();
        final outPath = p.join(
          dir.path,
          'combined_${DateTime.now().millisecondsSinceEpoch}.png',
        );
        final outFile = File(outPath);
        await outFile.writeAsBytes(byteData.buffer.asUint8List());

        if (mounted) {
          final fileSize = ImageProcessingService.formatFileSize(
            await outFile.length(),
          );
          context.push(
            '/result',
            extra: {
              'filePath': outFile.path,
              'fileSize': fileSize,
              'dimensions': '${canvasWidth} × $canvasHeight px',
              'format': 'PNG',
              'toolName': 'Combine Photo + Signature',
            },
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }

    setState(() => _isGenerating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.containerMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────
              Text(
                'Combine Photo & Signature',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: AppTheme.spaceSm),
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.workspace_premium,
                      size: 14,
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'REQUIRED FOR MANY GOVT FORMS',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spaceSm),
              Text(
                'Upload your portrait photo and handwritten signature to generate a single standardized document.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppTheme.spaceLg),

              // ── 1. Portrait Photo ───────────────────────────────
              _UploadSection(
                number: '1',
                title: 'Portrait Photo',
                badge: 'JPG, PNG, WEBP',
                file: _photo,
                onTap: _pickPhoto,
                onClear: () => setState(() => _photo = null),
                icon: Icons.camera_alt_rounded,
                uploadTitle: 'Click to upload photo',
              ),
              const SizedBox(height: AppTheme.spaceMd),

              // ── 2. Signature ────────────────────────────────────
              _UploadSection(
                number: '2',
                title: 'Signature',
                badge: 'Transparent PNG\npreferred',
                file: _signature,
                onTap: _pickSignature,
                onClear: () => setState(() => _signature = null),
                icon: Icons.draw_rounded,
                uploadTitle: 'Click to upload signature',
              ),
              const SizedBox(height: AppTheme.spaceLg),

              // ── Live Preview ────────────────────────────────────
              PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.preview_rounded,
                          size: 18,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Live Preview',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Standardized layout',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spaceMd),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppTheme.spaceLg),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: Column(
                        children: [
                          // Photo area
                          Container(
                            width: 140,
                            height: 180,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant.withOpacity(0.3),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).shadowColor.withOpacity(0.05),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _photo != null
                                ? Image.file(_photo!, fit: BoxFit.cover)
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.person_rounded,
                                        size: 40,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.outlineVariant,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Photo Area',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 11,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.outline,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          const SizedBox(height: 12),
                          // Signature area
                          Container(
                            width: 120,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant.withOpacity(0.3),
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _signature != null
                                ? Image.file(_signature!, fit: BoxFit.contain)
                                : Center(
                                    child: Text(
                                      'Signature Area',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 10,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.outline,
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spaceLg),

              // ── Generate Button ─────────────────────────────────
              PrimaryActionButton(
                label: 'Generate Image',
                icon: Icons.bolt_rounded,
                onPressed: _generateCombined,
                isLoading: _isGenerating,
              ),
              const SizedBox(height: AppTheme.spaceXl),
            ],
          ),
        ),
      ),
    );
  }
}

class _UploadSection extends StatelessWidget {
  final String number;
  final String title;
  final String badge;
  final File? file;
  final VoidCallback onTap;
  final VoidCallback onClear;
  final IconData icon;
  final String uploadTitle;

  const _UploadSection({
    required this.number,
    required this.title,
    required this.badge,
    required this.file,
    required this.onTap,
    required this.onClear,
    required this.icon,
    required this.uploadTitle,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    number,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                badge,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMd),
          UploadArea(
            onTap: onTap,
            icon: icon,
            title: uploadTitle,
            subtitle: 'or drag and drop file here',
            hasFile: file != null,
            preview: file != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        child: Image.file(
                          file!,
                          width: double.infinity,
                          height: 140,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: onClear,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
