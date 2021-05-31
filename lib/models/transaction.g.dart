// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 4;

  @override
  TransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionType.create;
      case 1:
        return TransactionType.update;
      case 2:
        return TransactionType.addSubTask;
      default:
        return TransactionType.create;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    switch (obj) {
      case TransactionType.create:
        writer.writeByte(0);
        break;
      case TransactionType.update:
        writer.writeByte(1);
        break;
      case TransactionType.addSubTask:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DataTypeAdapter extends TypeAdapter<DataType> {
  @override
  final int typeId = 5;

  @override
  DataType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DataType.task;
      case 1:
        return DataType.project;
      case 2:
        return DataType.subTask;
      default:
        return DataType.task;
    }
  }

  @override
  void write(BinaryWriter writer, DataType obj) {
    switch (obj) {
      case DataType.task:
        writer.writeByte(0);
        break;
      case DataType.project:
        writer.writeByte(1);
        break;
      case DataType.subTask:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 3;

  @override
  Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transaction(
      timeStamp: fields[0] as DateTime,
      transactionType: fields[1] as TransactionType,
      dataType: fields[2] as DataType,
      uid: fields[3] as String,
      token: fields[4] as String?,
      data: (fields[5] as Map).cast<dynamic, dynamic>(),
      objectId: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.timeStamp)
      ..writeByte(1)
      ..write(obj.transactionType)
      ..writeByte(2)
      ..write(obj.dataType)
      ..writeByte(3)
      ..write(obj.uid)
      ..writeByte(4)
      ..write(obj.token)
      ..writeByte(5)
      ..write(obj.data)
      ..writeByte(6)
      ..write(obj.objectId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
