import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'routine_block.dart';
import 'routine_day.dart';
import 'routine_item.dart';
import 'set_log.dart';

/// One set the user is expected to perform, in execution order.
class PlannedSet extends Equatable {
  const PlannedSet({
    required this.blockIndex,
    required this.blockLabel,
    required this.blockType,
    required this.rounds,
    required this.item,
    required this.itemOrder,
    required this.setIndex,
    required this.restAfterSeconds,
    required this.isCuttable,
    this.blockName,
  });

  final int blockIndex;
  final String blockLabel;
  final String? blockName;
  final BlockType blockType;

  /// Round count of the owning block; 1 for a straight block.
  final int rounds;

  final RoutineItem item;

  /// Position of this exercise within the whole session — the value stored on
  /// [SetLog.itemOrder].
  final int itemOrder;

  /// 1-based. For a superset this equals the round number.
  final int setIndex;

  /// Rest to start once this set is logged. Zero between the exercises of one
  /// superset round, and zero after the final set of the session.
  final int restAfterSeconds;

  final bool isCuttable;

  bool get isSuperset => blockType == BlockType.superset;

  bool get isTimed => item.repMode == RepMode.duration;

  BodyPart get bodyPart => item.bodyPart;

  /// `B3 · 2R/3` or `B1 · 2세트/4`
  String get positionLabel => isSuperset
      ? '$blockLabel · $setIndex라운드/$rounds'
      : '$blockLabel · $setIndex세트/${item.sets}';

  @override
  List<Object?> get props => [blockIndex, item.id, setIndex];
}

/// Expands a [RoutineDay] into the flat, ordered list of sets to perform.
///
/// Straight block  → item's sets run back to back.
/// Superset block  → items are cycled as rounds: A1 B1 · A2 B2 · A3 B3, and the
///                   rest only fires at the end of each round.
abstract final class SessionPlan {
  static List<PlannedSet> fromDay(RoutineDay day) {
    final planned = <PlannedSet>[];
    var itemOrder = 0;

    for (var blockIndex = 0; blockIndex < day.blocks.length; blockIndex++) {
      final block = day.blocks[blockIndex];
      if (block.items.isEmpty) continue;

      if (block.type == BlockType.superset) {
        final orders = <int, int>{};
        for (final item in block.items) {
          orders[item.id] = itemOrder++;
        }
        for (var round = 1; round <= block.rounds; round++) {
          for (var i = 0; i < block.items.length; i++) {
            final item = block.items[i];
            final isLastOfRound = i == block.items.length - 1;
            planned.add(
              _make(
                block: block,
                blockIndex: blockIndex,
                item: item,
                itemOrder: orders[item.id]!,
                setIndex: round,
                restAfterSeconds: isLastOfRound
                    ? (item.restSecondsOverride ?? block.restSeconds)
                    : 0,
              ),
            );
          }
        }
      } else {
        for (final item in block.items) {
          final order = itemOrder++;
          for (var setIndex = 1; setIndex <= item.sets; setIndex++) {
            planned.add(
              _make(
                block: block,
                blockIndex: blockIndex,
                item: item,
                itemOrder: order,
                setIndex: setIndex,
                restAfterSeconds: item.restSecondsOverride ?? block.restSeconds,
              ),
            );
          }
        }
      }
    }

    // Nothing to rest for after the very last set.
    if (planned.isNotEmpty && planned.last.restAfterSeconds != 0) {
      final last = planned.removeLast();
      planned.add(
        PlannedSet(
          blockIndex: last.blockIndex,
          blockLabel: last.blockLabel,
          blockName: last.blockName,
          blockType: last.blockType,
          rounds: last.rounds,
          item: last.item,
          itemOrder: last.itemOrder,
          setIndex: last.setIndex,
          restAfterSeconds: 0,
          isCuttable: last.isCuttable,
        ),
      );
    }

    return planned;
  }

  static PlannedSet _make({
    required RoutineBlock block,
    required int blockIndex,
    required RoutineItem item,
    required int itemOrder,
    required int setIndex,
    required int restAfterSeconds,
  }) => PlannedSet(
    blockIndex: blockIndex,
    blockLabel: block.label,
    blockName: block.name,
    blockType: block.type,
    rounds: block.rounds,
    item: item,
    itemOrder: itemOrder,
    setIndex: setIndex,
    restAfterSeconds: restAfterSeconds,
    isCuttable: block.isCuttable,
  );

  /// Index of the first planned set with no matching log — where to resume
  /// after the app was closed mid-session.
  static int resumeIndex(List<PlannedSet> plan, List<SetLog> logs) {
    final done = logs
        .map((log) => '${log.routineItemId}:${log.setIndex}')
        .toSet();
    for (var i = 0; i < plan.length; i++) {
      if (!done.contains('${plan[i].item.id}:${plan[i].setIndex}')) return i;
    }
    return plan.length;
  }
}
