import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/pdf_service.dart';
import '../../services/image_processing_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

/// Image to PDF screen.
class ImageToPdfScreen extends StatefulWidget {
  const ImageToPdfScreen({super.key});

  @override
  State<ImageToPdfScreen> createState() => _ImageToPdfScreenState();
}

class _ImageToPdfScreenState extends State<ImageToPdfScreen> {
  final List<File> _images = [];
  bool _isGenerating = false;

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final xFiles = await picker.pickMultiImage();
    if (xFiles.isNotEmpty) {
      setState(() {
        _images.addAll(xFiles.map((x) => File(x.path)));
      });
    }
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  void _reorderImages(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _images.removeAt(oldIndex);
      _images.insert(newIndex, item);
    });
  }

  Future<void> _generatePdf() async {
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    final result = await PdfService.imagesToPdf(
      imagePaths: _images.map((f) => f.path).toList(),
    );

    setState(() => _isGenerating = false);

    if (result != null && mounted) {
      final fileSize = ImageProcessingService.formatFileSize(
        await result.length(),
      );
      context.push(
        '/result',
        extra: {
          'filePath': result.path,
          'fileSize': fileSize,
          'dimensions': '${_images.length} pages',
          'format': 'PDF',
          'toolName': 'Image to PDF',
          'outputFormat': 'pdf',
        },
      );
    }
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
              // ── Header ──────────────────────────────────
              Text(
                'Image to PDF',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppTheme.spaceXs),
              Text(
                'Convert multiple images into a single PDF document. Drag to reorder pages.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppTheme.spaceLg),

              // ── Upload Area ─────────────────────────────
              UploadArea(
                onTap: _pickImages,
                icon: Icons.add_photo_alternate_rounded,
                title: 'Add Images',
                subtitle: 'Select multiple images',
              ),

              const SizedBox(height: AppTheme.spaceMd),

              // ── Image List ──────────────────────────────
              if (_images.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_images.length} image${_images.length > 1 ? 's' : ''} selected',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _removeImage(1),
                      icon: Icon(
                        Icons.delete_sweep_rounded,
                        size: 16,
                        color: Colors.red.shade700,
                      ),
                      label: Text(
                        'Clear All',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spaceSm),
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _images.length,
                  onReorder: _reorderImages,
                  proxyDecorator: (child, index, animation) {
                    return AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) => Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(12),
                        child: child,
                      ),
                      child: child,
                    );
                  },
                  itemBuilder: (context, index) {
                    return _ImageTile(
                      key: ValueKey(_images[index].path),
                      file: _images[index],
                      index: index,
                      onRemove: () => _removeImage(index),
                    );
                  },
                ),
              ],

              const SizedBox(height: AppTheme.spaceLg),

              // ── Generate Button ─────────────────────────
              PrimaryActionButton(
                label: 'Generate PDF',
                icon: Icons.picture_as_pdf_rounded,
                onPressed: _generatePdf,
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

class _ImageTile extends StatelessWidget {
  final File file;
  final int index;
  final VoidCallback onRemove;

  const _ImageTile({
    super.key,
    required this.file,
    required this.index,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.cardShadow,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(file, width: 48, height: 48, fit: BoxFit.cover),
        ),
        title: Text(
          'Page ${index + 1}',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          file.path.split('/').last,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: Theme.of(context).colorScheme.outline,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              color: Theme.of(context).colorScheme.outline,
              onPressed: onRemove,
            ),
            Icon(
              Icons.drag_handle_rounded,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ],
        ),
      ),
    );
  }
}
