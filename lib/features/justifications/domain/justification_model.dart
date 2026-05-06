import 'package:flutter/material.dart';

enum JustificationStatus {
  pending('En attente', Colors.orange, Icons.timer_outlined),
  approved('Validé', Colors.green, Icons.check_circle_outline),
  rejected('Refusé', Colors.red, Icons.cancel_outlined);

  final String label;
  final Color color;
  final IconData icon;

  const JustificationStatus(this.label, this.color, this.icon);

  static JustificationStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'validé':
      case 'approved':
        return JustificationStatus.approved;
      case 'rejeté':
      case 'rejected':
        return JustificationStatus.rejected;
      default:
        return JustificationStatus.pending;
    }
  }
}

class Justification {
  final String id;
  final String studentId;
  final String studentName;
  final String? studentEmail;
  final String? className;
  final String subjectName;
  final DateTime date;
  final String? reason;
  final String? rejectionReason;
  final String? imageUrl;
  final JustificationStatus status;
  final DateTime createdAt;

  Justification({
    required this.id,
    required this.studentId,
    required this.studentName,
    this.studentEmail,
    this.className,
    required this.subjectName,
    required this.date,
    this.reason,
    this.rejectionReason,
    this.imageUrl,
    required this.status,
    required this.createdAt,
  });

  String get initials {
    final parts = studentName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return studentName.isNotEmpty ? studentName[0].toUpperCase() : '?';
  }

  factory Justification.fromJson(Map<String, dynamic> json) {
    // Extraction des données jointes (Supabase)
    final userData = json['users'] as Map<String, dynamic>?;
    final studentName = userData != null 
        ? '${userData['first_name']} ${userData['last_name']}'
        : 'Étudiant inconnu';
    
    // Extraction des données de séance
    final presenceData = json['presences'] as Map<String, dynamic>?;
    final sessionData = presenceData?['sessions'] as Map<String, dynamic>?;
    final seanceData = sessionData?['seances'] as Map<String, dynamic>?;
    final subjectData = seanceData?['matieres'] as Map<String, dynamic>?;

    return Justification(
      id: json['id']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? 'ID_INCONNU',
      studentName: studentName,
      studentEmail: userData?['email'],
      className: json['class_name'],
      subjectName: subjectData?['name'] ?? 'Matière inconnue',
      date: DateTime.tryParse(seanceData?['date'] ?? '') ?? DateTime.now(),
      reason: json['reason'],
      rejectionReason: json['rejection_reason'],
      imageUrl: json['file_url'],
      status: JustificationStatus.fromString(json['statut'] ?? 'en attente'),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
