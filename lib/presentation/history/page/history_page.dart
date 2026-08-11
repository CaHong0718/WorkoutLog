import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../core/mvi/effect_listener.dart';
import '../../../core/router/app_router.dart';
import '../../common/branch_reveal.dart';
import '../../common/common_widgets.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_effect.dart';
import '../bloc/history_intent.dart';
import '../bloc/history_state.dart';
import '../bloc/stats_bloc.dart';
import '../bloc/stats_effect.dart';
import '../bloc/stats_intent.dart';
import '../bloc/stats_state.dart';
import '../widget/day_session_panel.dart';
import '../widget/exercise_trend_section.dart';
import '../widget/history_summary_card.dart';
import '../widget/month_calendar.dart';
import '../widget/segmented_tabs.dart';
import '../widget/weekly_volume_section.dart';

/// The "기록" branch of the bottom navigation.
///
/// Two blocs, one screen: [HistoryBloc] owns the calendar and the all-time
/// summary, [StatsBloc] owns the weekly volume and the per-exercise trend.
/// They are provided together because the segments are three views of the same
/// screen, and switching between them must not refetch anything.
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<HistoryBloc>()..add(const LoadHistory()),
        ),
        BlocProvider(create: (_) => getIt<StatsBloc>()..add(const LoadStats())),
      ],
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatefulWidget {
  const _HistoryView();

  @override
  State<_HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<_HistoryView> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final historyBloc = context.read<HistoryBloc>();
    final statsBloc = context.read<StatsBloc>();

    return OnBranchReveal(
      onReveal: () {
        historyBloc.add(const LoadHistory());
        statsBloc.add(const LoadStats());
      },
      child: EffectListener<HistoryEffect>(
        stream: historyBloc.effects,
        onEffect: _handleHistoryEffect,
        child: EffectListener<StatsEffect>(
          stream: statsBloc.effects,
          onEffect: _handleStatsEffect,
          child: Scaffold(
            appBar: AppBar(title: const Text(AppStrings.history)),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
                  child: SegmentedTabs(
                    labels: const [
                      AppStrings.tabCalendar,
                      AppStrings.tabVolume,
                      AppStrings.tabTrend,
                    ],
                    selectedIndex: _tab,
                    onChanged: (index) => setState(() => _tab = index),
                  ),
                ),
                Expanded(
                  child: IndexedStack(
                    index: _tab,
                    children: const [_CalendarTab(), _VolumeTab(), _TrendTab()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleHistoryEffect(BuildContext context, HistoryEffect effect) {
    switch (effect) {
      case OpenSessionDetail(:final sessionId):
        _push(context, Routes.sessionDetail, sessionId);
      case ResumeSessionFromHistory(:final sessionId):
        _push(context, Routes.session, sessionId);
      case ShowHistoryMessage(:final message):
        _snack(context, message);
    }
  }

  /// Reloads on return so a deleted record disappears from the calendar, the
  /// day panel and the weekly volume — and so sets logged in a resumed session
  /// show up right away.
  Future<void> _push(BuildContext context, String route, int sessionId) async {
    final historyBloc = context.read<HistoryBloc>();
    final statsBloc = context.read<StatsBloc>();

    await context.pushNamed(route, pathParameters: {'sessionId': '$sessionId'});

    historyBloc.add(const LoadHistory());
    statsBloc.add(const LoadStats());
  }

  void _handleStatsEffect(BuildContext context, StatsEffect effect) {
    switch (effect) {
      case ShowStatsMessage(:final message):
        _snack(context, message);
    }
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CalendarTab extends StatelessWidget {
  const _CalendarTab();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<HistoryBloc>();

    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        if (state.isLoading && !state.hasLoaded) {
          return const LoadingView();
        }
        if (state.failure != null && !state.hasLoaded) {
          return ErrorView(
            message: state.failure!.message,
            onRetry: () => bloc.add(const LoadHistory()),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => bloc.add(const LoadHistory()),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            children: [
              HistorySummaryCard(
                totalSessions: state.totalSessions,
                weekSets: state.weekSets,
                streakWeeks: state.streakWeeks,
                monthWorkouts: state.monthWorkoutCount,
              ),
              const SizedBox(height: 18),
              const Eyebrow('Calendar'),
              const SizedBox(height: 12),
              MonthCalendar(
                month: state.month,
                markedDates: state.workoutDates,
                dayBodyParts: state.dayBodyParts,
                selectedDate: state.selectedDate,
                isLoading: state.isMonthLoading,
                onChangeMonth: (delta) => bloc.add(ChangeMonth(delta)),
                onSelectDate: (date) => bloc.add(SelectDate(date)),
              ),
              const SizedBox(height: 14),
              DaySessionPanel(
                date: state.selectedDate,
                sessions: state.selectedSessions,
                isLoading: state.isDayLoading,
                onOpen: (session) => bloc.add(
                  OpenSessionRecord(
                    session.id,
                    isInProgress: session.isInProgress,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VolumeTab extends StatelessWidget {
  const _VolumeTab();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StatsBloc>();

    return BlocBuilder<StatsBloc, StatsState>(
      builder: (context, state) {
        if (state.isLoading && !state.hasLoaded) {
          return const LoadingView();
        }
        if (state.failure != null && !state.hasLoaded) {
          return ErrorView(
            message: state.failure!.message,
            onRetry: () => bloc.add(const LoadStats()),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => bloc.add(const LoadStats()),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            children: [
              WeeklyVolumeSection(
                state: state,
                onChangeWeek: (delta) => bloc.add(ChangeWeek(delta)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TrendTab extends StatelessWidget {
  const _TrendTab();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StatsBloc>();

    return BlocBuilder<StatsBloc, StatsState>(
      builder: (context, state) {
        if (state.isLoading && !state.hasLoaded) {
          return const LoadingView();
        }
        if (state.failure != null && !state.hasLoaded) {
          return ErrorView(
            message: state.failure!.message,
            onRetry: () => bloc.add(const LoadStats()),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => bloc.add(const LoadStats()),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            children: [
              const Eyebrow(AppStrings.progressChart),
              const SizedBox(height: 12),
              ExerciseTrendSection(
                state: state,
                onSelect: (id) => bloc.add(SelectTrendExercise(id)),
              ),
            ],
          ),
        );
      },
    );
  }
}
