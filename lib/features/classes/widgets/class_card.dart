import 'package:flutter/material.dart';

class ClassCard extends StatelessWidget {
  final String title;
  final String filiere;
  final int studentCount;
  final List<String> subjects;
  final double attendanceRate;

  const ClassCard({
    super.key,
    required this.title,
    required this.filiere,
    required this.studentCount,
    required this.subjects,
    required this.attendanceRate,
  });

  @override
  Widget build(BuildContext context) {
    final bool isHighAttendance = attendanceRate >= 80;
    final Color progressColor = isHighAttendance
        ? const Color(0xFF27AE60)
        : const Color(0xFFF2994A);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F092C4C), // 0.06 opacity
            offset: Offset(0, 4),
            blurRadius: 16,
          ),
          BoxShadow(
            color: Color(0x0A092C4C), // 0.04 opacity
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
        border: Border.all(color: Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Title & Students
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF092C4C),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      filiere,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4F4F4F),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EFF5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.people_alt_outlined,
                      size: 16,
                      color: Color(0xFF092C4C),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      studentCount.toString(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF092C4C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Subjects Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: subjects.map((subject) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  subject.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4F4F4F),
                    letterSpacing: 0.5,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Attendance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Taux d'assiduité global",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4F4F4F),
                ),
              ),
              Text(
                '${attendanceRate.round()}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: progressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: FractionallySizedBox(
              widthFactor: attendanceRate.clamp(0.0, 100.0) / 100.0,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: progressColor,
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
