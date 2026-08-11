import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/duration_x.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entity/exercise.dart';
import '../../../domain/entity/progression_suggestion.dart';
import '../../../domain/entity/workout_session.dart';
import '../../common/body_part_ui.dart';
import '../../common/common_widgets.dart';
import '../bloc/session_state.dart';

/// What the athlete chose to do with a session they are walking away from.
enum LeaveChoice {
  /// Leave the screen, session stays `inProgress` — the home banner picks it up.
  keepForLater,

  /// Close the session as aborted. Logged sets stay in history.
  abort,
}

/// Back / close on the session screen.
///
/// Three outcomes, but only two of them leave the screen, so they are not three
/// equal buttons: the two exits are described tiles and staying is the plain
/// button at the bottom. Dismissing the sheet also means "stay".
class LeaveSheet extends StatelessWidget {
  const LeaveSheet({required this.state, super.key});

  final SessionState state;

  static Future<LeaveChoice?> show(BuildContext context, SessionState state) =>
      showModalBottomSheet<LeaveChoice>(
        context: context,
        builder: (_) => LeaveSheet(state: state),
      );

  @override
  Widget build(BuildContext context) {
    final session = state.session;
    final done = state.completedSets;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.leaveSessionTitle,
              style: context.type.sectionTitle,
            ),
            const SizedBox(height: 4),
            Text(
              [
                if (session != null)
                  'DAY ${session.dayCode} · ${session.dayTitle}',
                '$done${AppStrings.setUnit} 완료',
                '${state.elapsed.koreanShort} 경과',
              ].join(' · '),
              style: context.type.caption,
            ),
            const SizedBox(height: 16),
            ChoiceTile(
              icon: Icons.play_circle_outline,
              title: AppStrings.keepSession,
              description: AppStrings.keepSessionHint,
              emphasized: true,
              onTap: () => Navigator.of(context).pop(LeaveChoice.keepForLater),
            ),
            const SizedBox(height: 10),
            ChoiceTile(
              icon: Icons.stop_circle_outlined,
              title: AppStrings.abortSession,
              description: done == 0
                  ? '기록된 세트가 없는 채로 세션을 닫습니다.'
                  : '한 $done${AppStrings.setUnit}는 기록에 남고 세션은 중단으로 닫힙니다. '
                        '다 마쳤다면 오른쪽 위 ${AppStrings.finishSession}을 쓰세요.',
              onTap: () => Navigator.of(context).pop(LeaveChoice.abort),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(AppStrings.continueSession),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Confirms finishing and collects an optional memo.
class FinishSheet extends StatefulWidget {
  const FinishSheet({required this.state, super.key});

  final SessionState state;

  static Future<String?> show(BuildContext context, SessionState state) =>
      showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        builder: (_) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: FinishSheet(state: state),
        ),
      );

  @override
  State<FinishSheet> createState() => _FinishSheetState();
}

class _FinishSheetState extends State<FinishSheet> {
  final _memo = TextEditingController();

  @override
  void dispose() {
    _memo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final remaining = state.plannedSets - state.currentIndex;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('운동을 종료할까요?', style: context.type.sectionTitle),
            const SizedBox(height: 12),
            Row(
              children: [
                _Stat(value: '${state.completedSets}', label: '완료 세트'),
                _Stat(value: state.elapsed.koreanShort, label: '소요 시간'),
                _Stat(value: '$remaining', label: '남은 세트'),
              ],
            ),
            if (remaining > 0) ...[
              const SizedBox(height: 10),
              Text(
                '남은 $remaining세트는 기록되지 않습니다. 컨디션이 나쁜 날은 축소가 기본값입니다.',
                style: context.type.caption,
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _memo,
              maxLines: 2,
              decoration: const InputDecoration(hintText: '메모 (선택)'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(AppStrings.cancel),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () =>
                        Navigator.of(context).pop(_memo.text.trim()),
                    child: const Text(AppStrings.finishSession),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: context.type.metric),
        const SizedBox(height: 2),
        Text(label, style: context.type.label),
      ],
    ),
  );
}

/// Post-session summary with double-progression suggestions.
class SessionResultDialog extends StatelessWidget {
  const SessionResultDialog({
    required this.session,
    required this.suggestions,
    super.key,
  });

  final WorkoutSession session;
  final List<ProgressionSuggestion> suggestions;

  static Future<void> show(
    BuildContext context, {
    required WorkoutSession session,
    required List<ProgressionSuggestion> suggestions,
  }) => showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) =>
        SessionResultDialog(session: session, suggestions: suggestions),
  );

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return AlertDialog(
      title: Text(
        'DAY ${session.dayCode} 완료',
        style: context.type.sectionTitle,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${session.completedSets}세트 · ${session.duration.koreanShort} · '
            '총 볼륨 ${session.totalVolume.toStringAsFixed(0)}kg',
            style: context.type.body,
          ),
          if (suggestions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              '다음 세션 증량 제안',
              style: context.type.label.copyWith(color: p.accent),
            ),
            const SizedBox(height: 8),
            for (final suggestion in suggestions)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion.exerciseName,
                      style: context.type.cardTitle.copyWith(fontSize: 13.5),
                    ),
                    Text(
                      '${suggestion.currentWeight?.toStringAsFixed(1)}kg '
                      '→ ${suggestion.suggestedWeight?.toStringAsFixed(1)}kg',
                      style: context.type.numeric.copyWith(
                        fontSize: 13,
                        color: p.accent,
                      ),
                    ),
                  ],
                ),
              ),
            Text(AppStrings.progressionHint, style: context.type.caption),
          ],
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.confirm),
        ),
      ],
    );
  }
}

/// Picks one of the routine item's predefined alternatives.
class SubstituteSheet extends StatelessWidget {
  const SubstituteSheet({required this.alternatives, super.key});

  final List<Exercise> alternatives;

  static Future<Exercise?> show(
    BuildContext context,
    List<Exercise> alternatives,
  ) => showModalBottomSheet<Exercise>(
    context: context,
    builder: (_) => SubstituteSheet(alternatives: alternatives),
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.switchExercise,
                  style: context.type.sectionTitle,
                ),
                const SizedBox(height: 4),
                Text('기구가 없으면 30초 안에 갈아탑니다.', style: context.type.caption),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (alternatives.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('지정된 대체 종목이 없습니다', style: context.type.caption),
            )
          else
            for (final exercise in alternatives)
              ListTile(
                onTap: () => Navigator.of(context).pop(exercise),
                leading: BodyPartBar(exercise.bodyPart, height: 26),
                title: Text(exercise.name, style: context.type.cardTitle),
                subtitle: exercise.equipment == null
                    ? null
                    : Text(exercise.equipment!, style: context.type.caption),
              ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
