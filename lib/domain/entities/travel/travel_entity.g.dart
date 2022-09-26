// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'travel_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TravelEntityAdapter extends TypeAdapter<TravelEntity> {
  @override
  final int typeId = 0;

  @override
  TravelEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TravelEntity(
      destinationName: fields[0] as String,
      destinationLat: fields[1] as double,
      destinationLong: fields[2] as double,
      date: fields[3] as DateTime,
      consideredDistance: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, TravelEntity obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.destinationName)
      ..writeByte(1)
      ..write(obj.destinationLat)
      ..writeByte(2)
      ..write(obj.destinationLong)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.consideredDistance);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TravelEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
