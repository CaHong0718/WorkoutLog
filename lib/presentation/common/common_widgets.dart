import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_typography.dart';

/// Bordered surface panel — the base container of every screen section.
class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
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
    return Material(
      color: p.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: p.line),
            gradient: accent == null
                ? null
                : LinearGradient(
                    colors: [accent!, accent!, Colors.transparent],
                    stops: const [0, 0.008, 0.008],
                  ),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// Uppercase label with a trailing hairline, mirroring the document's eyebrow.
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {this.color, super.key});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        Text(
          text.toUpperCase(),
          style: context.type.eyebrow.copyWith(color: color ?? p.accent),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(height: 1, constraints: const BoxConstraints(maxWidth: 160), color: p.line),
        ),
      ],
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator(strokeWidth: 2.4));
}

class EmptyView extends StatelessWidget {
  const EmptyView({this.message = AppStrings.emptyDefault, this.icon, super.key});

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 40, color: p.ink3),
            const SizedBox(height: 12),
          ],
          Text(message, style: context.type.caption, textAlign: TextAlign.center),
        ],
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 40, color: p.warn),
            const SizedBox(height: 12),
            Text(message, style: context.type.body, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onRetry, child: const Text(AppStrings.retry)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Temporary placeholder used while a screen is not implemented yet.
class PlaceholderScaffold extends StatelessWidget {
  const PlaceholderScaffold({required this.title, required this.step, super.key});

  final String title;
  final String step;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: EmptyView(message: '$step에서 구현합니다', icon: Icons.construction_outlined),
    );
  }
}
