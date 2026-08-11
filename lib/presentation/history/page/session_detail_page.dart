import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../core/mvi/effect_listener.dart';
import '../../common/common_widgets.dart';
import '../bloc/session_detail_bloc.dart';
import '../bloc/session_detail_effect.dart';
import '../bloc/session_detail_intent.dart';
import '../bloc/session_detail_state.dart';
import '../widget/session_log_list.dart';
import '../widget/session_summary_header.dart';

/// One finished session, rebuilt entirely from the logged snapshots.
class SessionDetailPage extends StatelessWidget {
  const SessionDetailPage({required this.sessionId, super.key});

  final int sessionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SessionDetailBloc>(param1: sessionId)
        ..add(const LoadSessionDetail()),
      child: const _SessionDetailView(),
    );
  }
}

class _SessionDetailView extends StatelessWidget {
  const _SessionDetailView();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SessionDetailBloc>();

    return EffectListener<SessionDetailEffect>(
      stream: bloc.effects,
      onEffect: _handleEffect,
      child: Scaffold(
        appBar: AppBar(title: const Text(AppStrings.sessionDetail)),
        body: BlocBuilder<SessionDetailBloc, SessionDetailState>(
          builder: (context, state) {
            if (state.isLoading && !state.hasSession) {
              return const LoadingView();
            }
            if (!state.hasSession) {
              return ErrorView(
                message: state.failure?.message ?? AppStrings.emptyDefault,
                onRetry: () => bloc.add(const LoadSessionDetail()),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => bloc.add(const LoadSessionDetail()),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  SessionSummaryHeader(session: state.session!),
                  const SizedBox(height: 20),
                  const Eyebrow('Sets'),
                  const SizedBox(height: 12),
                  SessionLogList(blocks: state.blocks),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleEffect(BuildContext context, SessionDetailEffect effect) {
    switch (effect) {
      case ShowSessionDetailMessage(:final message):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
