import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bars.dart';

/// Home screen matching the Stitch home_dashboard design.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FrostedAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.containerMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section Header ────────────────────────────────────────
            Text(
              'Tools',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppColors.onBackground,
                  ),
            ),
            const SizedBox(height: AppTheme.spaceXs),
            Text(
              'Select a utility to process your images.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppTheme.spaceLg),

            // ── Bento Grid ───────────────────────────────────────────
            // Row 1: Passport Photo Maker (full width, highlighted)
            _HighlightToolCard(
              title: 'Passport Photo Maker',
              subtitle: 'Create official compliant photos instantly.',
              icon: Icons.badge_rounded,
              isPro: true,
              onTap: () => context.push('/passport-photo'),
            ),
            const SizedBox(height: AppTheme.gutter),

            // Row 2: Resize Image to KB (full width)
            _HighlightToolCard(
              title: 'Resize Image to KB',
              subtitle: 'Precise file size targeting.',
              icon: Icons.aspect_ratio_rounded,
              isPro: false,
              backgroundColor: AppColors.surfaceContainerLow,
              onTap: () => context.push('/resize-image'),
            ),
            const SizedBox(height: AppTheme.gutter),

            // Row 3: 2-column grid
            Row(
              children: [
                Expanded(
                  child: _SmallToolCard(
                    title: 'Signature Maker',
                    icon: Icons.draw_rounded,
                    onTap: () => context.push('/signature-maker'),
                  ),
                ),
                const SizedBox(width: AppTheme.gutter),
                Expanded(
                  child: _SmallToolCard(
                    title: 'Compress Image',
                    icon: Icons.compress_rounded,
                    onTap: () => context.push('/compress-image'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.gutter),

            // Row 4: 2-column grid
            Row(
              children: [
                Expanded(
                  child: _SmallToolCard(
                    title: 'Combine Photo\n+ Signature',
                    icon: Icons.layers_rounded,
                    isPro: true,
                    onTap: () => context.push('/combine-tool'),
                  ),
                ),
                const SizedBox(width: AppTheme.gutter),
                Expanded(
                  child: _SmallToolCard(
                    title: 'Image to PDF',
                    icon: Icons.picture_as_pdf_rounded,
                    onTap: () => context.push('/image-to-pdf'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceXl),
          ],
        ),
      ),
    );
  }
}

/// Large horizontal tool card (Passport Photo, Resize to KB).
class _HighlightToolCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isPro;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const _HighlightToolCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isPro = false,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppTheme.cardShadow,
          border: Border.all(color: Colors.transparent),
        ),
        child: Stack(
          children: [
            // Decorative blur circle
            if (isPro)
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryFixed.withOpacity(0.2),
                  ),
                ),
              ),
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primaryContainer,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppTheme.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceXs),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: AppColors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isPro)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.6,
                      color: AppColors.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Small vertical tool card (Signature, Compress, Combine, Image to PDF).
class _SmallToolCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isPro;
  final VoidCallback? onTap;

  const _SmallToolCard({
    required this.title,
    required this.icon,
    this.isPro = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppTheme.cardShadow,
          border: Border.all(color: Colors.transparent),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.onSurfaceVariant,
                    size: 24,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceSm),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurface,
                    height: 1.3,
                  ),
                ),
              ],
            ),
            if (isPro)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.6,
                      color: AppColors.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
