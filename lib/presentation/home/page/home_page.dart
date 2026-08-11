import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/date_time_x.dart';
import '../../../core/mvi/effect_listener.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../common/common_widgets.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_effect.dart';
import '../bloc/home_intent.dart';
import '../bloc/home_state.dart';
import '../widget/block_preview_list.dart';
import '../widget/day_picker_sheet.dart';
import '../widget/day_summary_card.dart';
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

    return EffectListener<HomeEffect>(
      stream: bloc.effects,
      onEffect: _handleEffect,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.appName),
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
    );
  }

  void _handleEffect(BuildContext context, HomeEffect effect) {
    switch (effect) {
      case OpenSession(:final sessionId):
        context.pushNamed(
          Routes.session,
          pathParameters: {'sessionId': '$sessionId'},
        );
      case ShowHomeMessage(:final message):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
    }
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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          if (state.hasInProgress) ...[
            ResumeBanner(
              session: state.inProgressSession!,
              onResume: () => bloc.add(const ResumeWorkout()),
              onDiscard: () => bloc.add(const DiscardInProgress()),
            ),
            const SizedBox(height: 16),
          ],
          const Eyebrow('Today'),
          const SizedBox(height: 12),
          DaySummaryCard(day: day),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: state.isStarting
                      ? null
                      : () => bloc.add(const StartWorkout()),
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
          const SizedBox(height: 24),
          const Eyebrow('Blocks'),
          const SizedBox(height: 12),
          BlockPreviewList(day: day),
          const SizedBox(height: 14),
          const Eyebrow('This Week'),
          const SizedBox(height: 12),
          WeeklyVolumePanel(
            done: state.weeklyVolume,
            target: state.weeklyTarget,
          ),
        ],
      ),
    );
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
