import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'routine_day.dart';

/// A training program. Exactly one routine is [isActive] at a time.
class Routine extends Equatable {
  const Routine({
    required this.id,
    required this.name,
    required this.sessionMinutes,
    this.description,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.days = const [],
  });

  static const int unsavedId = 0;

  final int id;
  final String name;
  final String? description;

  /// Target length of one session, excluding the abs slot.
  final int sessionMinutes;

  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final List<RoutineDay> days;

  int get dayCount => days.length;

  /// Sets accumulated over one full rotation of every day.
  int get weeklySets => days.fold(0, (sum, d) => sum + d.totalSets);

  Map<BodyPart, int> get weeklyVolumeByBodyPart {
    final result = <BodyPart, int>{};
    for (final day in days) {
      day.volumeByBodyPart.forEach((part, sets) {
        result.update(part, (v) => v + sets, ifAbsent: () => sets);
      });
    }
    return result;
  }

  Routine copyWith({
    int? id,
    String? name,
    String? description,
    int? sessionMinutes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<RoutineDay>? days,
    bool clearDescription = false,
  }) {
    return Routine(
      id: id ?? this.id,
      name: name ?? this.name,
      description: clearDescription ? null : (description ?? this.description),
      sessionMinutes: sessionMinutes ?? this.sessionMinutes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      days: days ?? this.days,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    sessionMinutes,
    isActive,
    days,
  ];
}
