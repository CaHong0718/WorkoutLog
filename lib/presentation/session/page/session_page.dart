import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../core/mvi/effect_listener.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../common/common_widgets.dart';
import '../bloc/session_bloc.dart';
import '../bloc/session_effect.dart';
import '../bloc/session_intent.dart';
import '../bloc/session_state.dart';
import '../widget/current_set_card.dart';
import '../widget/plan_timeline.dart';
import '../widget/rest_timer_card.dart';
import '../widget/session_header.dart';
import '../widget/session_sheets.dart';

class SessionPage extends StatelessWidget {
  const SessionPage({required this.sessionId, super.key});

  final int sessionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<SessionBloc>(param1: sessionId)..add(const LoadSession()),
      child: const _SessionView(),
    );
  }
}

class _SessionView extends StatelessWidget {
  const _SessionView();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SessionBloc>();

    return EffectListener<SessionEffect>(
      stream: bloc.effects,
      onEffect: _handleEffect,
      child: BlocBuilder<SessionBloc, SessionState>(
        builder: (context, state) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) _confirmLeave(context, state);
            },
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => _confirmLeave(context, state),
                ),
                title: Text(
                  state.session == null
                      ? '운동 중'
                      : 'DAY ${state.session!.dayCode} · ${state.session!.dayTitle}',
                ),
                actions: [
                  TextButton(
                    onPressed: state.isFinishing
                        ? null
                        : () => _finish(context, state),
                    child: const Text('종료'),
                  ),
                ],
              ),
              body: _buildBody(context, state),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, SessionState state) {
    final bloc = context.read<SessionBloc>();

    if (state.isLoading && state.session == null) return const LoadingView();
    if (state.failure != null && !state.isReady) {
      return ErrorView(
        message: state.failure!.message,
        onRetry: () => bloc.add(const LoadSession()),
      );
    }
    if (!state.isReady) {
      return const EmptyView(message: '세션 정보를 불러올 수 없습니다');
    }

    return Column(
      children: [
        SessionHeader(state: state),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            children: [
              if (state.isResting)
                RestTimerCard(
                  rest: state.rest!,
                  nextLabel: _nextLabel(state),
                  onAddTime: () => bloc.add(const AddRest(15)),
                  onSkip: () => bloc.add(const SkipRest()),
                )
              else if (state.currentSet != null)
                CurrentSetCard(
                  key: ValueKey(
                    '${state.currentSet!.item.id}-${state.currentSet!.setIndex}',
                  ),
                  planned: state.currentSet!,
                  exercise: state.exerciseFor(state.currentSet!),
                  previousLogs:
                      state.lastLogs[state.exerciseFor(state.currentSet!).id] ??
                      const [],
                  onComplete: (values) => bloc.add(
                    CompleteCurrentSet(
                      weight: values.weight,
                      reps: values.reps,
                      rir: values.rir,
                      durationSeconds: values.durationSeconds,
                    ),
                  ),
                  onSkip: () => bloc.add(const SkipCurrentSet()),
                  onSubstitute: () => _substitute(context, state),
                )
              else
                _AllDoneCard(onFinish: () => _finish(context, state)),
              const SizedBox(height: 20),
              const Eyebrow('Session Plan'),
              const SizedBox(height: 12),
              PlanTimeline(
                state: state,
                onSkipBlock: (index) => bloc.add(SkipBlock(index)),
                onJump: (index) => bloc.add(JumpToSet(index)),
              ),
              const SizedBox(height: 8),
              Text(AppStrings.cutRuleHint, style: context.type.caption),
            ],
          ),
        ),
      ],
    );
  }

  String _nextLabel(SessionState state) {
    final next = state.currentSet;
    if (next == null) return '마지막 세트까지 완료';
    return '다음 · ${next.positionLabel} · ${state.exerciseFor(next).name}';
  }

  Future<void> _substitute(BuildContext context, SessionState state) async {
    final planned = state.currentSet;
    if (planned == null) return;
    final bloc = context.read<SessionBloc>();

    final picked = await SubstituteSheet.show(
      context,
      state.alternatives[planned.item.id] ?? const [],
    );
    if (picked != null) {
      bloc.add(SubstituteExercise(planned.item.id, picked));
    }
  }

  Future<void> _finish(BuildContext context, SessionState state) async {
    final bloc = context.read<SessionBloc>();
    final memo = await FinishSheet.show(context, state);
    if (memo == null) return;
    bloc.add(FinishSession(memo: memo.isEmpty ? null : memo));
  }

  Future<void> _confirmLeave(BuildContext context, SessionState state) async {
    final bloc = context.read<SessionBloc>();
    final navigator = Navigator.of(context);

    switch (await LeaveSheet.show(context, state)) {
      case LeaveChoice.keepForLater:
        navigator.pop();
      case LeaveChoice.abort:
        bloc.add(const AbortCurrentSession());
      case null:
        break;
    }
  }

  void _handleEffect(BuildContext context, SessionEffect effect) {
    switch (effect) {
      case RestFinished():
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(AppStrings.restDone),
              duration: Duration(seconds: 2),
            ),
          );
      case SessionCompleted(:final session, :final suggestions):
        SessionResultDialog.show(
          context,
          session: session,
          suggestions: suggestions,
        ).then((_) {
          if (context.mounted) Navigator.of(context).pop();
        });
      case SessionClosed():
        Navigator.of(context).pop();
      case ShowSessionMessage(:final message):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

class _AllDoneCard extends StatelessWidget {
  const _AllDoneCard({required this.onFinish});

  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SectionCard(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline, size: 44, color: p.accent),
          const SizedBox(height: 12),
          Text('계획한 세트를 모두 마쳤습니다', style: context.type.sectionTitle),
          const SizedBox(height: 6),
          Text(
            '복근 슬롯은 남은 시간만큼만 하고 끝내세요.',
            style: context.type.caption,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onFinish,
              child: const Text(AppStrings.finishSession),
            ),
          ),
        ],
      ),
    );
  }
}
