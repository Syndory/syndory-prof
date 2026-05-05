class SeanceDuJour {
  final String id;
  final String startTime;
  final String endTime;
  final String matiereName;
  final String className;
  final String? salleName;
  final bool isExam;

  const SeanceDuJour({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.matiereName,
    required this.className,
    this.salleName,
    required this.isExam,
  });

  factory SeanceDuJour.fromJson(Map<String, dynamic> json) {
    final startRaw = json['start_time'] as String;
    final endRaw = json['end_time'] as String;
    return SeanceDuJour(
      id: json['id'] as String,
      startTime: startRaw.length >= 5 ? startRaw.substring(0, 5) : startRaw,
      endTime: endRaw.length >= 5 ? endRaw.substring(0, 5) : endRaw,
      matiereName:
          (json['matieres'] as Map<String, dynamic>)['name'] as String,
      className: (json['classes'] as Map<String, dynamic>)['name'] as String,
      salleName: json['salles'] != null
          ? (json['salles'] as Map<String, dynamic>)['name'] as String?
          : null,
      isExam: json['is_exam'] as bool? ?? false,
    );
  }
}

class AccueilData {
  final String professorFirstName;
  final List<SeanceDuJour> seances;

  const AccueilData({
    required this.professorFirstName,
    required this.seances,
  });
}
