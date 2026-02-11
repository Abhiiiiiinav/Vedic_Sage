import 'package:hive/hive.dart';
import 'divisional_chart_model.dart';

/// Hive TypeAdapter for DivisionalChartModel
class DivisionalChartModelAdapter extends TypeAdapter<DivisionalChartModel> {
  @override
  final int typeId = 10;

  @override
  DivisionalChartModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    
    return DivisionalChartModel(
      chartType: fields[0] as String,
      ascendantSign: fields[1] as int,
      housePlanets: Map<int, List<String>>.from(
        (fields[2] as Map).map(
          (k, v) => MapEntry(k as int, List<String>.from(v as List)),
        ),
      ),
      svg: fields[3] as String,
      profileId: fields[4] as String,
      chartName: fields[5] as String,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
      planetDegrees: fields[8] != null
          ? Map<String, double>.from(fields[8] as Map)
          : null,
      metadata: fields[9] as Map<String, dynamic>?,
    );
  }

  @override
  void write(BinaryWriter writer, DivisionalChartModel obj) {
    writer
      ..writeByte(10) // number of fields
      ..writeByte(0)
      ..write(obj.chartType)
      ..writeByte(1)
      ..write(obj.ascendantSign)
      ..writeByte(2)
      ..write(obj.housePlanets)
      ..writeByte(3)
      ..write(obj.svg)
      ..writeByte(4)
      ..write(obj.profileId)
      ..writeByte(5)
      ..write(obj.chartName)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.planetDegrees)
      ..writeByte(9)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DivisionalChartModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
