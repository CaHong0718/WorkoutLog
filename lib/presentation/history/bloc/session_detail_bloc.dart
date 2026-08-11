import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/mvi/mvi_bloc.dart';
import '../../../core/result/result.dart';
import '../../../domain/usecase/history_usecases.dart';
import '../../../domain/usecase/workout_usecases.dart';
import 'session_detail_effect.dart';
import 'session_detail_intent.dart';
import 'session_detail_state.dart';

@injectable
class SessionDetailBloc
    extends MviBloc<SessionDetailIntent, SessionDetailState, SessionDetailEffect> {
  SessionDetailBloc(
    @factoryParam this.sessionId,
    this._getSessionDetail,
    this._deleteSession,
  ) : super(const SessionDetailState()) {
    on<LoadSessionDetail>(_onLoad, transformer: sequential());
    on<DeleteSessionRecord>(_onDelete, transformer: sequential());
  }

  final int sessionId;
  final GetSessionDetail _getSessionDetail;
  final DeleteSession _deleteSession;

  Future<void> _onLoad(
    LoadSessionDetail intent,
    Emitter<SessionDetailState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearFailure: true));

    switch (await _getSessionDetail(sessionId)) {
      case Ok(:final value):
        emit(state.copyWith(isLoading: false, session: value));
      case Err(:final failure):
        emit(state.copyWith(isLoading: false, failure: failure));
        // A refresh that fails keeps the record on screen; say so instead.
        if (state.hasSession) {
          emitEffect(ShowSessionDetailMessage(failure.message));
        }
    }
  }

  Future<void> _onDelete(
    DeleteSessionRecord intent,
    Emitter<SessionDetailState> emit,
  ) async {
    if (state.isDeleting) return;
    emit(state.copyWith(isDeleting: true));

    switch (await _deleteSession(sessionId)) {
      case Ok():
        emitEffect(const SessionRecordDeleted());
      case Err(:final failure):
        emit(state.copyWith(isDeleting: false));
        emitEffect(ShowSessionDetailMessage(failure.message));
    }
  }
}
