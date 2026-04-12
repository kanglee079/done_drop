// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_sync_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingSyncItemAdapter extends TypeAdapter<PendingSyncItem> {
  @override
  final int typeId = 0;

  @override
  PendingSyncItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingSyncItem()
      ..actionType = fields[0] as String
      ..payloadJson = fields[1] as String
      ..createdAt = fields[2] as DateTime
      ..retryCount = fields[3] as int
      ..lastError = fields[4] as String?
      ..status = fields[5] as String
      ..localFilePath = fields[6] as String?
      ..storagePath = fields[7] as String?
      ..priority = fields[8] as int
      ..targetId = fields[9] as String?;
  }

  @override
  void write(BinaryWriter writer, PendingSyncItem obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.actionType)
      ..writeByte(1)
      ..write(obj.payloadJson)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.retryCount)
      ..writeByte(4)
      ..write(obj.lastError)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.localFilePath)
      ..writeByte(7)
      ..write(obj.storagePath)
      ..writeByte(8)
      ..write(obj.priority)
      ..writeByte(9)
      ..write(obj.targetId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingSyncItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
