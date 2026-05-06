import 'package:flutter/material.dart';
import '../../domain/justification_model.dart';

class JustificatifCard extends StatelessWidget {
  final Justification item;
  final VoidCallback onTap;

  const JustificatifCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = item.status;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: status == JustificationStatus.pending
              ? const Color(0xFF092C4C).withOpacity(0.1)
              : const Color(0xFFE0E0E0).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFF092C4C),
                      child: Text(
                        item.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.studentName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF092C4C),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Absence du ${item.date.day}/${item.date.month}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF828282),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StatusBadge(status: status),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF2F2F2)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.book_outlined, size: 16, color: Color(0xFF828282)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cours : ${item.subjectName}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4F4F4F),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final JustificationStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label.toUpperCase(),
        style: TextStyle(
          color: status.color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
