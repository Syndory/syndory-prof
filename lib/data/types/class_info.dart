class ClassInfo {
  final String id;
  final String name;
  final String? promotion;
  final String filiereName;
  final int? studentCount;

  const ClassInfo({
    required this.id,
    required this.name,
    this.promotion,
    required this.filiereName,
    this.studentCount,
  });

  factory ClassInfo.fromJson(Map<String, dynamic> json) {
    return ClassInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      promotion: json['promotion'] as String?,
      filiereName: json['filieres'] != null 
          ? json['filieres']['name'] as String 
          : (json['filiere_name'] as String? ?? ''),
      studentCount: json['student_count'] as int?,
    );
  }
}
