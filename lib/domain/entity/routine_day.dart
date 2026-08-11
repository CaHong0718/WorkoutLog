import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'routine_block.dart';

/// One position in the A → B → C → D rotation.
///
/// Deliberately not tied to a weekday: the reference program rotates by
/// sequence so a missed session shifts everything by one instead of zeroing
/// out a body part.
class RoutineDay extends Equatable {
  const RoutineDay({
    required this.id,
    required this.routineId,
    required this.order,
    required this.code,
    required this.title,
    required this.primaryBodyPart,
    this.subtitle,
    this.description,
    this.blocks = const [],
  });

  static const int unsavedId = 0;

  final int id;
  final int routineId;

  /// 0-based rotation position.
  final int order;

  /// `A`, `B`, `C`, `D`
  final String code;

  /// `등 + 이두`
  final String title;

  /// `당기기 데이`
  final String? subtitle;

  /// Design rationale shown on the day card.
  final String? description;

  final BodyPart primaryBodyPart;

  final List<RoutineBlock> blocks;

  /// `등 + 이두 — 당기기 데이`
  String get fullTitle => subtitle == null ? title : '$title — $subtitle';

  int get totalSets => blocks.fold(0, (sum, b) => sum + b.totalSets);

  int get estimatedMinutes =>
      blocks.fold(0, (sum, b) => sum + (b.targetMinutes ?? 0));

  Map<BodyPart, int> get volumeByBodyPart {
    final result = <BodyPart, int>{};
    for (final block in blocks) {
      block.volumeByBodyPart.forEach((part, sets) {
        result.update(part, (v) => v + sets, ifAbsent: () => sets);
      });
    }
    return result;
  }

  RoutineDay copyWith({
    int? id,
    int? routineId,
    int? order,
    String? code,
    String? title,
    String? subtitle,
    String? description,
    BodyPart? primaryBodyPart,
    List<RoutineBlock>? blocks,
    bool clearSubtitle = false,
    bool clearDescription = false,
  }) {
    return RoutineDay(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      order: order ?? this.order,
      code: code ?? this.code,
      title: title ?? this.title,
      subtitle: clearSubtitle ? null : (subtitle ?? this.subtitle),
      description: clearDescription ? null : (description ?? this.description),
      primaryBodyPart: primaryBodyPart ?? this.primaryBodyPart,
      blocks: blocks ?? this.blocks,
    );
  }

  @override
  List<Object?> get props => [
    id,
    routineId,
    order,
    code,
    title,
    subtitle,
    description,
    primaryBodyPart,
    blocks,
  ];
}
