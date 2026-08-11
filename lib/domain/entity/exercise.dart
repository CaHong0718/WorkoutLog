import 'package:equatable/equatable.dart';

import 'enums.dart';

/// A movement in the exercise library.
///
/// Seeded from the reference routine; the user may add their own with
/// [isCustom] set.
class Exercise extends Equatable {
  const Exercise({
    required this.id,
    required this.name,
    required this.bodyPart,
    this.subTarget,
    this.equipment,
    this.isCustom = false,
    this.createdAt,
  });

  /// Placeholder id for a not-yet-persisted exercise.
  static const int unsavedId = 0;

  final int id;
  final String name;
  final BodyPart bodyPart;

  /// Finer target inside the body part: `측면`, `상부`, `사두` …
  final String? subTarget;

  /// `스미스머신`, `케이블`, `덤벨` …
  final String? equipment;

  final bool isCustom;
  final DateTime? createdAt;

  /// `사이드 레터럴 라이즈 · 측면` for list rows.
  String get displayName =>
      subTarget == null ? name : '$name · $subTarget';

  Exercise copyWith({
    int? id,
    String? name,
    BodyPart? bodyPart,
    String? subTarget,
    String? equipment,
    bool? isCustom,
    DateTime? createdAt,
    bool clearSubTarget = false,
    bool clearEquipment = false,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      bodyPart: bodyPart ?? this.bodyPart,
      subTarget: clearSubTarget ? null : (subTarget ?? this.subTarget),
      equipment: clearEquipment ? null : (equipment ?? this.equipment),
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    bodyPart,
    subTarget,
    equipment,
    isCustom,
  ];
}
