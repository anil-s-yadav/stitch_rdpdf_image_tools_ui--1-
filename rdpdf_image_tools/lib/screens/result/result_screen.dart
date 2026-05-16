import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/file_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bars.dart';
import '../../widgets/common_widgets.dart';

/// Processing Result screen matching process_result_dashboard design.
class ResultScreen extends StatelessWidget {
  final String filePath;
  final String fileSize;
  final String dimensions;
  final String format;
  final String originalSize;
  final String toolName;

  const ResultScreen({
    super.key,
    required this.filePath,
    required this.fileSize,
    required this.dimensions,
    required this.format,
    this.originalSize = '',
    this.toolName = '',
  });

  @override
  Widget build(BuildContext context) {
    final isImage = !filePath.toLowerCase().endsWith('.pdf');
    final file = File(filePath);

    return Scaffold(
      appBar: const GradientAppBar(showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.containerMargin),
        child: Column(
          children: [
            const SizedBox(height: AppTheme.spaceLg),

            // ── Success Icon ────────────────────────────────────
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryContainer.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: AppTheme.spaceMd),

            // ── Title ───────────────────────────────────────────
            Text(
              'Processing Complete',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.onSurface,
                    fontSize: 28,
                  ),
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              'Your image has been successfully optimized\nand is ready for download.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppTheme.spaceLg),

            // ── Preview Card ────────────────────────────────────
            PremiumCard(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              child: Column(
                children: [
                  // Image preview
                  Container(
                    width: double.infinity,
                    height: 240,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMd),
                      color: AppColors.surfaceContainer,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: isImage && file.existsSync()
                        ? Image.file(file, fit: BoxFit.contain)
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.picture_as_pdf_rounded,
                                  size: 64,
                                  color: AppColors.primaryContainer,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'PDF Document',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: AppTheme.spaceMd),

                  // ── File Details ──────────────────────────────
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'File Details',
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                  ),
                  const Divider(height: 20),

                  // Stat cards
                  Row(
                    children: [
                      // New size
                      Expanded(
                        child: _StatCard(
                          label: 'NEW SIZE',
                          value: fileSize,
                          subValue: originalSize.isNotEmpty
                              ? originalSize
                              : null,
                          valueColor: AppColors.primaryContainer,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spaceSm),
                      // Dimensions
                      Expanded(
                        child: _StatCard(
                          label: 'DIMENSIONS',
                          value: dimensions.isNotEmpty
                              ? dimensions
                              : '—',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                  // Format
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusDefault),
                      border: Border.all(
                          color: AppColors.outlineVariant.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FORMAT',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              format,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'OPTIMIZED',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              color: AppColors.onSurfaceVariant,
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

            // ── Download Button ─────────────────────────────────
            PrimaryActionButton(
              label: 'Download Now',
              icon: Icons.bolt_rounded,
              onPressed: () async {
                try {
                  final saved = await FileService.saveToDocuments(
                    File(filePath),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Saved to ${saved.path}'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error saving: $e')),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: AppTheme.spaceSm),

            // ── Share & Edit Row ────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        FileService.shareFile(filePath, subject: toolName),
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: const Text('Share'),
                  ),
                ),
                const SizedBox(width: AppTheme.spaceSm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('Edit Again'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spaceLg),

            // ── Back to Dashboard ───────────────────────────────
            TextButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Back to Dashboard'),
            ),
            const SizedBox(height: AppTheme.spaceXl),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subValue;
  final Color? valueColor;

  const _StatCard({
    required this.label,
    required this.value,
    this.subValue,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.onSurface,
            ),
          ),
          if (subValue != null) ...[
            const SizedBox(height: 2),
            Text(
              subValue!,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.outline,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
