class StudentModel {
  final String name;
  final String email;
  final String initials;
  final int attendanceRate;

  const StudentModel({
    required this.name,
    required this.email,
    required this.initials,
    required this.attendanceRate,
  });
}

class ClassModel {
  final String id;
  final String title;
  final String filiere;
  final List<String> subjects;
  final int studentCount;
  final double attendanceRate;
  final List<StudentModel> students;

  const ClassModel({
    required this.id,
    required this.title,
    required this.filiere,
    required this.subjects,
    required this.studentCount,
    required this.attendanceRate,
    required this.students,
  });
}
