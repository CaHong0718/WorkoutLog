/// Muscle group a movement is credited to. Drives weekly volume aggregation
/// and the identity color of every card.
enum BodyPart {
  back('등'),
  chest('가슴'),
  shoulder('어깨'),
  legs('하체'),
  arms('팔'),
  abs('복근');

  const BodyPart(this.label);

  final String label;

  static BodyPart fromName(String name) =>
      values.firstWhere((e) => e.name == name, orElse: () => BodyPart.abs);
}

/// How the exercises inside a block are executed.
enum BlockType {
  /// One exercise at a time, set after set.
  straight('일반'),

  /// Exercises are cycled as a round and the round repeats.
  superset('슈퍼세트');

  const BlockType(this.label);

  final String label;

  static BlockType fromName(String name) =>
      values.firstWhere((e) => e.name == name, orElse: () => BlockType.straight);
}

/// How a set's target is expressed.
enum RepMode {
  /// A rep window, e.g. 8–10.
  range,

  /// As many reps as possible.
  amrap,

  /// Time based, e.g. the 5-minute abs slot.
  duration;

  static RepMode fromName(String name) =>
      values.firstWhere((e) => e.name == name, orElse: () => RepMode.range);
}

enum SessionStatus {
  inProgress('진행 중'),
  completed('완료'),
  aborted('중단');

  const SessionStatus(this.label);

  final String label;

  static SessionStatus fromName(String name) => values.firstWhere(
    (e) => e.name == name,
    orElse: () => SessionStatus.inProgress,
  );
}
