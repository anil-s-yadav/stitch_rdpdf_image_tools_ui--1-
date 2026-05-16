import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

/// Home screen matching the Stitch home_dashboard design.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.containerMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section Header ────────────────────────────────────────
              Text(
                'Tools',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppTheme.spaceXs),
              Text(
                'Select a utility to process your images.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppTheme.spaceLg),

              // ── Bento Grid ───────────────────────────────────────────
              // Row 1: Passport Photo Maker (full width, highlighted)
              _HighlightToolCard(
                title: 'Passport Photo Maker',
                subtitle: 'Create official compliant photos instantly.',
                icon: Icons.badge_rounded,
                onTap: () => context.push('/passport-photo'),
              ),
              const SizedBox(height: AppTheme.gutter),

              // Row 2: Resize Image to KB (full width)
              _HighlightToolCard(
                title: 'Resize Image to KB',
                subtitle: 'Precise file size targeting.',
                icon: Icons.aspect_ratio_rounded,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerLow,
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
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const _HighlightToolCard({
    required this.title,
    required this.subtitle,
    required this.icon,
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
          color: backgroundColor ?? Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppTheme.cardShadow,
          border: Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primaryContainer,
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
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceXs),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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
  final VoidCallback? onTap;

  const _SmallToolCard({required this.title, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppTheme.cardShadow,
          border: Border.all(color: Colors.transparent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
