import 'package:drift/drift.dart';

import '../../../domain/entity/enums.dart';
import '../app_database.dart';

/// Fills an empty database with the reference program.
///
/// Source of truth: `docs/02-ROUTINE-SEED.md` (extracted from
/// `무분할-40분-루틴.html`). Keep both in sync when editing.
Future<void> seedIfEmpty(AppDatabase db) async {
  final existing = await (db.select(db.routines)..limit(1)).getSingleOrNull();
  if (existing != null) return;

  await db.transaction(() async {
    final exerciseIds = <String, int>{};
    for (final spec in _exercises) {
      exerciseIds[spec.name] = await db
          .into(db.exercises)
          .insert(
            ExercisesCompanion.insert(
              name: spec.name,
              bodyPart: spec.bodyPart.name,
              subTarget: Value(spec.subTarget),
              equipment: Value(spec.equipment),
            ),
          );
    }

    final routineId = await db
        .into(db.routines)
        .insert(
          RoutinesCompanion.insert(
            name: '무분할 40분',
            description: const Value(
              '우선순위 로테이션 무분할. 하체는 매 세션 고정 슬롯으로 들어가고, '
              '나머지는 그날의 메인 부위 하나에 볼륨을 몰아준다. 순번 A→B→C→D로 순환하며 요일에 묶지 않는다.',
            ),
            // 슈퍼세트를 빼면서 늘어난 값이다. 40분은 하체 머신과 상체 고립을
            // 겹쳐 돌려 휴식을 반으로 줄여서 나온 숫자였다. 한 기구씩 순서대로
            // 하면서 보조 블록 휴식을 60s(고반복 고립은 45s)로 조인 결과가 45분.
            sessionMinutes: const Value(45),
          ),
        );

    for (var dayIndex = 0; dayIndex < _days.length; dayIndex++) {
      final day = _days[dayIndex];
      final dayId = await db
          .into(db.routineDays)
          .insert(
            RoutineDaysCompanion.insert(
              routineId: routineId,
              sortOrder: dayIndex,
              code: day.code,
              title: day.title,
              subtitle: Value(day.subtitle),
              description: Value(day.description),
              primaryBodyPart: day.primaryBodyPart.name,
            ),
          );

      for (var blockIndex = 0; blockIndex < day.blocks.length; blockIndex++) {
        final block = day.blocks[blockIndex];
        final blockId = await db
            .into(db.routineBlocks)
            .insert(
              RoutineBlocksCompanion.insert(
                dayId: dayId,
                sortOrder: blockIndex,
                label: block.label,
                name: Value(block.name),
                // Every seeded block is straight. Supersets were dropped
                // because they need two machines at once — see
                // docs/02-ROUTINE-SEED.md §0-1. The block type still exists
                // for routines the user builds, so add the fields back here
                // if the seed ever needs one again.
                type: Value(BlockType.straight.name),
                rounds: const Value(1),
                restSeconds: block.restSeconds,
                targetMinutes: Value(block.targetMinutes),
                isCuttable: Value(block.isCuttable),
              ),
            );

        for (var itemIndex = 0; itemIndex < block.items.length; itemIndex++) {
          final item = block.items[itemIndex];
          final alternatives = item.alternatives
              .map((name) => exerciseIds[name])
              .whereType<int>()
              .join(',');

          await db
              .into(db.routineItems)
              .insert(
                RoutineItemsCompanion.insert(
                  blockId: blockId,
                  sortOrder: itemIndex,
                  exerciseId: exerciseIds[item.exerciseName]!,
                  sets: item.sets,
                  repMode: Value(item.repMode.name),
                  repMin: Value(item.repMin),
                  repMax: Value(item.repMax),
                  durationSeconds: Value(item.durationSeconds),
                  targetRir: Value(item.targetRir),
                  restSecondsOverride: Value(item.restSecondsOverride),
                  note: Value(item.note),
                  alternativeExerciseIds: Value(alternatives),
                ),
              );
        }
      }
    }
  });
}

// ── specs ─────────────────────────────────────────────────────────────────

class _ExerciseSpec {
  const _ExerciseSpec(
    this.name,
    this.bodyPart, {
    this.subTarget,
    this.equipment,
  });

  final String name;
  final BodyPart bodyPart;
  final String? subTarget;
  final String? equipment;
}

class _ItemSpec {
  const _ItemSpec(
    this.exerciseName, {
    required this.sets,
    this.repMode = RepMode.range,
    this.repMin,
    this.repMax,
    this.durationSeconds,
    this.targetRir,
    this.restSecondsOverride,
    this.note,
    this.alternatives = const [],
  });

  final String exerciseName;
  final int sets;

  /// Overrides the block's rest for this slot alone. Used where a high-rep
  /// isolation sits next to a machine movement that needs longer.
  final int? restSecondsOverride;
  final RepMode repMode;
  final int? repMin;
  final int? repMax;
  final int? durationSeconds;
  final int? targetRir;
  final String? note;
  final List<String> alternatives;
}

class _BlockSpec {
  const _BlockSpec({
    required this.label,
    required this.restSeconds,
    required this.items,
    this.name,
    this.targetMinutes,
    this.isCuttable = true,
  });

  final String label;
  final String? name;
  final int restSeconds;
  final int? targetMinutes;
  final bool isCuttable;
  final List<_ItemSpec> items;
}

class _DaySpec {
  const _DaySpec({
    required this.code,
    required this.title,
    required this.primaryBodyPart,
    required this.blocks,
    this.subtitle,
    this.description,
  });

  final String code;
  final String title;
  final String? subtitle;
  final String? description;
  final BodyPart primaryBodyPart;
  final List<_BlockSpec> blocks;
}

// ── exercise library ──────────────────────────────────────────────────────

const List<_ExerciseSpec> _exercises = [
  // 등
  _ExerciseSpec('풀업', BodyPart.back, subTarget: '수직 당기기', equipment: '맨몸'),
  _ExerciseSpec('렛풀다운', BodyPart.back, subTarget: '수직 당기기', equipment: '케이블'),
  _ExerciseSpec('티바로우', BodyPart.back, subTarget: '수평 당기기', equipment: '바벨'),
  _ExerciseSpec(
    '시티드 케이블 로우',
    BodyPart.back,
    subTarget: '수평 당기기',
    equipment: '케이블',
  ),
  _ExerciseSpec(
    '스트레이트암 풀다운',
    BodyPart.back,
    subTarget: '이두 개입 없음',
    equipment: '케이블',
  ),
  // 가슴
  _ExerciseSpec(
    '인클라인 벤치프레스 (스미스머신)',
    BodyPart.chest,
    subTarget: '상부',
    equipment: '스미스머신',
  ),
  _ExerciseSpec('인클라인 덤벨 프레스', BodyPart.chest, subTarget: '상부', equipment: '덤벨'),
  _ExerciseSpec(
    '인클라인 벤치프레스 머신',
    BodyPart.chest,
    subTarget: '상부',
    equipment: '머신',
  ),
  _ExerciseSpec(
    '케이블 크로스오버 (로우 → 하이)',
    BodyPart.chest,
    subTarget: '상부',
    equipment: '케이블',
  ),
  _ExerciseSpec('벡덱플라이', BodyPart.chest, subTarget: '고립', equipment: '머신'),
  _ExerciseSpec('딥스', BodyPart.chest, subTarget: '하부', equipment: '맨몸'),
  // 어깨
  _ExerciseSpec('사이드 레터럴 라이즈', BodyPart.shoulder, subTarget: '측면', equipment: '덤벨'),
  _ExerciseSpec(
    '케이블 사이드 레터럴',
    BodyPart.shoulder,
    subTarget: '측면',
    equipment: '케이블',
  ),
  _ExerciseSpec(
    '스탠딩 업라이트 로우',
    BodyPart.shoulder,
    subTarget: '측면',
    equipment: '스미스머신',
  ),
  _ExerciseSpec(
    '스미스머신 시티드 숄더프레스',
    BodyPart.shoulder,
    subTarget: '전면',
    equipment: '스미스머신',
  ),
  _ExerciseSpec('머신 숄더프레스', BodyPart.shoulder, subTarget: '전면', equipment: '머신'),
  _ExerciseSpec(
    '벤트오버 레터럴 레이즈',
    BodyPart.shoulder,
    subTarget: '후면',
    equipment: '덤벨',
  ),
  _ExerciseSpec('리버스 펙덱', BodyPart.shoulder, subTarget: '후면', equipment: '머신'),
  // 하체
  _ExerciseSpec('레그컬', BodyPart.legs, subTarget: '후면', equipment: '머신'),
  _ExerciseSpec('레그 익스텐션', BodyPart.legs, subTarget: '사두', equipment: '머신'),
  _ExerciseSpec('레그프레스', BodyPart.legs, subTarget: '사두/후면', equipment: '머신'),
  _ExerciseSpec('브이스쿼트 머신', BodyPart.legs, subTarget: '사두', equipment: '머신'),
  _ExerciseSpec('힙 어브덕션', BodyPart.legs, subTarget: '둔부', equipment: '머신'),
  _ExerciseSpec('힙 어덕션', BodyPart.legs, subTarget: '둔부', equipment: '머신'),
  // 팔
  _ExerciseSpec('케이블 해머컬', BodyPart.arms, subTarget: '이두/상완근', equipment: '케이블'),
  _ExerciseSpec('덤벨컬', BodyPart.arms, subTarget: '이두', equipment: '덤벨'),
  _ExerciseSpec('트라이셉스 푸시다운', BodyPart.arms, subTarget: '삼두', equipment: '케이블'),
  _ExerciseSpec('케이블 푸시다운', BodyPart.arms, subTarget: '삼두', equipment: '케이블'),
  // 복근
  _ExerciseSpec('복근', BodyPart.abs, subTarget: '자율'),
];

/// The abs slot: fixed 5-minute box, contents left to the user.
const _ItemSpec _absItem = _ItemSpec(
  '복근',
  sets: 1,
  repMode: RepMode.duration,
  durationSeconds: 300,
  note: '자율. 매일 다른 동작으로. 남은 시간이 3분이면 3분만 하고 끝낸다.',
);

const _BlockSpec _absBlock = _BlockSpec(
  label: '복근',
  name: '마감',
  restSeconds: 0,
  targetMinutes: 5,
  items: [_absItem],
);

// ── days ──────────────────────────────────────────────────────────────────

const List<_DaySpec> _days = [
  // ═══ DAY A ═══ 16 sets · 등 7
  _DaySpec(
    code: 'A',
    title: '등 + 이두',
    subtitle: '당기기 데이',
    description: '등에서 이미 예열된 이두와 후면삼각근을 뒤에 이어 붙인다. 시너지스트 원칙을 그대로 적용한 날.',
    primaryBodyPart: BodyPart.back,
    blocks: [
      _BlockSpec(
        label: 'B1',
        name: '메인 — 오늘의 약점',
        restSeconds: 120,
        targetMinutes: 13,
        isCuttable: false,
        items: [
          _ItemSpec(
            '풀업',
            sets: 4,
            repMode: RepMode.amrap,
            targetRir: 1,
            note: 'RIR 1 유지, 마지막 세트만 실패까지. 반복이 6회 밑으로 떨어지면 밴드 보조.',
          ),
        ],
      ),
      _BlockSpec(
        label: 'B2',
        name: '메인 보조',
        restSeconds: 90,
        targetMinutes: 9,
        items: [
          _ItemSpec(
            '티바로우',
            sets: 3,
            repMin: 8,
            repMax: 10,
            note: '상체 각도 45°, 광배 하부 조준. 허리로 튕기지 말 것 — 뒤에 하체가 남아 있다.',
            alternatives: ['시티드 케이블 로우'],
          ),
        ],
      ),
      _BlockSpec(
        label: 'B3',
        name: '하체 + 후면삼각',
        restSeconds: 60,
        targetMinutes: 12,
        items: [
          _ItemSpec(
            '레그컬',
            sets: 3,
            repMin: 10,
            repMax: 12,
            targetRir: 3,
            note: 'RIR 3. 하체 첫 진입일은 무게를 절대 올리지 않는다.',
            alternatives: ['레그프레스'],
          ),
          _ItemSpec(
            '벤트오버 레터럴 레이즈',
            sets: 3,
            repMin: 15,
            repMax: 20,
            restSecondsOverride: 45,
            note: '인클라인 벤치에 가슴만 기대고. 등 7세트 직후라 후면이 이미 예열된 상태 — '
                '가벼운 무게로 바로 유효 볼륨이 들어간다.',
            alternatives: ['리버스 펙덱'],
          ),
        ],
      ),
      _BlockSpec(
        label: 'B4',
        name: '이두 마감',
        restSeconds: 60,
        targetMinutes: 7,
        items: [
          _ItemSpec(
            '케이블 해머컬',
            sets: 2,
            repMin: 8,
            repMax: 10,
            note: '상완근이 더디므로 해머컬을 먼저 고중량으로 턴다. 등 7세트 뒤라 워밍업 세트가 필요 없다.',
          ),
          _ItemSpec('덤벨컬', sets: 1, repMin: 12, repMax: 15, note: '쥐어짜서 마무리.'),
        ],
      ),
      _absBlock,
    ],
  ),

  // ═══ DAY B ═══ 16 sets · 가슴 10
  _DaySpec(
    code: 'B',
    title: '가슴 상부 + 삼두',
    subtitle: '밀기 데이',
    description: '프리웨이트 인클라인이 무조건 첫 종목. 예열된 삼두를 뒤에 이어 붙이고, 전면삼각근은 따로 하지 않는다.',
    primaryBodyPart: BodyPart.chest,
    blocks: [
      _BlockSpec(
        label: 'B1',
        name: '메인 — 오늘의 약점',
        restSeconds: 120,
        targetMinutes: 13,
        isCuttable: false,
        items: [
          _ItemSpec(
            '인클라인 벤치프레스 (스미스머신)',
            sets: 4,
            repMin: 6,
            repMax: 10,
            note: '벤치 각도 30°. 45°는 어깨 앞쪽으로 부하가 새어나간다. 견갑 고정 후 명치 위쪽으로 바를 내린다.',
            alternatives: ['인클라인 벤치프레스 머신'],
          ),
        ],
      ),
      _BlockSpec(
        label: 'B2',
        name: '메인 보조',
        restSeconds: 90,
        targetMinutes: 9,
        items: [
          _ItemSpec(
            '인클라인 덤벨 프레스',
            sets: 3,
            repMin: 10,
            repMax: 12,
            note: '상부 근신경 개발이 목적이므로 무게보다 정지 1초 + 수축 자각. 팔꿈치를 몸통에서 45° 안쪽으로.',
          ),
        ],
      ),
      _BlockSpec(
        label: 'B3',
        name: '하체 + 가슴 상부',
        restSeconds: 60,
        targetMinutes: 12,
        items: [
          _ItemSpec(
            '레그 익스텐션',
            sets: 3,
            repMin: 12,
            repMax: 15,
            targetRir: 3,
            note: '사두. 지난 세션이 레그컬(후면)이었으니 여기는 전면.',
          ),
          _ItemSpec(
            '케이블 크로스오버 (로우 → 하이)',
            sets: 3,
            repMin: 12,
            repMax: 15,
            restSecondsOverride: 45,
            note: '풀리를 아래에 두고 위로 모은다. 상부 조준의 핵심. '
                '벡덱플라이로 대체할 땐 시트를 낮춰 손 위치를 어깨선 위로.',
            alternatives: ['벡덱플라이'],
          ),
        ],
      ),
      _BlockSpec(
        label: 'B4',
        name: '삼두 마감',
        restSeconds: 60,
        targetMinutes: 8,
        items: [
          _ItemSpec(
            '트라이셉스 푸시다운',
            sets: 2,
            repMin: 8,
            repMax: 10,
            note: '인클라인 프레스 7세트로 삼두는 이미 예열 완료. 고중량으로 턴다.',
          ),
          _ItemSpec('케이블 푸시다운', sets: 1, repMin: 15, repMax: 20, note: '저중량으로 마무리.'),
        ],
      ),
      _absBlock,
    ],
  ),

  // ═══ DAY C ═══ 19 sets · 어깨 13
  _DaySpec(
    code: 'C',
    title: '어깨',
    subtitle: '측면 최우선',
    description: '주간 최대 볼륨을 받는 날. 측면이 첫 종목이고 프레스는 그다음이다 — 순서가 이 세션의 전부다.',
    primaryBodyPart: BodyPart.shoulder,
    blocks: [
      _BlockSpec(
        label: 'B1',
        name: '메인 — 오늘의 약점',
        // Isolation main: the template's 120s exception.
        restSeconds: 75,
        targetMinutes: 11,
        isCuttable: false,
        items: [
          _ItemSpec(
            '사이드 레터럴 라이즈',
            sets: 4,
            repMin: 10,
            repMax: 15,
            note: '세션에서 가장 신선한 자리를 최대 약점에 준다. 프레스보다 앞이다. '
                '새끼손가락을 살짝 위로, 어깨선 이상 올리지 않는다. 격주로 케이블 사이드 레터럴과 교대.',
            alternatives: ['케이블 사이드 레터럴'],
          ),
        ],
      ),
      _BlockSpec(
        label: 'B2',
        name: '메인 보조',
        restSeconds: 90,
        targetMinutes: 9,
        items: [
          _ItemSpec(
            '스미스머신 시티드 숄더프레스',
            sets: 3,
            repMin: 8,
            repMax: 12,
            note: '전면은 인클라인 11세트에서 이미 대량으로 받는다 — 여기선 3세트면 충분하고, '
                '더 넣으면 측면 몫을 뺏는다. 2주마다 머신 숄더프레스와 교대.',
            alternatives: ['머신 숄더프레스'],
          ),
        ],
      ),
      _BlockSpec(
        label: 'B3',
        name: '하체 + 등',
        restSeconds: 60,
        targetMinutes: 13,
        items: [
          _ItemSpec(
            '레그프레스',
            sets: 3,
            repMin: 12,
            repMax: 15,
            targetRir: 3,
            note: '발 위치를 격주로 바꾼다 — 낮게(사두) / 높게(햄·둔근).',
          ),
          _ItemSpec(
            '시티드 케이블 로우',
            sets: 3,
            repMin: 10,
            repMax: 12,
            note: '등 주 3회 중 두 번째. 렛풀다운을 또 넣지 않는 이유는 DAY A 풀업이 이미 수직 당기기라서다 '
                '— 여긴 수평으로 채운다.',
          ),
        ],
      ),
      _BlockSpec(
        label: 'B4',
        name: '어깨 마감',
        restSeconds: 60,
        targetMinutes: 12,
        items: [
          _ItemSpec(
            '스탠딩 업라이트 로우',
            sets: 3,
            repMin: 10,
            repMax: 12,
            note: '측면 두 번째 각도. 그립을 어깨너비보다 넓게 잡아야 승모가 아니라 측면으로 간다.',
          ),
          _ItemSpec(
            '리버스 펙덱',
            sets: 3,
            repMin: 15,
            repMax: 20,
            restSecondsOverride: 45,
            note: '후면 주 2회 중 신선한 쪽. 벤트오버 레터럴과 4주마다 교대.',
            alternatives: ['벤트오버 레터럴 레이즈'],
          ),
        ],
      ),
      _absBlock,
    ],
  ),

  // ═══ DAY D ═══ 19 sets · 등 6
  _DaySpec(
    code: 'D',
    title: '가슴 상부 2차 + 등',
    description: '약점인 가슴 상부를 주 2회 메인으로. 등은 이날 6세트로 채워 가슴과 나란히 맞춘다.',
    primaryBodyPart: BodyPart.chest,
    blocks: [
      _BlockSpec(
        label: 'B1',
        name: '메인 — 오늘의 약점',
        restSeconds: 120,
        targetMinutes: 13,
        isCuttable: false,
        items: [
          _ItemSpec(
            '인클라인 벤치프레스 머신',
            sets: 4,
            repMin: 8,
            repMax: 12,
            note: 'DAY B가 프리웨이트였으니 여기는 고정 궤적으로. 안정성이 확보된 상태에서 상부 수축 자각에만 집중한다.',
          ),
        ],
      ),
      _BlockSpec(
        label: 'B2',
        name: '메인 보조',
        restSeconds: 90,
        targetMinutes: 8,
        items: [
          _ItemSpec(
            '딥스',
            sets: 3,
            repMode: RepMode.amrap,
            note: '인클라인만 6개월 하면 하부·전거근이 비어간다. 주 1회 딥스로 균형을 맞춘다. '
                '상체를 앞으로 기울여 가슴 버전으로.',
          ),
        ],
      ),
      _BlockSpec(
        label: 'B3',
        name: '하체 + 등',
        restSeconds: 60,
        targetMinutes: 13,
        items: [
          _ItemSpec(
            '브이스쿼트 머신',
            sets: 3,
            repMin: 10,
            repMax: 12,
            targetRir: 3,
            note: '주중 마지막 하체. 이날은 가동범위를 가장 깊게 가져간다.',
            alternatives: ['레그프레스'],
          ),
          _ItemSpec('렛풀다운', sets: 3, repMin: 10, repMax: 12, note: '등 유지 볼륨.'),
        ],
      ),
      _BlockSpec(
        label: 'B4',
        name: '마감',
        restSeconds: 60,
        targetMinutes: 12,
        items: [
          _ItemSpec(
            '스트레이트암 풀다운',
            sets: 3,
            repMin: 12,
            repMax: 15,
            restSecondsOverride: 45,
            note: '이두가 개입하지 않는 유일한 등 종목. DAY A에서 이두를 이미 털었으니, '
                '주 마지막 등 볼륨은 팔꿈치를 고정한 채 광배만 쓰는 쪽으로 채운다.',
          ),
          _ItemSpec(
            '케이블 사이드 레터럴',
            sets: 3,
            repMin: 12,
            repMax: 15,
            restSecondsOverride: 45,
            note: '측면 주 10세트의 마지막 3세트. DAY C와 겹치지 않게 덤벨↔케이블로 바꿔 잡는다.',
            alternatives: ['사이드 레터럴 라이즈'],
          ),
        ],
      ),
      _absBlock,
    ],
  ),
];
