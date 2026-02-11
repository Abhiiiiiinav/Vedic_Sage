/// Model to hold user birth details
class BirthDetails {
  final String name;
  final DateTime birthDateTime;
  final double latitude;
  final double longitude;
  final String cityName;
  final double timezoneOffset; // Offset from UTC in hours (e.g., 5.5)

  const BirthDetails({
    required this.name,
    required this.birthDateTime,
    required this.latitude,
    required this.longitude,
    required this.cityName,
    this.timezoneOffset = 5.5, // Default to IST if not specified
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'birthDateTime': birthDateTime.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'cityName': cityName,
      'timezoneOffset': timezoneOffset,
    };
  }

  factory BirthDetails.fromMap(Map<String, dynamic> map) {
    return BirthDetails(
      name: map['name'],
      birthDateTime: DateTime.parse(map['birthDateTime']),
      latitude: map['latitude'],
      longitude: map['longitude'],
      cityName: map['cityName'],
      timezoneOffset: map['timezoneOffset'] ?? 5.5,
    );
  }
}
