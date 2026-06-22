import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/file_service.dart';
import '../../services/image_processing_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

/// Resize Image to KB screen matching premium_resize_image design.
class ResizeImageScreen extends StatefulWidget {
  const ResizeImageScreen({super.key});

  @override
  State<ResizeImageScreen> createState() => _ResizeImageScreenState();
}

class _ResizeImageScreenState extends State<ResizeImageScreen> {
  File? _selectedImage;
  int _targetKB = 100;
  double _sliderValue = 100;
  int _selectedPresetIndex = 3; // 100kb default
  bool _isProcessing = false;
  String _originalSize = '';
  String _originalDimensions = '';
  OutputFormat _outputFormat = OutputFormat.png;

  final _kbController = TextEditingController(text: '100');

  final List<int> _presets = [10, 20, 50, 100];

  @override
  void dispose() {
    _kbController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile != null) {
      final file = File(xFile.path);
      final bytes = await file.length();
      setState(() {
        _selectedImage = file;
        _originalSize = ImageProcessingService.formatFileSize(bytes);
        _originalDimensions = ''; // Will be set after decode
      });

      // Decode dimensions
      final decoded = await decodeImageFromList(await file.readAsBytes());
      if (mounted) {
        setState(() {
          _originalDimensions = '${decoded.width} × ${decoded.height} px';
        });
      }
    }
  }

  void _setPreset(int index) {
    setState(() {
      _selectedPresetIndex = index;
      _targetKB = _presets[index];
      _sliderValue = _targetKB.toDouble();
      _kbController.text = _targetKB.toString();
    });
  }

  Future<void> _resizeImage() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    final result = await ImageProcessingService.resizeToTargetKB(
      inputPath: _selectedImage!.path,
      targetKB: _targetKB,
    );

    setState(() => _isProcessing = false);

    if (result != null && mounted) {
      final fileSize = ImageProcessingService.formatFileSize(
        await result.length(),
      );
      context.push(
        '/result',
        extra: {
          'filePath': result.path,
          'fileSize': fileSize,
          'dimensions': _originalDimensions,
          'format': 'JPEG',
          'originalSize': _originalSize,
          'toolName': 'Resize Image to KB',
          'outputFormat': _outputFormat.name,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate reduction percentage
    double reductionPercent = 0;
    if (_selectedImage != null && _originalSize.isNotEmpty) {
      // Extract original size in KB for comparison display
    }

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
                'Target File Size',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppTheme.spaceXs),
              Text(
                'Compress your image to an exact kilobyte threshold while maintaining maximum possible visual fidelity.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppTheme.spaceLg),

              // ── Image Preview / Upload ──────────────────────────
              PremiumCard(
                padding: const EdgeInsets.all(AppTheme.spaceMd),
                child: Column(
                  children: [
                    // Before / After comparison view
                    if (_selectedImage != null) ...[
                      Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusDefault,
                          ),
                          color: Theme.of(context).colorScheme.surfaceContainer,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(_selectedImage!, fit: BoxFit.cover),
                            // Original label
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'ORIGINAL',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                            // Preview label
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                      .withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'PREVIEW',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ),
                            // Center divider handle
                            Center(
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(
                                        context,
                                      ).shadowColor.withOpacity(0.15),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.code,
                                  size: 18,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      UploadArea(
                        onTap: _pickImage,
                        icon: Icons.cloud_upload_rounded,
                        title: 'Upload Image',
                        subtitle: 'Select an image to resize',
                      ),
                    ],

                    const SizedBox(height: AppTheme.spaceSm),

                    // Stats row
                    Row(
                      children: [
                        // Original stat
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(AppTheme.spaceSm),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusDefault,
                              ),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHigh,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.image,
                                      size: 16,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'ORIGINAL',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.5,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _originalSize.isEmpty ? '—' : _originalSize,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                                if (_originalDimensions.isNotEmpty)
                                  Text(
                                    _originalDimensions,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spaceSm),
                        // Final stat
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(AppTheme.spaceSm),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusDefault,
                              ),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer.withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.compress,
                                      size: 16,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'FINAL SIZE',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.5,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primaryContainer,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '$_targetKB',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primaryContainer,
                                        height: 1,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      'KB',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primaryContainer,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.verified,
                                        size: 12,
                                        color: Color(0xFF16A34A),
                                      ),
                                      SizedBox(width: 3),
                                      Text(
                                        'GUARANTEED UNDER LIMIT',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 8,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.3,
                                          color: Color(0xFF166534),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spaceLg),

              // ── Target Size Input ───────────────────────────────
              Text(
                'Enter Target Size Limit',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppTheme.spaceSm),
              Container(
                height: 64,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _kbController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onChanged: (val) {
                          final kb = int.tryParse(val);
                          if (kb != null && kb > 0) {
                            setState(() {
                              _targetKB = kb;
                              _sliderValue = kb.toDouble().clamp(10, 500);
                              _selectedPresetIndex = _presets.indexOf(kb);
                            });
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 16, left: 10),
                      child: Text(
                        'KB',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spaceMd),

              // ── Slider ──────────────────────────────────────────
              SliderTheme(
                data: Theme.of(context).sliderTheme.copyWith(
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 20,
                  ),
                ),
                child: Slider(
                  value: _sliderValue.clamp(10, 500),
                  min: 10,
                  max: 500,
                  onChanged: (val) {
                    setState(() {
                      _sliderValue = val;
                      _targetKB = val.round();
                      _kbController.text = _targetKB.toString();
                      _selectedPresetIndex = _presets.indexOf(_targetKB);
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '10 KB',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    Text(
                      'Max Quality',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 32),

              // ── Quick Presets ────────────────────────────────────
              const SectionLabel('Quick Presets'),
              const SizedBox(height: AppTheme.spaceSm),
              Row(
                children: List.generate(_presets.length, (index) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index < _presets.length - 1 ? 8 : 0,
                      ),
                      child: PresetChip(
                        label: '${_presets[index]}',
                        suffix: 'kb',
                        isSelected: _selectedPresetIndex == index,
                        onTap: () => _setPreset(index),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: AppTheme.spaceLg),

              // ── Output Format ────────────────────────────────────
              FormatPicker(
                selected: _outputFormat,
                onChanged: (fmt) => setState(() => _outputFormat = fmt),
              ),
              const SizedBox(height: AppTheme.spaceLg),

              // ── Resize Button ───────────────────────────────────
              PrimaryActionButton(
                label: 'Resize Image',
                icon: Icons.bolt_rounded,
                onPressed: _resizeImage,
                isLoading: _isProcessing,
              ),
              const SizedBox(height: AppTheme.spaceXl),
            ],
          ),
        ),
      ),
    );
  }
}
