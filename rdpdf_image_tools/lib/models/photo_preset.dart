/// Model for passport photo presets used in the passport photo maker.
class PhotoPreset {
  final String name;
  final String description;
  final int widthMm;
  final int heightMm;
  final int? targetKB;
  final String icon;

  const PhotoPreset({
    required this.name,
    required this.description,
    required this.widthMm,
    required this.heightMm,
    this.targetKB,
    this.icon = 'badge',
  });

  /// Standard Indian document photo presets.
  static const List<PhotoPreset> presets = [
    PhotoPreset(
      name: 'Aadhaar Card',
      description: 'Standard government ID format.',
      widthMm: 35,
      heightMm: 45,
      targetKB: 50,
      icon: 'badge',
    ),
    PhotoPreset(
      name: 'PAN Card',
      description: 'Financial document format.',
      widthMm: 35,
      heightMm: 45,
      targetKB: 50,
      icon: 'credit_card',
    ),
    PhotoPreset(
      name: 'Exam Photo',
      description: 'Passport size photo for applications.',
      widthMm: 35,
      heightMm: 45,
      targetKB: 50,
      icon: 'school',
    ),
    PhotoPreset(
      name: 'Passport',
      description: 'International passport standard.',
      widthMm: 51,
      heightMm: 51,
      targetKB: 100,
      icon: 'flight',
    ),
  ];

  String get dimensionText => '${widthMm}x$heightMm mm';
  String get targetText => targetKB != null ? 'Max ${targetKB}KB' : 'Auto';
}

/// Model for the processing result screen.
class ProcessingResult {
  final String filePath;
  final String fileSize;
  final String dimensions;
  final String format;
  final String? originalSize;
  final String toolName;

  const ProcessingResult({
    required this.filePath,
    required this.fileSize,
    required this.dimensions,
    required this.format,
    this.originalSize,
    required this.toolName,
  });
}
