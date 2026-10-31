// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoutineExerciseAdapter extends TypeAdapter<RoutineExercise> {
  @override
  final int typeId = 4;

  @override
  RoutineExercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RoutineExercise(
      exerciseId: fields[0] as String,
      exerciseName: fields[1] as String,
      muscleGroup: fields[2] as String,
      targetSets: fields[3] as int,
      targetReps: fields[4] as int?,
      targetWeight: fields[5] as double?,
      orderIndex: fields[6] as int,
      restSeconds: fields[7] as int?,
      notes: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RoutineExercise obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.exerciseId)
      ..writeByte(1)
      ..write(obj.exerciseName)
      ..writeByte(2)
      ..write(obj.muscleGroup)
      ..writeByte(3)
      ..write(obj.targetSets)
      ..writeByte(4)
      ..write(obj.targetReps)
      ..writeByte(5)
      ..write(obj.targetWeight)
      ..writeByte(6)
      ..write(obj.orderIndex)
      ..writeByte(7)
      ..write(obj.restSeconds)
      ..writeByte(8)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutineExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RoutineAdapter extends TypeAdapter<Routine> {
  @override
  final int typeId = 5;

  @override
  Routine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Routine(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      exercises: (fields[3] as List).cast<RoutineExercise>(),
      createdAt: fields[4] as DateTime,
      lastUsedAt: fields[5] as DateTime?,
      useCount: fields[6] as int,
      isSynced: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Routine obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.exercises)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.lastUsedAt)
      ..writeByte(6)
      ..write(obj.useCount)
      ..writeByte(7)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
