import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/date_time_x.dart';
import '../../../core/mvi/effect_listener.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_metrics.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../common/branch_reveal.dart';
import '../../common/common_widgets.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_effect.dart';
import '../bloc/home_intent.dart';
import '../bloc/home_state.dart';
import '../widget/block_preview_list.dart';
import '../widget/day_picker_sheet.dart';
import '../widget/day_summary_card.dart';
import '../widget/in_progress_sheet.dart';
import '../widget/resume_banner.dart';
import '../widget/weekly_volume_panel.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeBloc>()..add(const LoadHome()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<HomeBloc>();

    return OnBranchReveal(
      onReveal: () => bloc.add(const LoadHome()),
      child: EffectListener<HomeEffect>(
        stream: bloc.effects,
        onEffect: _handleEffect,
        child: Scaffold(
          appBar: AppBar(
            titleSpacing: 12,
            title: BlocBuilder<HomeBloc, HomeState>(
              buildWhen: (a, b) => a.routine?.name != b.routine?.name,
              builder: (context, state) =>
                  _RoutineSwitcher(name: state.routine?.name),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    DateTime.now().formatKo,
                    style: context.type.label,
                  ),
                ),
              ),
            ],
          ),
          body: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state.isLoading && state.routine == null) {
                return const LoadingView();
              }
              if (state.failure != null && state.routine == null) {
                return ErrorView(
                  message: state.failure!.message,
                  onRetry: () => bloc.add(const LoadHome()),
                );
              }
              if (!state.hasRoutine) {
                return const EmptyView(message: '루틴이 없습니다');
              }
              return _HomeContent(state: state);
            },
          ),
        ),
      ),
    );
  }

  void _handleEffect(BuildContext context, HomeEffect effect) {
    switch (effect) {
      case OpenSession(:final sessionId):
        _openSession(context, sessionId);
      case ShowHomeMessage(:final message):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  /// Reloads on return. The session opens on the root navigator, so coming back
  /// changes no branch and fires no reveal; without this Home keeps the state it
  /// had *before* the workout — a session left running would have no resume
  /// banner, and a finished one would still show it.
  Future<void> _openSession(BuildContext context, int sessionId) async {
    final bloc = context.read<HomeBloc>();

    await context.pushNamed(
      Routes.session,
      pathParameters: {'sessionId': '$sessionId'},
    );

    bloc.add(const LoadHome());
  }
}

/// The app bar shows *which routine is in use*, not the product name — that is
/// the one piece of context the home screen cannot infer from its own cards
/// once more than one routine exists. Tapping opens the library.
class _RoutineSwitcher extends StatelessWidget {
  const _RoutineSwitcher({required this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.pushNamed(Routes.routineList),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                name ?? AppStrings.appName,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.expand_more, size: 20, color: context.palette.ink3),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<HomeBloc>();
    final day = state.selectedDay!;

    return RefreshIndicator(
      onRefresh: () async => bloc.add(const LoadHome()),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          if (state.hasInProgress) ...[
            ResumeBanner(
              session: state.inProgressSession!,
              onResume: () => bloc.add(const ResumeWorkout()),
              onDiscard: () => _confirmDiscard(context),
            ),
            const SizedBox(height: 16),
          ],
          const Eyebrow('Today'),
          const SizedBox(height: AppLayout.labelGap),
          DaySummaryCard(day: day),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: state.isStarting ? null : () => _start(context),
                  icon: state.isStarting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow_rounded, size: 22),
                  label: const Text(AppStrings.startSession),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickDay(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                  ),
                  child: const Text(AppStrings.changeDay),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.cutRuleHint,
            style: context.type.caption.copyWith(color: context.palette.ink3),
          ),
          const SizedBox(height: AppLayout.sectionGap),
          const Eyebrow('Blocks'),
          const SizedBox(height: AppLayout.labelGap),
          BlockPreviewList(day: day),
          const SizedBox(height: AppLayout.sectionGap),
          const Eyebrow('This Week'),
          const SizedBox(height: AppLayout.labelGap),
          WeeklyVolumePanel(
            done: state.weeklyVolume,
            target: state.weeklyTarget,
          ),
        ],
      ),
    );
  }

  /// Starting a session aborts whatever is still open, so an unfinished workout
  /// is never replaced without saying so.
  Future<void> _start(BuildContext context) async {
    final bloc = context.read<HomeBloc>();
    final running = state.inProgressSession;
    if (running == null) {
      bloc.add(const StartWorkout());
      return;
    }

    final choice = await InProgressSheet.show(
      context,
      session: running,
      day: state.selectedDay!,
    );
    switch (choice) {
      case StartChoice.resume:
        bloc.add(const ResumeWorkout());
      case StartChoice.startNew:
        bloc.add(const StartWorkout());
      case null:
        break;
    }
  }

  Future<void> _confirmDiscard(BuildContext context) async {
    final bloc = context.read<HomeBloc>();
    final session = state.inProgressSession!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('진행 중인 운동을 중단할까요?'),
        content: Text(
          session.completedSets == 0
              ? 'DAY ${session.dayCode} 세션을 닫습니다. 기록된 세트는 없습니다.'
              : 'DAY ${session.dayCode} 세션을 닫습니다. '
                    '이미 한 ${session.completedSets}${AppStrings.setUnit}는 기록에 남습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(AppStrings.abortSession),
          ),
        ],
      ),
    );

    if (confirmed ?? false) bloc.add(const DiscardInProgress());
  }

  Future<void> _pickDay(BuildContext context) async {
    final bloc = context.read<HomeBloc>();
    final days = state.routine?.days ?? const [];
    if (days.isEmpty) return;

    final picked = await DayPickerSheet.show(
      context,
      days: days,
      selectedId: state.selectedDay!.id,
    );
    if (picked != null) bloc.add(SelectDay(picked));
  }
}
