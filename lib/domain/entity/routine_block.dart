import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'routine_item.dart';

/// A time-boxed segment of a session: B1 main, B2 secondary, B3 superset …
class RoutineBlock extends Equatable {
  const RoutineBlock({
    required this.id,
    required this.dayId,
    required this.order,
    required this.label,
    required this.restSeconds,
    this.name,
    this.type = BlockType.straight,
    this.rounds = 1,
    this.targetMinutes,
    this.isCuttable = true,
    this.items = const [],
  });

  static const int unsavedId = 0;

  final int id;
  final int dayId;

  /// 0-based position inside the day.
  final int order;

  /// `B1`, `B2`, `복근`
  final String label;

  /// `메인 — 오늘의 약점`, `이두 마감`
  final String? name;

  final BlockType type;

  /// Rounds for a superset; 1 for a straight block.
  final int rounds;

  /// Rest between sets (straight) or between rounds (superset).
  final int restSeconds;

  final int? targetMinutes;

  /// Whether the cut rule may drop this block when time runs short.
  /// The day's main block (B1) is never cuttable.
  final bool isCuttable;

  final List<RoutineItem> items;

  bool get isSuperset => type == BlockType.superset;

  /// Total working sets contributed by this block.
  int get totalSets => items.fold(0, (sum, item) => sum + item.volumeSets);

  Map<BodyPart, int> get volumeByBodyPart {
    final result = <BodyPart, int>{};
    for (final item in items) {
      if (item.volumeSets == 0) continue;
      result.update(
        item.bodyPart,
        (v) => v + item.volumeSets,
        ifAbsent: () => item.volumeSets,
      );
    }
    return result;
  }

  RoutineBlock copyWith({
    int? id,
    int? dayId,
    int? order,
    String? label,
    String? name,
    BlockType? type,
    int? rounds,
    int? restSeconds,
    int? targetMinutes,
    bool? isCuttable,
    List<RoutineItem>? items,
    bool clearName = false,
    bool clearTargetMinutes = false,
  }) {
    return RoutineBlock(
      id: id ?? this.id,
      dayId: dayId ?? this.dayId,
      order: order ?? this.order,
      label: label ?? this.label,
      name: clearName ? null : (name ?? this.name),
      type: type ?? this.type,
      rounds: rounds ?? this.rounds,
      restSeconds: restSeconds ?? this.restSeconds,
      targetMinutes: clearTargetMinutes
          ? null
          : (targetMinutes ?? this.targetMinutes),
      isCuttable: isCuttable ?? this.isCuttable,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [
    id,
    dayId,
    order,
    label,
    name,
    type,
    rounds,
    restSeconds,
    targetMinutes,
    isCuttable,
    items,
  ];
}
