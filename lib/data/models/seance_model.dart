class SeanceModel {
  final String id;
  final String startTime;
  final String endTime;
  final String matiereName;
  final String className;
  final String? classId;
  final String? salleName;
  final bool isExam;
  final DateTime? date;

  const SeanceModel({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.matiereName,
    required this.className,
    this.classId,
    this.salleName,
    required this.isExam,
    this.date,
  });

  factory SeanceModel.fromJson(Map<String, dynamic> json) {
    final startRaw = json['start_time'] as String;
    final endRaw = json['end_time'] as String;
    return SeanceModel(
      id: json['id'] as String,
      startTime: startRaw.length >= 5 ? startRaw.substring(0, 5) : startRaw,
      endTime: endRaw.length >= 5 ? endRaw.substring(0, 5) : endRaw,
      matiereName: (json['matieres'] as Map<String, dynamic>)['name'] as String,
      className: (json['classes'] as Map<String, dynamic>)['name'] as String,
      classId: json['class_id'] as String?,
      salleName: json['salles'] != null
          ? (json['salles'] as Map<String, dynamic>)['name'] as String?
          : null,
      isExam: json['is_exam'] as bool? ?? false,
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : null,
    );
  }
}
