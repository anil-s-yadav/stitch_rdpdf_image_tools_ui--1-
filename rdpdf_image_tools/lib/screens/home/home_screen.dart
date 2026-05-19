import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';

/// Home screen matching the Stitch home_dashboard design.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? null : AppColors.surfaceContainerHigh,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.containerMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section Header ────────────────────────────────────────
              Text(
                'Tools',
                style: Theme.of(
                  context,
                ).textTheme.displayMedium?.copyWith(color: cs.onSurface),
              ),
              const SizedBox(height: AppTheme.spaceXs),
              Text(
                'Select a utility to process your images.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: AppTheme.spaceLg),

              // ── Bento Grid ───────────────────────────────────────────
              // Row 1: Passport Photo Maker (full width, highlighted)
              _HighlightToolCard(
                title: 'Passport Photo Maker',
                subtitle:
                    'For Aadhar, PAN, Gov forms, Office, School & College.',
                icon: Icons.badge_rounded,
                useGradientIcon: true,
                onTap: () => context.push('/passport-photo'),
              ),
              const SizedBox(height: AppTheme.gutter),

              // Row 2: Resize Image to KB (full width)
              _HighlightToolCard(
                title: 'Resize Image to KB',
                subtitle: 'Precise file size targeting.',
                icon: Icons.aspect_ratio_rounded,
                useGradientIcon: true,
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
      ),
    );
  }
}

/// Large horizontal tool card (Passport Photo, Resize to KB).
class _HighlightToolCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool useGradientIcon;
  final VoidCallback? onTap;

  const _HighlightToolCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.useGradientIcon = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        decoration: BoxDecoration(
          color: isDark ? cs.surfaceContainerLow : cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: cs.outlineVariant.withOpacity(isDark ? 0.3 : 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: useGradientIcon ? AppColors.primaryGradient : null,
                color: useGradientIcon
                    ? null
                    : (isDark
                          ? cs.surfaceContainerHigh
                          : AppColors.surfaceContainer),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: useGradientIcon ? Colors.white : cs.primary,
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
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceXs),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: cs.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: cs.onSurfaceVariant.withOpacity(0.5),
              size: 22,
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
  final VoidCallback? onTap;

  const _SmallToolCard({required this.title, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        decoration: BoxDecoration(
          color: isDark ? cs.surfaceContainerLow : cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: cs.outlineVariant.withOpacity(isDark ? 0.3 : 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark
                    ? cs.surfaceContainerHigh
                    : AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: cs.primary, size: 24),
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: cs.onSurface,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
