import 'package:flutter/material.dart';
import '../models/models.dart';

class StudentCard extends StatelessWidget {
  final StudentModel student;

  const StudentCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    Color badgeBg;
    Color badgeText;

    if (student.attendanceRate >= 90) {
      badgeBg = const Color(0xFFE8F8EF); // --success-dim
      badgeText = const Color(0xFF27AE60); // --success
    } else if (student.attendanceRate >= 70) {
      badgeBg = const Color(0xFFFEF3E7); // --secondary-dim
      badgeText = const Color(0xFFF2994A); // --secondary
    } else {
      badgeBg = const Color(0xFFFEECEC); // --error-dim
      badgeText = const Color(0xFFEB5757); // --error
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            offset: Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFE8EFF5), // --primary-dim
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              student.initials,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF092C4C), // --primary
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333333), // --gray1
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  student.email,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF828282), // --gray3
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(8),
            ),
            constraints: const BoxConstraints(minWidth: 54),
            alignment: Alignment.center,
            child: Text(
              '${student.attendanceRate}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: badgeText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
