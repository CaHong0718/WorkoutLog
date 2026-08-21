import '../../../core/error/failure.dart';
import '../../../core/mvi/mvi_state.dart';
import '../../../domain/entity/backup_package.dart';

class BackupState extends MviState {
  const BackupState({
    this.isLoading = true,
    this.isBusy = false,
    this.failure,
    this.summary = const BackupSummary(),
  });

  final bool isLoading;

  /// True while a write or a platform dialog is in flight — the buttons
  /// disable so a double tap cannot restore the same file twice.
  final bool isBusy;

  final Failure? failure;

  /// What this phone holds right now.
  final BackupSummary summary;

  /// Nothing worth putting in a file yet.
  bool get isEmpty => !summary.hasSessions && summary.setCount == 0;

  BackupState copyWith({
    bool? isLoading,
    bool? isBusy,
    Failure? failure,
    BackupSummary? summary,
    bool clearFailure = false,
  }) {
    return BackupState(
      isLoading: isLoading ?? this.isLoading,
      isBusy: isBusy ?? this.isBusy,
      failure: clearFailure ? null : (failure ?? this.failure),
      summary: summary ?? this.summary,
    );
  }

  @override
  List<Object?> get props => [isLoading, isBusy, failure, summary];
}
