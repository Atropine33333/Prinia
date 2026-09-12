// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts
    with TableInfo<$AccountsTable, AccountRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: genUuid,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: dbNowMs,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => DeviceIdentity.current,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 8,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 16,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<int> occurredAt = GeneratedColumn<int>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: dbNowMs,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: dbNowMs,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuid,
    updatedAt,
    deviceId,
    isDeleted,
    amount,
    type,
    category,
    note,
    occurredAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<AccountRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
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
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  AccountRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountRow(
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurred_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class AccountRow extends DataClass implements Insertable<AccountRow> {
  final String uuid;
  final int updatedAt;
  final String deviceId;
  final bool isDeleted;

  /// 金额恒为正数，收支由 [type] 区分。
  final double amount;

  /// 'income' 或 'expense'
  final String type;

  /// 餐饮/购物/学习/交通/娱乐/医疗/其他
  final String category;
  final String? note;
  final int occurredAt;
  final int createdAt;
  const AccountRow({
    required this.uuid,
    required this.updatedAt,
    required this.deviceId,
    required this.isDeleted,
    required this.amount,
    required this.type,
    required this.category,
    this.note,
    required this.occurredAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['updated_at'] = Variable<int>(updatedAt);
    map['device_id'] = Variable<String>(deviceId);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['amount'] = Variable<double>(amount);
    map['type'] = Variable<String>(type);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['occurred_at'] = Variable<int>(occurredAt);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      uuid: Value(uuid),
      updatedAt: Value(updatedAt),
      deviceId: Value(deviceId),
      isDeleted: Value(isDeleted),
      amount: Value(amount),
      type: Value(type),
      category: Value(category),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      occurredAt: Value(occurredAt),
      createdAt: Value(createdAt),
    );
  }

  factory AccountRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountRow(
      uuid: serializer.fromJson<String>(json['uuid']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      amount: serializer.fromJson<double>(json['amount']),
      type: serializer.fromJson<String>(json['type']),
      category: serializer.fromJson<String>(json['category']),
      note: serializer.fromJson<String?>(json['note']),
      occurredAt: serializer.fromJson<int>(json['occurredAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'amount': serializer.toJson<double>(amount),
      'type': serializer.toJson<String>(type),
      'category': serializer.toJson<String>(category),
      'note': serializer.toJson<String?>(note),
      'occurredAt': serializer.toJson<int>(occurredAt),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  AccountRow copyWith({
    String? uuid,
    int? updatedAt,
    String? deviceId,
    bool? isDeleted,
    double? amount,
    String? type,
    String? category,
    Value<String?> note = const Value.absent(),
    int? occurredAt,
    int? createdAt,
  }) => AccountRow(
    uuid: uuid ?? this.uuid,
    updatedAt: updatedAt ?? this.updatedAt,
    deviceId: deviceId ?? this.deviceId,
    isDeleted: isDeleted ?? this.isDeleted,
    amount: amount ?? this.amount,
    type: type ?? this.type,
    category: category ?? this.category,
    note: note.present ? note.value : this.note,
    occurredAt: occurredAt ?? this.occurredAt,
    createdAt: createdAt ?? this.createdAt,
  );
  AccountRow copyWithCompanion(AccountsCompanion data) {
    return AccountRow(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      amount: data.amount.present ? data.amount.value : this.amount,
      type: data.type.present ? data.type.value : this.type,
      category: data.category.present ? data.category.value : this.category,
      note: data.note.present ? data.note.value : this.note,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountRow(')
          ..write('uuid: $uuid, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('note: $note, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uuid,
    updatedAt,
    deviceId,
    isDeleted,
    amount,
    type,
    category,
    note,
    occurredAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountRow &&
          other.uuid == this.uuid &&
          other.updatedAt == this.updatedAt &&
          other.deviceId == this.deviceId &&
          other.isDeleted == this.isDeleted &&
          other.amount == this.amount &&
          other.type == this.type &&
          other.category == this.category &&
          other.note == this.note &&
          other.occurredAt == this.occurredAt &&
          other.createdAt == this.createdAt);
}

class AccountsCompanion extends UpdateCompanion<AccountRow> {
  final Value<String> uuid;
  final Value<int> updatedAt;
  final Value<String> deviceId;
  final Value<bool> isDeleted;
  final Value<double> amount;
  final Value<String> type;
  final Value<String> category;
  final Value<String?> note;
  final Value<int> occurredAt;
  final Value<int> createdAt;
  final Value<int> rowid;
  const AccountsCompanion({
    this.uuid = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.amount = const Value.absent(),
    this.type = const Value.absent(),
    this.category = const Value.absent(),
    this.note = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    this.uuid = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required double amount,
    required String type,
    required String category,
    this.note = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : amount = Value(amount),
       type = Value(type),
       category = Value(category);
  static Insertable<AccountRow> custom({
    Expression<String>? uuid,
    Expression<int>? updatedAt,
    Expression<String>? deviceId,
    Expression<bool>? isDeleted,
    Expression<double>? amount,
    Expression<String>? type,
    Expression<String>? category,
    Expression<String>? note,
    Expression<int>? occurredAt,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (amount != null) 'amount': amount,
      if (type != null) 'type': type,
      if (category != null) 'category': category,
      if (note != null) 'note': note,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith({
    Value<String>? uuid,
    Value<int>? updatedAt,
    Value<String>? deviceId,
    Value<bool>? isDeleted,
    Value<double>? amount,
    Value<String>? type,
    Value<String>? category,
    Value<String?>? note,
    Value<int>? occurredAt,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return AccountsCompanion(
      uuid: uuid ?? this.uuid,
      updatedAt: updatedAt ?? this.updatedAt,
      deviceId: deviceId ?? this.deviceId,
      isDeleted: isDeleted ?? this.isDeleted,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      note: note ?? this.note,
      occurredAt: occurredAt ?? this.occurredAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<int>(occurredAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('note: $note, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FocusSessionsTable extends FocusSessions
    with TableInfo<$FocusSessionsTable, FocusSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FocusSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: genUuid,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: dbNowMs,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => DeviceIdentity.current,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: () => 0,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<int> startTime = GeneratedColumn<int>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: dbNowMs,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<int> endTime = GeneratedColumn<int>(
    'end_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 16,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuid,
    updatedAt,
    deviceId,
    isDeleted,
    durationSeconds,
    startTime,
    endTime,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'focus_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<FocusSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
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
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  FocusSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FocusSessionRow(
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_time'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $FocusSessionsTable createAlias(String alias) {
    return $FocusSessionsTable(attachedDatabase, alias);
  }
}

class FocusSessionRow extends DataClass implements Insertable<FocusSessionRow> {
  final String uuid;
  final int updatedAt;
  final String deviceId;
  final bool isDeleted;
  final int durationSeconds;
  final int startTime;
  final int endTime;

  /// 'completed' 或 'interrupted'
  final String status;
  const FocusSessionRow({
    required this.uuid,
    required this.updatedAt,
    required this.deviceId,
    required this.isDeleted,
    required this.durationSeconds,
    required this.startTime,
    required this.endTime,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['updated_at'] = Variable<int>(updatedAt);
    map['device_id'] = Variable<String>(deviceId);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['start_time'] = Variable<int>(startTime);
    map['end_time'] = Variable<int>(endTime);
    map['status'] = Variable<String>(status);
    return map;
  }

  FocusSessionsCompanion toCompanion(bool nullToAbsent) {
    return FocusSessionsCompanion(
      uuid: Value(uuid),
      updatedAt: Value(updatedAt),
      deviceId: Value(deviceId),
      isDeleted: Value(isDeleted),
      durationSeconds: Value(durationSeconds),
      startTime: Value(startTime),
      endTime: Value(endTime),
      status: Value(status),
    );
  }

  factory FocusSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FocusSessionRow(
      uuid: serializer.fromJson<String>(json['uuid']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      startTime: serializer.fromJson<int>(json['startTime']),
      endTime: serializer.fromJson<int>(json['endTime']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'startTime': serializer.toJson<int>(startTime),
      'endTime': serializer.toJson<int>(endTime),
      'status': serializer.toJson<String>(status),
    };
  }

  FocusSessionRow copyWith({
    String? uuid,
    int? updatedAt,
    String? deviceId,
    bool? isDeleted,
    int? durationSeconds,
    int? startTime,
    int? endTime,
    String? status,
  }) => FocusSessionRow(
    uuid: uuid ?? this.uuid,
    updatedAt: updatedAt ?? this.updatedAt,
    deviceId: deviceId ?? this.deviceId,
    isDeleted: isDeleted ?? this.isDeleted,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    status: status ?? this.status,
  );
  FocusSessionRow copyWithCompanion(FocusSessionsCompanion data) {
    return FocusSessionRow(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FocusSessionRow(')
          ..write('uuid: $uuid, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uuid,
    updatedAt,
    deviceId,
    isDeleted,
    durationSeconds,
    startTime,
    endTime,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FocusSessionRow &&
          other.uuid == this.uuid &&
          other.updatedAt == this.updatedAt &&
          other.deviceId == this.deviceId &&
          other.isDeleted == this.isDeleted &&
          other.durationSeconds == this.durationSeconds &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.status == this.status);
}

class FocusSessionsCompanion extends UpdateCompanion<FocusSessionRow> {
  final Value<String> uuid;
  final Value<int> updatedAt;
  final Value<String> deviceId;
  final Value<bool> isDeleted;
  final Value<int> durationSeconds;
  final Value<int> startTime;
  final Value<int> endTime;
  final Value<String> status;
  final Value<int> rowid;
  const FocusSessionsCompanion({
    this.uuid = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FocusSessionsCompanion.insert({
    this.uuid = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.startTime = const Value.absent(),
    required int endTime,
    required String status,
    this.rowid = const Value.absent(),
  }) : endTime = Value(endTime),
       status = Value(status);
  static Insertable<FocusSessionRow> custom({
    Expression<String>? uuid,
    Expression<int>? updatedAt,
    Expression<String>? deviceId,
    Expression<bool>? isDeleted,
    Expression<int>? durationSeconds,
    Expression<int>? startTime,
    Expression<int>? endTime,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FocusSessionsCompanion copyWith({
    Value<String>? uuid,
    Value<int>? updatedAt,
    Value<String>? deviceId,
    Value<bool>? isDeleted,
    Value<int>? durationSeconds,
    Value<int>? startTime,
    Value<int>? endTime,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return FocusSessionsCompanion(
      uuid: uuid ?? this.uuid,
      updatedAt: updatedAt ?? this.updatedAt,
      deviceId: deviceId ?? this.deviceId,
      isDeleted: isDeleted ?? this.isDeleted,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<int>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<int>(endTime.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FocusSessionsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CoursesTable extends Courses with TableInfo<$CoursesTable, CourseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoursesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: genUuid,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: dbNowMs,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => DeviceIdentity.current,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teacherMeta = const VerificationMeta(
    'teacher',
  );
  @override
  late final GeneratedColumn<String> teacher = GeneratedColumn<String>(
    'teacher',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roomMeta = const VerificationMeta('room');
  @override
  late final GeneratedColumn<String> room = GeneratedColumn<String>(
    'room',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weekdayMeta = const VerificationMeta(
    'weekday',
  );
  @override
  late final GeneratedColumn<int> weekday = GeneratedColumn<int>(
    'weekday',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startWeekMeta = const VerificationMeta(
    'startWeek',
  );
  @override
  late final GeneratedColumn<int> startWeek = GeneratedColumn<int>(
    'start_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endWeekMeta = const VerificationMeta(
    'endWeek',
  );
  @override
  late final GeneratedColumn<int> endWeek = GeneratedColumn<int>(
    'end_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekParityMeta = const VerificationMeta(
    'weekParity',
  );
  @override
  late final GeneratedColumn<int> weekParity = GeneratedColumn<int>(
    'week_parity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _startMinutesMeta = const VerificationMeta(
    'startMinutes',
  );
  @override
  late final GeneratedColumn<int> startMinutes = GeneratedColumn<int>(
    'start_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: () => 8 * 60,
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: () => 60,
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 7,
      maxTextLength: 9,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#7A9E9F'),
  );
  static const VerificationMeta _remindersJsonMeta = const VerificationMeta(
    'remindersJson',
  );
  @override
  late final GeneratedColumn<String> remindersJson = GeneratedColumn<String>(
    'reminders_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuid,
    updatedAt,
    deviceId,
    isDeleted,
    name,
    teacher,
    room,
    weekday,
    startWeek,
    endWeek,
    weekParity,
    startMinutes,
    durationMinutes,
    colorHex,
    remindersJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'courses';
  @override
  VerificationContext validateIntegrity(
    Insertable<CourseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('teacher')) {
      context.handle(
        _teacherMeta,
        teacher.isAcceptableOrUnknown(data['teacher']!, _teacherMeta),
      );
    }
    if (data.containsKey('room')) {
      context.handle(
        _roomMeta,
        room.isAcceptableOrUnknown(data['room']!, _roomMeta),
      );
    }
    if (data.containsKey('weekday')) {
      context.handle(
        _weekdayMeta,
        weekday.isAcceptableOrUnknown(data['weekday']!, _weekdayMeta),
      );
    } else if (isInserting) {
      context.missing(_weekdayMeta);
    }
    if (data.containsKey('start_week')) {
      context.handle(
        _startWeekMeta,
        startWeek.isAcceptableOrUnknown(data['start_week']!, _startWeekMeta),
      );
    } else if (isInserting) {
      context.missing(_startWeekMeta);
    }
    if (data.containsKey('end_week')) {
      context.handle(
        _endWeekMeta,
        endWeek.isAcceptableOrUnknown(data['end_week']!, _endWeekMeta),
      );
    } else if (isInserting) {
      context.missing(_endWeekMeta);
    }
    if (data.containsKey('week_parity')) {
      context.handle(
        _weekParityMeta,
        weekParity.isAcceptableOrUnknown(data['week_parity']!, _weekParityMeta),
      );
    }
    if (data.containsKey('start_minutes')) {
      context.handle(
        _startMinutesMeta,
        startMinutes.isAcceptableOrUnknown(
          data['start_minutes']!,
          _startMinutesMeta,
        ),
      );
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    }
    if (data.containsKey('reminders_json')) {
      context.handle(
        _remindersJsonMeta,
        remindersJson.isAcceptableOrUnknown(
          data['reminders_json']!,
          _remindersJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  CourseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CourseRow(
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      teacher: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}teacher'],
      ),
      room: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room'],
      ),
      weekday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekday'],
      )!,
      startWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_week'],
      )!,
      endWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_week'],
      )!,
      weekParity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}week_parity'],
      )!,
      startMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_minutes'],
      )!,
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      )!,
      remindersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminders_json'],
      )!,
    );
  }

  @override
  $CoursesTable createAlias(String alias) {
    return $CoursesTable(attachedDatabase, alias);
  }
}

class CourseRow extends DataClass implements Insertable<CourseRow> {
  final String uuid;
  final int updatedAt;
  final String deviceId;
  final bool isDeleted;
  final String name;
  final String? teacher;
  final String? room;

  /// 1~7，周一到周日
  final int weekday;
  final int startWeek;
  final int endWeek;

  /// 单双周：0=每周，1=单周，2=双周
  final int weekParity;

  /// 开始时刻（当日 0 点起的分钟数，15 分钟步进）
  final int startMinutes;

  /// 时长（分钟，15 的倍数）
  final int durationMinutes;
  final String colorHex;

  /// JSON 数组：[{"date":"2025-12-01","text":"交作业"}]
  final String remindersJson;
  const CourseRow({
    required this.uuid,
    required this.updatedAt,
    required this.deviceId,
    required this.isDeleted,
    required this.name,
    this.teacher,
    this.room,
    required this.weekday,
    required this.startWeek,
    required this.endWeek,
    required this.weekParity,
    required this.startMinutes,
    required this.durationMinutes,
    required this.colorHex,
    required this.remindersJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['updated_at'] = Variable<int>(updatedAt);
    map['device_id'] = Variable<String>(deviceId);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || teacher != null) {
      map['teacher'] = Variable<String>(teacher);
    }
    if (!nullToAbsent || room != null) {
      map['room'] = Variable<String>(room);
    }
    map['weekday'] = Variable<int>(weekday);
    map['start_week'] = Variable<int>(startWeek);
    map['end_week'] = Variable<int>(endWeek);
    map['week_parity'] = Variable<int>(weekParity);
    map['start_minutes'] = Variable<int>(startMinutes);
    map['duration_minutes'] = Variable<int>(durationMinutes);
    map['color_hex'] = Variable<String>(colorHex);
    map['reminders_json'] = Variable<String>(remindersJson);
    return map;
  }

  CoursesCompanion toCompanion(bool nullToAbsent) {
    return CoursesCompanion(
      uuid: Value(uuid),
      updatedAt: Value(updatedAt),
      deviceId: Value(deviceId),
      isDeleted: Value(isDeleted),
      name: Value(name),
      teacher: teacher == null && nullToAbsent
          ? const Value.absent()
          : Value(teacher),
      room: room == null && nullToAbsent ? const Value.absent() : Value(room),
      weekday: Value(weekday),
      startWeek: Value(startWeek),
      endWeek: Value(endWeek),
      weekParity: Value(weekParity),
      startMinutes: Value(startMinutes),
      durationMinutes: Value(durationMinutes),
      colorHex: Value(colorHex),
      remindersJson: Value(remindersJson),
    );
  }

  factory CourseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CourseRow(
      uuid: serializer.fromJson<String>(json['uuid']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      name: serializer.fromJson<String>(json['name']),
      teacher: serializer.fromJson<String?>(json['teacher']),
      room: serializer.fromJson<String?>(json['room']),
      weekday: serializer.fromJson<int>(json['weekday']),
      startWeek: serializer.fromJson<int>(json['startWeek']),
      endWeek: serializer.fromJson<int>(json['endWeek']),
      weekParity: serializer.fromJson<int>(json['weekParity']),
      startMinutes: serializer.fromJson<int>(json['startMinutes']),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      remindersJson: serializer.fromJson<String>(json['remindersJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'name': serializer.toJson<String>(name),
      'teacher': serializer.toJson<String?>(teacher),
      'room': serializer.toJson<String?>(room),
      'weekday': serializer.toJson<int>(weekday),
      'startWeek': serializer.toJson<int>(startWeek),
      'endWeek': serializer.toJson<int>(endWeek),
      'weekParity': serializer.toJson<int>(weekParity),
      'startMinutes': serializer.toJson<int>(startMinutes),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
      'colorHex': serializer.toJson<String>(colorHex),
      'remindersJson': serializer.toJson<String>(remindersJson),
    };
  }

  CourseRow copyWith({
    String? uuid,
    int? updatedAt,
    String? deviceId,
    bool? isDeleted,
    String? name,
    Value<String?> teacher = const Value.absent(),
    Value<String?> room = const Value.absent(),
    int? weekday,
    int? startWeek,
    int? endWeek,
    int? weekParity,
    int? startMinutes,
    int? durationMinutes,
    String? colorHex,
    String? remindersJson,
  }) => CourseRow(
    uuid: uuid ?? this.uuid,
    updatedAt: updatedAt ?? this.updatedAt,
    deviceId: deviceId ?? this.deviceId,
    isDeleted: isDeleted ?? this.isDeleted,
    name: name ?? this.name,
    teacher: teacher.present ? teacher.value : this.teacher,
    room: room.present ? room.value : this.room,
    weekday: weekday ?? this.weekday,
    startWeek: startWeek ?? this.startWeek,
    endWeek: endWeek ?? this.endWeek,
    weekParity: weekParity ?? this.weekParity,
    startMinutes: startMinutes ?? this.startMinutes,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    colorHex: colorHex ?? this.colorHex,
    remindersJson: remindersJson ?? this.remindersJson,
  );
  CourseRow copyWithCompanion(CoursesCompanion data) {
    return CourseRow(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      name: data.name.present ? data.name.value : this.name,
      teacher: data.teacher.present ? data.teacher.value : this.teacher,
      room: data.room.present ? data.room.value : this.room,
      weekday: data.weekday.present ? data.weekday.value : this.weekday,
      startWeek: data.startWeek.present ? data.startWeek.value : this.startWeek,
      endWeek: data.endWeek.present ? data.endWeek.value : this.endWeek,
      weekParity: data.weekParity.present
          ? data.weekParity.value
          : this.weekParity,
      startMinutes: data.startMinutes.present
          ? data.startMinutes.value
          : this.startMinutes,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      remindersJson: data.remindersJson.present
          ? data.remindersJson.value
          : this.remindersJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CourseRow(')
          ..write('uuid: $uuid, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('name: $name, ')
          ..write('teacher: $teacher, ')
          ..write('room: $room, ')
          ..write('weekday: $weekday, ')
          ..write('startWeek: $startWeek, ')
          ..write('endWeek: $endWeek, ')
          ..write('weekParity: $weekParity, ')
          ..write('startMinutes: $startMinutes, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('colorHex: $colorHex, ')
          ..write('remindersJson: $remindersJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uuid,
    updatedAt,
    deviceId,
    isDeleted,
    name,
    teacher,
    room,
    weekday,
    startWeek,
    endWeek,
    weekParity,
    startMinutes,
    durationMinutes,
    colorHex,
    remindersJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CourseRow &&
          other.uuid == this.uuid &&
          other.updatedAt == this.updatedAt &&
          other.deviceId == this.deviceId &&
          other.isDeleted == this.isDeleted &&
          other.name == this.name &&
          other.teacher == this.teacher &&
          other.room == this.room &&
          other.weekday == this.weekday &&
          other.startWeek == this.startWeek &&
          other.endWeek == this.endWeek &&
          other.weekParity == this.weekParity &&
          other.startMinutes == this.startMinutes &&
          other.durationMinutes == this.durationMinutes &&
          other.colorHex == this.colorHex &&
          other.remindersJson == this.remindersJson);
}

class CoursesCompanion extends UpdateCompanion<CourseRow> {
  final Value<String> uuid;
  final Value<int> updatedAt;
  final Value<String> deviceId;
  final Value<bool> isDeleted;
  final Value<String> name;
  final Value<String?> teacher;
  final Value<String?> room;
  final Value<int> weekday;
  final Value<int> startWeek;
  final Value<int> endWeek;
  final Value<int> weekParity;
  final Value<int> startMinutes;
  final Value<int> durationMinutes;
  final Value<String> colorHex;
  final Value<String> remindersJson;
  final Value<int> rowid;
  const CoursesCompanion({
    this.uuid = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.name = const Value.absent(),
    this.teacher = const Value.absent(),
    this.room = const Value.absent(),
    this.weekday = const Value.absent(),
    this.startWeek = const Value.absent(),
    this.endWeek = const Value.absent(),
    this.weekParity = const Value.absent(),
    this.startMinutes = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.remindersJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CoursesCompanion.insert({
    this.uuid = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required String name,
    this.teacher = const Value.absent(),
    this.room = const Value.absent(),
    required int weekday,
    required int startWeek,
    required int endWeek,
    this.weekParity = const Value.absent(),
    this.startMinutes = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.remindersJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       weekday = Value(weekday),
       startWeek = Value(startWeek),
       endWeek = Value(endWeek);
  static Insertable<CourseRow> custom({
    Expression<String>? uuid,
    Expression<int>? updatedAt,
    Expression<String>? deviceId,
    Expression<bool>? isDeleted,
    Expression<String>? name,
    Expression<String>? teacher,
    Expression<String>? room,
    Expression<int>? weekday,
    Expression<int>? startWeek,
    Expression<int>? endWeek,
    Expression<int>? weekParity,
    Expression<int>? startMinutes,
    Expression<int>? durationMinutes,
    Expression<String>? colorHex,
    Expression<String>? remindersJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (name != null) 'name': name,
      if (teacher != null) 'teacher': teacher,
      if (room != null) 'room': room,
      if (weekday != null) 'weekday': weekday,
      if (startWeek != null) 'start_week': startWeek,
      if (endWeek != null) 'end_week': endWeek,
      if (weekParity != null) 'week_parity': weekParity,
      if (startMinutes != null) 'start_minutes': startMinutes,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (colorHex != null) 'color_hex': colorHex,
      if (remindersJson != null) 'reminders_json': remindersJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CoursesCompanion copyWith({
    Value<String>? uuid,
    Value<int>? updatedAt,
    Value<String>? deviceId,
    Value<bool>? isDeleted,
    Value<String>? name,
    Value<String?>? teacher,
    Value<String?>? room,
    Value<int>? weekday,
    Value<int>? startWeek,
    Value<int>? endWeek,
    Value<int>? weekParity,
    Value<int>? startMinutes,
    Value<int>? durationMinutes,
    Value<String>? colorHex,
    Value<String>? remindersJson,
    Value<int>? rowid,
  }) {
    return CoursesCompanion(
      uuid: uuid ?? this.uuid,
      updatedAt: updatedAt ?? this.updatedAt,
      deviceId: deviceId ?? this.deviceId,
      isDeleted: isDeleted ?? this.isDeleted,
      name: name ?? this.name,
      teacher: teacher ?? this.teacher,
      room: room ?? this.room,
      weekday: weekday ?? this.weekday,
      startWeek: startWeek ?? this.startWeek,
      endWeek: endWeek ?? this.endWeek,
      weekParity: weekParity ?? this.weekParity,
      startMinutes: startMinutes ?? this.startMinutes,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      colorHex: colorHex ?? this.colorHex,
      remindersJson: remindersJson ?? this.remindersJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (teacher.present) {
      map['teacher'] = Variable<String>(teacher.value);
    }
    if (room.present) {
      map['room'] = Variable<String>(room.value);
    }
    if (weekday.present) {
      map['weekday'] = Variable<int>(weekday.value);
    }
    if (startWeek.present) {
      map['start_week'] = Variable<int>(startWeek.value);
    }
    if (endWeek.present) {
      map['end_week'] = Variable<int>(endWeek.value);
    }
    if (weekParity.present) {
      map['week_parity'] = Variable<int>(weekParity.value);
    }
    if (startMinutes.present) {
      map['start_minutes'] = Variable<int>(startMinutes.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (remindersJson.present) {
      map['reminders_json'] = Variable<String>(remindersJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoursesCompanion(')
          ..write('uuid: $uuid, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('name: $name, ')
          ..write('teacher: $teacher, ')
          ..write('room: $room, ')
          ..write('weekday: $weekday, ')
          ..write('startWeek: $startWeek, ')
          ..write('endWeek: $endWeek, ')
          ..write('weekParity: $weekParity, ')
          ..write('startMinutes: $startMinutes, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('colorHex: $colorHex, ')
          ..write('remindersJson: $remindersJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomCategoriesTable extends CustomCategories
    with TableInfo<$CustomCategoriesTable, CustomCategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: genUuid,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: dbNowMs,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => DeviceIdentity.current,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 16,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconCodeMeta = const VerificationMeta(
    'iconCode',
  );
  @override
  late final GeneratedColumn<int> iconCode = GeneratedColumn<int>(
    'icon_code',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: () => 0xe57f,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 8,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuid,
    updatedAt,
    deviceId,
    isDeleted,
    name,
    iconCode,
    type,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomCategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_code')) {
      context.handle(
        _iconCodeMeta,
        iconCode.isAcceptableOrUnknown(data['icon_code']!, _iconCodeMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  CustomCategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomCategoryRow(
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      iconCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}icon_code'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
    );
  }

  @override
  $CustomCategoriesTable createAlias(String alias) {
    return $CustomCategoriesTable(attachedDatabase, alias);
  }
}

class CustomCategoryRow extends DataClass
    implements Insertable<CustomCategoryRow> {
  final String uuid;
  final int updatedAt;
  final String deviceId;
  final bool isDeleted;
  final String name;

  /// MaterialIcons 码点（来自内置精选目录）。
  final int iconCode;

  /// 'expense' 或 'income'
  final String type;
  const CustomCategoryRow({
    required this.uuid,
    required this.updatedAt,
    required this.deviceId,
    required this.isDeleted,
    required this.name,
    required this.iconCode,
    required this.type,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['updated_at'] = Variable<int>(updatedAt);
    map['device_id'] = Variable<String>(deviceId);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['name'] = Variable<String>(name);
    map['icon_code'] = Variable<int>(iconCode);
    map['type'] = Variable<String>(type);
    return map;
  }

  CustomCategoriesCompanion toCompanion(bool nullToAbsent) {
    return CustomCategoriesCompanion(
      uuid: Value(uuid),
      updatedAt: Value(updatedAt),
      deviceId: Value(deviceId),
      isDeleted: Value(isDeleted),
      name: Value(name),
      iconCode: Value(iconCode),
      type: Value(type),
    );
  }

  factory CustomCategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomCategoryRow(
      uuid: serializer.fromJson<String>(json['uuid']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      name: serializer.fromJson<String>(json['name']),
      iconCode: serializer.fromJson<int>(json['iconCode']),
      type: serializer.fromJson<String>(json['type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'name': serializer.toJson<String>(name),
      'iconCode': serializer.toJson<int>(iconCode),
      'type': serializer.toJson<String>(type),
    };
  }

  CustomCategoryRow copyWith({
    String? uuid,
    int? updatedAt,
    String? deviceId,
    bool? isDeleted,
    String? name,
    int? iconCode,
    String? type,
  }) => CustomCategoryRow(
    uuid: uuid ?? this.uuid,
    updatedAt: updatedAt ?? this.updatedAt,
    deviceId: deviceId ?? this.deviceId,
    isDeleted: isDeleted ?? this.isDeleted,
    name: name ?? this.name,
    iconCode: iconCode ?? this.iconCode,
    type: type ?? this.type,
  );
  CustomCategoryRow copyWithCompanion(CustomCategoriesCompanion data) {
    return CustomCategoryRow(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      name: data.name.present ? data.name.value : this.name,
      iconCode: data.iconCode.present ? data.iconCode.value : this.iconCode,
      type: data.type.present ? data.type.value : this.type,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomCategoryRow(')
          ..write('uuid: $uuid, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('name: $name, ')
          ..write('iconCode: $iconCode, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(uuid, updatedAt, deviceId, isDeleted, name, iconCode, type);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomCategoryRow &&
          other.uuid == this.uuid &&
          other.updatedAt == this.updatedAt &&
          other.deviceId == this.deviceId &&
          other.isDeleted == this.isDeleted &&
          other.name == this.name &&
          other.iconCode == this.iconCode &&
          other.type == this.type);
}

class CustomCategoriesCompanion extends UpdateCompanion<CustomCategoryRow> {
  final Value<String> uuid;
  final Value<int> updatedAt;
  final Value<String> deviceId;
  final Value<bool> isDeleted;
  final Value<String> name;
  final Value<int> iconCode;
  final Value<String> type;
  final Value<int> rowid;
  const CustomCategoriesCompanion({
    this.uuid = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.name = const Value.absent(),
    this.iconCode = const Value.absent(),
    this.type = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomCategoriesCompanion.insert({
    this.uuid = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required String name,
    this.iconCode = const Value.absent(),
    required String type,
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       type = Value(type);
  static Insertable<CustomCategoryRow> custom({
    Expression<String>? uuid,
    Expression<int>? updatedAt,
    Expression<String>? deviceId,
    Expression<bool>? isDeleted,
    Expression<String>? name,
    Expression<int>? iconCode,
    Expression<String>? type,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (name != null) 'name': name,
      if (iconCode != null) 'icon_code': iconCode,
      if (type != null) 'type': type,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomCategoriesCompanion copyWith({
    Value<String>? uuid,
    Value<int>? updatedAt,
    Value<String>? deviceId,
    Value<bool>? isDeleted,
    Value<String>? name,
    Value<int>? iconCode,
    Value<String>? type,
    Value<int>? rowid,
  }) {
    return CustomCategoriesCompanion(
      uuid: uuid ?? this.uuid,
      updatedAt: updatedAt ?? this.updatedAt,
      deviceId: deviceId ?? this.deviceId,
      isDeleted: isDeleted ?? this.isDeleted,
      name: name ?? this.name,
      iconCode: iconCode ?? this.iconCode,
      type: type ?? this.type,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconCode.present) {
      map['icon_code'] = Variable<int>(iconCode.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomCategoriesCompanion(')
          ..write('uuid: $uuid, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('name: $name, ')
          ..write('iconCode: $iconCode, ')
          ..write('type: $type, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppMetaTable extends AppMeta with TableInfo<$AppMetaTable, AppMetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: genUuid,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: dbNowMs,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => DeviceIdentity.current,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _metaKeyMeta = const VerificationMeta(
    'metaKey',
  );
  @override
  late final GeneratedColumn<String> metaKey = GeneratedColumn<String>(
    'meta_key',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metaValueMeta = const VerificationMeta(
    'metaValue',
  );
  @override
  late final GeneratedColumn<String> metaValue = GeneratedColumn<String>(
    'meta_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuid,
    updatedAt,
    deviceId,
    isDeleted,
    metaKey,
    metaValue,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppMetaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('meta_key')) {
      context.handle(
        _metaKeyMeta,
        metaKey.isAcceptableOrUnknown(data['meta_key']!, _metaKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_metaKeyMeta);
    }
    if (data.containsKey('meta_value')) {
      context.handle(
        _metaValueMeta,
        metaValue.isAcceptableOrUnknown(data['meta_value']!, _metaValueMeta),
      );
    } else if (isInserting) {
      context.missing(_metaValueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {metaKey};
  @override
  AppMetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetaRow(
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      metaKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meta_key'],
      )!,
      metaValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meta_value'],
      )!,
    );
  }

  @override
  $AppMetaTable createAlias(String alias) {
    return $AppMetaTable(attachedDatabase, alias);
  }
}

class AppMetaRow extends DataClass implements Insertable<AppMetaRow> {
  final String uuid;
  final int updatedAt;
  final String deviceId;
  final bool isDeleted;
  final String metaKey;
  final String metaValue;
  const AppMetaRow({
    required this.uuid,
    required this.updatedAt,
    required this.deviceId,
    required this.isDeleted,
    required this.metaKey,
    required this.metaValue,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['updated_at'] = Variable<int>(updatedAt);
    map['device_id'] = Variable<String>(deviceId);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['meta_key'] = Variable<String>(metaKey);
    map['meta_value'] = Variable<String>(metaValue);
    return map;
  }

  AppMetaCompanion toCompanion(bool nullToAbsent) {
    return AppMetaCompanion(
      uuid: Value(uuid),
      updatedAt: Value(updatedAt),
      deviceId: Value(deviceId),
      isDeleted: Value(isDeleted),
      metaKey: Value(metaKey),
      metaValue: Value(metaValue),
    );
  }

  factory AppMetaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetaRow(
      uuid: serializer.fromJson<String>(json['uuid']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      metaKey: serializer.fromJson<String>(json['metaKey']),
      metaValue: serializer.fromJson<String>(json['metaValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'metaKey': serializer.toJson<String>(metaKey),
      'metaValue': serializer.toJson<String>(metaValue),
    };
  }

  AppMetaRow copyWith({
    String? uuid,
    int? updatedAt,
    String? deviceId,
    bool? isDeleted,
    String? metaKey,
    String? metaValue,
  }) => AppMetaRow(
    uuid: uuid ?? this.uuid,
    updatedAt: updatedAt ?? this.updatedAt,
    deviceId: deviceId ?? this.deviceId,
    isDeleted: isDeleted ?? this.isDeleted,
    metaKey: metaKey ?? this.metaKey,
    metaValue: metaValue ?? this.metaValue,
  );
  AppMetaRow copyWithCompanion(AppMetaCompanion data) {
    return AppMetaRow(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      metaKey: data.metaKey.present ? data.metaKey.value : this.metaKey,
      metaValue: data.metaValue.present ? data.metaValue.value : this.metaValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaRow(')
          ..write('uuid: $uuid, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('metaKey: $metaKey, ')
          ..write('metaValue: $metaValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(uuid, updatedAt, deviceId, isDeleted, metaKey, metaValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetaRow &&
          other.uuid == this.uuid &&
          other.updatedAt == this.updatedAt &&
          other.deviceId == this.deviceId &&
          other.isDeleted == this.isDeleted &&
          other.metaKey == this.metaKey &&
          other.metaValue == this.metaValue);
}

class AppMetaCompanion extends UpdateCompanion<AppMetaRow> {
  final Value<String> uuid;
  final Value<int> updatedAt;
  final Value<String> deviceId;
  final Value<bool> isDeleted;
  final Value<String> metaKey;
  final Value<String> metaValue;
  final Value<int> rowid;
  const AppMetaCompanion({
    this.uuid = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.metaKey = const Value.absent(),
    this.metaValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetaCompanion.insert({
    this.uuid = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required String metaKey,
    required String metaValue,
    this.rowid = const Value.absent(),
  }) : metaKey = Value(metaKey),
       metaValue = Value(metaValue);
  static Insertable<AppMetaRow> custom({
    Expression<String>? uuid,
    Expression<int>? updatedAt,
    Expression<String>? deviceId,
    Expression<bool>? isDeleted,
    Expression<String>? metaKey,
    Expression<String>? metaValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (metaKey != null) 'meta_key': metaKey,
      if (metaValue != null) 'meta_value': metaValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetaCompanion copyWith({
    Value<String>? uuid,
    Value<int>? updatedAt,
    Value<String>? deviceId,
    Value<bool>? isDeleted,
    Value<String>? metaKey,
    Value<String>? metaValue,
    Value<int>? rowid,
  }) {
    return AppMetaCompanion(
      uuid: uuid ?? this.uuid,
      updatedAt: updatedAt ?? this.updatedAt,
      deviceId: deviceId ?? this.deviceId,
      isDeleted: isDeleted ?? this.isDeleted,
      metaKey: metaKey ?? this.metaKey,
      metaValue: metaValue ?? this.metaValue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (metaKey.present) {
      map['meta_key'] = Variable<String>(metaKey.value);
    }
    if (metaValue.present) {
      map['meta_value'] = Variable<String>(metaValue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaCompanion(')
          ..write('uuid: $uuid, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('metaKey: $metaKey, ')
          ..write('metaValue: $metaValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncPeersTable extends SyncPeers
    with TableInfo<$SyncPeersTable, SyncPeerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncPeersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _peerDeviceIdMeta = const VerificationMeta(
    'peerDeviceId',
  );
  @override
  late final GeneratedColumn<String> peerDeviceId = GeneratedColumn<String>(
    'peer_device_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _peerNameMeta = const VerificationMeta(
    'peerName',
  );
  @override
  late final GeneratedColumn<String> peerName = GeneratedColumn<String>(
    'peer_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncAtMeta = const VerificationMeta(
    'lastSyncAt',
  );
  @override
  late final GeneratedColumn<int> lastSyncAt = GeneratedColumn<int>(
    'last_sync_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [peerDeviceId, peerName, lastSyncAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_peers';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncPeerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('peer_device_id')) {
      context.handle(
        _peerDeviceIdMeta,
        peerDeviceId.isAcceptableOrUnknown(
          data['peer_device_id']!,
          _peerDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_peerDeviceIdMeta);
    }
    if (data.containsKey('peer_name')) {
      context.handle(
        _peerNameMeta,
        peerName.isAcceptableOrUnknown(data['peer_name']!, _peerNameMeta),
      );
    } else if (isInserting) {
      context.missing(_peerNameMeta);
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
        _lastSyncAtMeta,
        lastSyncAt.isAcceptableOrUnknown(
          data['last_sync_at']!,
          _lastSyncAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSyncAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {peerDeviceId};
  @override
  SyncPeerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncPeerRow(
      peerDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}peer_device_id'],
      )!,
      peerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}peer_name'],
      )!,
      lastSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_sync_at'],
      )!,
    );
  }

  @override
  $SyncPeersTable createAlias(String alias) {
    return $SyncPeersTable(attachedDatabase, alias);
  }
}

class SyncPeerRow extends DataClass implements Insertable<SyncPeerRow> {
  final String peerDeviceId;
  final String peerName;
  final int lastSyncAt;
  const SyncPeerRow({
    required this.peerDeviceId,
    required this.peerName,
    required this.lastSyncAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['peer_device_id'] = Variable<String>(peerDeviceId);
    map['peer_name'] = Variable<String>(peerName);
    map['last_sync_at'] = Variable<int>(lastSyncAt);
    return map;
  }

  SyncPeersCompanion toCompanion(bool nullToAbsent) {
    return SyncPeersCompanion(
      peerDeviceId: Value(peerDeviceId),
      peerName: Value(peerName),
      lastSyncAt: Value(lastSyncAt),
    );
  }

  factory SyncPeerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncPeerRow(
      peerDeviceId: serializer.fromJson<String>(json['peerDeviceId']),
      peerName: serializer.fromJson<String>(json['peerName']),
      lastSyncAt: serializer.fromJson<int>(json['lastSyncAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'peerDeviceId': serializer.toJson<String>(peerDeviceId),
      'peerName': serializer.toJson<String>(peerName),
      'lastSyncAt': serializer.toJson<int>(lastSyncAt),
    };
  }

  SyncPeerRow copyWith({
    String? peerDeviceId,
    String? peerName,
    int? lastSyncAt,
  }) => SyncPeerRow(
    peerDeviceId: peerDeviceId ?? this.peerDeviceId,
    peerName: peerName ?? this.peerName,
    lastSyncAt: lastSyncAt ?? this.lastSyncAt,
  );
  SyncPeerRow copyWithCompanion(SyncPeersCompanion data) {
    return SyncPeerRow(
      peerDeviceId: data.peerDeviceId.present
          ? data.peerDeviceId.value
          : this.peerDeviceId,
      peerName: data.peerName.present ? data.peerName.value : this.peerName,
      lastSyncAt: data.lastSyncAt.present
          ? data.lastSyncAt.value
          : this.lastSyncAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncPeerRow(')
          ..write('peerDeviceId: $peerDeviceId, ')
          ..write('peerName: $peerName, ')
          ..write('lastSyncAt: $lastSyncAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(peerDeviceId, peerName, lastSyncAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncPeerRow &&
          other.peerDeviceId == this.peerDeviceId &&
          other.peerName == this.peerName &&
          other.lastSyncAt == this.lastSyncAt);
}

class SyncPeersCompanion extends UpdateCompanion<SyncPeerRow> {
  final Value<String> peerDeviceId;
  final Value<String> peerName;
  final Value<int> lastSyncAt;
  final Value<int> rowid;
  const SyncPeersCompanion({
    this.peerDeviceId = const Value.absent(),
    this.peerName = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncPeersCompanion.insert({
    required String peerDeviceId,
    required String peerName,
    required int lastSyncAt,
    this.rowid = const Value.absent(),
  }) : peerDeviceId = Value(peerDeviceId),
       peerName = Value(peerName),
       lastSyncAt = Value(lastSyncAt);
  static Insertable<SyncPeerRow> custom({
    Expression<String>? peerDeviceId,
    Expression<String>? peerName,
    Expression<int>? lastSyncAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (peerDeviceId != null) 'peer_device_id': peerDeviceId,
      if (peerName != null) 'peer_name': peerName,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncPeersCompanion copyWith({
    Value<String>? peerDeviceId,
    Value<String>? peerName,
    Value<int>? lastSyncAt,
    Value<int>? rowid,
  }) {
    return SyncPeersCompanion(
      peerDeviceId: peerDeviceId ?? this.peerDeviceId,
      peerName: peerName ?? this.peerName,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (peerDeviceId.present) {
      map['peer_device_id'] = Variable<String>(peerDeviceId.value);
    }
    if (peerName.present) {
      map['peer_name'] = Variable<String>(peerName.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<int>(lastSyncAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncPeersCompanion(')
          ..write('peerDeviceId: $peerDeviceId, ')
          ..write('peerName: $peerName, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $FocusSessionsTable focusSessions = $FocusSessionsTable(this);
  late final $CoursesTable courses = $CoursesTable(this);
  late final $CustomCategoriesTable customCategories = $CustomCategoriesTable(
    this,
  );
  late final $AppMetaTable appMeta = $AppMetaTable(this);
  late final $SyncPeersTable syncPeers = $SyncPeersTable(this);
  late final Index idxAccountsOccurred = Index(
    'idx_accounts_occurred',
    'CREATE INDEX idx_accounts_occurred ON accounts (occurred_at)',
  );
  late final Index idxFocusStart = Index(
    'idx_focus_start',
    'CREATE INDEX idx_focus_start ON focus_sessions (start_time)',
  );
  late final Index idxCoursesWeekday = Index(
    'idx_courses_weekday',
    'CREATE INDEX idx_courses_weekday ON courses (weekday)',
  );
  late final Index idxCustomCatType = Index(
    'idx_custom_cat_type',
    'CREATE INDEX idx_custom_cat_type ON custom_categories (type)',
  );
  late final AccountsDao accountsDao = AccountsDao(this as AppDatabase);
  late final FocusSessionsDao focusSessionsDao = FocusSessionsDao(
    this as AppDatabase,
  );
  late final CoursesDao coursesDao = CoursesDao(this as AppDatabase);
  late final CustomCategoriesDao customCategoriesDao = CustomCategoriesDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    accounts,
    focusSessions,
    courses,
    customCategories,
    appMeta,
    syncPeers,
    idxAccountsOccurred,
    idxFocusStart,
    idxCoursesWeekday,
    idxCustomCatType,
  ];
}

typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  Value<String> uuid,
  Value<int> updatedAt,
  Value<String> deviceId,
  Value<bool> isDeleted,
  required double amount,
  required String type,
  required String category,
  Value<String?> note,
  Value<int> occurredAt,
  Value<int> createdAt,
  Value<int> rowid,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<String> uuid,
  Value<int> updatedAt,
  Value<String> deviceId,
  Value<bool> isDeleted,
  Value<double> amount,
  Value<String> type,
  Value<String> category,
  Value<String?> note,
  Value<int> occurredAt,
  Value<int> createdAt,
  Value<int> rowid,
});

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountsTable,
          AccountRow,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (
            AccountRow,
            BaseReferences<_$AppDatabase, $AccountsTable, AccountRow>,
          ),
          AccountRow,
          PrefetchHooks Function()
        > {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> occurredAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion(
                uuid: uuid,
                updatedAt: updatedAt,
                deviceId: deviceId,
                isDeleted: isDeleted,
                amount: amount,
                type: type,
                category: category,
                note: note,
                occurredAt: occurredAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required double amount,
                required String type,
                required String category,
                Value<String?> note = const Value.absent(),
                Value<int> occurredAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion.insert(
                uuid: uuid,
                updatedAt: updatedAt,
                deviceId: deviceId,
                isDeleted: isDeleted,
                amount: amount,
                type: type,
                category: category,
                note: note,
                occurredAt: occurredAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountsTable,
      AccountRow,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (AccountRow, BaseReferences<_$AppDatabase, $AccountsTable, AccountRow>),
      AccountRow,
      PrefetchHooks Function()
    >;
typedef $$FocusSessionsTableCreateCompanionBuilder =
    FocusSessionsCompanion Function({
      Value<String> uuid,
      Value<int> updatedAt,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<int> durationSeconds,
      Value<int> startTime,
      required int endTime,
      required String status,
      Value<int> rowid,
    });
typedef $$FocusSessionsTableUpdateCompanionBuilder =
    FocusSessionsCompanion Function({
      Value<String> uuid,
      Value<int> updatedAt,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<int> durationSeconds,
      Value<int> startTime,
      Value<int> endTime,
      Value<String> status,
      Value<int> rowid,
    });

class $$FocusSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FocusSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FocusSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<int> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$FocusSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FocusSessionsTable,
          FocusSessionRow,
          $$FocusSessionsTableFilterComposer,
          $$FocusSessionsTableOrderingComposer,
          $$FocusSessionsTableAnnotationComposer,
          $$FocusSessionsTableCreateCompanionBuilder,
          $$FocusSessionsTableUpdateCompanionBuilder,
          (
            FocusSessionRow,
            BaseReferences<_$AppDatabase, $FocusSessionsTable, FocusSessionRow>,
          ),
          FocusSessionRow,
          PrefetchHooks Function()
        > {
  $$FocusSessionsTableTableManager(_$AppDatabase db, $FocusSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FocusSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FocusSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FocusSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<int> startTime = const Value.absent(),
                Value<int> endTime = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FocusSessionsCompanion(
                uuid: uuid,
                updatedAt: updatedAt,
                deviceId: deviceId,
                isDeleted: isDeleted,
                durationSeconds: durationSeconds,
                startTime: startTime,
                endTime: endTime,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<int> startTime = const Value.absent(),
                required int endTime,
                required String status,
                Value<int> rowid = const Value.absent(),
              }) => FocusSessionsCompanion.insert(
                uuid: uuid,
                updatedAt: updatedAt,
                deviceId: deviceId,
                isDeleted: isDeleted,
                durationSeconds: durationSeconds,
                startTime: startTime,
                endTime: endTime,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FocusSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FocusSessionsTable,
      FocusSessionRow,
      $$FocusSessionsTableFilterComposer,
      $$FocusSessionsTableOrderingComposer,
      $$FocusSessionsTableAnnotationComposer,
      $$FocusSessionsTableCreateCompanionBuilder,
      $$FocusSessionsTableUpdateCompanionBuilder,
      (
        FocusSessionRow,
        BaseReferences<_$AppDatabase, $FocusSessionsTable, FocusSessionRow>,
      ),
      FocusSessionRow,
      PrefetchHooks Function()
    >;
typedef $$CoursesTableCreateCompanionBuilder = CoursesCompanion Function({
  Value<String> uuid,
  Value<int> updatedAt,
  Value<String> deviceId,
  Value<bool> isDeleted,
  required String name,
  Value<String?> teacher,
  Value<String?> room,
  required int weekday,
  required int startWeek,
  required int endWeek,
  Value<int> weekParity,
  Value<int> startMinutes,
  Value<int> durationMinutes,
  Value<String> colorHex,
  Value<String> remindersJson,
  Value<int> rowid,
});
typedef $$CoursesTableUpdateCompanionBuilder = CoursesCompanion Function({
  Value<String> uuid,
  Value<int> updatedAt,
  Value<String> deviceId,
  Value<bool> isDeleted,
  Value<String> name,
  Value<String?> teacher,
  Value<String?> room,
  Value<int> weekday,
  Value<int> startWeek,
  Value<int> endWeek,
  Value<int> weekParity,
  Value<int> startMinutes,
  Value<int> durationMinutes,
  Value<String> colorHex,
  Value<String> remindersJson,
  Value<int> rowid,
});

class $$CoursesTableFilterComposer
    extends Composer<_$AppDatabase, $CoursesTable> {
  $$CoursesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teacher => $composableBuilder(
    column: $table.teacher,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get room => $composableBuilder(
    column: $table.room,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startWeek => $composableBuilder(
    column: $table.startWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endWeek => $composableBuilder(
    column: $table.endWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekParity => $composableBuilder(
    column: $table.weekParity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remindersJson => $composableBuilder(
    column: $table.remindersJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CoursesTableOrderingComposer
    extends Composer<_$AppDatabase, $CoursesTable> {
  $$CoursesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teacher => $composableBuilder(
    column: $table.teacher,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get room => $composableBuilder(
    column: $table.room,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startWeek => $composableBuilder(
    column: $table.startWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endWeek => $composableBuilder(
    column: $table.endWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekParity => $composableBuilder(
    column: $table.weekParity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remindersJson => $composableBuilder(
    column: $table.remindersJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CoursesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CoursesTable> {
  $$CoursesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get teacher =>
      $composableBuilder(column: $table.teacher, builder: (column) => column);

  GeneratedColumn<String> get room =>
      $composableBuilder(column: $table.room, builder: (column) => column);

  GeneratedColumn<int> get weekday =>
      $composableBuilder(column: $table.weekday, builder: (column) => column);

  GeneratedColumn<int> get startWeek =>
      $composableBuilder(column: $table.startWeek, builder: (column) => column);

  GeneratedColumn<int> get endWeek =>
      $composableBuilder(column: $table.endWeek, builder: (column) => column);

  GeneratedColumn<int> get weekParity => $composableBuilder(
    column: $table.weekParity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<String> get remindersJson => $composableBuilder(
    column: $table.remindersJson,
    builder: (column) => column,
  );
}

class $$CoursesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CoursesTable,
          CourseRow,
          $$CoursesTableFilterComposer,
          $$CoursesTableOrderingComposer,
          $$CoursesTableAnnotationComposer,
          $$CoursesTableCreateCompanionBuilder,
          $$CoursesTableUpdateCompanionBuilder,
          (CourseRow, BaseReferences<_$AppDatabase, $CoursesTable, CourseRow>),
          CourseRow,
          PrefetchHooks Function()
        > {
  $$CoursesTableTableManager(_$AppDatabase db, $CoursesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CoursesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CoursesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CoursesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> teacher = const Value.absent(),
                Value<String?> room = const Value.absent(),
                Value<int> weekday = const Value.absent(),
                Value<int> startWeek = const Value.absent(),
                Value<int> endWeek = const Value.absent(),
                Value<int> weekParity = const Value.absent(),
                Value<int> startMinutes = const Value.absent(),
                Value<int> durationMinutes = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<String> remindersJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CoursesCompanion(
                uuid: uuid,
                updatedAt: updatedAt,
                deviceId: deviceId,
                isDeleted: isDeleted,
                name: name,
                teacher: teacher,
                room: room,
                weekday: weekday,
                startWeek: startWeek,
                endWeek: endWeek,
                weekParity: weekParity,
                startMinutes: startMinutes,
                durationMinutes: durationMinutes,
                colorHex: colorHex,
                remindersJson: remindersJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required String name,
                Value<String?> teacher = const Value.absent(),
                Value<String?> room = const Value.absent(),
                required int weekday,
                required int startWeek,
                required int endWeek,
                Value<int> weekParity = const Value.absent(),
                Value<int> startMinutes = const Value.absent(),
                Value<int> durationMinutes = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<String> remindersJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CoursesCompanion.insert(
                uuid: uuid,
                updatedAt: updatedAt,
                deviceId: deviceId,
                isDeleted: isDeleted,
                name: name,
                teacher: teacher,
                room: room,
                weekday: weekday,
                startWeek: startWeek,
                endWeek: endWeek,
                weekParity: weekParity,
                startMinutes: startMinutes,
                durationMinutes: durationMinutes,
                colorHex: colorHex,
                remindersJson: remindersJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CoursesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CoursesTable,
      CourseRow,
      $$CoursesTableFilterComposer,
      $$CoursesTableOrderingComposer,
      $$CoursesTableAnnotationComposer,
      $$CoursesTableCreateCompanionBuilder,
      $$CoursesTableUpdateCompanionBuilder,
      (CourseRow, BaseReferences<_$AppDatabase, $CoursesTable, CourseRow>),
      CourseRow,
      PrefetchHooks Function()
    >;
typedef $$CustomCategoriesTableCreateCompanionBuilder =
    CustomCategoriesCompanion Function({
      Value<String> uuid,
      Value<int> updatedAt,
      Value<String> deviceId,
      Value<bool> isDeleted,
      required String name,
      Value<int> iconCode,
      required String type,
      Value<int> rowid,
    });
typedef $$CustomCategoriesTableUpdateCompanionBuilder =
    CustomCategoriesCompanion Function({
      Value<String> uuid,
      Value<int> updatedAt,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<String> name,
      Value<int> iconCode,
      Value<String> type,
      Value<int> rowid,
    });

class $$CustomCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CustomCategoriesTable> {
  $$CustomCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iconCode => $composableBuilder(
    column: $table.iconCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomCategoriesTable> {
  $$CustomCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iconCode => $composableBuilder(
    column: $table.iconCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomCategoriesTable> {
  $$CustomCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get iconCode =>
      $composableBuilder(column: $table.iconCode, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);
}

class $$CustomCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomCategoriesTable,
          CustomCategoryRow,
          $$CustomCategoriesTableFilterComposer,
          $$CustomCategoriesTableOrderingComposer,
          $$CustomCategoriesTableAnnotationComposer,
          $$CustomCategoriesTableCreateCompanionBuilder,
          $$CustomCategoriesTableUpdateCompanionBuilder,
          (
            CustomCategoryRow,
            BaseReferences<
              _$AppDatabase,
              $CustomCategoriesTable,
              CustomCategoryRow
            >,
          ),
          CustomCategoryRow,
          PrefetchHooks Function()
        > {
  $$CustomCategoriesTableTableManager(
    _$AppDatabase db,
    $CustomCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> iconCode = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomCategoriesCompanion(
                uuid: uuid,
                updatedAt: updatedAt,
                deviceId: deviceId,
                isDeleted: isDeleted,
                name: name,
                iconCode: iconCode,
                type: type,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required String name,
                Value<int> iconCode = const Value.absent(),
                required String type,
                Value<int> rowid = const Value.absent(),
              }) => CustomCategoriesCompanion.insert(
                uuid: uuid,
                updatedAt: updatedAt,
                deviceId: deviceId,
                isDeleted: isDeleted,
                name: name,
                iconCode: iconCode,
                type: type,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomCategoriesTable,
      CustomCategoryRow,
      $$CustomCategoriesTableFilterComposer,
      $$CustomCategoriesTableOrderingComposer,
      $$CustomCategoriesTableAnnotationComposer,
      $$CustomCategoriesTableCreateCompanionBuilder,
      $$CustomCategoriesTableUpdateCompanionBuilder,
      (
        CustomCategoryRow,
        BaseReferences<
          _$AppDatabase,
          $CustomCategoriesTable,
          CustomCategoryRow
        >,
      ),
      CustomCategoryRow,
      PrefetchHooks Function()
    >;
typedef $$AppMetaTableCreateCompanionBuilder = AppMetaCompanion Function({
  Value<String> uuid,
  Value<int> updatedAt,
  Value<String> deviceId,
  Value<bool> isDeleted,
  required String metaKey,
  required String metaValue,
  Value<int> rowid,
});
typedef $$AppMetaTableUpdateCompanionBuilder = AppMetaCompanion Function({
  Value<String> uuid,
  Value<int> updatedAt,
  Value<String> deviceId,
  Value<bool> isDeleted,
  Value<String> metaKey,
  Value<String> metaValue,
  Value<int> rowid,
});

class $$AppMetaTableFilterComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metaKey => $composableBuilder(
    column: $table.metaKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metaValue => $composableBuilder(
    column: $table.metaValue,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metaKey => $composableBuilder(
    column: $table.metaKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metaValue => $composableBuilder(
    column: $table.metaValue,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get metaKey =>
      $composableBuilder(column: $table.metaKey, builder: (column) => column);

  GeneratedColumn<String> get metaValue =>
      $composableBuilder(column: $table.metaValue, builder: (column) => column);
}

class $$AppMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppMetaTable,
          AppMetaRow,
          $$AppMetaTableFilterComposer,
          $$AppMetaTableOrderingComposer,
          $$AppMetaTableAnnotationComposer,
          $$AppMetaTableCreateCompanionBuilder,
          $$AppMetaTableUpdateCompanionBuilder,
          (
            AppMetaRow,
            BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaRow>,
          ),
          AppMetaRow,
          PrefetchHooks Function()
        > {
  $$AppMetaTableTableManager(_$AppDatabase db, $AppMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> metaKey = const Value.absent(),
                Value<String> metaValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppMetaCompanion(
                uuid: uuid,
                updatedAt: updatedAt,
                deviceId: deviceId,
                isDeleted: isDeleted,
                metaKey: metaKey,
                metaValue: metaValue,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required String metaKey,
                required String metaValue,
                Value<int> rowid = const Value.absent(),
              }) => AppMetaCompanion.insert(
                uuid: uuid,
                updatedAt: updatedAt,
                deviceId: deviceId,
                isDeleted: isDeleted,
                metaKey: metaKey,
                metaValue: metaValue,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppMetaTable,
      AppMetaRow,
      $$AppMetaTableFilterComposer,
      $$AppMetaTableOrderingComposer,
      $$AppMetaTableAnnotationComposer,
      $$AppMetaTableCreateCompanionBuilder,
      $$AppMetaTableUpdateCompanionBuilder,
      (AppMetaRow, BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaRow>),
      AppMetaRow,
      PrefetchHooks Function()
    >;
typedef $$SyncPeersTableCreateCompanionBuilder = SyncPeersCompanion Function({
  required String peerDeviceId,
  required String peerName,
  required int lastSyncAt,
  Value<int> rowid,
});
typedef $$SyncPeersTableUpdateCompanionBuilder = SyncPeersCompanion Function({
  Value<String> peerDeviceId,
  Value<String> peerName,
  Value<int> lastSyncAt,
  Value<int> rowid,
});

class $$SyncPeersTableFilterComposer
    extends Composer<_$AppDatabase, $SyncPeersTable> {
  $$SyncPeersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get peerDeviceId => $composableBuilder(
    column: $table.peerDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get peerName => $composableBuilder(
    column: $table.peerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncPeersTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncPeersTable> {
  $$SyncPeersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get peerDeviceId => $composableBuilder(
    column: $table.peerDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get peerName => $composableBuilder(
    column: $table.peerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncPeersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncPeersTable> {
  $$SyncPeersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get peerDeviceId => $composableBuilder(
    column: $table.peerDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get peerName =>
      $composableBuilder(column: $table.peerName, builder: (column) => column);

  GeneratedColumn<int> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => column,
  );
}

class $$SyncPeersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncPeersTable,
          SyncPeerRow,
          $$SyncPeersTableFilterComposer,
          $$SyncPeersTableOrderingComposer,
          $$SyncPeersTableAnnotationComposer,
          $$SyncPeersTableCreateCompanionBuilder,
          $$SyncPeersTableUpdateCompanionBuilder,
          (
            SyncPeerRow,
            BaseReferences<_$AppDatabase, $SyncPeersTable, SyncPeerRow>,
          ),
          SyncPeerRow,
          PrefetchHooks Function()
        > {
  $$SyncPeersTableTableManager(_$AppDatabase db, $SyncPeersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncPeersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncPeersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncPeersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> peerDeviceId = const Value.absent(),
                Value<String> peerName = const Value.absent(),
                Value<int> lastSyncAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncPeersCompanion(
                peerDeviceId: peerDeviceId,
                peerName: peerName,
                lastSyncAt: lastSyncAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String peerDeviceId,
                required String peerName,
                required int lastSyncAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncPeersCompanion.insert(
                peerDeviceId: peerDeviceId,
                peerName: peerName,
                lastSyncAt: lastSyncAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncPeersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncPeersTable,
      SyncPeerRow,
      $$SyncPeersTableFilterComposer,
      $$SyncPeersTableOrderingComposer,
      $$SyncPeersTableAnnotationComposer,
      $$SyncPeersTableCreateCompanionBuilder,
      $$SyncPeersTableUpdateCompanionBuilder,
      (
        SyncPeerRow,
        BaseReferences<_$AppDatabase, $SyncPeersTable, SyncPeerRow>,
      ),
      SyncPeerRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$FocusSessionsTableTableManager get focusSessions =>
      $$FocusSessionsTableTableManager(_db, _db.focusSessions);
  $$CoursesTableTableManager get courses =>
      $$CoursesTableTableManager(_db, _db.courses);
  $$CustomCategoriesTableTableManager get customCategories =>
      $$CustomCategoriesTableTableManager(_db, _db.customCategories);
  $$AppMetaTableTableManager get appMeta =>
      $$AppMetaTableTableManager(_db, _db.appMeta);
  $$SyncPeersTableTableManager get syncPeers =>
      $$SyncPeersTableTableManager(_db, _db.syncPeers);
}
