/// All user-facing Korean text lives here.
abstract final class AppStrings {
  static const appName = '무분할 40분';

  // Navigation
  static const navHome = '오늘';
  static const navHistory = '기록';
  static const navRoutine = '루틴';

  // Common
  static const start = '시작';
  static const cancel = '취소';
  static const confirm = '확인';
  static const save = '저장';
  static const delete = '삭제';
  static const edit = '편집';
  static const add = '추가';
  static const close = '닫기';
  static const skip = '건너뛰기';
  static const retry = '다시 시도';
  static const loading = '불러오는 중';
  static const emptyDefault = '아직 내용이 없습니다';

  // Home
  static const todayRoutine = '오늘의 루틴';
  static const startSession = '운동 시작';
  static const resumeSession = '이어서 하기';
  static const changeDay = 'DAY 변경';
  static const weeklyVolume = '이번 주 볼륨';
  static const totalSets = '총 세트';
  static const estimatedTime = '예상 시간';

  // Session
  static const sessionInProgress = '진행 중인 운동이 있습니다';
  static const rest = '휴식';
  static const restDone = '휴식 완료';
  static const addFifteen = '+15초';
  static const skipRest = '휴식 건너뛰기';
  static const weight = '무게';
  static const reps = '반복';
  static const rir = 'RIR';
  static const setUnit = '세트';
  static const round = '라운드';
  static const superset = '슈퍼세트';
  static const finishSession = '운동 종료';
  static const abortSession = '운동 중단';
  static const switchExercise = '대체 종목으로 변경';
  static const lastRecord = '지난 기록';

  // Routine editing
  static const routineEdit = '루틴 편집';
  static const addDay = 'DAY 추가';
  static const addBlock = '블록 추가';
  static const addExercise = '종목 추가';
  static const exerciseLibrary = '종목 목록';
  static const restSeconds = '휴식 시간(초)';
  static const targetMinutes = '목표 시간(분)';
  static const repRange = '반복 구간';
  static const alternatives = '대체 종목';

  // History
  static const history = '운동 기록';
  static const sessionDetail = '세션 상세';
  static const progressChart = '무게 추이';
  static const noRecordThisDay = '이 날은 운동 기록이 없습니다';

  // Rules surfaced in the UI (from the reference document)
  static const cutRuleHint = '시간이 부족하면 뒤 블록부터 자릅니다. B1은 자르지 않습니다.';
  static const progressionHint = '목표 반복 상단을 모든 세트에서 채우면 다음 세션에 무게를 2.5~5% 올리세요.';
  static const legsFirstWeeksHint = '하체는 첫 3주 동안 RIR 2~3으로 유지합니다.';
}
