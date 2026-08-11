import 'package:equatable/equatable.dart';

/// A user intention entering the bloc. Named in imperative form
/// (`LoadTodayRoutine`, `CompleteSet`).
abstract class MviIntent extends Equatable {
  const MviIntent();

  @override
  List<Object?> get props => const [];
}
