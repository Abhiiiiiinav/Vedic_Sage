/// Data models for Vimshottari Dasha system

class MahadashaModel {
  final String lord;
  final String fullName;
  final double years;
  final DateTime startDate;
  final DateTime endDate;
  final bool isPartial;
  
  MahadashaModel({
    required this.lord,
    required this.fullName,
    required this.years,
    required this.startDate,
    required this.endDate,
    this.isPartial = false,
  });
  
  factory MahadashaModel.fromMap(Map<String, dynamic> map) {
    return MahadashaModel(
      lord: map['lord'],
      fullName: map['fullName'],
      years: map['years'],
      startDate: map['startDate'],
      endDate: map['endDate'],
      isPartial: map['isPartial'] ?? false,
    );
  }
  
  int get durationInDays => endDate.difference(startDate).inDays;
  
  bool isActiveOn(DateTime date) {
    return date.isAfter(startDate) && date.isBefore(endDate);
  }
}

class AntardashaModel {
  final String lord;
  final String fullName;
  final double years;
  final int days;
  final DateTime startDate;
  final DateTime endDate;
  
  AntardashaModel({
    required this.lord,
    required this.fullName,
    required this.years,
    required this.days,
    required this.startDate,
    required this.endDate,
  });
  
  factory AntardashaModel.fromMap(Map<String, dynamic> map) {
    return AntardashaModel(
      lord: map['lord'],
      fullName: map['fullName'],
      years: map['years'],
      days: map['days'],
      startDate: map['startDate'],
      endDate: map['endDate'],
    );
  }
  
  bool isActiveOn(DateTime date) {
    return date.isAfter(startDate) && date.isBefore(endDate);
  }
  
  int daysRemaining(DateTime from) {
    return endDate.difference(from).inDays;
  }
}

class DashaInterpretation {
  final String mdLord;
  final String adLord;
  final int dashaLagna;
  final String lifeTheme;
  final String currentFocus;
  final List<String> keyAreas;
  final List<String> advice;
  final String aiInterpretation;
  
  DashaInterpretation({
    required this.mdLord,
    required this.adLord,
    required this.dashaLagna,
    required this.lifeTheme,
    required this.currentFocus,
    required this.keyAreas,
    required this.advice,
    this.aiInterpretation = '',
  });
}
