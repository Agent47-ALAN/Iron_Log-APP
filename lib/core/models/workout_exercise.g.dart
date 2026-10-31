// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_exercise.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutExerciseAdapter extends TypeAdapter<WorkoutExercise> {
  @override
  final int typeId = 2;

  @override
  WorkoutExercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutExercise(
      id: fields[0] as String,
      exerciseId: fields[1] as String,
      exerciseName: fields[2] as String,
      muscleGroup: fields[3] as String,
      sets: (fields[4] as List).cast<WorkoutSet>(),
      orderIndex: fields[5] as int,
      notes: fields[6] as String?,
      restSeconds: fields[7] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutExercise obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.exerciseId)
      ..writeByte(2)
      ..write(obj.exerciseName)
      ..writeByte(3)
      ..write(obj.muscleGroup)
      ..writeByte(4)
      ..write(obj.sets)
      ..writeByte(5)
      ..write(obj.orderIndex)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.restSeconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
