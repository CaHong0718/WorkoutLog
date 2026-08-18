/// All user-facing Korean text lives here.
abstract final class AppStrings {
  /// App name. The routine inside it is still called `무분할 40분` — that is a
  /// routine, stored in the database, not the product.
  static const appName = 'Workout Log';

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

  // Leaving / resuming a session
  static const sessionInProgress = '진행 중인 운동이 있습니다';
  static const keepSession = '나중에 이어서 하기';
  static const keepSessionHint = '기록을 그대로 두고 나갑니다. 홈 맨 위 배너에서 다시 들어올 수 있어요.';
  static const continueSession = '계속 운동하기';
  static const leaveSessionTitle = '운동을 멈추고 나갈까요?';
  static const startNewSession = '새로 시작하기';
  static const resumeSessionHint = '하던 세트부터 이어서 진행합니다.';

  // Session
  static const rest = '휴식';
  static const restDone = '휴식 완료';
  static const addFifteen = '+15초';
  static const skipRest = '휴식 건너뛰기';
  static const weight = '무게';
  static const bodyweight = '맨몸';
  static const reps = '반복';
  static const rir = 'RIR';
  static const setUnit = '세트';
  static const round = '라운드';
  static const superset = '슈퍼세트';
  static const finishSession = '운동 종료';
  static const abortSession = '운동 중단';
  static const switchExercise = '대체 종목으로 변경';
  static const lastRecord = '지난 기록';
  static const relogBadge = '수정 중';
  static const saveSetEdit = '수정 저장';
  static const setUpdated = '세트를 수정했습니다.';
  static const setLogDeleted = '세트를 지웠습니다.';

  // Routine library
  static const routineList = '내 루틴';
  static const activeRoutine = '사용 중';
  static const switchRoutine = '루틴 전환';
  static const newRoutine = '새 루틴';
  static const routineInfo = '루틴 정보';
  static const routineNameField = '루틴 이름';
  static const routineDescriptionField = '설명';
  static const sessionMinutesField = '1회 목표 시간(분)';
  static const activateRoutine = '이 루틴 사용';
  static const duplicateRoutine = '복제';
  static const exportRoutine = '내보내기';
  static const importRoutine = '가져오기';
  static const importFromFile = '파일에서 가져오기';
  static const routineActivated = '루틴을 전환했습니다.';
  static const routineDeleted = '루틴을 삭제했습니다.';
  static const routineDuplicated = '루틴을 복제했습니다.';
  static const routineExported = '루틴 파일을 만들었습니다.';
  static const deleteRoutineConfirm =
      '루틴과 그 안의 DAY·블록·종목이 모두 사라집니다. 이미 기록한 운동은 그대로 남습니다.';
  static const noRoutineFilePicked = '파일을 읽지 못했습니다.';
  static const exportFailed = '내보내기를 마치지 못했습니다.';
  static const routineListHint = '사용 중인 루틴 하나가 홈과 운동 화면에 나옵니다. 나머지는 그대로 보관됩니다.';

  // Routine import
  static const importPreview = '가져올 루틴';
  static const importConfirm = '이 루틴 추가';
  static const importAndActivate = '추가하고 바로 사용';
  static const importErrorTitle = '루틴 파일을 읽을 수 없습니다';
  static const importWarningTitle = '확인해 주세요';
  static const importErrorHint = '아래 위치를 고쳐서 다시 시도하세요.';
  static const importedExercises = '종목';
  static const importReuseSuffix = '개 재사용';
  static const importCreateSuffix = '개 새로 추가';

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

  // Routine editing — day list
  static const dayEditTitle = 'DAY 편집';
  static const dayInfo = 'DAY 정보';
  static const dayCode = 'DAY 코드';
  static const dayTitleField = '제목';
  static const daySubtitle = '부제';
  static const dayDescription = '설명';
  static const primaryBodyPart = '메인 부위';
  static const weeklySets = '주간 세트';
  static const dayCount = 'DAY 수';
  static const noDays = 'DAY가 없습니다. DAY를 추가하세요.';
  static const reorderHint = '손잡이를 끌어 순서를 바꿉니다';
  static const deleteDayConfirm =
      'DAY를 삭제하면 블록과 종목도 함께 사라집니다. 이미 기록한 운동은 그대로 남습니다.';

  // Routine editing — blocks
  static const blockLabel = '블록 라벨';
  static const blockName = '블록 이름';
  static const blockTypeField = '블록 타입';
  static const blockOrder = '블록 순서';
  static const roundCount = '라운드 수';
  static const cuttable = '시간 부족 시 컷 가능';
  static const noBlocks = '블록이 없습니다. 블록을 추가하세요.';
  static const noItems = '종목이 없습니다';
  static const deleteBlockConfirm = '블록을 삭제하면 안에 있는 종목도 함께 사라집니다.';
  static const deleteItemConfirm = '이 종목을 블록에서 뺄까요?';

  // Routine editing — items
  static const setCount = '세트 수';
  static const repModeField = '목표 방식';
  static const repModeRange = '반복 구간';
  static const repModeAmrap = '가능한 만큼';
  static const repModeDuration = '시간';
  static const repMinField = '최소 반복';
  static const repMaxField = '최대 반복';
  static const durationMinutes = '수행 시간(분)';
  static const useBlockRest = '블록 휴식 사용';
  static const targetRir = '목표 RIR';
  static const noteField = '메모';
  static const addAlternative = '대체 종목 추가';
  static const noAlternatives = '지정된 대체 종목이 없습니다';

  // Exercise library
  static const selectExercise = '종목 선택';
  static const searchExercise = '종목 검색';
  static const allBodyParts = '전체';
  static const newExercise = '새 종목';
  static const editExercise = '종목 편집';
  static const exerciseNameField = '종목 이름';
  static const bodyPartField = '부위';
  static const subTargetField = '세부 타깃';
  static const equipmentField = '기구';
  static const customBadge = '커스텀';
  static const deleteExerciseConfirm = '종목을 삭제할까요? 루틴에서 사용 중이면 삭제할 수 없습니다.';
  static const noExercises = '조건에 맞는 종목이 없습니다';
  static const supersetRoundsHint = '슈퍼세트로 바꾸면 블록 안 종목의 세트 수가 라운드 수에 맞춰집니다.';

  // History
  static const history = '운동 기록';
  static const sessionDetail = '세션 상세';
  static const deleteRecord = '기록 삭제';
  static const deleteRecordConfirm =
      '이 운동 기록을 삭제합니다. 기록된 세트가 모두 지워지고 되돌릴 수 없습니다.';
  static const recordDeleted = '운동 기록을 삭제했습니다.';
  static const progressChart = '무게 추이';
  static const noRecordThisDay = '이 날은 운동 기록이 없습니다';

  // History — tabs
  static const tabCalendar = '달력';
  static const tabVolume = '볼륨';
  static const tabTrend = '추이';

  // History — summary
  static const totalSessionCount = '총 세션';
  static const weekSetCount = '이번 주 세트';
  static const streakWeeks = '연속 주';
  static const monthWorkoutCount = '이번 달 운동';
  static const sessionUnit = '회';
  static const weekUnit = '주';
  static const noSessionsYet = '아직 운동 기록이 없습니다';
  static const pickDateHint = '날짜를 누르면 그날의 기록이 보입니다';

  // History — session detail
  static const workoutDuration = '소요 시간';
  static const completedSetCount = '완료 세트';
  static const totalVolume = '총 볼륨';
  static const sessionMemo = '메모';
  static const skippedSet = '건너뜀';
  static const editSet = '세트 수정';
  static const deleteSet = '세트 삭제';
  static const deleteSetConfirm = '이 세트 기록을 지웁니다. 되돌릴 수 없습니다.';
  static const countThisSet = '완료한 세트로 기록';
  static const countThisSetHint = '끄면 건너뛴 세트로 남아 볼륨에 잡히지 않습니다.';
  static const durationField = '시간';
  static const setEditHint = '세트를 누르면 무게와 반복을 고칠 수 있습니다.';
  static const actualRest = '휴식';
  static const noSetLogs = '기록된 세트가 없습니다';

  // History — weekly volume
  static const weeklyTarget = '주간 목표';
  static const thisWeek = '이번 주';
  static const volumeShare = '부위별 분포';
  static const noWeekVolume = '이 주에는 완료한 세트가 없습니다';

  // History — trend
  static const selectTrendExercise = '종목 선택';
  static const changeExercise = '종목 변경';
  static const topWeight = '최고 중량';
  static const estimated1RM = '추정 1RM';
  static const trendNeedsMoreData = '기록이 2회 이상 쌓이면 추이가 그려집니다';
  static const noTrendExercise = '무게를 기록한 종목이 아직 없습니다';
  static const latestRecord = '최근 기록';

  // Rules surfaced in the UI (from the reference document)
  static const cutRuleHint = '시간이 부족하면 뒤 블록부터 자릅니다. B1은 자르지 않습니다.';
  static const progressionHint =
      '목표 반복 상단을 모든 세트에서 채우면 다음 세션에 무게를 2.5~5% 올리세요.';
  static const rirHint = 'RIR은 세트를 멈춘 뒤 더 할 수 있었던 반복 수입니다. 2면 2회 여유, 0은 실패 직전.';
}
