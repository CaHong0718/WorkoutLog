import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_typography.dart';

/// Bordered surface panel — the base container of every screen section.
class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppLayout.cardPadding),
    this.accent,
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// When set, draws a 3px identity bar down the left edge.
  final Color? accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    Widget body = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: p.line),
      ),
      padding: padding,
      child: child,
    );

    if (accent != null) {
      // A painted stripe rather than a gradient edge: the guide allows no
      // gradients, and this bar carries information, not decoration. The
      // Material below clips it to the rounded corner.
      body = Stack(
        children: [
          body,
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(width: 3, color: accent),
          ),
        ],
      );
    }

    return Material(
      color: p.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: body),
    );
  }
}

/// One branch of a decision, stated as a sentence rather than a bare verb.
///
/// Stacked full-width tiles beat a row of same-weight dialog buttons whenever
/// the options differ in consequence: the title says what happens, the line
/// under it says what it costs, and [emphasized] marks the safe default.
class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.emphasized = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  /// Draws the tile in accent colors — use for the recommended option.
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final tint = emphasized ? p.accent : p.ink2;

    return Material(
      color: emphasized ? p.accentWash : p.surface2,
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.button),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: emphasized ? Border.all(color: p.accent) : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: tint),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.type.cardTitle.copyWith(
                        color: emphasized ? p.accent : p.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(description, style: context.type.caption),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Section label sitting above a card.
///
/// Plain sentence case: the guide rules out uppercase and letter-spacing here
/// because both turn a quiet label into a shout.
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {this.color, super.key});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: context.type.eyebrow.copyWith(color: color));
}

/// A static block standing in for content that has not arrived.
///
/// No pulse — the guide asks for skeletons that sit still.
class SkeletonBlock extends StatelessWidget {
  const SkeletonBlock({required this.height, this.width, super.key});

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    width: width,
    decoration: BoxDecoration(
      color: context.palette.surface2,
      borderRadius: BorderRadius.circular(AppRadius.card),
    ),
  );
}

/// Loading placeholder for a list screen.
///
/// A skeleton rather than a centred spinner: the page keeps its shape, so
/// nothing jumps when the real content lands.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(
      AppLayout.screenPadding,
      8,
      AppLayout.screenPadding,
      AppLayout.screenPadding,
    ),
    children: const [
      SkeletonBlock(height: 104),
      SizedBox(height: 12),
      SkeletonBlock(height: AppLayout.buttonHeight),
      SizedBox(height: AppLayout.sectionGap),
      SkeletonBlock(height: 14, width: 72),
      SizedBox(height: AppLayout.labelGap),
      SkeletonBlock(height: 72),
      SizedBox(height: 10),
      SkeletonBlock(height: 72),
    ],
  );
}

class EmptyView extends StatelessWidget {
  const EmptyView({
    this.message = AppStrings.emptyDefault,
    this.icon,
    super.key,
  });

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppLayout.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 24, color: p.ink3),
              const SizedBox(height: 12),
            ],
            Text(
              message,
              style: context.type.body,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({required this.message, this.onRetry, super.key});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppLayout.sectionGap),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 24, color: p.danger),
            const SizedBox(height: 12),
            Text(
              message,
              style: context.type.body,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: onRetry,
                child: const Text(AppStrings.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Temporary placeholder used while a screen is not implemented yet.
class PlaceholderScaffold extends StatelessWidget {
  const PlaceholderScaffold({
    required this.title,
    required this.step,
    super.key,
  });

  final String title;
  final String step;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: EmptyView(
        message: '$step에서 구현합니다',
        icon: Icons.construction_outlined,
      ),
    );
  }
}
