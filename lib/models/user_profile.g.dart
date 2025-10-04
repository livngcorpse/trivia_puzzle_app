// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 0;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      username: fields[0] as String,
      avatarIndex: fields[1] as int,
      subjectScores: (fields[2] as List).cast<SubjectScore>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.username)
      ..writeByte(1)
      ..write(obj.avatarIndex)
      ..writeByte(2)
      ..write(obj.subjectScores);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SubjectScoreAdapter extends TypeAdapter<SubjectScore> {
  @override
  final int typeId = 1;

  @override
  SubjectScore read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubjectScore(
      subject: fields[0] as String,
      gameModeScores: (fields[1] as List).cast<GameModeScore>(),
    );
  }

  @override
  void write(BinaryWriter writer, SubjectScore obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.subject)
      ..writeByte(1)
      ..write(obj.gameModeScores);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubjectScoreAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GameModeScoreAdapter extends TypeAdapter<GameModeScore> {
  @override
  final int typeId = 2;

  @override
  GameModeScore read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameModeScore(
      gameMode: fields[0] as String,
      score: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, GameModeScore obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.gameMode)
      ..writeByte(1)
      ..write(obj.score);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameModeScoreAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
