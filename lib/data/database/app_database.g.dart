// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ExercisesTable extends Exercises
    with TableInfo<$ExercisesTable, ExerciseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyPartMeta = const VerificationMeta(
    'bodyPart',
  );
  @override
  late final GeneratedColumn<String> bodyPart = GeneratedColumn<String>(
    'body_part',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subTargetMeta = const VerificationMeta(
    'subTarget',
  );
  @override
  late final GeneratedColumn<String> subTarget = GeneratedColumn<String>(
    'sub_target',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _equipmentMeta = const VerificationMeta(
    'equipment',
  );
  @override
  late final GeneratedColumn<String> equipment = GeneratedColumn<String>(
    'equipment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCustomMeta = const VerificationMeta(
    'isCustom',
  );
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    bodyPart,
    subTarget,
    equipment,
    isCustom,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('body_part')) {
      context.handle(
        _bodyPartMeta,
        bodyPart.isAcceptableOrUnknown(data['body_part']!, _bodyPartMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyPartMeta);
    }
    if (data.containsKey('sub_target')) {
      context.handle(
        _subTargetMeta,
        subTarget.isAcceptableOrUnknown(data['sub_target']!, _subTargetMeta),
      );
    }
    if (data.containsKey('equipment')) {
      context.handle(
        _equipmentMeta,
        equipment.isAcceptableOrUnknown(data['equipment']!, _equipmentMeta),
      );
    }
    if (data.containsKey('is_custom')) {
      context.handle(
        _isCustomMeta,
        isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      bodyPart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_part'],
      )!,
      subTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sub_target'],
      ),
      equipment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment'],
      ),
      isCustom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }
}

class ExerciseRow extends DataClass implements Insertable<ExerciseRow> {
  final int id;
  final String name;

  /// [BodyPart.name]
  final String bodyPart;
  final String? subTarget;
  final String? equipment;
  final bool isCustom;
  final DateTime createdAt;
  const ExerciseRow({
    required this.id,
    required this.name,
    required this.bodyPart,
    this.subTarget,
    this.equipment,
    required this.isCustom,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['body_part'] = Variable<String>(bodyPart);
    if (!nullToAbsent || subTarget != null) {
      map['sub_target'] = Variable<String>(subTarget);
    }
    if (!nullToAbsent || equipment != null) {
      map['equipment'] = Variable<String>(equipment);
    }
    map['is_custom'] = Variable<bool>(isCustom);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      name: Value(name),
      bodyPart: Value(bodyPart),
      subTarget: subTarget == null && nullToAbsent
          ? const Value.absent()
          : Value(subTarget),
      equipment: equipment == null && nullToAbsent
          ? const Value.absent()
          : Value(equipment),
      isCustom: Value(isCustom),
      createdAt: Value(createdAt),
    );
  }

  factory ExerciseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      bodyPart: serializer.fromJson<String>(json['bodyPart']),
      subTarget: serializer.fromJson<String?>(json['subTarget']),
      equipment: serializer.fromJson<String?>(json['equipment']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'bodyPart': serializer.toJson<String>(bodyPart),
      'subTarget': serializer.toJson<String?>(subTarget),
      'equipment': serializer.toJson<String?>(equipment),
      'isCustom': serializer.toJson<bool>(isCustom),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ExerciseRow copyWith({
    int? id,
    String? name,
    String? bodyPart,
    Value<String?> subTarget = const Value.absent(),
    Value<String?> equipment = const Value.absent(),
    bool? isCustom,
    DateTime? createdAt,
  }) => ExerciseRow(
    id: id ?? this.id,
    name: name ?? this.name,
    bodyPart: bodyPart ?? this.bodyPart,
    subTarget: subTarget.present ? subTarget.value : this.subTarget,
    equipment: equipment.present ? equipment.value : this.equipment,
    isCustom: isCustom ?? this.isCustom,
    createdAt: createdAt ?? this.createdAt,
  );
  ExerciseRow copyWithCompanion(ExercisesCompanion data) {
    return ExerciseRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      bodyPart: data.bodyPart.present ? data.bodyPart.value : this.bodyPart,
      subTarget: data.subTarget.present ? data.subTarget.value : this.subTarget,
      equipment: data.equipment.present ? data.equipment.value : this.equipment,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('bodyPart: $bodyPart, ')
          ..write('subTarget: $subTarget, ')
          ..write('equipment: $equipment, ')
          ..write('isCustom: $isCustom, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    bodyPart,
    subTarget,
    equipment,
    isCustom,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.bodyPart == this.bodyPart &&
          other.subTarget == this.subTarget &&
          other.equipment == this.equipment &&
          other.isCustom == this.isCustom &&
          other.createdAt == this.createdAt);
}

class ExercisesCompanion extends UpdateCompanion<ExerciseRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> bodyPart;
  final Value<String?> subTarget;
  final Value<String?> equipment;
  final Value<bool> isCustom;
  final Value<DateTime> createdAt;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.bodyPart = const Value.absent(),
    this.subTarget = const Value.absent(),
    this.equipment = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ExercisesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String bodyPart,
    this.subTarget = const Value.absent(),
    this.equipment = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       bodyPart = Value(bodyPart);
  static Insertable<ExerciseRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? bodyPart,
    Expression<String>? subTarget,
    Expression<String>? equipment,
    Expression<bool>? isCustom,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (bodyPart != null) 'body_part': bodyPart,
      if (subTarget != null) 'sub_target': subTarget,
      if (equipment != null) 'equipment': equipment,
      if (isCustom != null) 'is_custom': isCustom,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ExercisesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? bodyPart,
    Value<String?>? subTarget,
    Value<String?>? equipment,
    Value<bool>? isCustom,
    Value<DateTime>? createdAt,
  }) {
    return ExercisesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      bodyPart: bodyPart ?? this.bodyPart,
      subTarget: subTarget ?? this.subTarget,
      equipment: equipment ?? this.equipment,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (bodyPart.present) {
      map['body_part'] = Variable<String>(bodyPart.value);
    }
    if (subTarget.present) {
      map['sub_target'] = Variable<String>(subTarget.value);
    }
    if (equipment.present) {
      map['equipment'] = Variable<String>(equipment.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('bodyPart: $bodyPart, ')
          ..write('subTarget: $subTarget, ')
          ..write('equipment: $equipment, ')
          ..write('isCustom: $isCustom, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $RoutinesTable extends Routines
    with TableInfo<$RoutinesTable, RoutineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sessionMinutesMeta = const VerificationMeta(
    'sessionMinutes',
  );
  @override
  late final GeneratedColumn<int> sessionMinutes = GeneratedColumn<int>(
    'session_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(40),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    sessionMinutes,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routines';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('session_minutes')) {
      context.handle(
        _sessionMinutesMeta,
        sessionMinutes.isAcceptableOrUnknown(
          data['session_minutes']!,
          _sessionMinutesMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      sessionMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_minutes'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RoutinesTable createAlias(String alias) {
    return $RoutinesTable(attachedDatabase, alias);
  }
}

class RoutineRow extends DataClass implements Insertable<RoutineRow> {
  final int id;
  final String name;
  final String? description;
  final int sessionMinutes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const RoutineRow({
    required this.id,
    required this.name,
    this.description,
    required this.sessionMinutes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['session_minutes'] = Variable<int>(sessionMinutes);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RoutinesCompanion toCompanion(bool nullToAbsent) {
    return RoutinesCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      sessionMinutes: Value(sessionMinutes),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory RoutineRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      sessionMinutes: serializer.fromJson<int>(json['sessionMinutes']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'sessionMinutes': serializer.toJson<int>(sessionMinutes),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RoutineRow copyWith({
    int? id,
    String? name,
    Value<String?> description = const Value.absent(),
    int? sessionMinutes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => RoutineRow(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    sessionMinutes: sessionMinutes ?? this.sessionMinutes,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RoutineRow copyWithCompanion(RoutinesCompanion data) {
    return RoutineRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      sessionMinutes: data.sessionMinutes.present
          ? data.sessionMinutes.value
          : this.sessionMinutes,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('sessionMinutes: $sessionMinutes, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    sessionMinutes,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.sessionMinutes == this.sessionMinutes &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RoutinesCompanion extends UpdateCompanion<RoutineRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<int> sessionMinutes;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const RoutinesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.sessionMinutes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  RoutinesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.sessionMinutes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<RoutineRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? sessionMinutes,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (sessionMinutes != null) 'session_minutes': sessionMinutes,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  RoutinesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<int>? sessionMinutes,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return RoutinesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sessionMinutes: sessionMinutes ?? this.sessionMinutes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (sessionMinutes.present) {
      map['session_minutes'] = Variable<int>(sessionMinutes.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutinesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('sessionMinutes: $sessionMinutes, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $RoutineDaysTable extends RoutineDays
    with TableInfo<$RoutineDaysTable, RoutineDayRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _routineIdMeta = const VerificationMeta(
    'routineId',
  );
  @override
  late final GeneratedColumn<int> routineId = GeneratedColumn<int>(
    'routine_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routines (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 8),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtitleMeta = const VerificationMeta(
    'subtitle',
  );
  @override
  late final GeneratedColumn<String> subtitle = GeneratedColumn<String>(
    'subtitle',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _primaryBodyPartMeta = const VerificationMeta(
    'primaryBodyPart',
  );
  @override
  late final GeneratedColumn<String> primaryBodyPart = GeneratedColumn<String>(
    'primary_body_part',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    routineId,
    sortOrder,
    code,
    title,
    subtitle,
    description,
    primaryBodyPart,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineDayRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('routine_id')) {
      context.handle(
        _routineIdMeta,
        routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routineIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('subtitle')) {
      context.handle(
        _subtitleMeta,
        subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('primary_body_part')) {
      context.handle(
        _primaryBodyPartMeta,
        primaryBodyPart.isAcceptableOrUnknown(
          data['primary_body_part']!,
          _primaryBodyPartMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_primaryBodyPartMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineDayRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineDayRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      routineId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}routine_id'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      subtitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtitle'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      primaryBodyPart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_body_part'],
      )!,
    );
  }

  @override
  $RoutineDaysTable createAlias(String alias) {
    return $RoutineDaysTable(attachedDatabase, alias);
  }
}

class RoutineDayRow extends DataClass implements Insertable<RoutineDayRow> {
  final int id;
  final int routineId;

  /// 0-based rotation position. Named `sortOrder` because `order` is a SQL
  /// keyword.
  final int sortOrder;
  final String code;
  final String title;
  final String? subtitle;
  final String? description;

  /// [BodyPart.name]
  final String primaryBodyPart;
  const RoutineDayRow({
    required this.id,
    required this.routineId,
    required this.sortOrder,
    required this.code,
    required this.title,
    this.subtitle,
    this.description,
    required this.primaryBodyPart,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['routine_id'] = Variable<int>(routineId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['code'] = Variable<String>(code);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || subtitle != null) {
      map['subtitle'] = Variable<String>(subtitle);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['primary_body_part'] = Variable<String>(primaryBodyPart);
    return map;
  }

  RoutineDaysCompanion toCompanion(bool nullToAbsent) {
    return RoutineDaysCompanion(
      id: Value(id),
      routineId: Value(routineId),
      sortOrder: Value(sortOrder),
      code: Value(code),
      title: Value(title),
      subtitle: subtitle == null && nullToAbsent
          ? const Value.absent()
          : Value(subtitle),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      primaryBodyPart: Value(primaryBodyPart),
    );
  }

  factory RoutineDayRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineDayRow(
      id: serializer.fromJson<int>(json['id']),
      routineId: serializer.fromJson<int>(json['routineId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      code: serializer.fromJson<String>(json['code']),
      title: serializer.fromJson<String>(json['title']),
      subtitle: serializer.fromJson<String?>(json['subtitle']),
      description: serializer.fromJson<String?>(json['description']),
      primaryBodyPart: serializer.fromJson<String>(json['primaryBodyPart']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'routineId': serializer.toJson<int>(routineId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'code': serializer.toJson<String>(code),
      'title': serializer.toJson<String>(title),
      'subtitle': serializer.toJson<String?>(subtitle),
      'description': serializer.toJson<String?>(description),
      'primaryBodyPart': serializer.toJson<String>(primaryBodyPart),
    };
  }

  RoutineDayRow copyWith({
    int? id,
    int? routineId,
    int? sortOrder,
    String? code,
    String? title,
    Value<String?> subtitle = const Value.absent(),
    Value<String?> description = const Value.absent(),
    String? primaryBodyPart,
  }) => RoutineDayRow(
    id: id ?? this.id,
    routineId: routineId ?? this.routineId,
    sortOrder: sortOrder ?? this.sortOrder,
    code: code ?? this.code,
    title: title ?? this.title,
    subtitle: subtitle.present ? subtitle.value : this.subtitle,
    description: description.present ? description.value : this.description,
    primaryBodyPart: primaryBodyPart ?? this.primaryBodyPart,
  );
  RoutineDayRow copyWithCompanion(RoutineDaysCompanion data) {
    return RoutineDayRow(
      id: data.id.present ? data.id.value : this.id,
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      code: data.code.present ? data.code.value : this.code,
      title: data.title.present ? data.title.value : this.title,
      subtitle: data.subtitle.present ? data.subtitle.value : this.subtitle,
      description: data.description.present
          ? data.description.value
          : this.description,
      primaryBodyPart: data.primaryBodyPart.present
          ? data.primaryBodyPart.value
          : this.primaryBodyPart,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineDayRow(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('code: $code, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('description: $description, ')
          ..write('primaryBodyPart: $primaryBodyPart')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    routineId,
    sortOrder,
    code,
    title,
    subtitle,
    description,
    primaryBodyPart,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineDayRow &&
          other.id == this.id &&
          other.routineId == this.routineId &&
          other.sortOrder == this.sortOrder &&
          other.code == this.code &&
          other.title == this.title &&
          other.subtitle == this.subtitle &&
          other.description == this.description &&
          other.primaryBodyPart == this.primaryBodyPart);
}

class RoutineDaysCompanion extends UpdateCompanion<RoutineDayRow> {
  final Value<int> id;
  final Value<int> routineId;
  final Value<int> sortOrder;
  final Value<String> code;
  final Value<String> title;
  final Value<String?> subtitle;
  final Value<String?> description;
  final Value<String> primaryBodyPart;
  const RoutineDaysCompanion({
    this.id = const Value.absent(),
    this.routineId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.code = const Value.absent(),
    this.title = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.description = const Value.absent(),
    this.primaryBodyPart = const Value.absent(),
  });
  RoutineDaysCompanion.insert({
    this.id = const Value.absent(),
    required int routineId,
    required int sortOrder,
    required String code,
    required String title,
    this.subtitle = const Value.absent(),
    this.description = const Value.absent(),
    required String primaryBodyPart,
  }) : routineId = Value(routineId),
       sortOrder = Value(sortOrder),
       code = Value(code),
       title = Value(title),
       primaryBodyPart = Value(primaryBodyPart);
  static Insertable<RoutineDayRow> custom({
    Expression<int>? id,
    Expression<int>? routineId,
    Expression<int>? sortOrder,
    Expression<String>? code,
    Expression<String>? title,
    Expression<String>? subtitle,
    Expression<String>? description,
    Expression<String>? primaryBodyPart,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routineId != null) 'routine_id': routineId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (code != null) 'code': code,
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (description != null) 'description': description,
      if (primaryBodyPart != null) 'primary_body_part': primaryBodyPart,
    });
  }

  RoutineDaysCompanion copyWith({
    Value<int>? id,
    Value<int>? routineId,
    Value<int>? sortOrder,
    Value<String>? code,
    Value<String>? title,
    Value<String?>? subtitle,
    Value<String?>? description,
    Value<String>? primaryBodyPart,
  }) {
    return RoutineDaysCompanion(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      sortOrder: sortOrder ?? this.sortOrder,
      code: code ?? this.code,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      primaryBodyPart: primaryBodyPart ?? this.primaryBodyPart,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (routineId.present) {
      map['routine_id'] = Variable<int>(routineId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (subtitle.present) {
      map['subtitle'] = Variable<String>(subtitle.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (primaryBodyPart.present) {
      map['primary_body_part'] = Variable<String>(primaryBodyPart.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineDaysCompanion(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('code: $code, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('description: $description, ')
          ..write('primaryBodyPart: $primaryBodyPart')
          ..write(')'))
        .toString();
  }
}

class $RoutineBlocksTable extends RoutineBlocks
    with TableInfo<$RoutineBlocksTable, RoutineBlockRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineBlocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dayIdMeta = const VerificationMeta('dayId');
  @override
  late final GeneratedColumn<int> dayId = GeneratedColumn<int>(
    'day_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routine_days (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('straight'),
  );
  static const VerificationMeta _roundsMeta = const VerificationMeta('rounds');
  @override
  late final GeneratedColumn<int> rounds = GeneratedColumn<int>(
    'rounds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _restSecondsMeta = const VerificationMeta(
    'restSeconds',
  );
  @override
  late final GeneratedColumn<int> restSeconds = GeneratedColumn<int>(
    'rest_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetMinutesMeta = const VerificationMeta(
    'targetMinutes',
  );
  @override
  late final GeneratedColumn<int> targetMinutes = GeneratedColumn<int>(
    'target_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCuttableMeta = const VerificationMeta(
    'isCuttable',
  );
  @override
  late final GeneratedColumn<bool> isCuttable = GeneratedColumn<bool>(
    'is_cuttable',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_cuttable" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dayId,
    sortOrder,
    label,
    name,
    type,
    rounds,
    restSeconds,
    targetMinutes,
    isCuttable,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_blocks';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineBlockRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day_id')) {
      context.handle(
        _dayIdMeta,
        dayId.isAcceptableOrUnknown(data['day_id']!, _dayIdMeta),
      );
    } else if (isInserting) {
      context.missing(_dayIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('rounds')) {
      context.handle(
        _roundsMeta,
        rounds.isAcceptableOrUnknown(data['rounds']!, _roundsMeta),
      );
    }
    if (data.containsKey('rest_seconds')) {
      context.handle(
        _restSecondsMeta,
        restSeconds.isAcceptableOrUnknown(
          data['rest_seconds']!,
          _restSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_restSecondsMeta);
    }
    if (data.containsKey('target_minutes')) {
      context.handle(
        _targetMinutesMeta,
        targetMinutes.isAcceptableOrUnknown(
          data['target_minutes']!,
          _targetMinutesMeta,
        ),
      );
    }
    if (data.containsKey('is_cuttable')) {
      context.handle(
        _isCuttableMeta,
        isCuttable.isAcceptableOrUnknown(data['is_cuttable']!, _isCuttableMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineBlockRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineBlockRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dayId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_id'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      rounds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rounds'],
      )!,
      restSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_seconds'],
      )!,
      targetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_minutes'],
      ),
      isCuttable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_cuttable'],
      )!,
    );
  }

  @override
  $RoutineBlocksTable createAlias(String alias) {
    return $RoutineBlocksTable(attachedDatabase, alias);
  }
}

class RoutineBlockRow extends DataClass implements Insertable<RoutineBlockRow> {
  final int id;
  final int dayId;
  final int sortOrder;

  /// `B1`, `B2`, `복근`
  final String label;
  final String? name;

  /// [BlockType.name]
  final String type;
  final int rounds;
  final int restSeconds;
  final int? targetMinutes;

  /// The cut rule may drop this block when time runs short. Never true for B1.
  final bool isCuttable;
  const RoutineBlockRow({
    required this.id,
    required this.dayId,
    required this.sortOrder,
    required this.label,
    this.name,
    required this.type,
    required this.rounds,
    required this.restSeconds,
    this.targetMinutes,
    required this.isCuttable,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['day_id'] = Variable<int>(dayId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['type'] = Variable<String>(type);
    map['rounds'] = Variable<int>(rounds);
    map['rest_seconds'] = Variable<int>(restSeconds);
    if (!nullToAbsent || targetMinutes != null) {
      map['target_minutes'] = Variable<int>(targetMinutes);
    }
    map['is_cuttable'] = Variable<bool>(isCuttable);
    return map;
  }

  RoutineBlocksCompanion toCompanion(bool nullToAbsent) {
    return RoutineBlocksCompanion(
      id: Value(id),
      dayId: Value(dayId),
      sortOrder: Value(sortOrder),
      label: Value(label),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      type: Value(type),
      rounds: Value(rounds),
      restSeconds: Value(restSeconds),
      targetMinutes: targetMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(targetMinutes),
      isCuttable: Value(isCuttable),
    );
  }

  factory RoutineBlockRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineBlockRow(
      id: serializer.fromJson<int>(json['id']),
      dayId: serializer.fromJson<int>(json['dayId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      label: serializer.fromJson<String>(json['label']),
      name: serializer.fromJson<String?>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      rounds: serializer.fromJson<int>(json['rounds']),
      restSeconds: serializer.fromJson<int>(json['restSeconds']),
      targetMinutes: serializer.fromJson<int?>(json['targetMinutes']),
      isCuttable: serializer.fromJson<bool>(json['isCuttable']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dayId': serializer.toJson<int>(dayId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'label': serializer.toJson<String>(label),
      'name': serializer.toJson<String?>(name),
      'type': serializer.toJson<String>(type),
      'rounds': serializer.toJson<int>(rounds),
      'restSeconds': serializer.toJson<int>(restSeconds),
      'targetMinutes': serializer.toJson<int?>(targetMinutes),
      'isCuttable': serializer.toJson<bool>(isCuttable),
    };
  }

  RoutineBlockRow copyWith({
    int? id,
    int? dayId,
    int? sortOrder,
    String? label,
    Value<String?> name = const Value.absent(),
    String? type,
    int? rounds,
    int? restSeconds,
    Value<int?> targetMinutes = const Value.absent(),
    bool? isCuttable,
  }) => RoutineBlockRow(
    id: id ?? this.id,
    dayId: dayId ?? this.dayId,
    sortOrder: sortOrder ?? this.sortOrder,
    label: label ?? this.label,
    name: name.present ? name.value : this.name,
    type: type ?? this.type,
    rounds: rounds ?? this.rounds,
    restSeconds: restSeconds ?? this.restSeconds,
    targetMinutes: targetMinutes.present
        ? targetMinutes.value
        : this.targetMinutes,
    isCuttable: isCuttable ?? this.isCuttable,
  );
  RoutineBlockRow copyWithCompanion(RoutineBlocksCompanion data) {
    return RoutineBlockRow(
      id: data.id.present ? data.id.value : this.id,
      dayId: data.dayId.present ? data.dayId.value : this.dayId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      label: data.label.present ? data.label.value : this.label,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      rounds: data.rounds.present ? data.rounds.value : this.rounds,
      restSeconds: data.restSeconds.present
          ? data.restSeconds.value
          : this.restSeconds,
      targetMinutes: data.targetMinutes.present
          ? data.targetMinutes.value
          : this.targetMinutes,
      isCuttable: data.isCuttable.present
          ? data.isCuttable.value
          : this.isCuttable,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineBlockRow(')
          ..write('id: $id, ')
          ..write('dayId: $dayId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('label: $label, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('rounds: $rounds, ')
          ..write('restSeconds: $restSeconds, ')
          ..write('targetMinutes: $targetMinutes, ')
          ..write('isCuttable: $isCuttable')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dayId,
    sortOrder,
    label,
    name,
    type,
    rounds,
    restSeconds,
    targetMinutes,
    isCuttable,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineBlockRow &&
          other.id == this.id &&
          other.dayId == this.dayId &&
          other.sortOrder == this.sortOrder &&
          other.label == this.label &&
          other.name == this.name &&
          other.type == this.type &&
          other.rounds == this.rounds &&
          other.restSeconds == this.restSeconds &&
          other.targetMinutes == this.targetMinutes &&
          other.isCuttable == this.isCuttable);
}

class RoutineBlocksCompanion extends UpdateCompanion<RoutineBlockRow> {
  final Value<int> id;
  final Value<int> dayId;
  final Value<int> sortOrder;
  final Value<String> label;
  final Value<String?> name;
  final Value<String> type;
  final Value<int> rounds;
  final Value<int> restSeconds;
  final Value<int?> targetMinutes;
  final Value<bool> isCuttable;
  const RoutineBlocksCompanion({
    this.id = const Value.absent(),
    this.dayId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.label = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.rounds = const Value.absent(),
    this.restSeconds = const Value.absent(),
    this.targetMinutes = const Value.absent(),
    this.isCuttable = const Value.absent(),
  });
  RoutineBlocksCompanion.insert({
    this.id = const Value.absent(),
    required int dayId,
    required int sortOrder,
    required String label,
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.rounds = const Value.absent(),
    required int restSeconds,
    this.targetMinutes = const Value.absent(),
    this.isCuttable = const Value.absent(),
  }) : dayId = Value(dayId),
       sortOrder = Value(sortOrder),
       label = Value(label),
       restSeconds = Value(restSeconds);
  static Insertable<RoutineBlockRow> custom({
    Expression<int>? id,
    Expression<int>? dayId,
    Expression<int>? sortOrder,
    Expression<String>? label,
    Expression<String>? name,
    Expression<String>? type,
    Expression<int>? rounds,
    Expression<int>? restSeconds,
    Expression<int>? targetMinutes,
    Expression<bool>? isCuttable,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dayId != null) 'day_id': dayId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (label != null) 'label': label,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (rounds != null) 'rounds': rounds,
      if (restSeconds != null) 'rest_seconds': restSeconds,
      if (targetMinutes != null) 'target_minutes': targetMinutes,
      if (isCuttable != null) 'is_cuttable': isCuttable,
    });
  }

  RoutineBlocksCompanion copyWith({
    Value<int>? id,
    Value<int>? dayId,
    Value<int>? sortOrder,
    Value<String>? label,
    Value<String?>? name,
    Value<String>? type,
    Value<int>? rounds,
    Value<int>? restSeconds,
    Value<int?>? targetMinutes,
    Value<bool>? isCuttable,
  }) {
    return RoutineBlocksCompanion(
      id: id ?? this.id,
      dayId: dayId ?? this.dayId,
      sortOrder: sortOrder ?? this.sortOrder,
      label: label ?? this.label,
      name: name ?? this.name,
      type: type ?? this.type,
      rounds: rounds ?? this.rounds,
      restSeconds: restSeconds ?? this.restSeconds,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      isCuttable: isCuttable ?? this.isCuttable,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dayId.present) {
      map['day_id'] = Variable<int>(dayId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (rounds.present) {
      map['rounds'] = Variable<int>(rounds.value);
    }
    if (restSeconds.present) {
      map['rest_seconds'] = Variable<int>(restSeconds.value);
    }
    if (targetMinutes.present) {
      map['target_minutes'] = Variable<int>(targetMinutes.value);
    }
    if (isCuttable.present) {
      map['is_cuttable'] = Variable<bool>(isCuttable.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineBlocksCompanion(')
          ..write('id: $id, ')
          ..write('dayId: $dayId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('label: $label, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('rounds: $rounds, ')
          ..write('restSeconds: $restSeconds, ')
          ..write('targetMinutes: $targetMinutes, ')
          ..write('isCuttable: $isCuttable')
          ..write(')'))
        .toString();
  }
}

class $RoutineItemsTable extends RoutineItems
    with TableInfo<$RoutineItemsTable, RoutineItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _blockIdMeta = const VerificationMeta(
    'blockId',
  );
  @override
  late final GeneratedColumn<int> blockId = GeneratedColumn<int>(
    'block_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routine_blocks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id)',
    ),
  );
  static const VerificationMeta _setsMeta = const VerificationMeta('sets');
  @override
  late final GeneratedColumn<int> sets = GeneratedColumn<int>(
    'sets',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repModeMeta = const VerificationMeta(
    'repMode',
  );
  @override
  late final GeneratedColumn<String> repMode = GeneratedColumn<String>(
    'rep_mode',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('range'),
  );
  static const VerificationMeta _repMinMeta = const VerificationMeta('repMin');
  @override
  late final GeneratedColumn<int> repMin = GeneratedColumn<int>(
    'rep_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repMaxMeta = const VerificationMeta('repMax');
  @override
  late final GeneratedColumn<int> repMax = GeneratedColumn<int>(
    'rep_max',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restSecondsOverrideMeta =
      const VerificationMeta('restSecondsOverride');
  @override
  late final GeneratedColumn<int> restSecondsOverride = GeneratedColumn<int>(
    'rest_seconds_override',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetRirMeta = const VerificationMeta(
    'targetRir',
  );
  @override
  late final GeneratedColumn<int> targetRir = GeneratedColumn<int>(
    'target_rir',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alternativeExerciseIdsMeta =
      const VerificationMeta('alternativeExerciseIds');
  @override
  late final GeneratedColumn<String> alternativeExerciseIds =
      GeneratedColumn<String>(
        'alternative_exercise_ids',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    blockId,
    sortOrder,
    exerciseId,
    sets,
    repMode,
    repMin,
    repMax,
    durationSeconds,
    restSecondsOverride,
    targetRir,
    note,
    alternativeExerciseIds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('block_id')) {
      context.handle(
        _blockIdMeta,
        blockId.isAcceptableOrUnknown(data['block_id']!, _blockIdMeta),
      );
    } else if (isInserting) {
      context.missing(_blockIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('sets')) {
      context.handle(
        _setsMeta,
        sets.isAcceptableOrUnknown(data['sets']!, _setsMeta),
      );
    } else if (isInserting) {
      context.missing(_setsMeta);
    }
    if (data.containsKey('rep_mode')) {
      context.handle(
        _repModeMeta,
        repMode.isAcceptableOrUnknown(data['rep_mode']!, _repModeMeta),
      );
    }
    if (data.containsKey('rep_min')) {
      context.handle(
        _repMinMeta,
        repMin.isAcceptableOrUnknown(data['rep_min']!, _repMinMeta),
      );
    }
    if (data.containsKey('rep_max')) {
      context.handle(
        _repMaxMeta,
        repMax.isAcceptableOrUnknown(data['rep_max']!, _repMaxMeta),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('rest_seconds_override')) {
      context.handle(
        _restSecondsOverrideMeta,
        restSecondsOverride.isAcceptableOrUnknown(
          data['rest_seconds_override']!,
          _restSecondsOverrideMeta,
        ),
      );
    }
    if (data.containsKey('target_rir')) {
      context.handle(
        _targetRirMeta,
        targetRir.isAcceptableOrUnknown(data['target_rir']!, _targetRirMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('alternative_exercise_ids')) {
      context.handle(
        _alternativeExerciseIdsMeta,
        alternativeExerciseIds.isAcceptableOrUnknown(
          data['alternative_exercise_ids']!,
          _alternativeExerciseIdsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      blockId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}block_id'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_id'],
      )!,
      sets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sets'],
      )!,
      repMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rep_mode'],
      )!,
      repMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rep_min'],
      ),
      repMax: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rep_max'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      ),
      restSecondsOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_seconds_override'],
      ),
      targetRir: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_rir'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      alternativeExerciseIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alternative_exercise_ids'],
      )!,
    );
  }

  @override
  $RoutineItemsTable createAlias(String alias) {
    return $RoutineItemsTable(attachedDatabase, alias);
  }
}

class RoutineItemRow extends DataClass implements Insertable<RoutineItemRow> {
  final int id;
  final int blockId;
  final int sortOrder;
  final int exerciseId;
  final int sets;

  /// [RepMode.name]
  final String repMode;
  final int? repMin;
  final int? repMax;
  final int? durationSeconds;
  final int? restSecondsOverride;
  final int? targetRir;
  final String? note;

  /// Comma-separated exercise ids used when the machine is occupied.
  final String alternativeExerciseIds;
  const RoutineItemRow({
    required this.id,
    required this.blockId,
    required this.sortOrder,
    required this.exerciseId,
    required this.sets,
    required this.repMode,
    this.repMin,
    this.repMax,
    this.durationSeconds,
    this.restSecondsOverride,
    this.targetRir,
    this.note,
    required this.alternativeExerciseIds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['block_id'] = Variable<int>(blockId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['exercise_id'] = Variable<int>(exerciseId);
    map['sets'] = Variable<int>(sets);
    map['rep_mode'] = Variable<String>(repMode);
    if (!nullToAbsent || repMin != null) {
      map['rep_min'] = Variable<int>(repMin);
    }
    if (!nullToAbsent || repMax != null) {
      map['rep_max'] = Variable<int>(repMax);
    }
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<int>(durationSeconds);
    }
    if (!nullToAbsent || restSecondsOverride != null) {
      map['rest_seconds_override'] = Variable<int>(restSecondsOverride);
    }
    if (!nullToAbsent || targetRir != null) {
      map['target_rir'] = Variable<int>(targetRir);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['alternative_exercise_ids'] = Variable<String>(alternativeExerciseIds);
    return map;
  }

  RoutineItemsCompanion toCompanion(bool nullToAbsent) {
    return RoutineItemsCompanion(
      id: Value(id),
      blockId: Value(blockId),
      sortOrder: Value(sortOrder),
      exerciseId: Value(exerciseId),
      sets: Value(sets),
      repMode: Value(repMode),
      repMin: repMin == null && nullToAbsent
          ? const Value.absent()
          : Value(repMin),
      repMax: repMax == null && nullToAbsent
          ? const Value.absent()
          : Value(repMax),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      restSecondsOverride: restSecondsOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(restSecondsOverride),
      targetRir: targetRir == null && nullToAbsent
          ? const Value.absent()
          : Value(targetRir),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      alternativeExerciseIds: Value(alternativeExerciseIds),
    );
  }

  factory RoutineItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineItemRow(
      id: serializer.fromJson<int>(json['id']),
      blockId: serializer.fromJson<int>(json['blockId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      sets: serializer.fromJson<int>(json['sets']),
      repMode: serializer.fromJson<String>(json['repMode']),
      repMin: serializer.fromJson<int?>(json['repMin']),
      repMax: serializer.fromJson<int?>(json['repMax']),
      durationSeconds: serializer.fromJson<int?>(json['durationSeconds']),
      restSecondsOverride: serializer.fromJson<int?>(
        json['restSecondsOverride'],
      ),
      targetRir: serializer.fromJson<int?>(json['targetRir']),
      note: serializer.fromJson<String?>(json['note']),
      alternativeExerciseIds: serializer.fromJson<String>(
        json['alternativeExerciseIds'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'blockId': serializer.toJson<int>(blockId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'exerciseId': serializer.toJson<int>(exerciseId),
      'sets': serializer.toJson<int>(sets),
      'repMode': serializer.toJson<String>(repMode),
      'repMin': serializer.toJson<int?>(repMin),
      'repMax': serializer.toJson<int?>(repMax),
      'durationSeconds': serializer.toJson<int?>(durationSeconds),
      'restSecondsOverride': serializer.toJson<int?>(restSecondsOverride),
      'targetRir': serializer.toJson<int?>(targetRir),
      'note': serializer.toJson<String?>(note),
      'alternativeExerciseIds': serializer.toJson<String>(
        alternativeExerciseIds,
      ),
    };
  }

  RoutineItemRow copyWith({
    int? id,
    int? blockId,
    int? sortOrder,
    int? exerciseId,
    int? sets,
    String? repMode,
    Value<int?> repMin = const Value.absent(),
    Value<int?> repMax = const Value.absent(),
    Value<int?> durationSeconds = const Value.absent(),
    Value<int?> restSecondsOverride = const Value.absent(),
    Value<int?> targetRir = const Value.absent(),
    Value<String?> note = const Value.absent(),
    String? alternativeExerciseIds,
  }) => RoutineItemRow(
    id: id ?? this.id,
    blockId: blockId ?? this.blockId,
    sortOrder: sortOrder ?? this.sortOrder,
    exerciseId: exerciseId ?? this.exerciseId,
    sets: sets ?? this.sets,
    repMode: repMode ?? this.repMode,
    repMin: repMin.present ? repMin.value : this.repMin,
    repMax: repMax.present ? repMax.value : this.repMax,
    durationSeconds: durationSeconds.present
        ? durationSeconds.value
        : this.durationSeconds,
    restSecondsOverride: restSecondsOverride.present
        ? restSecondsOverride.value
        : this.restSecondsOverride,
    targetRir: targetRir.present ? targetRir.value : this.targetRir,
    note: note.present ? note.value : this.note,
    alternativeExerciseIds:
        alternativeExerciseIds ?? this.alternativeExerciseIds,
  );
  RoutineItemRow copyWithCompanion(RoutineItemsCompanion data) {
    return RoutineItemRow(
      id: data.id.present ? data.id.value : this.id,
      blockId: data.blockId.present ? data.blockId.value : this.blockId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      sets: data.sets.present ? data.sets.value : this.sets,
      repMode: data.repMode.present ? data.repMode.value : this.repMode,
      repMin: data.repMin.present ? data.repMin.value : this.repMin,
      repMax: data.repMax.present ? data.repMax.value : this.repMax,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      restSecondsOverride: data.restSecondsOverride.present
          ? data.restSecondsOverride.value
          : this.restSecondsOverride,
      targetRir: data.targetRir.present ? data.targetRir.value : this.targetRir,
      note: data.note.present ? data.note.value : this.note,
      alternativeExerciseIds: data.alternativeExerciseIds.present
          ? data.alternativeExerciseIds.value
          : this.alternativeExerciseIds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineItemRow(')
          ..write('id: $id, ')
          ..write('blockId: $blockId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('sets: $sets, ')
          ..write('repMode: $repMode, ')
          ..write('repMin: $repMin, ')
          ..write('repMax: $repMax, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('restSecondsOverride: $restSecondsOverride, ')
          ..write('targetRir: $targetRir, ')
          ..write('note: $note, ')
          ..write('alternativeExerciseIds: $alternativeExerciseIds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    blockId,
    sortOrder,
    exerciseId,
    sets,
    repMode,
    repMin,
    repMax,
    durationSeconds,
    restSecondsOverride,
    targetRir,
    note,
    alternativeExerciseIds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineItemRow &&
          other.id == this.id &&
          other.blockId == this.blockId &&
          other.sortOrder == this.sortOrder &&
          other.exerciseId == this.exerciseId &&
          other.sets == this.sets &&
          other.repMode == this.repMode &&
          other.repMin == this.repMin &&
          other.repMax == this.repMax &&
          other.durationSeconds == this.durationSeconds &&
          other.restSecondsOverride == this.restSecondsOverride &&
          other.targetRir == this.targetRir &&
          other.note == this.note &&
          other.alternativeExerciseIds == this.alternativeExerciseIds);
}

class RoutineItemsCompanion extends UpdateCompanion<RoutineItemRow> {
  final Value<int> id;
  final Value<int> blockId;
  final Value<int> sortOrder;
  final Value<int> exerciseId;
  final Value<int> sets;
  final Value<String> repMode;
  final Value<int?> repMin;
  final Value<int?> repMax;
  final Value<int?> durationSeconds;
  final Value<int?> restSecondsOverride;
  final Value<int?> targetRir;
  final Value<String?> note;
  final Value<String> alternativeExerciseIds;
  const RoutineItemsCompanion({
    this.id = const Value.absent(),
    this.blockId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.sets = const Value.absent(),
    this.repMode = const Value.absent(),
    this.repMin = const Value.absent(),
    this.repMax = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.restSecondsOverride = const Value.absent(),
    this.targetRir = const Value.absent(),
    this.note = const Value.absent(),
    this.alternativeExerciseIds = const Value.absent(),
  });
  RoutineItemsCompanion.insert({
    this.id = const Value.absent(),
    required int blockId,
    required int sortOrder,
    required int exerciseId,
    required int sets,
    this.repMode = const Value.absent(),
    this.repMin = const Value.absent(),
    this.repMax = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.restSecondsOverride = const Value.absent(),
    this.targetRir = const Value.absent(),
    this.note = const Value.absent(),
    this.alternativeExerciseIds = const Value.absent(),
  }) : blockId = Value(blockId),
       sortOrder = Value(sortOrder),
       exerciseId = Value(exerciseId),
       sets = Value(sets);
  static Insertable<RoutineItemRow> custom({
    Expression<int>? id,
    Expression<int>? blockId,
    Expression<int>? sortOrder,
    Expression<int>? exerciseId,
    Expression<int>? sets,
    Expression<String>? repMode,
    Expression<int>? repMin,
    Expression<int>? repMax,
    Expression<int>? durationSeconds,
    Expression<int>? restSecondsOverride,
    Expression<int>? targetRir,
    Expression<String>? note,
    Expression<String>? alternativeExerciseIds,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (blockId != null) 'block_id': blockId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (sets != null) 'sets': sets,
      if (repMode != null) 'rep_mode': repMode,
      if (repMin != null) 'rep_min': repMin,
      if (repMax != null) 'rep_max': repMax,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (restSecondsOverride != null)
        'rest_seconds_override': restSecondsOverride,
      if (targetRir != null) 'target_rir': targetRir,
      if (note != null) 'note': note,
      if (alternativeExerciseIds != null)
        'alternative_exercise_ids': alternativeExerciseIds,
    });
  }

  RoutineItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? blockId,
    Value<int>? sortOrder,
    Value<int>? exerciseId,
    Value<int>? sets,
    Value<String>? repMode,
    Value<int?>? repMin,
    Value<int?>? repMax,
    Value<int?>? durationSeconds,
    Value<int?>? restSecondsOverride,
    Value<int?>? targetRir,
    Value<String?>? note,
    Value<String>? alternativeExerciseIds,
  }) {
    return RoutineItemsCompanion(
      id: id ?? this.id,
      blockId: blockId ?? this.blockId,
      sortOrder: sortOrder ?? this.sortOrder,
      exerciseId: exerciseId ?? this.exerciseId,
      sets: sets ?? this.sets,
      repMode: repMode ?? this.repMode,
      repMin: repMin ?? this.repMin,
      repMax: repMax ?? this.repMax,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      restSecondsOverride: restSecondsOverride ?? this.restSecondsOverride,
      targetRir: targetRir ?? this.targetRir,
      note: note ?? this.note,
      alternativeExerciseIds:
          alternativeExerciseIds ?? this.alternativeExerciseIds,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (blockId.present) {
      map['block_id'] = Variable<int>(blockId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (sets.present) {
      map['sets'] = Variable<int>(sets.value);
    }
    if (repMode.present) {
      map['rep_mode'] = Variable<String>(repMode.value);
    }
    if (repMin.present) {
      map['rep_min'] = Variable<int>(repMin.value);
    }
    if (repMax.present) {
      map['rep_max'] = Variable<int>(repMax.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (restSecondsOverride.present) {
      map['rest_seconds_override'] = Variable<int>(restSecondsOverride.value);
    }
    if (targetRir.present) {
      map['target_rir'] = Variable<int>(targetRir.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (alternativeExerciseIds.present) {
      map['alternative_exercise_ids'] = Variable<String>(
        alternativeExerciseIds.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineItemsCompanion(')
          ..write('id: $id, ')
          ..write('blockId: $blockId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('sets: $sets, ')
          ..write('repMode: $repMode, ')
          ..write('repMin: $repMin, ')
          ..write('repMax: $repMax, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('restSecondsOverride: $restSecondsOverride, ')
          ..write('targetRir: $targetRir, ')
          ..write('note: $note, ')
          ..write('alternativeExerciseIds: $alternativeExerciseIds')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSessionsTable extends WorkoutSessions
    with TableInfo<$WorkoutSessionsTable, WorkoutSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _routineIdMeta = const VerificationMeta(
    'routineId',
  );
  @override
  late final GeneratedColumn<int> routineId = GeneratedColumn<int>(
    'routine_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayIdMeta = const VerificationMeta('dayId');
  @override
  late final GeneratedColumn<int> dayId = GeneratedColumn<int>(
    'day_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routine_days (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _dayCodeMeta = const VerificationMeta(
    'dayCode',
  );
  @override
  late final GeneratedColumn<String> dayCode = GeneratedColumn<String>(
    'day_code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 8),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayTitleMeta = const VerificationMeta(
    'dayTitle',
  );
  @override
  late final GeneratedColumn<String> dayTitle = GeneratedColumn<String>(
    'day_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('inProgress'),
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    routineId,
    dayId,
    dayCode,
    dayTitle,
    date,
    startedAt,
    endedAt,
    status,
    memo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('routine_id')) {
      context.handle(
        _routineIdMeta,
        routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routineIdMeta);
    }
    if (data.containsKey('day_id')) {
      context.handle(
        _dayIdMeta,
        dayId.isAcceptableOrUnknown(data['day_id']!, _dayIdMeta),
      );
    }
    if (data.containsKey('day_code')) {
      context.handle(
        _dayCodeMeta,
        dayCode.isAcceptableOrUnknown(data['day_code']!, _dayCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_dayCodeMeta);
    }
    if (data.containsKey('day_title')) {
      context.handle(
        _dayTitleMeta,
        dayTitle.isAcceptableOrUnknown(data['day_title']!, _dayTitleMeta),
      );
    } else if (isInserting) {
      context.missing(_dayTitleMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      routineId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}routine_id'],
      )!,
      dayId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_id'],
      ),
      dayCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_code'],
      )!,
      dayTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_title'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
    );
  }

  @override
  $WorkoutSessionsTable createAlias(String alias) {
    return $WorkoutSessionsTable(attachedDatabase, alias);
  }
}

class WorkoutSessionRow extends DataClass
    implements Insertable<WorkoutSessionRow> {
  final int id;
  final int routineId;

  /// Set to null if the routine day is deleted; the snapshot columns keep the
  /// record readable.
  final int? dayId;
  final String dayCode;
  final String dayTitle;

  /// Midnight of the training day — the calendar key.
  final DateTime date;
  final DateTime startedAt;
  final DateTime? endedAt;

  /// [SessionStatus.name]
  final String status;
  final String? memo;
  const WorkoutSessionRow({
    required this.id,
    required this.routineId,
    this.dayId,
    required this.dayCode,
    required this.dayTitle,
    required this.date,
    required this.startedAt,
    this.endedAt,
    required this.status,
    this.memo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['routine_id'] = Variable<int>(routineId);
    if (!nullToAbsent || dayId != null) {
      map['day_id'] = Variable<int>(dayId);
    }
    map['day_code'] = Variable<String>(dayCode);
    map['day_title'] = Variable<String>(dayTitle);
    map['date'] = Variable<DateTime>(date);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    return map;
  }

  WorkoutSessionsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSessionsCompanion(
      id: Value(id),
      routineId: Value(routineId),
      dayId: dayId == null && nullToAbsent
          ? const Value.absent()
          : Value(dayId),
      dayCode: Value(dayCode),
      dayTitle: Value(dayTitle),
      date: Value(date),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      status: Value(status),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
    );
  }

  factory WorkoutSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSessionRow(
      id: serializer.fromJson<int>(json['id']),
      routineId: serializer.fromJson<int>(json['routineId']),
      dayId: serializer.fromJson<int?>(json['dayId']),
      dayCode: serializer.fromJson<String>(json['dayCode']),
      dayTitle: serializer.fromJson<String>(json['dayTitle']),
      date: serializer.fromJson<DateTime>(json['date']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      status: serializer.fromJson<String>(json['status']),
      memo: serializer.fromJson<String?>(json['memo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'routineId': serializer.toJson<int>(routineId),
      'dayId': serializer.toJson<int?>(dayId),
      'dayCode': serializer.toJson<String>(dayCode),
      'dayTitle': serializer.toJson<String>(dayTitle),
      'date': serializer.toJson<DateTime>(date),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'status': serializer.toJson<String>(status),
      'memo': serializer.toJson<String?>(memo),
    };
  }

  WorkoutSessionRow copyWith({
    int? id,
    int? routineId,
    Value<int?> dayId = const Value.absent(),
    String? dayCode,
    String? dayTitle,
    DateTime? date,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    String? status,
    Value<String?> memo = const Value.absent(),
  }) => WorkoutSessionRow(
    id: id ?? this.id,
    routineId: routineId ?? this.routineId,
    dayId: dayId.present ? dayId.value : this.dayId,
    dayCode: dayCode ?? this.dayCode,
    dayTitle: dayTitle ?? this.dayTitle,
    date: date ?? this.date,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    status: status ?? this.status,
    memo: memo.present ? memo.value : this.memo,
  );
  WorkoutSessionRow copyWithCompanion(WorkoutSessionsCompanion data) {
    return WorkoutSessionRow(
      id: data.id.present ? data.id.value : this.id,
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
      dayId: data.dayId.present ? data.dayId.value : this.dayId,
      dayCode: data.dayCode.present ? data.dayCode.value : this.dayCode,
      dayTitle: data.dayTitle.present ? data.dayTitle.value : this.dayTitle,
      date: data.date.present ? data.date.value : this.date,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      status: data.status.present ? data.status.value : this.status,
      memo: data.memo.present ? data.memo.value : this.memo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionRow(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('dayId: $dayId, ')
          ..write('dayCode: $dayCode, ')
          ..write('dayTitle: $dayTitle, ')
          ..write('date: $date, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('status: $status, ')
          ..write('memo: $memo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    routineId,
    dayId,
    dayCode,
    dayTitle,
    date,
    startedAt,
    endedAt,
    status,
    memo,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSessionRow &&
          other.id == this.id &&
          other.routineId == this.routineId &&
          other.dayId == this.dayId &&
          other.dayCode == this.dayCode &&
          other.dayTitle == this.dayTitle &&
          other.date == this.date &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.status == this.status &&
          other.memo == this.memo);
}

class WorkoutSessionsCompanion extends UpdateCompanion<WorkoutSessionRow> {
  final Value<int> id;
  final Value<int> routineId;
  final Value<int?> dayId;
  final Value<String> dayCode;
  final Value<String> dayTitle;
  final Value<DateTime> date;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<String> status;
  final Value<String?> memo;
  const WorkoutSessionsCompanion({
    this.id = const Value.absent(),
    this.routineId = const Value.absent(),
    this.dayId = const Value.absent(),
    this.dayCode = const Value.absent(),
    this.dayTitle = const Value.absent(),
    this.date = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.memo = const Value.absent(),
  });
  WorkoutSessionsCompanion.insert({
    this.id = const Value.absent(),
    required int routineId,
    this.dayId = const Value.absent(),
    required String dayCode,
    required String dayTitle,
    required DateTime date,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.memo = const Value.absent(),
  }) : routineId = Value(routineId),
       dayCode = Value(dayCode),
       dayTitle = Value(dayTitle),
       date = Value(date),
       startedAt = Value(startedAt);
  static Insertable<WorkoutSessionRow> custom({
    Expression<int>? id,
    Expression<int>? routineId,
    Expression<int>? dayId,
    Expression<String>? dayCode,
    Expression<String>? dayTitle,
    Expression<DateTime>? date,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? status,
    Expression<String>? memo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routineId != null) 'routine_id': routineId,
      if (dayId != null) 'day_id': dayId,
      if (dayCode != null) 'day_code': dayCode,
      if (dayTitle != null) 'day_title': dayTitle,
      if (date != null) 'date': date,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (status != null) 'status': status,
      if (memo != null) 'memo': memo,
    });
  }

  WorkoutSessionsCompanion copyWith({
    Value<int>? id,
    Value<int>? routineId,
    Value<int?>? dayId,
    Value<String>? dayCode,
    Value<String>? dayTitle,
    Value<DateTime>? date,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<String>? status,
    Value<String?>? memo,
  }) {
    return WorkoutSessionsCompanion(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      dayId: dayId ?? this.dayId,
      dayCode: dayCode ?? this.dayCode,
      dayTitle: dayTitle ?? this.dayTitle,
      date: date ?? this.date,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      status: status ?? this.status,
      memo: memo ?? this.memo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (routineId.present) {
      map['routine_id'] = Variable<int>(routineId.value);
    }
    if (dayId.present) {
      map['day_id'] = Variable<int>(dayId.value);
    }
    if (dayCode.present) {
      map['day_code'] = Variable<String>(dayCode.value);
    }
    if (dayTitle.present) {
      map['day_title'] = Variable<String>(dayTitle.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionsCompanion(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('dayId: $dayId, ')
          ..write('dayCode: $dayCode, ')
          ..write('dayTitle: $dayTitle, ')
          ..write('date: $date, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('status: $status, ')
          ..write('memo: $memo')
          ..write(')'))
        .toString();
  }
}

class $SetLogsTable extends SetLogs with TableInfo<$SetLogsTable, SetLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SetLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workout_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _routineItemIdMeta = const VerificationMeta(
    'routineItemId',
  );
  @override
  late final GeneratedColumn<int> routineItemId = GeneratedColumn<int>(
    'routine_item_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseNameMeta = const VerificationMeta(
    'exerciseName',
  );
  @override
  late final GeneratedColumn<String> exerciseName = GeneratedColumn<String>(
    'exercise_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyPartMeta = const VerificationMeta(
    'bodyPart',
  );
  @override
  late final GeneratedColumn<String> bodyPart = GeneratedColumn<String>(
    'body_part',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _blockLabelMeta = const VerificationMeta(
    'blockLabel',
  );
  @override
  late final GeneratedColumn<String> blockLabel = GeneratedColumn<String>(
    'block_label',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemOrderMeta = const VerificationMeta(
    'itemOrder',
  );
  @override
  late final GeneratedColumn<int> itemOrder = GeneratedColumn<int>(
    'item_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setIndexMeta = const VerificationMeta(
    'setIndex',
  );
  @override
  late final GeneratedColumn<int> setIndex = GeneratedColumn<int>(
    'set_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rirMeta = const VerificationMeta('rir');
  @override
  late final GeneratedColumn<int> rir = GeneratedColumn<int>(
    'rir',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restSecondsMeta = const VerificationMeta(
    'restSeconds',
  );
  @override
  late final GeneratedColumn<int> restSeconds = GeneratedColumn<int>(
    'rest_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    routineItemId,
    exerciseId,
    exerciseName,
    bodyPart,
    blockLabel,
    itemOrder,
    setIndex,
    weight,
    reps,
    durationSeconds,
    rir,
    restSeconds,
    isCompleted,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'set_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SetLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('routine_item_id')) {
      context.handle(
        _routineItemIdMeta,
        routineItemId.isAcceptableOrUnknown(
          data['routine_item_id']!,
          _routineItemIdMeta,
        ),
      );
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('exercise_name')) {
      context.handle(
        _exerciseNameMeta,
        exerciseName.isAcceptableOrUnknown(
          data['exercise_name']!,
          _exerciseNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exerciseNameMeta);
    }
    if (data.containsKey('body_part')) {
      context.handle(
        _bodyPartMeta,
        bodyPart.isAcceptableOrUnknown(data['body_part']!, _bodyPartMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyPartMeta);
    }
    if (data.containsKey('block_label')) {
      context.handle(
        _blockLabelMeta,
        blockLabel.isAcceptableOrUnknown(data['block_label']!, _blockLabelMeta),
      );
    } else if (isInserting) {
      context.missing(_blockLabelMeta);
    }
    if (data.containsKey('item_order')) {
      context.handle(
        _itemOrderMeta,
        itemOrder.isAcceptableOrUnknown(data['item_order']!, _itemOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_itemOrderMeta);
    }
    if (data.containsKey('set_index')) {
      context.handle(
        _setIndexMeta,
        setIndex.isAcceptableOrUnknown(data['set_index']!, _setIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_setIndexMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('rir')) {
      context.handle(
        _rirMeta,
        rir.isAcceptableOrUnknown(data['rir']!, _rirMeta),
      );
    }
    if (data.containsKey('rest_seconds')) {
      context.handle(
        _restSecondsMeta,
        restSeconds.isAcceptableOrUnknown(
          data['rest_seconds']!,
          _restSecondsMeta,
        ),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SetLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SetLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      routineItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}routine_item_id'],
      ),
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_id'],
      )!,
      exerciseName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_name'],
      )!,
      bodyPart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_part'],
      )!,
      blockLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}block_label'],
      )!,
      itemOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_order'],
      )!,
      setIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}set_index'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      ),
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      ),
      rir: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rir'],
      ),
      restSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_seconds'],
      ),
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
    );
  }

  @override
  $SetLogsTable createAlias(String alias) {
    return $SetLogsTable(attachedDatabase, alias);
  }
}

class SetLogRow extends DataClass implements Insertable<SetLogRow> {
  final int id;
  final int sessionId;

  /// Intentionally not a foreign key: editing the routine must not rewrite or
  /// remove history.
  final int? routineItemId;
  final int exerciseId;

  /// Snapshot — survives renames and deletions.
  final String exerciseName;

  /// Snapshot of [BodyPart.name] — drives weekly volume aggregation.
  final String bodyPart;

  /// Snapshot of the block label (`B1`).
  final String blockLabel;
  final int itemOrder;

  /// 1-based set number within the exercise.
  final int setIndex;
  final double? weight;
  final int? reps;
  final int? durationSeconds;
  final int? rir;

  /// Rest actually measured after this set.
  final int? restSeconds;
  final bool isCompleted;
  final DateTime completedAt;
  const SetLogRow({
    required this.id,
    required this.sessionId,
    this.routineItemId,
    required this.exerciseId,
    required this.exerciseName,
    required this.bodyPart,
    required this.blockLabel,
    required this.itemOrder,
    required this.setIndex,
    this.weight,
    this.reps,
    this.durationSeconds,
    this.rir,
    this.restSeconds,
    required this.isCompleted,
    required this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    if (!nullToAbsent || routineItemId != null) {
      map['routine_item_id'] = Variable<int>(routineItemId);
    }
    map['exercise_id'] = Variable<int>(exerciseId);
    map['exercise_name'] = Variable<String>(exerciseName);
    map['body_part'] = Variable<String>(bodyPart);
    map['block_label'] = Variable<String>(blockLabel);
    map['item_order'] = Variable<int>(itemOrder);
    map['set_index'] = Variable<int>(setIndex);
    if (!nullToAbsent || weight != null) {
      map['weight'] = Variable<double>(weight);
    }
    if (!nullToAbsent || reps != null) {
      map['reps'] = Variable<int>(reps);
    }
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<int>(durationSeconds);
    }
    if (!nullToAbsent || rir != null) {
      map['rir'] = Variable<int>(rir);
    }
    if (!nullToAbsent || restSeconds != null) {
      map['rest_seconds'] = Variable<int>(restSeconds);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    map['completed_at'] = Variable<DateTime>(completedAt);
    return map;
  }

  SetLogsCompanion toCompanion(bool nullToAbsent) {
    return SetLogsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      routineItemId: routineItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(routineItemId),
      exerciseId: Value(exerciseId),
      exerciseName: Value(exerciseName),
      bodyPart: Value(bodyPart),
      blockLabel: Value(blockLabel),
      itemOrder: Value(itemOrder),
      setIndex: Value(setIndex),
      weight: weight == null && nullToAbsent
          ? const Value.absent()
          : Value(weight),
      reps: reps == null && nullToAbsent ? const Value.absent() : Value(reps),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      rir: rir == null && nullToAbsent ? const Value.absent() : Value(rir),
      restSeconds: restSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(restSeconds),
      isCompleted: Value(isCompleted),
      completedAt: Value(completedAt),
    );
  }

  factory SetLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SetLogRow(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      routineItemId: serializer.fromJson<int?>(json['routineItemId']),
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      exerciseName: serializer.fromJson<String>(json['exerciseName']),
      bodyPart: serializer.fromJson<String>(json['bodyPart']),
      blockLabel: serializer.fromJson<String>(json['blockLabel']),
      itemOrder: serializer.fromJson<int>(json['itemOrder']),
      setIndex: serializer.fromJson<int>(json['setIndex']),
      weight: serializer.fromJson<double?>(json['weight']),
      reps: serializer.fromJson<int?>(json['reps']),
      durationSeconds: serializer.fromJson<int?>(json['durationSeconds']),
      rir: serializer.fromJson<int?>(json['rir']),
      restSeconds: serializer.fromJson<int?>(json['restSeconds']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'routineItemId': serializer.toJson<int?>(routineItemId),
      'exerciseId': serializer.toJson<int>(exerciseId),
      'exerciseName': serializer.toJson<String>(exerciseName),
      'bodyPart': serializer.toJson<String>(bodyPart),
      'blockLabel': serializer.toJson<String>(blockLabel),
      'itemOrder': serializer.toJson<int>(itemOrder),
      'setIndex': serializer.toJson<int>(setIndex),
      'weight': serializer.toJson<double?>(weight),
      'reps': serializer.toJson<int?>(reps),
      'durationSeconds': serializer.toJson<int?>(durationSeconds),
      'rir': serializer.toJson<int?>(rir),
      'restSeconds': serializer.toJson<int?>(restSeconds),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'completedAt': serializer.toJson<DateTime>(completedAt),
    };
  }

  SetLogRow copyWith({
    int? id,
    int? sessionId,
    Value<int?> routineItemId = const Value.absent(),
    int? exerciseId,
    String? exerciseName,
    String? bodyPart,
    String? blockLabel,
    int? itemOrder,
    int? setIndex,
    Value<double?> weight = const Value.absent(),
    Value<int?> reps = const Value.absent(),
    Value<int?> durationSeconds = const Value.absent(),
    Value<int?> rir = const Value.absent(),
    Value<int?> restSeconds = const Value.absent(),
    bool? isCompleted,
    DateTime? completedAt,
  }) => SetLogRow(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    routineItemId: routineItemId.present
        ? routineItemId.value
        : this.routineItemId,
    exerciseId: exerciseId ?? this.exerciseId,
    exerciseName: exerciseName ?? this.exerciseName,
    bodyPart: bodyPart ?? this.bodyPart,
    blockLabel: blockLabel ?? this.blockLabel,
    itemOrder: itemOrder ?? this.itemOrder,
    setIndex: setIndex ?? this.setIndex,
    weight: weight.present ? weight.value : this.weight,
    reps: reps.present ? reps.value : this.reps,
    durationSeconds: durationSeconds.present
        ? durationSeconds.value
        : this.durationSeconds,
    rir: rir.present ? rir.value : this.rir,
    restSeconds: restSeconds.present ? restSeconds.value : this.restSeconds,
    isCompleted: isCompleted ?? this.isCompleted,
    completedAt: completedAt ?? this.completedAt,
  );
  SetLogRow copyWithCompanion(SetLogsCompanion data) {
    return SetLogRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      routineItemId: data.routineItemId.present
          ? data.routineItemId.value
          : this.routineItemId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      exerciseName: data.exerciseName.present
          ? data.exerciseName.value
          : this.exerciseName,
      bodyPart: data.bodyPart.present ? data.bodyPart.value : this.bodyPart,
      blockLabel: data.blockLabel.present
          ? data.blockLabel.value
          : this.blockLabel,
      itemOrder: data.itemOrder.present ? data.itemOrder.value : this.itemOrder,
      setIndex: data.setIndex.present ? data.setIndex.value : this.setIndex,
      weight: data.weight.present ? data.weight.value : this.weight,
      reps: data.reps.present ? data.reps.value : this.reps,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      rir: data.rir.present ? data.rir.value : this.rir,
      restSeconds: data.restSeconds.present
          ? data.restSeconds.value
          : this.restSeconds,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SetLogRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('routineItemId: $routineItemId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('exerciseName: $exerciseName, ')
          ..write('bodyPart: $bodyPart, ')
          ..write('blockLabel: $blockLabel, ')
          ..write('itemOrder: $itemOrder, ')
          ..write('setIndex: $setIndex, ')
          ..write('weight: $weight, ')
          ..write('reps: $reps, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('rir: $rir, ')
          ..write('restSeconds: $restSeconds, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    routineItemId,
    exerciseId,
    exerciseName,
    bodyPart,
    blockLabel,
    itemOrder,
    setIndex,
    weight,
    reps,
    durationSeconds,
    rir,
    restSeconds,
    isCompleted,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SetLogRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.routineItemId == this.routineItemId &&
          other.exerciseId == this.exerciseId &&
          other.exerciseName == this.exerciseName &&
          other.bodyPart == this.bodyPart &&
          other.blockLabel == this.blockLabel &&
          other.itemOrder == this.itemOrder &&
          other.setIndex == this.setIndex &&
          other.weight == this.weight &&
          other.reps == this.reps &&
          other.durationSeconds == this.durationSeconds &&
          other.rir == this.rir &&
          other.restSeconds == this.restSeconds &&
          other.isCompleted == this.isCompleted &&
          other.completedAt == this.completedAt);
}

class SetLogsCompanion extends UpdateCompanion<SetLogRow> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int?> routineItemId;
  final Value<int> exerciseId;
  final Value<String> exerciseName;
  final Value<String> bodyPart;
  final Value<String> blockLabel;
  final Value<int> itemOrder;
  final Value<int> setIndex;
  final Value<double?> weight;
  final Value<int?> reps;
  final Value<int?> durationSeconds;
  final Value<int?> rir;
  final Value<int?> restSeconds;
  final Value<bool> isCompleted;
  final Value<DateTime> completedAt;
  const SetLogsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.routineItemId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.exerciseName = const Value.absent(),
    this.bodyPart = const Value.absent(),
    this.blockLabel = const Value.absent(),
    this.itemOrder = const Value.absent(),
    this.setIndex = const Value.absent(),
    this.weight = const Value.absent(),
    this.reps = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.rir = const Value.absent(),
    this.restSeconds = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  SetLogsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    this.routineItemId = const Value.absent(),
    required int exerciseId,
    required String exerciseName,
    required String bodyPart,
    required String blockLabel,
    required int itemOrder,
    required int setIndex,
    this.weight = const Value.absent(),
    this.reps = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.rir = const Value.absent(),
    this.restSeconds = const Value.absent(),
    this.isCompleted = const Value.absent(),
    required DateTime completedAt,
  }) : sessionId = Value(sessionId),
       exerciseId = Value(exerciseId),
       exerciseName = Value(exerciseName),
       bodyPart = Value(bodyPart),
       blockLabel = Value(blockLabel),
       itemOrder = Value(itemOrder),
       setIndex = Value(setIndex),
       completedAt = Value(completedAt);
  static Insertable<SetLogRow> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? routineItemId,
    Expression<int>? exerciseId,
    Expression<String>? exerciseName,
    Expression<String>? bodyPart,
    Expression<String>? blockLabel,
    Expression<int>? itemOrder,
    Expression<int>? setIndex,
    Expression<double>? weight,
    Expression<int>? reps,
    Expression<int>? durationSeconds,
    Expression<int>? rir,
    Expression<int>? restSeconds,
    Expression<bool>? isCompleted,
    Expression<DateTime>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (routineItemId != null) 'routine_item_id': routineItemId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (exerciseName != null) 'exercise_name': exerciseName,
      if (bodyPart != null) 'body_part': bodyPart,
      if (blockLabel != null) 'block_label': blockLabel,
      if (itemOrder != null) 'item_order': itemOrder,
      if (setIndex != null) 'set_index': setIndex,
      if (weight != null) 'weight': weight,
      if (reps != null) 'reps': reps,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (rir != null) 'rir': rir,
      if (restSeconds != null) 'rest_seconds': restSeconds,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  SetLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<int?>? routineItemId,
    Value<int>? exerciseId,
    Value<String>? exerciseName,
    Value<String>? bodyPart,
    Value<String>? blockLabel,
    Value<int>? itemOrder,
    Value<int>? setIndex,
    Value<double?>? weight,
    Value<int?>? reps,
    Value<int?>? durationSeconds,
    Value<int?>? rir,
    Value<int?>? restSeconds,
    Value<bool>? isCompleted,
    Value<DateTime>? completedAt,
  }) {
    return SetLogsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      routineItemId: routineItemId ?? this.routineItemId,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      bodyPart: bodyPart ?? this.bodyPart,
      blockLabel: blockLabel ?? this.blockLabel,
      itemOrder: itemOrder ?? this.itemOrder,
      setIndex: setIndex ?? this.setIndex,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      rir: rir ?? this.rir,
      restSeconds: restSeconds ?? this.restSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (routineItemId.present) {
      map['routine_item_id'] = Variable<int>(routineItemId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (exerciseName.present) {
      map['exercise_name'] = Variable<String>(exerciseName.value);
    }
    if (bodyPart.present) {
      map['body_part'] = Variable<String>(bodyPart.value);
    }
    if (blockLabel.present) {
      map['block_label'] = Variable<String>(blockLabel.value);
    }
    if (itemOrder.present) {
      map['item_order'] = Variable<int>(itemOrder.value);
    }
    if (setIndex.present) {
      map['set_index'] = Variable<int>(setIndex.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (rir.present) {
      map['rir'] = Variable<int>(rir.value);
    }
    if (restSeconds.present) {
      map['rest_seconds'] = Variable<int>(restSeconds.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SetLogsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('routineItemId: $routineItemId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('exerciseName: $exerciseName, ')
          ..write('bodyPart: $bodyPart, ')
          ..write('blockLabel: $blockLabel, ')
          ..write('itemOrder: $itemOrder, ')
          ..write('setIndex: $setIndex, ')
          ..write('weight: $weight, ')
          ..write('reps: $reps, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('rir: $rir, ')
          ..write('restSeconds: $restSeconds, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $RoutinesTable routines = $RoutinesTable(this);
  late final $RoutineDaysTable routineDays = $RoutineDaysTable(this);
  late final $RoutineBlocksTable routineBlocks = $RoutineBlocksTable(this);
  late final $RoutineItemsTable routineItems = $RoutineItemsTable(this);
  late final $WorkoutSessionsTable workoutSessions = $WorkoutSessionsTable(
    this,
  );
  late final $SetLogsTable setLogs = $SetLogsTable(this);
  late final RoutineDao routineDao = RoutineDao(this as AppDatabase);
  late final ExerciseDao exerciseDao = ExerciseDao(this as AppDatabase);
  late final WorkoutDao workoutDao = WorkoutDao(this as AppDatabase);
  late final HistoryDao historyDao = HistoryDao(this as AppDatabase);
  late final BackupDao backupDao = BackupDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    exercises,
    routines,
    routineDays,
    routineBlocks,
    routineItems,
    workoutSessions,
    setLogs,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'routines',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('routine_days', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'routine_days',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('routine_blocks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'routine_blocks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('routine_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'routine_days',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('workout_sessions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workout_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('set_logs', kind: UpdateKind.delete)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$ExercisesTableCreateCompanionBuilder =
    ExercisesCompanion Function({
      Value<int> id,
      required String name,
      required String bodyPart,
      Value<String?> subTarget,
      Value<String?> equipment,
      Value<bool> isCustom,
      Value<DateTime> createdAt,
    });
typedef $$ExercisesTableUpdateCompanionBuilder =
    ExercisesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> bodyPart,
      Value<String?> subTarget,
      Value<String?> equipment,
      Value<bool> isCustom,
      Value<DateTime> createdAt,
    });

final class $$ExercisesTableReferences
    extends BaseReferences<_$AppDatabase, $ExercisesTable, ExerciseRow> {
  $$ExercisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RoutineItemsTable, List<RoutineItemRow>>
  _routineItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.routineItems,
    aliasName: 'exercises__id__routine_items__exercise_id',
  );

  $$RoutineItemsTableProcessedTableManager get routineItemsRefs {
    final manager = $$RoutineItemsTableTableManager(
      $_db,
      $_db.routineItems,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_routineItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodyPart => $composableBuilder(
    column: $table.bodyPart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subTarget => $composableBuilder(
    column: $table.subTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> routineItemsRefs(
    Expression<bool> Function($$RoutineItemsTableFilterComposer f) f,
  ) {
    final $$RoutineItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineItems,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineItemsTableFilterComposer(
            $db: $db,
            $table: $db.routineItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyPart => $composableBuilder(
    column: $table.bodyPart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subTarget => $composableBuilder(
    column: $table.subTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get bodyPart =>
      $composableBuilder(column: $table.bodyPart, builder: (column) => column);

  GeneratedColumn<String> get subTarget =>
      $composableBuilder(column: $table.subTarget, builder: (column) => column);

  GeneratedColumn<String> get equipment =>
      $composableBuilder(column: $table.equipment, builder: (column) => column);

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> routineItemsRefs<T extends Object>(
    Expression<T> Function($$RoutineItemsTableAnnotationComposer a) f,
  ) {
    final $$RoutineItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineItems,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.routineItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExercisesTable,
          ExerciseRow,
          $$ExercisesTableFilterComposer,
          $$ExercisesTableOrderingComposer,
          $$ExercisesTableAnnotationComposer,
          $$ExercisesTableCreateCompanionBuilder,
          $$ExercisesTableUpdateCompanionBuilder,
          (ExerciseRow, $$ExercisesTableReferences),
          ExerciseRow,
          PrefetchHooks Function({bool routineItemsRefs})
        > {
  $$ExercisesTableTableManager(_$AppDatabase db, $ExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> bodyPart = const Value.absent(),
                Value<String?> subTarget = const Value.absent(),
                Value<String?> equipment = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ExercisesCompanion(
                id: id,
                name: name,
                bodyPart: bodyPart,
                subTarget: subTarget,
                equipment: equipment,
                isCustom: isCustom,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String bodyPart,
                Value<String?> subTarget = const Value.absent(),
                Value<String?> equipment = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ExercisesCompanion.insert(
                id: id,
                name: name,
                bodyPart: bodyPart,
                subTarget: subTarget,
                equipment: equipment,
                isCustom: isCustom,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({routineItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (routineItemsRefs) db.routineItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (routineItemsRefs)
                    await $_getPrefetchedData<
                      ExerciseRow,
                      $ExercisesTable,
                      RoutineItemRow
                    >(
                      currentTable: table,
                      referencedTable: $$ExercisesTableReferences
                          ._routineItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ExercisesTableReferences(
                            db,
                            table,
                            p0,
                          ).routineItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.exerciseId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExercisesTable,
      ExerciseRow,
      $$ExercisesTableFilterComposer,
      $$ExercisesTableOrderingComposer,
      $$ExercisesTableAnnotationComposer,
      $$ExercisesTableCreateCompanionBuilder,
      $$ExercisesTableUpdateCompanionBuilder,
      (ExerciseRow, $$ExercisesTableReferences),
      ExerciseRow,
      PrefetchHooks Function({bool routineItemsRefs})
    >;
typedef $$RoutinesTableCreateCompanionBuilder =
    RoutinesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> description,
      Value<int> sessionMinutes,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$RoutinesTableUpdateCompanionBuilder =
    RoutinesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> description,
      Value<int> sessionMinutes,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$RoutinesTableReferences
    extends BaseReferences<_$AppDatabase, $RoutinesTable, RoutineRow> {
  $$RoutinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RoutineDaysTable, List<RoutineDayRow>>
  _routineDaysRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.routineDays,
    aliasName: 'routines__id__routine_days__routine_id',
  );

  $$RoutineDaysTableProcessedTableManager get routineDaysRefs {
    final manager = $$RoutineDaysTableTableManager(
      $_db,
      $_db.routineDays,
    ).filter((f) => f.routineId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_routineDaysRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoutinesTableFilterComposer
    extends Composer<_$AppDatabase, $RoutinesTable> {
  $$RoutinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessionMinutes => $composableBuilder(
    column: $table.sessionMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> routineDaysRefs(
    Expression<bool> Function($$RoutineDaysTableFilterComposer f) f,
  ) {
    final $$RoutineDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineDays,
      getReferencedColumn: (t) => t.routineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineDaysTableFilterComposer(
            $db: $db,
            $table: $db.routineDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutinesTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutinesTable> {
  $$RoutinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionMinutes => $composableBuilder(
    column: $table.sessionMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoutinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutinesTable> {
  $$RoutinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sessionMinutes => $composableBuilder(
    column: $table.sessionMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> routineDaysRefs<T extends Object>(
    Expression<T> Function($$RoutineDaysTableAnnotationComposer a) f,
  ) {
    final $$RoutineDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineDays,
      getReferencedColumn: (t) => t.routineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.routineDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutinesTable,
          RoutineRow,
          $$RoutinesTableFilterComposer,
          $$RoutinesTableOrderingComposer,
          $$RoutinesTableAnnotationComposer,
          $$RoutinesTableCreateCompanionBuilder,
          $$RoutinesTableUpdateCompanionBuilder,
          (RoutineRow, $$RoutinesTableReferences),
          RoutineRow,
          PrefetchHooks Function({bool routineDaysRefs})
        > {
  $$RoutinesTableTableManager(_$AppDatabase db, $RoutinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> sessionMinutes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => RoutinesCompanion(
                id: id,
                name: name,
                description: description,
                sessionMinutes: sessionMinutes,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                Value<int> sessionMinutes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => RoutinesCompanion.insert(
                id: id,
                name: name,
                description: description,
                sessionMinutes: sessionMinutes,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RoutinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({routineDaysRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (routineDaysRefs) db.routineDays],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (routineDaysRefs)
                    await $_getPrefetchedData<
                      RoutineRow,
                      $RoutinesTable,
                      RoutineDayRow
                    >(
                      currentTable: table,
                      referencedTable: $$RoutinesTableReferences
                          ._routineDaysRefsTable(db),
                      managerFromTypedResult: (p0) => $$RoutinesTableReferences(
                        db,
                        table,
                        p0,
                      ).routineDaysRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.routineId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RoutinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutinesTable,
      RoutineRow,
      $$RoutinesTableFilterComposer,
      $$RoutinesTableOrderingComposer,
      $$RoutinesTableAnnotationComposer,
      $$RoutinesTableCreateCompanionBuilder,
      $$RoutinesTableUpdateCompanionBuilder,
      (RoutineRow, $$RoutinesTableReferences),
      RoutineRow,
      PrefetchHooks Function({bool routineDaysRefs})
    >;
typedef $$RoutineDaysTableCreateCompanionBuilder =
    RoutineDaysCompanion Function({
      Value<int> id,
      required int routineId,
      required int sortOrder,
      required String code,
      required String title,
      Value<String?> subtitle,
      Value<String?> description,
      required String primaryBodyPart,
    });
typedef $$RoutineDaysTableUpdateCompanionBuilder =
    RoutineDaysCompanion Function({
      Value<int> id,
      Value<int> routineId,
      Value<int> sortOrder,
      Value<String> code,
      Value<String> title,
      Value<String?> subtitle,
      Value<String?> description,
      Value<String> primaryBodyPart,
    });

final class $$RoutineDaysTableReferences
    extends BaseReferences<_$AppDatabase, $RoutineDaysTable, RoutineDayRow> {
  $$RoutineDaysTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoutinesTable _routineIdTable(_$AppDatabase db) =>
      db.routines.createAlias('routine_days__routine_id__routines__id');

  $$RoutinesTableProcessedTableManager get routineId {
    final $_column = $_itemColumn<int>('routine_id')!;

    final manager = $$RoutinesTableTableManager(
      $_db,
      $_db.routines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RoutineBlocksTable, List<RoutineBlockRow>>
  _routineBlocksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.routineBlocks,
    aliasName: 'routine_days__id__routine_blocks__day_id',
  );

  $$RoutineBlocksTableProcessedTableManager get routineBlocksRefs {
    final manager = $$RoutineBlocksTableTableManager(
      $_db,
      $_db.routineBlocks,
    ).filter((f) => f.dayId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_routineBlocksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkoutSessionsTable, List<WorkoutSessionRow>>
  _workoutSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workoutSessions,
    aliasName: 'routine_days__id__workout_sessions__day_id',
  );

  $$WorkoutSessionsTableProcessedTableManager get workoutSessionsRefs {
    final manager = $$WorkoutSessionsTableTableManager(
      $_db,
      $_db.workoutSessions,
    ).filter((f) => f.dayId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutSessionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoutineDaysTableFilterComposer
    extends Composer<_$AppDatabase, $RoutineDaysTable> {
  $$RoutineDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryBodyPart => $composableBuilder(
    column: $table.primaryBodyPart,
    builder: (column) => ColumnFilters(column),
  );

  $$RoutinesTableFilterComposer get routineId {
    final $$RoutinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableFilterComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> routineBlocksRefs(
    Expression<bool> Function($$RoutineBlocksTableFilterComposer f) f,
  ) {
    final $$RoutineBlocksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineBlocks,
      getReferencedColumn: (t) => t.dayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineBlocksTableFilterComposer(
            $db: $db,
            $table: $db.routineBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workoutSessionsRefs(
    Expression<bool> Function($$WorkoutSessionsTableFilterComposer f) f,
  ) {
    final $$WorkoutSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.dayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableFilterComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutineDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutineDaysTable> {
  $$RoutineDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryBodyPart => $composableBuilder(
    column: $table.primaryBodyPart,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoutinesTableOrderingComposer get routineId {
    final $$RoutinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableOrderingComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutineDaysTable> {
  $$RoutineDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get subtitle =>
      $composableBuilder(column: $table.subtitle, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get primaryBodyPart => $composableBuilder(
    column: $table.primaryBodyPart,
    builder: (column) => column,
  );

  $$RoutinesTableAnnotationComposer get routineId {
    final $$RoutinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableAnnotationComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> routineBlocksRefs<T extends Object>(
    Expression<T> Function($$RoutineBlocksTableAnnotationComposer a) f,
  ) {
    final $$RoutineBlocksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineBlocks,
      getReferencedColumn: (t) => t.dayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineBlocksTableAnnotationComposer(
            $db: $db,
            $table: $db.routineBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> workoutSessionsRefs<T extends Object>(
    Expression<T> Function($$WorkoutSessionsTableAnnotationComposer a) f,
  ) {
    final $$WorkoutSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.dayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutineDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutineDaysTable,
          RoutineDayRow,
          $$RoutineDaysTableFilterComposer,
          $$RoutineDaysTableOrderingComposer,
          $$RoutineDaysTableAnnotationComposer,
          $$RoutineDaysTableCreateCompanionBuilder,
          $$RoutineDaysTableUpdateCompanionBuilder,
          (RoutineDayRow, $$RoutineDaysTableReferences),
          RoutineDayRow,
          PrefetchHooks Function({
            bool routineId,
            bool routineBlocksRefs,
            bool workoutSessionsRefs,
          })
        > {
  $$RoutineDaysTableTableManager(_$AppDatabase db, $RoutineDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutineDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutineDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> routineId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> subtitle = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> primaryBodyPart = const Value.absent(),
              }) => RoutineDaysCompanion(
                id: id,
                routineId: routineId,
                sortOrder: sortOrder,
                code: code,
                title: title,
                subtitle: subtitle,
                description: description,
                primaryBodyPart: primaryBodyPart,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int routineId,
                required int sortOrder,
                required String code,
                required String title,
                Value<String?> subtitle = const Value.absent(),
                Value<String?> description = const Value.absent(),
                required String primaryBodyPart,
              }) => RoutineDaysCompanion.insert(
                id: id,
                routineId: routineId,
                sortOrder: sortOrder,
                code: code,
                title: title,
                subtitle: subtitle,
                description: description,
                primaryBodyPart: primaryBodyPart,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RoutineDaysTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                routineId = false,
                routineBlocksRefs = false,
                workoutSessionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (routineBlocksRefs) db.routineBlocks,
                    if (workoutSessionsRefs) db.workoutSessions,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (routineId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.routineId,
                                    referencedTable:
                                        $$RoutineDaysTableReferences
                                            ._routineIdTable(db),
                                    referencedColumn:
                                        $$RoutineDaysTableReferences
                                            ._routineIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (routineBlocksRefs)
                        await $_getPrefetchedData<
                          RoutineDayRow,
                          $RoutineDaysTable,
                          RoutineBlockRow
                        >(
                          currentTable: table,
                          referencedTable: $$RoutineDaysTableReferences
                              ._routineBlocksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoutineDaysTableReferences(
                                db,
                                table,
                                p0,
                              ).routineBlocksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.dayId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workoutSessionsRefs)
                        await $_getPrefetchedData<
                          RoutineDayRow,
                          $RoutineDaysTable,
                          WorkoutSessionRow
                        >(
                          currentTable: table,
                          referencedTable: $$RoutineDaysTableReferences
                              ._workoutSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoutineDaysTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutSessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.dayId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RoutineDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutineDaysTable,
      RoutineDayRow,
      $$RoutineDaysTableFilterComposer,
      $$RoutineDaysTableOrderingComposer,
      $$RoutineDaysTableAnnotationComposer,
      $$RoutineDaysTableCreateCompanionBuilder,
      $$RoutineDaysTableUpdateCompanionBuilder,
      (RoutineDayRow, $$RoutineDaysTableReferences),
      RoutineDayRow,
      PrefetchHooks Function({
        bool routineId,
        bool routineBlocksRefs,
        bool workoutSessionsRefs,
      })
    >;
typedef $$RoutineBlocksTableCreateCompanionBuilder =
    RoutineBlocksCompanion Function({
      Value<int> id,
      required int dayId,
      required int sortOrder,
      required String label,
      Value<String?> name,
      Value<String> type,
      Value<int> rounds,
      required int restSeconds,
      Value<int?> targetMinutes,
      Value<bool> isCuttable,
    });
typedef $$RoutineBlocksTableUpdateCompanionBuilder =
    RoutineBlocksCompanion Function({
      Value<int> id,
      Value<int> dayId,
      Value<int> sortOrder,
      Value<String> label,
      Value<String?> name,
      Value<String> type,
      Value<int> rounds,
      Value<int> restSeconds,
      Value<int?> targetMinutes,
      Value<bool> isCuttable,
    });

final class $$RoutineBlocksTableReferences
    extends
        BaseReferences<_$AppDatabase, $RoutineBlocksTable, RoutineBlockRow> {
  $$RoutineBlocksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RoutineDaysTable _dayIdTable(_$AppDatabase db) =>
      db.routineDays.createAlias('routine_blocks__day_id__routine_days__id');

  $$RoutineDaysTableProcessedTableManager get dayId {
    final $_column = $_itemColumn<int>('day_id')!;

    final manager = $$RoutineDaysTableTableManager(
      $_db,
      $_db.routineDays,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dayIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RoutineItemsTable, List<RoutineItemRow>>
  _routineItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.routineItems,
    aliasName: 'routine_blocks__id__routine_items__block_id',
  );

  $$RoutineItemsTableProcessedTableManager get routineItemsRefs {
    final manager = $$RoutineItemsTableTableManager(
      $_db,
      $_db.routineItems,
    ).filter((f) => f.blockId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_routineItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoutineBlocksTableFilterComposer
    extends Composer<_$AppDatabase, $RoutineBlocksTable> {
  $$RoutineBlocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rounds => $composableBuilder(
    column: $table.rounds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetMinutes => $composableBuilder(
    column: $table.targetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCuttable => $composableBuilder(
    column: $table.isCuttable,
    builder: (column) => ColumnFilters(column),
  );

  $$RoutineDaysTableFilterComposer get dayId {
    final $$RoutineDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.routineDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineDaysTableFilterComposer(
            $db: $db,
            $table: $db.routineDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> routineItemsRefs(
    Expression<bool> Function($$RoutineItemsTableFilterComposer f) f,
  ) {
    final $$RoutineItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineItems,
      getReferencedColumn: (t) => t.blockId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineItemsTableFilterComposer(
            $db: $db,
            $table: $db.routineItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutineBlocksTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutineBlocksTable> {
  $$RoutineBlocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rounds => $composableBuilder(
    column: $table.rounds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetMinutes => $composableBuilder(
    column: $table.targetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCuttable => $composableBuilder(
    column: $table.isCuttable,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoutineDaysTableOrderingComposer get dayId {
    final $$RoutineDaysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.routineDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineDaysTableOrderingComposer(
            $db: $db,
            $table: $db.routineDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineBlocksTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutineBlocksTable> {
  $$RoutineBlocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get rounds =>
      $composableBuilder(column: $table.rounds, builder: (column) => column);

  GeneratedColumn<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetMinutes => $composableBuilder(
    column: $table.targetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCuttable => $composableBuilder(
    column: $table.isCuttable,
    builder: (column) => column,
  );

  $$RoutineDaysTableAnnotationComposer get dayId {
    final $$RoutineDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.routineDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.routineDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> routineItemsRefs<T extends Object>(
    Expression<T> Function($$RoutineItemsTableAnnotationComposer a) f,
  ) {
    final $$RoutineItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineItems,
      getReferencedColumn: (t) => t.blockId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.routineItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutineBlocksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutineBlocksTable,
          RoutineBlockRow,
          $$RoutineBlocksTableFilterComposer,
          $$RoutineBlocksTableOrderingComposer,
          $$RoutineBlocksTableAnnotationComposer,
          $$RoutineBlocksTableCreateCompanionBuilder,
          $$RoutineBlocksTableUpdateCompanionBuilder,
          (RoutineBlockRow, $$RoutineBlocksTableReferences),
          RoutineBlockRow,
          PrefetchHooks Function({bool dayId, bool routineItemsRefs})
        > {
  $$RoutineBlocksTableTableManager(_$AppDatabase db, $RoutineBlocksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineBlocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutineBlocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutineBlocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> dayId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> rounds = const Value.absent(),
                Value<int> restSeconds = const Value.absent(),
                Value<int?> targetMinutes = const Value.absent(),
                Value<bool> isCuttable = const Value.absent(),
              }) => RoutineBlocksCompanion(
                id: id,
                dayId: dayId,
                sortOrder: sortOrder,
                label: label,
                name: name,
                type: type,
                rounds: rounds,
                restSeconds: restSeconds,
                targetMinutes: targetMinutes,
                isCuttable: isCuttable,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int dayId,
                required int sortOrder,
                required String label,
                Value<String?> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> rounds = const Value.absent(),
                required int restSeconds,
                Value<int?> targetMinutes = const Value.absent(),
                Value<bool> isCuttable = const Value.absent(),
              }) => RoutineBlocksCompanion.insert(
                id: id,
                dayId: dayId,
                sortOrder: sortOrder,
                label: label,
                name: name,
                type: type,
                rounds: rounds,
                restSeconds: restSeconds,
                targetMinutes: targetMinutes,
                isCuttable: isCuttable,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RoutineBlocksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({dayId = false, routineItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (routineItemsRefs) db.routineItems],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (dayId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.dayId,
                                referencedTable: $$RoutineBlocksTableReferences
                                    ._dayIdTable(db),
                                referencedColumn: $$RoutineBlocksTableReferences
                                    ._dayIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (routineItemsRefs)
                    await $_getPrefetchedData<
                      RoutineBlockRow,
                      $RoutineBlocksTable,
                      RoutineItemRow
                    >(
                      currentTable: table,
                      referencedTable: $$RoutineBlocksTableReferences
                          ._routineItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$RoutineBlocksTableReferences(
                            db,
                            table,
                            p0,
                          ).routineItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.blockId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RoutineBlocksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutineBlocksTable,
      RoutineBlockRow,
      $$RoutineBlocksTableFilterComposer,
      $$RoutineBlocksTableOrderingComposer,
      $$RoutineBlocksTableAnnotationComposer,
      $$RoutineBlocksTableCreateCompanionBuilder,
      $$RoutineBlocksTableUpdateCompanionBuilder,
      (RoutineBlockRow, $$RoutineBlocksTableReferences),
      RoutineBlockRow,
      PrefetchHooks Function({bool dayId, bool routineItemsRefs})
    >;
typedef $$RoutineItemsTableCreateCompanionBuilder =
    RoutineItemsCompanion Function({
      Value<int> id,
      required int blockId,
      required int sortOrder,
      required int exerciseId,
      required int sets,
      Value<String> repMode,
      Value<int?> repMin,
      Value<int?> repMax,
      Value<int?> durationSeconds,
      Value<int?> restSecondsOverride,
      Value<int?> targetRir,
      Value<String?> note,
      Value<String> alternativeExerciseIds,
    });
typedef $$RoutineItemsTableUpdateCompanionBuilder =
    RoutineItemsCompanion Function({
      Value<int> id,
      Value<int> blockId,
      Value<int> sortOrder,
      Value<int> exerciseId,
      Value<int> sets,
      Value<String> repMode,
      Value<int?> repMin,
      Value<int?> repMax,
      Value<int?> durationSeconds,
      Value<int?> restSecondsOverride,
      Value<int?> targetRir,
      Value<String?> note,
      Value<String> alternativeExerciseIds,
    });

final class $$RoutineItemsTableReferences
    extends BaseReferences<_$AppDatabase, $RoutineItemsTable, RoutineItemRow> {
  $$RoutineItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoutineBlocksTable _blockIdTable(_$AppDatabase db) => db.routineBlocks
      .createAlias('routine_items__block_id__routine_blocks__id');

  $$RoutineBlocksTableProcessedTableManager get blockId {
    final $_column = $_itemColumn<int>('block_id')!;

    final manager = $$RoutineBlocksTableTableManager(
      $_db,
      $_db.routineBlocks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_blockIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias('routine_items__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RoutineItemsTableFilterComposer
    extends Composer<_$AppDatabase, $RoutineItemsTable> {
  $$RoutineItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sets => $composableBuilder(
    column: $table.sets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repMode => $composableBuilder(
    column: $table.repMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repMin => $composableBuilder(
    column: $table.repMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repMax => $composableBuilder(
    column: $table.repMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restSecondsOverride => $composableBuilder(
    column: $table.restSecondsOverride,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetRir => $composableBuilder(
    column: $table.targetRir,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alternativeExerciseIds => $composableBuilder(
    column: $table.alternativeExerciseIds,
    builder: (column) => ColumnFilters(column),
  );

  $$RoutineBlocksTableFilterComposer get blockId {
    final $$RoutineBlocksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.blockId,
      referencedTable: $db.routineBlocks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineBlocksTableFilterComposer(
            $db: $db,
            $table: $db.routineBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutineItemsTable> {
  $$RoutineItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sets => $composableBuilder(
    column: $table.sets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repMode => $composableBuilder(
    column: $table.repMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repMin => $composableBuilder(
    column: $table.repMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repMax => $composableBuilder(
    column: $table.repMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restSecondsOverride => $composableBuilder(
    column: $table.restSecondsOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetRir => $composableBuilder(
    column: $table.targetRir,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alternativeExerciseIds => $composableBuilder(
    column: $table.alternativeExerciseIds,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoutineBlocksTableOrderingComposer get blockId {
    final $$RoutineBlocksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.blockId,
      referencedTable: $db.routineBlocks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineBlocksTableOrderingComposer(
            $db: $db,
            $table: $db.routineBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutineItemsTable> {
  $$RoutineItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get sets =>
      $composableBuilder(column: $table.sets, builder: (column) => column);

  GeneratedColumn<String> get repMode =>
      $composableBuilder(column: $table.repMode, builder: (column) => column);

  GeneratedColumn<int> get repMin =>
      $composableBuilder(column: $table.repMin, builder: (column) => column);

  GeneratedColumn<int> get repMax =>
      $composableBuilder(column: $table.repMax, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get restSecondsOverride => $composableBuilder(
    column: $table.restSecondsOverride,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetRir =>
      $composableBuilder(column: $table.targetRir, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get alternativeExerciseIds => $composableBuilder(
    column: $table.alternativeExerciseIds,
    builder: (column) => column,
  );

  $$RoutineBlocksTableAnnotationComposer get blockId {
    final $$RoutineBlocksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.blockId,
      referencedTable: $db.routineBlocks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineBlocksTableAnnotationComposer(
            $db: $db,
            $table: $db.routineBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutineItemsTable,
          RoutineItemRow,
          $$RoutineItemsTableFilterComposer,
          $$RoutineItemsTableOrderingComposer,
          $$RoutineItemsTableAnnotationComposer,
          $$RoutineItemsTableCreateCompanionBuilder,
          $$RoutineItemsTableUpdateCompanionBuilder,
          (RoutineItemRow, $$RoutineItemsTableReferences),
          RoutineItemRow,
          PrefetchHooks Function({bool blockId, bool exerciseId})
        > {
  $$RoutineItemsTableTableManager(_$AppDatabase db, $RoutineItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutineItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutineItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> blockId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> exerciseId = const Value.absent(),
                Value<int> sets = const Value.absent(),
                Value<String> repMode = const Value.absent(),
                Value<int?> repMin = const Value.absent(),
                Value<int?> repMax = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<int?> restSecondsOverride = const Value.absent(),
                Value<int?> targetRir = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> alternativeExerciseIds = const Value.absent(),
              }) => RoutineItemsCompanion(
                id: id,
                blockId: blockId,
                sortOrder: sortOrder,
                exerciseId: exerciseId,
                sets: sets,
                repMode: repMode,
                repMin: repMin,
                repMax: repMax,
                durationSeconds: durationSeconds,
                restSecondsOverride: restSecondsOverride,
                targetRir: targetRir,
                note: note,
                alternativeExerciseIds: alternativeExerciseIds,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int blockId,
                required int sortOrder,
                required int exerciseId,
                required int sets,
                Value<String> repMode = const Value.absent(),
                Value<int?> repMin = const Value.absent(),
                Value<int?> repMax = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<int?> restSecondsOverride = const Value.absent(),
                Value<int?> targetRir = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> alternativeExerciseIds = const Value.absent(),
              }) => RoutineItemsCompanion.insert(
                id: id,
                blockId: blockId,
                sortOrder: sortOrder,
                exerciseId: exerciseId,
                sets: sets,
                repMode: repMode,
                repMin: repMin,
                repMax: repMax,
                durationSeconds: durationSeconds,
                restSecondsOverride: restSecondsOverride,
                targetRir: targetRir,
                note: note,
                alternativeExerciseIds: alternativeExerciseIds,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RoutineItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({blockId = false, exerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (blockId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.blockId,
                                referencedTable: $$RoutineItemsTableReferences
                                    ._blockIdTable(db),
                                referencedColumn: $$RoutineItemsTableReferences
                                    ._blockIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable: $$RoutineItemsTableReferences
                                    ._exerciseIdTable(db),
                                referencedColumn: $$RoutineItemsTableReferences
                                    ._exerciseIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RoutineItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutineItemsTable,
      RoutineItemRow,
      $$RoutineItemsTableFilterComposer,
      $$RoutineItemsTableOrderingComposer,
      $$RoutineItemsTableAnnotationComposer,
      $$RoutineItemsTableCreateCompanionBuilder,
      $$RoutineItemsTableUpdateCompanionBuilder,
      (RoutineItemRow, $$RoutineItemsTableReferences),
      RoutineItemRow,
      PrefetchHooks Function({bool blockId, bool exerciseId})
    >;
typedef $$WorkoutSessionsTableCreateCompanionBuilder =
    WorkoutSessionsCompanion Function({
      Value<int> id,
      required int routineId,
      Value<int?> dayId,
      required String dayCode,
      required String dayTitle,
      required DateTime date,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<String> status,
      Value<String?> memo,
    });
typedef $$WorkoutSessionsTableUpdateCompanionBuilder =
    WorkoutSessionsCompanion Function({
      Value<int> id,
      Value<int> routineId,
      Value<int?> dayId,
      Value<String> dayCode,
      Value<String> dayTitle,
      Value<DateTime> date,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<String> status,
      Value<String?> memo,
    });

final class $$WorkoutSessionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $WorkoutSessionsTable,
          WorkoutSessionRow
        > {
  $$WorkoutSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RoutineDaysTable _dayIdTable(_$AppDatabase db) =>
      db.routineDays.createAlias('workout_sessions__day_id__routine_days__id');

  $$RoutineDaysTableProcessedTableManager? get dayId {
    final $_column = $_itemColumn<int>('day_id');
    if ($_column == null) return null;
    final manager = $$RoutineDaysTableTableManager(
      $_db,
      $_db.routineDays,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dayIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SetLogsTable, List<SetLogRow>> _setLogsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.setLogs,
    aliasName: 'workout_sessions__id__set_logs__session_id',
  );

  $$SetLogsTableProcessedTableManager get setLogsRefs {
    final manager = $$SetLogsTableTableManager(
      $_db,
      $_db.setLogs,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_setLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkoutSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get routineId => $composableBuilder(
    column: $table.routineId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dayCode => $composableBuilder(
    column: $table.dayCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dayTitle => $composableBuilder(
    column: $table.dayTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  $$RoutineDaysTableFilterComposer get dayId {
    final $$RoutineDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.routineDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineDaysTableFilterComposer(
            $db: $db,
            $table: $db.routineDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> setLogsRefs(
    Expression<bool> Function($$SetLogsTableFilterComposer f) f,
  ) {
    final $$SetLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.setLogs,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetLogsTableFilterComposer(
            $db: $db,
            $table: $db.setLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get routineId => $composableBuilder(
    column: $table.routineId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayCode => $composableBuilder(
    column: $table.dayCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayTitle => $composableBuilder(
    column: $table.dayTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoutineDaysTableOrderingComposer get dayId {
    final $$RoutineDaysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.routineDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineDaysTableOrderingComposer(
            $db: $db,
            $table: $db.routineDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get routineId =>
      $composableBuilder(column: $table.routineId, builder: (column) => column);

  GeneratedColumn<String> get dayCode =>
      $composableBuilder(column: $table.dayCode, builder: (column) => column);

  GeneratedColumn<String> get dayTitle =>
      $composableBuilder(column: $table.dayTitle, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  $$RoutineDaysTableAnnotationComposer get dayId {
    final $$RoutineDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.routineDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.routineDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> setLogsRefs<T extends Object>(
    Expression<T> Function($$SetLogsTableAnnotationComposer a) f,
  ) {
    final $$SetLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.setLogs,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.setLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutSessionsTable,
          WorkoutSessionRow,
          $$WorkoutSessionsTableFilterComposer,
          $$WorkoutSessionsTableOrderingComposer,
          $$WorkoutSessionsTableAnnotationComposer,
          $$WorkoutSessionsTableCreateCompanionBuilder,
          $$WorkoutSessionsTableUpdateCompanionBuilder,
          (WorkoutSessionRow, $$WorkoutSessionsTableReferences),
          WorkoutSessionRow,
          PrefetchHooks Function({bool dayId, bool setLogsRefs})
        > {
  $$WorkoutSessionsTableTableManager(
    _$AppDatabase db,
    $WorkoutSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> routineId = const Value.absent(),
                Value<int?> dayId = const Value.absent(),
                Value<String> dayCode = const Value.absent(),
                Value<String> dayTitle = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> memo = const Value.absent(),
              }) => WorkoutSessionsCompanion(
                id: id,
                routineId: routineId,
                dayId: dayId,
                dayCode: dayCode,
                dayTitle: dayTitle,
                date: date,
                startedAt: startedAt,
                endedAt: endedAt,
                status: status,
                memo: memo,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int routineId,
                Value<int?> dayId = const Value.absent(),
                required String dayCode,
                required String dayTitle,
                required DateTime date,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> memo = const Value.absent(),
              }) => WorkoutSessionsCompanion.insert(
                id: id,
                routineId: routineId,
                dayId: dayId,
                dayCode: dayCode,
                dayTitle: dayTitle,
                date: date,
                startedAt: startedAt,
                endedAt: endedAt,
                status: status,
                memo: memo,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkoutSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({dayId = false, setLogsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (setLogsRefs) db.setLogs],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (dayId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.dayId,
                                referencedTable:
                                    $$WorkoutSessionsTableReferences
                                        ._dayIdTable(db),
                                referencedColumn:
                                    $$WorkoutSessionsTableReferences
                                        ._dayIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (setLogsRefs)
                    await $_getPrefetchedData<
                      WorkoutSessionRow,
                      $WorkoutSessionsTable,
                      SetLogRow
                    >(
                      currentTable: table,
                      referencedTable: $$WorkoutSessionsTableReferences
                          ._setLogsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$WorkoutSessionsTableReferences(
                            db,
                            table,
                            p0,
                          ).setLogsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WorkoutSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutSessionsTable,
      WorkoutSessionRow,
      $$WorkoutSessionsTableFilterComposer,
      $$WorkoutSessionsTableOrderingComposer,
      $$WorkoutSessionsTableAnnotationComposer,
      $$WorkoutSessionsTableCreateCompanionBuilder,
      $$WorkoutSessionsTableUpdateCompanionBuilder,
      (WorkoutSessionRow, $$WorkoutSessionsTableReferences),
      WorkoutSessionRow,
      PrefetchHooks Function({bool dayId, bool setLogsRefs})
    >;
typedef $$SetLogsTableCreateCompanionBuilder =
    SetLogsCompanion Function({
      Value<int> id,
      required int sessionId,
      Value<int?> routineItemId,
      required int exerciseId,
      required String exerciseName,
      required String bodyPart,
      required String blockLabel,
      required int itemOrder,
      required int setIndex,
      Value<double?> weight,
      Value<int?> reps,
      Value<int?> durationSeconds,
      Value<int?> rir,
      Value<int?> restSeconds,
      Value<bool> isCompleted,
      required DateTime completedAt,
    });
typedef $$SetLogsTableUpdateCompanionBuilder =
    SetLogsCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<int?> routineItemId,
      Value<int> exerciseId,
      Value<String> exerciseName,
      Value<String> bodyPart,
      Value<String> blockLabel,
      Value<int> itemOrder,
      Value<int> setIndex,
      Value<double?> weight,
      Value<int?> reps,
      Value<int?> durationSeconds,
      Value<int?> rir,
      Value<int?> restSeconds,
      Value<bool> isCompleted,
      Value<DateTime> completedAt,
    });

final class $$SetLogsTableReferences
    extends BaseReferences<_$AppDatabase, $SetLogsTable, SetLogRow> {
  $$SetLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkoutSessionsTable _sessionIdTable(_$AppDatabase db) => db
      .workoutSessions
      .createAlias('set_logs__session_id__workout_sessions__id');

  $$WorkoutSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$WorkoutSessionsTableTableManager(
      $_db,
      $_db.workoutSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SetLogsTableFilterComposer
    extends Composer<_$AppDatabase, $SetLogsTable> {
  $$SetLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get routineItemId => $composableBuilder(
    column: $table.routineItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodyPart => $composableBuilder(
    column: $table.bodyPart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get blockLabel => $composableBuilder(
    column: $table.blockLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemOrder => $composableBuilder(
    column: $table.itemOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get setIndex => $composableBuilder(
    column: $table.setIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rir => $composableBuilder(
    column: $table.rir,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutSessionsTableFilterComposer get sessionId {
    final $$WorkoutSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableFilterComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $SetLogsTable> {
  $$SetLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get routineItemId => $composableBuilder(
    column: $table.routineItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyPart => $composableBuilder(
    column: $table.bodyPart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get blockLabel => $composableBuilder(
    column: $table.blockLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemOrder => $composableBuilder(
    column: $table.itemOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get setIndex => $composableBuilder(
    column: $table.setIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rir => $composableBuilder(
    column: $table.rir,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutSessionsTableOrderingComposer get sessionId {
    final $$WorkoutSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SetLogsTable> {
  $$SetLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get routineItemId => $composableBuilder(
    column: $table.routineItemId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bodyPart =>
      $composableBuilder(column: $table.bodyPart, builder: (column) => column);

  GeneratedColumn<String> get blockLabel => $composableBuilder(
    column: $table.blockLabel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get itemOrder =>
      $composableBuilder(column: $table.itemOrder, builder: (column) => column);

  GeneratedColumn<int> get setIndex =>
      $composableBuilder(column: $table.setIndex, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rir =>
      $composableBuilder(column: $table.rir, builder: (column) => column);

  GeneratedColumn<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  $$WorkoutSessionsTableAnnotationComposer get sessionId {
    final $$WorkoutSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SetLogsTable,
          SetLogRow,
          $$SetLogsTableFilterComposer,
          $$SetLogsTableOrderingComposer,
          $$SetLogsTableAnnotationComposer,
          $$SetLogsTableCreateCompanionBuilder,
          $$SetLogsTableUpdateCompanionBuilder,
          (SetLogRow, $$SetLogsTableReferences),
          SetLogRow,
          PrefetchHooks Function({bool sessionId})
        > {
  $$SetLogsTableTableManager(_$AppDatabase db, $SetLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SetLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SetLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SetLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<int?> routineItemId = const Value.absent(),
                Value<int> exerciseId = const Value.absent(),
                Value<String> exerciseName = const Value.absent(),
                Value<String> bodyPart = const Value.absent(),
                Value<String> blockLabel = const Value.absent(),
                Value<int> itemOrder = const Value.absent(),
                Value<int> setIndex = const Value.absent(),
                Value<double?> weight = const Value.absent(),
                Value<int?> reps = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<int?> rir = const Value.absent(),
                Value<int?> restSeconds = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
              }) => SetLogsCompanion(
                id: id,
                sessionId: sessionId,
                routineItemId: routineItemId,
                exerciseId: exerciseId,
                exerciseName: exerciseName,
                bodyPart: bodyPart,
                blockLabel: blockLabel,
                itemOrder: itemOrder,
                setIndex: setIndex,
                weight: weight,
                reps: reps,
                durationSeconds: durationSeconds,
                rir: rir,
                restSeconds: restSeconds,
                isCompleted: isCompleted,
                completedAt: completedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                Value<int?> routineItemId = const Value.absent(),
                required int exerciseId,
                required String exerciseName,
                required String bodyPart,
                required String blockLabel,
                required int itemOrder,
                required int setIndex,
                Value<double?> weight = const Value.absent(),
                Value<int?> reps = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<int?> rir = const Value.absent(),
                Value<int?> restSeconds = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                required DateTime completedAt,
              }) => SetLogsCompanion.insert(
                id: id,
                sessionId: sessionId,
                routineItemId: routineItemId,
                exerciseId: exerciseId,
                exerciseName: exerciseName,
                bodyPart: bodyPart,
                blockLabel: blockLabel,
                itemOrder: itemOrder,
                setIndex: setIndex,
                weight: weight,
                reps: reps,
                durationSeconds: durationSeconds,
                rir: rir,
                restSeconds: restSeconds,
                isCompleted: isCompleted,
                completedAt: completedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SetLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$SetLogsTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$SetLogsTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SetLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SetLogsTable,
      SetLogRow,
      $$SetLogsTableFilterComposer,
      $$SetLogsTableOrderingComposer,
      $$SetLogsTableAnnotationComposer,
      $$SetLogsTableCreateCompanionBuilder,
      $$SetLogsTableUpdateCompanionBuilder,
      (SetLogRow, $$SetLogsTableReferences),
      SetLogRow,
      PrefetchHooks Function({bool sessionId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db, _db.exercises);
  $$RoutinesTableTableManager get routines =>
      $$RoutinesTableTableManager(_db, _db.routines);
  $$RoutineDaysTableTableManager get routineDays =>
      $$RoutineDaysTableTableManager(_db, _db.routineDays);
  $$RoutineBlocksTableTableManager get routineBlocks =>
      $$RoutineBlocksTableTableManager(_db, _db.routineBlocks);
  $$RoutineItemsTableTableManager get routineItems =>
      $$RoutineItemsTableTableManager(_db, _db.routineItems);
  $$WorkoutSessionsTableTableManager get workoutSessions =>
      $$WorkoutSessionsTableTableManager(_db, _db.workoutSessions);
  $$SetLogsTableTableManager get setLogs =>
      $$SetLogsTableTableManager(_db, _db.setLogs);
}
