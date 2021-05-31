// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SyncStatusAdapter extends TypeAdapter<SyncStatus> {
  @override
  final int typeId = 1;

  @override
  SyncStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SyncStatus.fullySynced;
      case 1:
        return SyncStatus.newTask;
      case 2:
        return SyncStatus.updatedTask;
      default:
        return SyncStatus.fullySynced;
    }
  }

  @override
  void write(BinaryWriter writer, SyncStatus obj) {
    switch (obj) {
      case SyncStatus.fullySynced:
        writer.writeByte(0);
        break;
      case SyncStatus.newTask:
        writer.writeByte(1);
        break;
      case SyncStatus.updatedTask:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      syncStatus: fields[0] as SyncStatus,
      id: fields[1] as String,
      title: fields[2] as String,
      start: fields[3] as DateTime,
      latestPause: fields[4] as DateTime?,
      end: fields[5] as DateTime?,
      pauses: fields[6] as int,
      pauseTime: Duration(seconds: fields[7] as int),
      isRunning: fields[8] as bool,
      isPaused: fields[9] as bool,
      category: fields[10] as String,
      labels: (fields[11] as List?)?.cast<String>(),
      goalTime: Duration(seconds: fields[12] as int),
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.syncStatus)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.start)
      ..writeByte(4)
      ..write(obj.latestPause)
      ..writeByte(5)
      ..write(obj.end)
      ..writeByte(6)
      ..write(obj.pauses)
      ..writeByte(7)
      ..write(obj.pauseTime.inSeconds)
      ..writeByte(8)
      ..write(obj.isRunning)
      ..writeByte(9)
      ..write(obj.isPaused)
      ..writeByte(10)
      ..write(obj.category)
      ..writeByte(11)
      ..write(obj.labels)
      ..writeByte(12)
      ..write(obj.goalTime.inSeconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
