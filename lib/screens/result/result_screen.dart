import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/file_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

/// Processing Result screen — auto-saves to Downloads/RedImage/ on load.
class ResultScreen extends StatefulWidget {
  final String filePath;
  final String fileSize;
  final String dimensions;
  final String format;
  final String originalSize;
  final String toolName;
  final String outputFormat; // 'png', 'jpeg', or 'pdf'

  const ResultScreen({
    super.key,
    required this.filePath,
    required this.fileSize,
    required this.dimensions,
    required this.format,
    this.originalSize = '',
    this.toolName = '',
    this.outputFormat = 'png',
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _autoSaved = false;
  bool _saveFailed = false;
  String _savedPath = '';
  bool _isSaving = false;
  String _errorMessage = '';

  OutputFormat get _outputFormat {
    switch (widget.outputFormat.toLowerCase()) {
      case 'jpeg':
      case 'jpg':
        return OutputFormat.jpeg;
      case 'pdf':
        return OutputFormat.pdf;
      default:
        return OutputFormat.png;
    }
  }

  @override
  void initState() {
    super.initState();
    _autoSave();
  }

  Future<void> _autoSave() async {
    setState(() {
      _saveFailed = false;
      _autoSaved = false;
    });
    try {
      final file = File(widget.filePath);
      if (!file.existsSync()) {
        if (mounted) {
          setState(() {
            _saveFailed = true;
            _errorMessage = 'Source file not found';
          });
        }
        return;
      }

      final saved = await FileService.saveToRedImage(
        file,
        toolName: widget.toolName,
        outputFormat: _outputFormat,
      );

      if (mounted) {
        setState(() {
          _autoSaved = true;
          _saveFailed = false;
          _savedPath = saved.path;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _saveFailed = true;
          _autoSaved = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _saveAgain() async {
    setState(() => _isSaving = true);
    try {
      final file = File(widget.filePath);
      if (!file.existsSync()) throw Exception('Source file not found');

      final saved = await FileService.saveToRedImage(
        file,
        toolName: widget.toolName,
        outputFormat: _outputFormat,
      );

      if (mounted) {
        setState(() {
          _savedPath = saved.path;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Saved as ${_outputFormat.name.toUpperCase()} to Downloads/RedImage/',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isImage = !widget.filePath.toLowerCase().endsWith('.pdf');
    final file = File(widget.filePath);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.containerMargin),
          child: Column(
            children: [
              const SizedBox(height: AppTheme.spaceLg),

              // ── Success Icon ────────────────────────────────────
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: cs.primaryContainer.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: cs.onPrimaryContainer,
                  size: 40,
                ),
              ),
              const SizedBox(height: AppTheme.spaceMd),

              // ── Title ───────────────────────────────────────────
              Text(
                _saveFailed ? 'Save Failed' : 'Saved Successfully',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: _saveFailed ? cs.error : cs.onSurface,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: AppTheme.spaceSm),

              // ── Auto-save status ────────────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _autoSaved
                    ? Container(
                        key: const ValueKey('saved'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.success,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Saved to device & Downloads/RedImage/',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _saveFailed
                        ? GestureDetector(
                            onTap: _autoSave,
                            child: Container(
                              key: const ValueKey('failed'),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: cs.error.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.error_rounded,
                                    color: cs.error,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Save failed — tap to retry',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: cs.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container(
                            key: const ValueKey('saving'),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: cs.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Saving…',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
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
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        color: cs.surfaceContainer,
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
                                    color: cs.primaryContainer,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'PDF Document',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      color: cs.onSurfaceVariant,
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
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Divider(height: 20),

                    // Stat cards
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'NEW SIZE',
                            value: widget.fileSize,
                            subValue: widget.originalSize.isNotEmpty
                                ? widget.originalSize
                                : null,
                            valueColor: cs.primaryContainer,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spaceSm),
                        Expanded(
                          child: _StatCard(
                            label: 'DIMENSIONS',
                            value: widget.dimensions.isNotEmpty
                                ? widget.dimensions
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
                        color: cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusDefault,
                        ),
                        border: Border.all(
                          color: cs.outlineVariant.withOpacity(0.2),
                        ),
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
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _outputFormat.name.toUpperCase(),
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Optimized',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                color: cs.onSurfaceVariant,
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

              // ── Save Again Button ───────────────────────────────
              PrimaryActionButton(
                label: 'Save Again',
                icon: Icons.save_rounded,
                onPressed: _saveAgain,
                isLoading: _isSaving,
              ),
              const SizedBox(height: AppTheme.spaceSm),

              // ── Share & Edit Row ────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => FileService.shareFile(
                        _savedPath.isNotEmpty ? _savedPath : widget.filePath,
                        subject: widget.toolName,
                      ),
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
      ),
    );
  }
}

// ── Stat Card ────────────────────────────────────────────────────────────
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
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.2)),
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
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: valueColor ?? cs.onSurface,
            ),
          ),
          if (subValue != null) ...[
            const SizedBox(height: 2),
            Text(
              subValue!,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: cs.outline,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
