import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failure.dart';
import '../../../core/mvi/mvi_bloc.dart';
import '../../../core/result/result.dart';
import '../../../domain/entity/exercise.dart';
import '../../../domain/usecase/exercise_usecases.dart';
import 'exercise_library_effect.dart';
import 'exercise_library_intent.dart';
import 'exercise_library_state.dart';

/// Exercise master data: browse, search, add, edit, delete.
@injectable
class ExerciseLibraryBloc
    extends
        MviBloc<
          ExerciseLibraryIntent,
          ExerciseLibraryState,
          ExerciseLibraryEffect
        > {
  ExerciseLibraryBloc(
    this._watchExercises,
    this._upsertExercise,
    this._deleteExercise,
  ) : super(const ExerciseLibraryState()) {
    on<LoadLibrary>(_onLoad);
    on<FilterLibrary>(_onFilter);
    on<SearchLibrary>(_onSearch);
    on<SaveExercise>(_onSave, transformer: sequential());
    on<RemoveExercise>(_onRemove, transformer: sequential());
  }

  final WatchExercises _watchExercises;
  final UpsertExercise _upsertExercise;
  final DeleteExercise _deleteExercise;

  bool _isWatching = false;

  Future<void> _onLoad(
    LoadLibrary intent,
    Emitter<ExerciseLibraryState> emit,
  ) async {
    if (_isWatching) return;
    _isWatching = true;

    emit(state.copyWith(isLoading: true, clearFailure: true));
    await emit.forEach<List<Exercise>>(
      _watchExercises(),
      onData: (exercises) => state.copyWith(
        isLoading: false,
        exercises: exercises,
        clearFailure: true,
      ),
      onError: (error, _) => state.copyWith(
        isLoading: false,
        failure: DatabaseFailure('종목 목록을 불러오지 못했습니다.', cause: error),
      ),
    );
    // The stream ended (error or close) — allow the retry button to resubscribe.
    _isWatching = false;
  }

  void _onFilter(FilterLibrary intent, Emitter<ExerciseLibraryState> emit) {
    emit(
      state.copyWith(
        bodyPart: intent.bodyPart,
        clearBodyPart: intent.bodyPart == null,
      ),
    );
  }

  void _onSearch(SearchLibrary intent, Emitter<ExerciseLibraryState> emit) {
    emit(state.copyWith(query: intent.query));
  }

  Future<void> _onSave(
    SaveExercise intent,
    Emitter<ExerciseLibraryState> emit,
  ) async {
    emit(state.copyWith(isSaving: true));
    final isNew = intent.exercise.id == Exercise.unsavedId;
    // Anything the user creates or edits by hand is their own entry.
    final result = await _upsertExercise(
      isNew ? intent.exercise.copyWith(isCustom: true) : intent.exercise,
    );
    emit(state.copyWith(isSaving: false));

    switch (result) {
      case Ok():
        emitEffect(ShowLibraryMessage(isNew ? '종목을 추가했습니다.' : '종목을 수정했습니다.'));
      case Err(:final failure):
        emitEffect(ShowLibraryMessage(failure.message));
    }
  }

  Future<void> _onRemove(
    RemoveExercise intent,
    Emitter<ExerciseLibraryState> emit,
  ) async {
    emit(state.copyWith(isSaving: true));
    final result = await _deleteExercise(intent.exerciseId);
    emit(state.copyWith(isSaving: false));

    switch (result) {
      case Ok():
        emitEffect(const ShowLibraryMessage('종목을 삭제했습니다.'));
      case Err(:final failure):
        // ValidationFailure when a routine still uses it.
        emitEffect(ShowLibraryMessage(failure.message));
    }
  }
}
