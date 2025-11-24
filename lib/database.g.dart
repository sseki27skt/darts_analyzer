// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $GamesTable extends Games with TableInfo<$GamesTable, Game> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GamesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meanXMeta = const VerificationMeta('meanX');
  @override
  late final GeneratedColumn<double> meanX = GeneratedColumn<double>(
    'mean_x',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meanYMeta = const VerificationMeta('meanY');
  @override
  late final GeneratedColumn<double> meanY = GeneratedColumn<double>(
    'mean_y',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sdXMeta = const VerificationMeta('sdX');
  @override
  late final GeneratedColumn<double> sdX = GeneratedColumn<double>(
    'sd_x',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sdYMeta = const VerificationMeta('sdY');
  @override
  late final GeneratedColumn<double> sdY = GeneratedColumn<double>(
    'sd_y',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ringSizeMmMeta = const VerificationMeta(
    'ringSizeMm',
  );
  @override
  late final GeneratedColumn<double> ringSizeMm = GeneratedColumn<double>(
    'ring_size_mm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ringLargeMmMeta = const VerificationMeta(
    'ringLargeMm',
  );
  @override
  late final GeneratedColumn<double> ringLargeMm = GeneratedColumn<double>(
    'ring_large_mm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gameTypeMeta = const VerificationMeta(
    'gameType',
  );
  @override
  late final GeneratedColumn<int> gameType = GeneratedColumn<int>(
    'game_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isMasterOutMeta = const VerificationMeta(
    'isMasterOut',
  );
  @override
  late final GeneratedColumn<bool> isMasterOut = GeneratedColumn<bool>(
    'is_master_out',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_master_out" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    score,
    meanX,
    meanY,
    sdX,
    sdY,
    ringSizeMm,
    ringLargeMm,
    gameType,
    isMasterOut,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'games';
  @override
  VerificationContext validateIntegrity(
    Insertable<Game> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('mean_x')) {
      context.handle(
        _meanXMeta,
        meanX.isAcceptableOrUnknown(data['mean_x']!, _meanXMeta),
      );
    } else if (isInserting) {
      context.missing(_meanXMeta);
    }
    if (data.containsKey('mean_y')) {
      context.handle(
        _meanYMeta,
        meanY.isAcceptableOrUnknown(data['mean_y']!, _meanYMeta),
      );
    } else if (isInserting) {
      context.missing(_meanYMeta);
    }
    if (data.containsKey('sd_x')) {
      context.handle(
        _sdXMeta,
        sdX.isAcceptableOrUnknown(data['sd_x']!, _sdXMeta),
      );
    } else if (isInserting) {
      context.missing(_sdXMeta);
    }
    if (data.containsKey('sd_y')) {
      context.handle(
        _sdYMeta,
        sdY.isAcceptableOrUnknown(data['sd_y']!, _sdYMeta),
      );
    } else if (isInserting) {
      context.missing(_sdYMeta);
    }
    if (data.containsKey('ring_size_mm')) {
      context.handle(
        _ringSizeMmMeta,
        ringSizeMm.isAcceptableOrUnknown(
          data['ring_size_mm']!,
          _ringSizeMmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ringSizeMmMeta);
    }
    if (data.containsKey('ring_large_mm')) {
      context.handle(
        _ringLargeMmMeta,
        ringLargeMm.isAcceptableOrUnknown(
          data['ring_large_mm']!,
          _ringLargeMmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ringLargeMmMeta);
    }
    if (data.containsKey('game_type')) {
      context.handle(
        _gameTypeMeta,
        gameType.isAcceptableOrUnknown(data['game_type']!, _gameTypeMeta),
      );
    }
    if (data.containsKey('is_master_out')) {
      context.handle(
        _isMasterOutMeta,
        isMasterOut.isAcceptableOrUnknown(
          data['is_master_out']!,
          _isMasterOutMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Game map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Game(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      meanX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}mean_x'],
      )!,
      meanY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}mean_y'],
      )!,
      sdX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sd_x'],
      )!,
      sdY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sd_y'],
      )!,
      ringSizeMm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ring_size_mm'],
      )!,
      ringLargeMm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ring_large_mm'],
      )!,
      gameType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_type'],
      )!,
      isMasterOut: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_master_out'],
      )!,
    );
  }

  @override
  $GamesTable createAlias(String alias) {
    return $GamesTable(attachedDatabase, alias);
  }
}

class Game extends DataClass implements Insertable<Game> {
  final int id;
  final DateTime date;
  final int score;
  final double meanX;
  final double meanY;
  final double sdX;
  final double sdY;
  final double ringSizeMm;
  final double ringLargeMm;
  final int gameType;
  final bool isMasterOut;
  const Game({
    required this.id,
    required this.date,
    required this.score,
    required this.meanX,
    required this.meanY,
    required this.sdX,
    required this.sdY,
    required this.ringSizeMm,
    required this.ringLargeMm,
    required this.gameType,
    required this.isMasterOut,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['score'] = Variable<int>(score);
    map['mean_x'] = Variable<double>(meanX);
    map['mean_y'] = Variable<double>(meanY);
    map['sd_x'] = Variable<double>(sdX);
    map['sd_y'] = Variable<double>(sdY);
    map['ring_size_mm'] = Variable<double>(ringSizeMm);
    map['ring_large_mm'] = Variable<double>(ringLargeMm);
    map['game_type'] = Variable<int>(gameType);
    map['is_master_out'] = Variable<bool>(isMasterOut);
    return map;
  }

  GamesCompanion toCompanion(bool nullToAbsent) {
    return GamesCompanion(
      id: Value(id),
      date: Value(date),
      score: Value(score),
      meanX: Value(meanX),
      meanY: Value(meanY),
      sdX: Value(sdX),
      sdY: Value(sdY),
      ringSizeMm: Value(ringSizeMm),
      ringLargeMm: Value(ringLargeMm),
      gameType: Value(gameType),
      isMasterOut: Value(isMasterOut),
    );
  }

  factory Game.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Game(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      score: serializer.fromJson<int>(json['score']),
      meanX: serializer.fromJson<double>(json['meanX']),
      meanY: serializer.fromJson<double>(json['meanY']),
      sdX: serializer.fromJson<double>(json['sdX']),
      sdY: serializer.fromJson<double>(json['sdY']),
      ringSizeMm: serializer.fromJson<double>(json['ringSizeMm']),
      ringLargeMm: serializer.fromJson<double>(json['ringLargeMm']),
      gameType: serializer.fromJson<int>(json['gameType']),
      isMasterOut: serializer.fromJson<bool>(json['isMasterOut']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'score': serializer.toJson<int>(score),
      'meanX': serializer.toJson<double>(meanX),
      'meanY': serializer.toJson<double>(meanY),
      'sdX': serializer.toJson<double>(sdX),
      'sdY': serializer.toJson<double>(sdY),
      'ringSizeMm': serializer.toJson<double>(ringSizeMm),
      'ringLargeMm': serializer.toJson<double>(ringLargeMm),
      'gameType': serializer.toJson<int>(gameType),
      'isMasterOut': serializer.toJson<bool>(isMasterOut),
    };
  }

  Game copyWith({
    int? id,
    DateTime? date,
    int? score,
    double? meanX,
    double? meanY,
    double? sdX,
    double? sdY,
    double? ringSizeMm,
    double? ringLargeMm,
    int? gameType,
    bool? isMasterOut,
  }) => Game(
    id: id ?? this.id,
    date: date ?? this.date,
    score: score ?? this.score,
    meanX: meanX ?? this.meanX,
    meanY: meanY ?? this.meanY,
    sdX: sdX ?? this.sdX,
    sdY: sdY ?? this.sdY,
    ringSizeMm: ringSizeMm ?? this.ringSizeMm,
    ringLargeMm: ringLargeMm ?? this.ringLargeMm,
    gameType: gameType ?? this.gameType,
    isMasterOut: isMasterOut ?? this.isMasterOut,
  );
  Game copyWithCompanion(GamesCompanion data) {
    return Game(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      score: data.score.present ? data.score.value : this.score,
      meanX: data.meanX.present ? data.meanX.value : this.meanX,
      meanY: data.meanY.present ? data.meanY.value : this.meanY,
      sdX: data.sdX.present ? data.sdX.value : this.sdX,
      sdY: data.sdY.present ? data.sdY.value : this.sdY,
      ringSizeMm: data.ringSizeMm.present
          ? data.ringSizeMm.value
          : this.ringSizeMm,
      ringLargeMm: data.ringLargeMm.present
          ? data.ringLargeMm.value
          : this.ringLargeMm,
      gameType: data.gameType.present ? data.gameType.value : this.gameType,
      isMasterOut: data.isMasterOut.present
          ? data.isMasterOut.value
          : this.isMasterOut,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Game(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('score: $score, ')
          ..write('meanX: $meanX, ')
          ..write('meanY: $meanY, ')
          ..write('sdX: $sdX, ')
          ..write('sdY: $sdY, ')
          ..write('ringSizeMm: $ringSizeMm, ')
          ..write('ringLargeMm: $ringLargeMm, ')
          ..write('gameType: $gameType, ')
          ..write('isMasterOut: $isMasterOut')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    score,
    meanX,
    meanY,
    sdX,
    sdY,
    ringSizeMm,
    ringLargeMm,
    gameType,
    isMasterOut,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Game &&
          other.id == this.id &&
          other.date == this.date &&
          other.score == this.score &&
          other.meanX == this.meanX &&
          other.meanY == this.meanY &&
          other.sdX == this.sdX &&
          other.sdY == this.sdY &&
          other.ringSizeMm == this.ringSizeMm &&
          other.ringLargeMm == this.ringLargeMm &&
          other.gameType == this.gameType &&
          other.isMasterOut == this.isMasterOut);
}

class GamesCompanion extends UpdateCompanion<Game> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<int> score;
  final Value<double> meanX;
  final Value<double> meanY;
  final Value<double> sdX;
  final Value<double> sdY;
  final Value<double> ringSizeMm;
  final Value<double> ringLargeMm;
  final Value<int> gameType;
  final Value<bool> isMasterOut;
  const GamesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.score = const Value.absent(),
    this.meanX = const Value.absent(),
    this.meanY = const Value.absent(),
    this.sdX = const Value.absent(),
    this.sdY = const Value.absent(),
    this.ringSizeMm = const Value.absent(),
    this.ringLargeMm = const Value.absent(),
    this.gameType = const Value.absent(),
    this.isMasterOut = const Value.absent(),
  });
  GamesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required int score,
    required double meanX,
    required double meanY,
    required double sdX,
    required double sdY,
    required double ringSizeMm,
    required double ringLargeMm,
    this.gameType = const Value.absent(),
    this.isMasterOut = const Value.absent(),
  }) : date = Value(date),
       score = Value(score),
       meanX = Value(meanX),
       meanY = Value(meanY),
       sdX = Value(sdX),
       sdY = Value(sdY),
       ringSizeMm = Value(ringSizeMm),
       ringLargeMm = Value(ringLargeMm);
  static Insertable<Game> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<int>? score,
    Expression<double>? meanX,
    Expression<double>? meanY,
    Expression<double>? sdX,
    Expression<double>? sdY,
    Expression<double>? ringSizeMm,
    Expression<double>? ringLargeMm,
    Expression<int>? gameType,
    Expression<bool>? isMasterOut,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (score != null) 'score': score,
      if (meanX != null) 'mean_x': meanX,
      if (meanY != null) 'mean_y': meanY,
      if (sdX != null) 'sd_x': sdX,
      if (sdY != null) 'sd_y': sdY,
      if (ringSizeMm != null) 'ring_size_mm': ringSizeMm,
      if (ringLargeMm != null) 'ring_large_mm': ringLargeMm,
      if (gameType != null) 'game_type': gameType,
      if (isMasterOut != null) 'is_master_out': isMasterOut,
    });
  }

  GamesCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<int>? score,
    Value<double>? meanX,
    Value<double>? meanY,
    Value<double>? sdX,
    Value<double>? sdY,
    Value<double>? ringSizeMm,
    Value<double>? ringLargeMm,
    Value<int>? gameType,
    Value<bool>? isMasterOut,
  }) {
    return GamesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      score: score ?? this.score,
      meanX: meanX ?? this.meanX,
      meanY: meanY ?? this.meanY,
      sdX: sdX ?? this.sdX,
      sdY: sdY ?? this.sdY,
      ringSizeMm: ringSizeMm ?? this.ringSizeMm,
      ringLargeMm: ringLargeMm ?? this.ringLargeMm,
      gameType: gameType ?? this.gameType,
      isMasterOut: isMasterOut ?? this.isMasterOut,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (meanX.present) {
      map['mean_x'] = Variable<double>(meanX.value);
    }
    if (meanY.present) {
      map['mean_y'] = Variable<double>(meanY.value);
    }
    if (sdX.present) {
      map['sd_x'] = Variable<double>(sdX.value);
    }
    if (sdY.present) {
      map['sd_y'] = Variable<double>(sdY.value);
    }
    if (ringSizeMm.present) {
      map['ring_size_mm'] = Variable<double>(ringSizeMm.value);
    }
    if (ringLargeMm.present) {
      map['ring_large_mm'] = Variable<double>(ringLargeMm.value);
    }
    if (gameType.present) {
      map['game_type'] = Variable<int>(gameType.value);
    }
    if (isMasterOut.present) {
      map['is_master_out'] = Variable<bool>(isMasterOut.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GamesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('score: $score, ')
          ..write('meanX: $meanX, ')
          ..write('meanY: $meanY, ')
          ..write('sdX: $sdX, ')
          ..write('sdY: $sdY, ')
          ..write('ringSizeMm: $ringSizeMm, ')
          ..write('ringLargeMm: $ringLargeMm, ')
          ..write('gameType: $gameType, ')
          ..write('isMasterOut: $isMasterOut')
          ..write(')'))
        .toString();
  }
}

class $ThrowsTable extends Throws with TableInfo<$ThrowsTable, Throw> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ThrowsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<int> gameId = GeneratedColumn<int>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES games (id)',
    ),
  );
  static const VerificationMeta _xMeta = const VerificationMeta('x');
  @override
  late final GeneratedColumn<double> x = GeneratedColumn<double>(
    'x',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yMeta = const VerificationMeta('y');
  @override
  late final GeneratedColumn<double> y = GeneratedColumn<double>(
    'y',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _segmentLabelMeta = const VerificationMeta(
    'segmentLabel',
  );
  @override
  late final GeneratedColumn<String> segmentLabel = GeneratedColumn<String>(
    'segment_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gameId,
    x,
    y,
    orderIndex,
    segmentLabel,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'throws';
  @override
  VerificationContext validateIntegrity(
    Insertable<Throw> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('x')) {
      context.handle(_xMeta, x.isAcceptableOrUnknown(data['x']!, _xMeta));
    } else if (isInserting) {
      context.missing(_xMeta);
    }
    if (data.containsKey('y')) {
      context.handle(_yMeta, y.isAcceptableOrUnknown(data['y']!, _yMeta));
    } else if (isInserting) {
      context.missing(_yMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('segment_label')) {
      context.handle(
        _segmentLabelMeta,
        segmentLabel.isAcceptableOrUnknown(
          data['segment_label']!,
          _segmentLabelMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Throw map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Throw(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_id'],
      )!,
      x: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}x'],
      )!,
      y: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}y'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      segmentLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}segment_label'],
      )!,
    );
  }

  @override
  $ThrowsTable createAlias(String alias) {
    return $ThrowsTable(attachedDatabase, alias);
  }
}

class Throw extends DataClass implements Insertable<Throw> {
  final int id;
  final int gameId;
  final double x;
  final double y;
  final int orderIndex;
  final String segmentLabel;
  const Throw({
    required this.id,
    required this.gameId,
    required this.x,
    required this.y,
    required this.orderIndex,
    required this.segmentLabel,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['game_id'] = Variable<int>(gameId);
    map['x'] = Variable<double>(x);
    map['y'] = Variable<double>(y);
    map['order_index'] = Variable<int>(orderIndex);
    map['segment_label'] = Variable<String>(segmentLabel);
    return map;
  }

  ThrowsCompanion toCompanion(bool nullToAbsent) {
    return ThrowsCompanion(
      id: Value(id),
      gameId: Value(gameId),
      x: Value(x),
      y: Value(y),
      orderIndex: Value(orderIndex),
      segmentLabel: Value(segmentLabel),
    );
  }

  factory Throw.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Throw(
      id: serializer.fromJson<int>(json['id']),
      gameId: serializer.fromJson<int>(json['gameId']),
      x: serializer.fromJson<double>(json['x']),
      y: serializer.fromJson<double>(json['y']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      segmentLabel: serializer.fromJson<String>(json['segmentLabel']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'gameId': serializer.toJson<int>(gameId),
      'x': serializer.toJson<double>(x),
      'y': serializer.toJson<double>(y),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'segmentLabel': serializer.toJson<String>(segmentLabel),
    };
  }

  Throw copyWith({
    int? id,
    int? gameId,
    double? x,
    double? y,
    int? orderIndex,
    String? segmentLabel,
  }) => Throw(
    id: id ?? this.id,
    gameId: gameId ?? this.gameId,
    x: x ?? this.x,
    y: y ?? this.y,
    orderIndex: orderIndex ?? this.orderIndex,
    segmentLabel: segmentLabel ?? this.segmentLabel,
  );
  Throw copyWithCompanion(ThrowsCompanion data) {
    return Throw(
      id: data.id.present ? data.id.value : this.id,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      x: data.x.present ? data.x.value : this.x,
      y: data.y.present ? data.y.value : this.y,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      segmentLabel: data.segmentLabel.present
          ? data.segmentLabel.value
          : this.segmentLabel,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Throw(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('segmentLabel: $segmentLabel')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, gameId, x, y, orderIndex, segmentLabel);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Throw &&
          other.id == this.id &&
          other.gameId == this.gameId &&
          other.x == this.x &&
          other.y == this.y &&
          other.orderIndex == this.orderIndex &&
          other.segmentLabel == this.segmentLabel);
}

class ThrowsCompanion extends UpdateCompanion<Throw> {
  final Value<int> id;
  final Value<int> gameId;
  final Value<double> x;
  final Value<double> y;
  final Value<int> orderIndex;
  final Value<String> segmentLabel;
  const ThrowsCompanion({
    this.id = const Value.absent(),
    this.gameId = const Value.absent(),
    this.x = const Value.absent(),
    this.y = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.segmentLabel = const Value.absent(),
  });
  ThrowsCompanion.insert({
    this.id = const Value.absent(),
    required int gameId,
    required double x,
    required double y,
    required int orderIndex,
    this.segmentLabel = const Value.absent(),
  }) : gameId = Value(gameId),
       x = Value(x),
       y = Value(y),
       orderIndex = Value(orderIndex);
  static Insertable<Throw> custom({
    Expression<int>? id,
    Expression<int>? gameId,
    Expression<double>? x,
    Expression<double>? y,
    Expression<int>? orderIndex,
    Expression<String>? segmentLabel,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameId != null) 'game_id': gameId,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (orderIndex != null) 'order_index': orderIndex,
      if (segmentLabel != null) 'segment_label': segmentLabel,
    });
  }

  ThrowsCompanion copyWith({
    Value<int>? id,
    Value<int>? gameId,
    Value<double>? x,
    Value<double>? y,
    Value<int>? orderIndex,
    Value<String>? segmentLabel,
  }) {
    return ThrowsCompanion(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      x: x ?? this.x,
      y: y ?? this.y,
      orderIndex: orderIndex ?? this.orderIndex,
      segmentLabel: segmentLabel ?? this.segmentLabel,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<int>(gameId.value);
    }
    if (x.present) {
      map['x'] = Variable<double>(x.value);
    }
    if (y.present) {
      map['y'] = Variable<double>(y.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (segmentLabel.present) {
      map['segment_label'] = Variable<String>(segmentLabel.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ThrowsCompanion(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('segmentLabel: $segmentLabel')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GamesTable games = $GamesTable(this);
  late final $ThrowsTable throws = $ThrowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [games, throws];
}

typedef $$GamesTableCreateCompanionBuilder =
    GamesCompanion Function({
      Value<int> id,
      required DateTime date,
      required int score,
      required double meanX,
      required double meanY,
      required double sdX,
      required double sdY,
      required double ringSizeMm,
      required double ringLargeMm,
      Value<int> gameType,
      Value<bool> isMasterOut,
    });
typedef $$GamesTableUpdateCompanionBuilder =
    GamesCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<int> score,
      Value<double> meanX,
      Value<double> meanY,
      Value<double> sdX,
      Value<double> sdY,
      Value<double> ringSizeMm,
      Value<double> ringLargeMm,
      Value<int> gameType,
      Value<bool> isMasterOut,
    });

final class $$GamesTableReferences
    extends BaseReferences<_$AppDatabase, $GamesTable, Game> {
  $$GamesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ThrowsTable, List<Throw>> _throwsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.throws,
    aliasName: $_aliasNameGenerator(db.games.id, db.throws.gameId),
  );

  $$ThrowsTableProcessedTableManager get throwsRefs {
    final manager = $$ThrowsTableTableManager(
      $_db,
      $_db.throws,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_throwsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GamesTableFilterComposer extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableFilterComposer({
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

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get meanX => $composableBuilder(
    column: $table.meanX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get meanY => $composableBuilder(
    column: $table.meanY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sdX => $composableBuilder(
    column: $table.sdX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sdY => $composableBuilder(
    column: $table.sdY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ringSizeMm => $composableBuilder(
    column: $table.ringSizeMm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ringLargeMm => $composableBuilder(
    column: $table.ringLargeMm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gameType => $composableBuilder(
    column: $table.gameType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMasterOut => $composableBuilder(
    column: $table.isMasterOut,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> throwsRefs(
    Expression<bool> Function($$ThrowsTableFilterComposer f) f,
  ) {
    final $$ThrowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.throws,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ThrowsTableFilterComposer(
            $db: $db,
            $table: $db.throws,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GamesTableOrderingComposer
    extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get meanX => $composableBuilder(
    column: $table.meanX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get meanY => $composableBuilder(
    column: $table.meanY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sdX => $composableBuilder(
    column: $table.sdX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sdY => $composableBuilder(
    column: $table.sdY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ringSizeMm => $composableBuilder(
    column: $table.ringSizeMm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ringLargeMm => $composableBuilder(
    column: $table.ringLargeMm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gameType => $composableBuilder(
    column: $table.gameType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMasterOut => $composableBuilder(
    column: $table.isMasterOut,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GamesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<double> get meanX =>
      $composableBuilder(column: $table.meanX, builder: (column) => column);

  GeneratedColumn<double> get meanY =>
      $composableBuilder(column: $table.meanY, builder: (column) => column);

  GeneratedColumn<double> get sdX =>
      $composableBuilder(column: $table.sdX, builder: (column) => column);

  GeneratedColumn<double> get sdY =>
      $composableBuilder(column: $table.sdY, builder: (column) => column);

  GeneratedColumn<double> get ringSizeMm => $composableBuilder(
    column: $table.ringSizeMm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ringLargeMm => $composableBuilder(
    column: $table.ringLargeMm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get gameType =>
      $composableBuilder(column: $table.gameType, builder: (column) => column);

  GeneratedColumn<bool> get isMasterOut => $composableBuilder(
    column: $table.isMasterOut,
    builder: (column) => column,
  );

  Expression<T> throwsRefs<T extends Object>(
    Expression<T> Function($$ThrowsTableAnnotationComposer a) f,
  ) {
    final $$ThrowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.throws,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ThrowsTableAnnotationComposer(
            $db: $db,
            $table: $db.throws,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GamesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GamesTable,
          Game,
          $$GamesTableFilterComposer,
          $$GamesTableOrderingComposer,
          $$GamesTableAnnotationComposer,
          $$GamesTableCreateCompanionBuilder,
          $$GamesTableUpdateCompanionBuilder,
          (Game, $$GamesTableReferences),
          Game,
          PrefetchHooks Function({bool throwsRefs})
        > {
  $$GamesTableTableManager(_$AppDatabase db, $GamesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GamesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GamesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GamesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<double> meanX = const Value.absent(),
                Value<double> meanY = const Value.absent(),
                Value<double> sdX = const Value.absent(),
                Value<double> sdY = const Value.absent(),
                Value<double> ringSizeMm = const Value.absent(),
                Value<double> ringLargeMm = const Value.absent(),
                Value<int> gameType = const Value.absent(),
                Value<bool> isMasterOut = const Value.absent(),
              }) => GamesCompanion(
                id: id,
                date: date,
                score: score,
                meanX: meanX,
                meanY: meanY,
                sdX: sdX,
                sdY: sdY,
                ringSizeMm: ringSizeMm,
                ringLargeMm: ringLargeMm,
                gameType: gameType,
                isMasterOut: isMasterOut,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required int score,
                required double meanX,
                required double meanY,
                required double sdX,
                required double sdY,
                required double ringSizeMm,
                required double ringLargeMm,
                Value<int> gameType = const Value.absent(),
                Value<bool> isMasterOut = const Value.absent(),
              }) => GamesCompanion.insert(
                id: id,
                date: date,
                score: score,
                meanX: meanX,
                meanY: meanY,
                sdX: sdX,
                sdY: sdY,
                ringSizeMm: ringSizeMm,
                ringLargeMm: ringLargeMm,
                gameType: gameType,
                isMasterOut: isMasterOut,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$GamesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({throwsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (throwsRefs) db.throws],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (throwsRefs)
                    await $_getPrefetchedData<Game, $GamesTable, Throw>(
                      currentTable: table,
                      referencedTable: $$GamesTableReferences._throwsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$GamesTableReferences(db, table, p0).throwsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.gameId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GamesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GamesTable,
      Game,
      $$GamesTableFilterComposer,
      $$GamesTableOrderingComposer,
      $$GamesTableAnnotationComposer,
      $$GamesTableCreateCompanionBuilder,
      $$GamesTableUpdateCompanionBuilder,
      (Game, $$GamesTableReferences),
      Game,
      PrefetchHooks Function({bool throwsRefs})
    >;
typedef $$ThrowsTableCreateCompanionBuilder =
    ThrowsCompanion Function({
      Value<int> id,
      required int gameId,
      required double x,
      required double y,
      required int orderIndex,
      Value<String> segmentLabel,
    });
typedef $$ThrowsTableUpdateCompanionBuilder =
    ThrowsCompanion Function({
      Value<int> id,
      Value<int> gameId,
      Value<double> x,
      Value<double> y,
      Value<int> orderIndex,
      Value<String> segmentLabel,
    });

final class $$ThrowsTableReferences
    extends BaseReferences<_$AppDatabase, $ThrowsTable, Throw> {
  $$ThrowsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GamesTable _gameIdTable(_$AppDatabase db) =>
      db.games.createAlias($_aliasNameGenerator(db.throws.gameId, db.games.id));

  $$GamesTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<int>('game_id')!;

    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ThrowsTableFilterComposer
    extends Composer<_$AppDatabase, $ThrowsTable> {
  $$ThrowsTableFilterComposer({
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

  ColumnFilters<double> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get segmentLabel => $composableBuilder(
    column: $table.segmentLabel,
    builder: (column) => ColumnFilters(column),
  );

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ThrowsTableOrderingComposer
    extends Composer<_$AppDatabase, $ThrowsTable> {
  $$ThrowsTableOrderingComposer({
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

  ColumnOrderings<double> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get segmentLabel => $composableBuilder(
    column: $table.segmentLabel,
    builder: (column) => ColumnOrderings(column),
  );

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ThrowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ThrowsTable> {
  $$ThrowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get x =>
      $composableBuilder(column: $table.x, builder: (column) => column);

  GeneratedColumn<double> get y =>
      $composableBuilder(column: $table.y, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get segmentLabel => $composableBuilder(
    column: $table.segmentLabel,
    builder: (column) => column,
  );

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ThrowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ThrowsTable,
          Throw,
          $$ThrowsTableFilterComposer,
          $$ThrowsTableOrderingComposer,
          $$ThrowsTableAnnotationComposer,
          $$ThrowsTableCreateCompanionBuilder,
          $$ThrowsTableUpdateCompanionBuilder,
          (Throw, $$ThrowsTableReferences),
          Throw,
          PrefetchHooks Function({bool gameId})
        > {
  $$ThrowsTableTableManager(_$AppDatabase db, $ThrowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ThrowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ThrowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ThrowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> gameId = const Value.absent(),
                Value<double> x = const Value.absent(),
                Value<double> y = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<String> segmentLabel = const Value.absent(),
              }) => ThrowsCompanion(
                id: id,
                gameId: gameId,
                x: x,
                y: y,
                orderIndex: orderIndex,
                segmentLabel: segmentLabel,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int gameId,
                required double x,
                required double y,
                required int orderIndex,
                Value<String> segmentLabel = const Value.absent(),
              }) => ThrowsCompanion.insert(
                id: id,
                gameId: gameId,
                x: x,
                y: y,
                orderIndex: orderIndex,
                segmentLabel: segmentLabel,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$ThrowsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({gameId = false}) {
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
                    if (gameId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.gameId,
                                referencedTable: $$ThrowsTableReferences
                                    ._gameIdTable(db),
                                referencedColumn: $$ThrowsTableReferences
                                    ._gameIdTable(db)
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

typedef $$ThrowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ThrowsTable,
      Throw,
      $$ThrowsTableFilterComposer,
      $$ThrowsTableOrderingComposer,
      $$ThrowsTableAnnotationComposer,
      $$ThrowsTableCreateCompanionBuilder,
      $$ThrowsTableUpdateCompanionBuilder,
      (Throw, $$ThrowsTableReferences),
      Throw,
      PrefetchHooks Function({bool gameId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GamesTableTableManager get games =>
      $$GamesTableTableManager(_db, _db.games);
  $$ThrowsTableTableManager get throws =>
      $$ThrowsTableTableManager(_db, _db.throws);
}
