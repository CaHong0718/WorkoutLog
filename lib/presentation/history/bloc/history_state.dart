import '../../../core/error/failure.dart';
import '../../../core/extensions/date_time_x.dart';
import '../../../core/mvi/mvi_state.dart';
import '../../../domain/entity/enums.dart';
import '../../../domain/entity/workout_session.dart';

/// Calendar tab state: one month of markers plus the all-time summary.
class HistoryState extends MviState {
  const HistoryState({
    required this.month,
    this.isLoading = true,
    this.hasLoaded = false,
    this.isMonthLoading = false,
    this.isDayLoading = false,
    this.failure,
    this.workoutDates = const <DateTime>{},
    this.dayBodyParts = const <DateTime, BodyPart>{},
    this.selectedDate,
    this.selectedSessions = const [],
    this.totalSessions = 0,
    this.weeklyVolume = const {},
    this.streakWeeks = 0,
  });

  factory HistoryState.initial() =>
      HistoryState(month: DateTime.now().startOfMonth);

  final bool isLoading;

  /// True once the first load finished — separates "empty" from "not yet".
  final bool hasLoaded;

  /// True while another month is being fetched — keeps the grid on screen.
  final bool isMonthLoading;

  /// True while the tapped day's sessions are being fetched.
  final bool isDayLoading;

  final Failure? failure;

  /// First day of the month currently drawn by the calendar.
  final DateTime month;

  /// Days of [month] with at least one **completed** session.
  final Set<DateTime> workoutDates;

  /// Dominant body part of each marked day — drives the marker color.
  final Map<DateTime, BodyPart> dayBodyParts;

  final DateTime? selectedDate;

  /// Every session recorded on [selectedDate], aborted ones included.
  final List<WorkoutSession> selectedSessions;

  /// All-time completed session count.
  final int totalSessions;

  /// Completed sets per body part in the current week.
  final Map<BodyPart, int> weeklyVolume;

  /// Consecutive weeks, counting back from now, with at least one session.
  final int streakWeeks;

  int get monthWorkoutCount => workoutDates.length;

  int get weekSets => weeklyVolume.values.fold(0, (sum, v) => sum + v);

  bool get hasSelection => selectedDate != null;

  HistoryState copyWith({
    bool? isLoading,
    bool? hasLoaded,
    bool? isMonthLoading,
    bool? isDayLoading,
    Failure? failure,
    DateTime? month,
    Set<DateTime>? workoutDates,
    Map<DateTime, BodyPart>? dayBodyParts,
    DateTime? selectedDate,
    List<WorkoutSession>? selectedSessions,
    int? totalSessions,
    Map<BodyPart, int>? weeklyVolume,
    int? streakWeeks,
    bool clearFailure = false,
    bool clearSelection = false,
  }) {
    return HistoryState(
      isLoading: isLoading ?? this.isLoading,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      isMonthLoading: isMonthLoading ?? this.isMonthLoading,
      isDayLoading: isDayLoading ?? this.isDayLoading,
      failure: clearFailure ? null : (failure ?? this.failure),
      month: month ?? this.month,
      workoutDates: workoutDates ?? this.workoutDates,
      dayBodyParts: dayBodyParts ?? this.dayBodyParts,
      selectedDate: clearSelection
          ? null
          : (selectedDate ?? this.selectedDate),
      selectedSessions: clearSelection
          ? const []
          : (selectedSessions ?? this.selectedSessions),
      totalSessions: totalSessions ?? this.totalSessions,
      weeklyVolume: weeklyVolume ?? this.weeklyVolume,
      streakWeeks: streakWeeks ?? this.streakWeeks,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    hasLoaded,
    isMonthLoading,
    isDayLoading,
    failure,
    month,
    workoutDates,
    dayBodyParts,
    selectedDate,
    selectedSessions,
    totalSessions,
    weeklyVolume,
    streakWeeks,
  ];
}
