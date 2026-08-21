import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/error/failure.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_typography.dart';

/// Bottom-sheet frame with a free-form footer.
///
/// `EditSheet` is not reused for these: they are not forms, and their footers
/// are a checkbox or a pair of choices rather than cancel / save.
class SheetFrame extends StatelessWidget {
  const SheetFrame({
    required this.title,
    required this.children,
    required this.footer,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.88),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.type.sectionTitle),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(subtitle!, style: context.type.caption),
                    ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
                children: children,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
              child: footer,
            ),
          ],
        ),
      ),
    );
  }
}

/// Lists every problem found in a file, each with its path inside the
/// document. All of them at once — fixing typos one round-trip at a time is
/// what this sheet exists to avoid.
///
/// Shared by the routine importer and the backup restorer: both read JSON with
/// the same reader and fail with the same [RoutineFormatFailure].
Future<void> showFileErrorSheet(
  BuildContext context, {
  required RoutineFormatFailure failure,
  String title = AppStrings.importErrorTitle,
  String? fileName,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      final p = sheetContext.palette;
      return SheetFrame(
        title: title,
        subtitle: fileName,
        footer: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.of(sheetContext).pop(),
            child: const Text(AppStrings.close),
          ),
        ),
        children: [
          Text(failure.message, style: sheetContext.type.body),
          const SizedBox(height: 6),
          Text(AppStrings.importErrorHint, style: sheetContext.type.caption),
          const SizedBox(height: 14),
          for (final error in failure.errors)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Icon(Icons.close, size: 13, color: p.warn),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SelectableText(
                      error,
                      style: sheetContext.type.caption.copyWith(
                        color: p.ink2,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    },
  );
}

/// Problems a reader recovered from, listed where the user is about to decide.
///
/// Warnings never block an import — they are the difference between "this file
/// is wrong" and "this file is not quite what you may expect".
class WarningBox extends StatelessWidget {
  const WarningBox({
    required this.warnings,
    this.title = AppStrings.importWarningTitle,
    super.key,
  });

  final List<String> warnings;
  final String title;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: p.warn.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.warn.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: p.warn),
              const SizedBox(width: 6),
              Text(title, style: context.type.label.copyWith(color: p.warn)),
            ],
          ),
          const SizedBox(height: 8),
          for (final warning in warnings)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('· $warning', style: context.type.caption),
            ),
        ],
      ),
    );
  }
}
