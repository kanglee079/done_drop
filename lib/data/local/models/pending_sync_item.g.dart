// GENERATED CODE - DO NOT MODIFY BY HAND
// This is a simplified manually-written Isar generated file.
// Run `dart run build_runner build` to regenerate properly.

part of 'pending_sync_item.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_this, cascade_invocations, lines_longer_than_80_chars

extension GetPendingSyncItemCollection on Isar {
  IsarCollection<PendingSyncItem> get pendingSyncItems => this.collection();
}

const PendingSyncItemSchema = CollectionSchema(
  name: r'PendingSyncItem',
  id: 4978419684612478988,
  properties: {
    r'actionType': PropertySchema(
      id: 0,
      name: r'actionType',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'lastError': PropertySchema(
      id: 2,
      name: r'lastError',
      type: IsarType.string,
    ),
    r'localFilePath': PropertySchema(
      id: 3,
      name: r'localFilePath',
      type: IsarType.string,
    ),
    r'priority': PropertySchema(
      id: 4,
      name: r'priority',
      type: IsarType.long,
    ),
    r'retryCount': PropertySchema(
      id: 5,
      name: r'retryCount',
      type: IsarType.long,
    ),
    r'status': PropertySchema(
      id: 6,
      name: r'status',
      type: IsarType.string,
    ),
    r'storagePath': PropertySchema(
      id: 7,
      name: r'storagePath',
      type: IsarType.string,
    ),
    r'targetId': PropertySchema(
      id: 8,
      name: r'targetId',
      type: IsarType.string,
    ),
  },
  estimateSize: _pendingSyncItemEstimateSize,
  serialize: _pendingSyncItemSerialize,
  deserialize: _pendingSyncItemDeserialize,
  deserializeProp: _pendingSyncItemDeserializeProp,
  idName: r'id',
  indexes: {
    r'actionType': IndexSchema(
      id: -3268401673993471355,
      name: r'actionType',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'actionType',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'status': IndexSchema(
      id: -7033627348578893724,
      name: r'status',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'status',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'targetId': IndexSchema(
      id: -5773013208636978469,
      name: r'targetId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'targetId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _pendingSyncItemGetId,
  getLinks: _pendingSyncItemGetLinks,
  attach: _pendingSyncItemAttach,
  version: '3.1.0+1',
);

int _pendingSyncItemEstimateSize(
  PendingSyncItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.actionType.length * 3;
  final v0 = object.lastError;
  if (v0 != null) {
    bytesCount += 3 + v0.length * 3;
  }
  final v1 = object.localFilePath;
  if (v1 != null) {
    bytesCount += 3 + v1.length * 3;
  }
  final v2 = object.storagePath;
  if (v2 != null) {
    bytesCount += 3 + v2.length * 3;
  }
  final v3 = object.targetId;
  if (v3 != null) {
    bytesCount += 3 + v3.length * 3;
  }
  return bytesCount;
}

void _pendingSyncItemSerialize(
  PendingSyncItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.actionType);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.lastError);
  writer.writeString(offsets[3], object.localFilePath);
  writer.writeLong(offsets[4], object.priority);
  writer.writeLong(offsets[5], object.retryCount);
  writer.writeString(offsets[6], object.status);
  writer.writeString(offsets[7], object.storagePath);
  writer.writeString(offsets[8], object.targetId);
}

PendingSyncItem _pendingSyncItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PendingSyncItem();
  object.createdAt = reader.readDateTime(offsets[1]);
  object.id = id;
  object.lastError = reader.readStringOrNull(offsets[2]);
  object.localFilePath = reader.readStringOrNull(offsets[3]);
  object.priority = reader.readLongOrNull(offsets[4]) ?? 0;
  object.retryCount = reader.readLongOrNull(offsets[5]) ?? 0;
  object.status = reader.readStringOrNull(offsets[6]) ?? 'pending';
  object.storagePath = reader.readStringOrNull(offsets[7]);
  object.targetId = reader.readStringOrNull(offsets[8]);
  object.actionType = reader.readString(offsets[0]);
  return object;
}

P _pendingSyncItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 5:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 6:
      return (reader.readStringOrNull(offset) ?? 'pending') as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _pendingSyncItemGetId(PendingSyncItem object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _pendingSyncItemGetLinks(PendingSyncItem object) {
  return [];
}

void _pendingSyncItemAttach(
    IsarCollection<dynamic> col, Id id, PendingSyncItem object) {
  object.id = id;
}

extension PendingSyncItemQueryWhereSort
    on QueryBuilder<PendingSyncItem, PendingSyncItem, QWhere> {
  QueryBuilder<PendingSyncItem, PendingSyncItem, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PendingSyncItemQueryWhere
    on QueryBuilder<PendingSyncItem, PendingSyncItem, QWhereClause> {
  QueryBuilder<PendingSyncItem, PendingSyncItem, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PendingSyncItem, PendingSyncItem, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PendingSyncItem, PendingSyncItem, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PendingSyncItem, PendingSyncItem, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PendingSyncItem, PendingSyncItem, QAfterWhereClause>
      actionTypeEqualTo(String actionType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'actionType',
        value: [actionType],
      ));
    });
  }

  QueryBuilder<PendingSyncItem, PendingSyncItem, QAfterWhereClause>
      statusEqualTo(String status) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'status',
        value: [status],
      ));
    });
  }

  QueryBuilder<PendingSyncItem, PendingSyncItem, QAfterWhereClause>
      targetIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.equalTo(indexName: r'targetId', value: [null]),
      );
    });
  }

  QueryBuilder<PendingSyncItem, PendingSyncItem, QAfterWhereClause>
      targetIdEqualTo(String? targetId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'targetId',
        value: [targetId],
      ));
    });
  }
}

extension PendingSyncItemQueryFilter
    on QueryBuilder<PendingSyncItem, PendingSyncItem, QFilterCondition> {
  QueryBuilder<PendingSyncItem, PendingSyncItem, QAfterFilterCondition>
      actionTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingSyncItem, PendingSyncItem, QAfterFilterCondition>
      statusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }
}

extension PendingSyncItemQuerySortBy
    on QueryBuilder<PendingSyncItem, PendingSyncItem, QSortBy> {
  QueryBuilder<PendingSyncItem, PendingSyncItem, QAfterSortBy>
      sortByActionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionType', Sort.asc);
    });
  }

  QueryBuilder<PendingSyncItem, PendingSyncItem, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PendingSyncItem, PendingSyncItem, QAfterSortBy>
      sortByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<PendingSyncItem, PendingSyncItem, QAfterSortBy>
      sortByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.asc);
    });
  }

  QueryBuilder<PendingSyncItem, PendingSyncItem, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }
}

  extension PendingSyncItemQueryWhereDistinct
    on QueryBuilder<PendingSyncItem, PendingSyncItem, QDistinct> {
  QueryBuilder<PendingSyncItem, PendingSyncItem, QDistinct>
      distinctByActionType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actionType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingSyncItem, PendingSyncItem, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }
}

extension PendingSyncItemQueryProperty
    on QueryBuilder<PendingSyncItem, PendingSyncItem, QQueryProperty> {
  QueryBuilder<PendingSyncItem, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PendingSyncItem, String, QQueryOperations>
      actionTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actionType');
    });
  }

  QueryBuilder<PendingSyncItem, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<PendingSyncItem, String, QQueryOperations> lastErrorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastError');
    });
  }

  QueryBuilder<PendingSyncItem, String, QQueryOperations>
      localFilePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localFilePath');
    });
  }

  QueryBuilder<PendingSyncItem, int, QQueryOperations> priorityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'priority');
    });
  }

  QueryBuilder<PendingSyncItem, int, QQueryOperations> retryCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'retryCount');
    });
  }

  QueryBuilder<PendingSyncItem, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<PendingSyncItem, String, QQueryOperations>
      storagePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'storagePath');
    });
  }

  QueryBuilder<PendingSyncItem, String, QQueryOperations> targetIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetId');
    });
  }
}
