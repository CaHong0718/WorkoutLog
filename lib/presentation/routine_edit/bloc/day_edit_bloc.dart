import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/mvi/mvi_bloc.dart';
import '../../../core/result/result.dart';
import '../../../domain/entity/routine_block.dart';
import '../../../domain/entity/routine_item.dart';
import '../../../domain/usecase/exercise_usecases.dart';
import '../../../domain/usecase/routine_usecases.dart';
import 'day_edit_effect.dart';
import 'day_edit_intent.dart';
import 'day_edit_state.dart';

/// Editor for one rotation day: its meta, its blocks and the exercise slots
/// inside them.
///
/// Every handler that writes runs through [sequential] — two quick taps on
/// "종목 추가" must not both read the same `items.length` and insert twice.
@injectable
class DayEditBloc extends MviBloc<DayEditIntent, DayEditState, DayEditEffect> {
  DayEditBloc(
    @factoryParam this.dayId,
    this._getDayDetail,
    this._getAllExercises,
    this._upsertDay,
    this._upsertBlock,
    this._deleteBlock,
    this._reorderBlocks,
    this._upsertItem,
    this._deleteItem,
    this._reorderItems,
  ) : super(const DayEditState()) {
    on<LoadDay>(_onLoad);
    on<SaveDayMeta>(_onSaveDayMeta, transformer: sequential());
    on<CreateBlock>(_onCreateBlock, transformer: sequential());
    on<SaveBlock>(_onSaveBlock, transformer: sequential());
    on<RemoveBlock>(_onRemoveBlock, transformer: sequential());
    on<MoveBlock>(_onMoveBlock, transformer: sequential());
    on<CreateItem>(_onCreateItem, transformer: sequential());
    on<SaveItem>(_onSaveItem, transformer: sequential());
    on<RemoveItem>(_onRemoveItem, transformer: sequential());
    on<MoveItem>(_onMoveItem, transformer: sequential());
  }

  final int dayId;
  final GetDayDetail _getDayDetail;
  final GetAllExercises _getAllExercises;
  final UpsertDay _upsertDay;
  final UpsertBlock _upsertBlock;
  final DeleteBlock _deleteBlock;
  final ReorderBlocks _reorderBlocks;
  final UpsertItem _upsertItem;
  final DeleteItem _deleteItem;
  final ReorderItems _reorderItems;

  Future<void> _onLoad(LoadDay intent, Emitter<DayEditState> emit) async {
    emit(state.copyWith(isLoading: true, clearFailure: true));

    final exercises = (await _getAllExercises()).valueOrNull ?? const [];
    final dayResult = await _getDayDetail(dayId);

    switch (dayResult) {
      case Ok(:final value):
        emit(
          state.copyWith(
            isLoading: false,
            day: value,
            exercises: exercises,
            clearFailure: true,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            isLoading: false,
            exercises: exercises,
            failure: failure,
          ),
        );
    }
  }

  Future<void> _onSaveDayMeta(
    SaveDayMeta intent,
    Emitter<DayEditState> emit,
  ) async {
    final day = state.day;
    if (day == null) return;

    await _write(
      emit,
      () => _upsertDay(
        intent.day.copyWith(
          id: day.id,
          routineId: day.routineId,
          order: day.order,
        ),
      ),
    );
  }

  Future<void> _onCreateBlock(
    CreateBlock intent,
    Emitter<DayEditState> emit,
  ) async {
    final day = state.day;
    if (day == null) return;

    await _write(
      emit,
      () => _upsertBlock(
        RoutineBlock(
          id: RoutineBlock.unsavedId,
          dayId: day.id,
          order: day.blocks.length,
          label: _nextBlockLabel(),
          restSeconds: 90,
          targetMinutes: 8,
        ),
      ),
    );
  }

  Future<void> _onSaveBlock(
    SaveBlock intent,
    Emitter<DayEditState> emit,
  ) async {
    final block = intent.block;
    final rounds = block.isSuperset ? block.rounds : 1;

    await _write(emit, () async {
      final result = await _upsertBlock(block.copyWith(rounds: rounds));
      if (result.isErr) return result;

      // A superset prescribes rounds, not per-exercise sets: keep the slots in
      // step so the session plan can cycle them.
      if (block.isSuperset) {
        final current = state.blocks.where((b) => b.id == block.id).firstOrNull;
        for (final item in current?.items ?? const <RoutineItem>[]) {
          if (item.sets == rounds) continue;
          await _upsertItem(item.copyWith(sets: rounds));
        }
      }
      return result;
    });
  }

  Future<void> _onRemoveBlock(
    RemoveBlock intent,
    Emitter<DayEditState> emit,
  ) async {
    final day = state.day;
    if (day == null) return;

    await _write(emit, () async {
      final result = await _deleteBlock(intent.blockId);
      if (result.isErr) return result;
      return _reorderBlocks(
        day.id,
        state.blocks
            .where((block) => block.id != intent.blockId)
            .map((block) => block.id)
            .toList(),
      );
    });
  }

  Future<void> _onMoveBlock(
    MoveBlock intent,
    Emitter<DayEditState> emit,
  ) async {
    final day = state.day;
    if (day == null) return;

    final blocks = _moved(state.blocks, intent.oldIndex, intent.newIndex);
    if (blocks == null) return;

    emit(state.copyWith(day: day.copyWith(blocks: blocks)));
    await _write(
      emit,
      () => _reorderBlocks(day.id, blocks.map((block) => block.id).toList()),
    );
  }

  Future<void> _onCreateItem(
    CreateItem intent,
    Emitter<DayEditState> emit,
  ) async {
    final block = state.blocks.where((b) => b.id == intent.blockId).firstOrNull;
    if (block == null) return;

    await _write(
      emit,
      () => _upsertItem(
        RoutineItem(
          id: RoutineItem.unsavedId,
          blockId: block.id,
          order: block.items.length,
          exercise: intent.exercise,
          sets: block.isSuperset ? block.rounds : 3,
          repMin: 8,
          repMax: 12,
        ),
      ),
    );
  }

  Future<void> _onSaveItem(SaveItem intent, Emitter<DayEditState> emit) =>
      _write(emit, () => _upsertItem(intent.item));

  Future<void> _onRemoveItem(
    RemoveItem intent,
    Emitter<DayEditState> emit,
  ) async {
    final block = state.blocks
        .where((b) => b.items.any((item) => item.id == intent.itemId))
        .firstOrNull;
    if (block == null) return;

    await _write(emit, () async {
      final result = await _deleteItem(intent.itemId);
      if (result.isErr) return result;
      return _reorderItems(
        block.id,
        block.items
            .where((item) => item.id != intent.itemId)
            .map((item) => item.id)
            .toList(),
      );
    });
  }

  Future<void> _onMoveItem(MoveItem intent, Emitter<DayEditState> emit) async {
    final day = state.day;
    final block = state.blocks.where((b) => b.id == intent.blockId).firstOrNull;
    if (day == null || block == null) return;

    final items = _moved(block.items, intent.oldIndex, intent.newIndex);
    if (items == null) return;

    emit(
      state.copyWith(
        day: day.copyWith(
          blocks: [
            for (final b in day.blocks)
              if (b.id == block.id) b.copyWith(items: items) else b,
          ],
        ),
      ),
    );
    await _write(
      emit,
      () => _reorderItems(block.id, items.map((item) => item.id).toList()),
    );
  }

  // ── internals ───────────────────────────────────────────────────────────

  /// Runs a write, surfaces its failure as a message and reloads the day so
  /// the screen always shows what the database actually holds.
  Future<void> _write(
    Emitter<DayEditState> emit,
    Future<Result<Object?>> Function() body,
  ) async {
    if (state.isSaving) return;
    emit(state.copyWith(isSaving: true));

    final result = await body();
    if (result.isErr) {
      emit(state.copyWith(isSaving: false));
      emitEffect(ShowDayEditMessage(result.failureOrNull!.message));
      return;
    }

    final dayResult = await _getDayDetail(dayId);
    switch (dayResult) {
      case Ok(:final value):
        emit(state.copyWith(isSaving: false, day: value, clearFailure: true));
      case Err(:final failure):
        emit(state.copyWith(isSaving: false, failure: failure));
    }
  }

  /// Applies a drag. Indices arrive already normalised from
  /// `ReorderableListView.onReorderItem`. Returns null for a no-op.
  List<T>? _moved<T>(List<T> source, int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= source.length) return null;
    if (newIndex < 0 || newIndex >= source.length) return null;
    if (oldIndex == newIndex) return null;

    final moved = [...source];
    moved.insert(newIndex, moved.removeAt(oldIndex));
    return moved;
  }

  /// `B1`, `B2`, … continuing after the highest numbered label in use.
  String _nextBlockLabel() {
    var highest = 0;
    for (final block in state.blocks) {
      final match = RegExp(r'^B(\d+)$').firstMatch(block.label);
      final value = int.tryParse(match?.group(1) ?? '');
      if (value != null && value > highest) highest = value;
    }
    return 'B${highest + 1}';
  }
}
