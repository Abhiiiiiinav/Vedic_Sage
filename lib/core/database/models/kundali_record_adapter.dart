import 'package:hive/hive.dart';
import 'kundali_record_model.dart';

/// Hive TypeAdapter for KundaliRecordModel
/// Handles serialization/deserialization of the comprehensive kundali record
class KundaliRecordModelAdapter extends TypeAdapter<KundaliRecordModel> {
  @override
  final int typeId = 11;

  @override
  KundaliRecordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return KundaliRecordModel(
      id: fields[0] as String,
      name: fields[1] as String,
      dateOfBirth: fields[2] as DateTime,
      placeOfBirth: fields[3] as String,
      latitude: (fields[4] as num).toDouble(),
      longitude: (fields[5] as num).toDouble(),
      timezoneOffset: (fields[6] as num).toDouble(),
      ascendants: Map<String, int>.from(
        (fields[7] as Map)
            .map((k, v) => MapEntry(k.toString(), (v as num).toInt())),
      ),
      planetNakshatras: Map<String, String>.from(
        (fields[8] as Map).map((k, v) => MapEntry(k.toString(), v.toString())),
      ),
      planetNakshatraPadas: Map<String, int>.from(
        (fields[9] as Map)
            .map((k, v) => MapEntry(k.toString(), (v as num).toInt())),
      ),
      planetNakshatraLords: Map<String, String>.from(
        (fields[10] as Map).map((k, v) => MapEntry(k.toString(), v.toString())),
      ),
      planetSignsJson: fields[11] as String,
      planetDegrees: Map<String, double>.from(
        (fields[12] as Map)
            .map((k, v) => MapEntry(k.toString(), (v as num).toDouble())),
      ),
      planetRetrogrades: Map<String, bool>.from(
        (fields[13] as Map).map((k, v) => MapEntry(k.toString(), v as bool)),
      ),
      karakas: Map<String, String>.from(
        (fields[14] as Map).map((k, v) => MapEntry(k.toString(), v.toString())),
      ),
      createdAt: fields[15] as DateTime,
      updatedAt: fields[16] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, KundaliRecordModel obj) {
    writer
      ..writeByte(17) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.dateOfBirth)
      ..writeByte(3)
      ..write(obj.placeOfBirth)
      ..writeByte(4)
      ..write(obj.latitude)
      ..writeByte(5)
      ..write(obj.longitude)
      ..writeByte(6)
      ..write(obj.timezoneOffset)
      ..writeByte(7)
      ..write(obj.ascendants)
      ..writeByte(8)
      ..write(obj.planetNakshatras)
      ..writeByte(9)
      ..write(obj.planetNakshatraPadas)
      ..writeByte(10)
      ..write(obj.planetNakshatraLords)
      ..writeByte(11)
      ..write(obj.planetSignsJson)
      ..writeByte(12)
      ..write(obj.planetDegrees)
      ..writeByte(13)
      ..write(obj.planetRetrogrades)
      ..writeByte(14)
      ..write(obj.karakas)
      ..writeByte(15)
      ..write(obj.createdAt)
      ..writeByte(16)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KundaliRecordModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
