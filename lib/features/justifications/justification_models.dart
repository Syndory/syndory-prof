import 'package:flutter/material.dart';

enum JustificationStatus {
  enAttente,
  valide,
  rejete,
  unknown,
}

extension JustificationStatusExtension on JustificationStatus {
  String get label {
    switch (this) {
      case JustificationStatus.enAttente:
        return 'En attente';
      case JustificationStatus.valide:
        return 'Validé';
      case JustificationStatus.rejete:
        return 'Rejeté';
      case JustificationStatus.unknown:
        return 'Inconnu';
    }
  }

  IconData get icon {
    switch (this) {
      case JustificationStatus.enAttente:
        return Icons.hourglass_empty_outlined;
      case JustificationStatus.valide:
        return Icons.check_circle_outline;
      case JustificationStatus.rejete:
        return Icons.cancel_outlined;
      case JustificationStatus.unknown:
        return Icons.help_outline;
    }
  }

  Color get color {
    switch (this) {
      case JustificationStatus.enAttente:
        return const Color(0xFFF2994A);
      case JustificationStatus.valide:
        return const Color(0xFF219653);
      case JustificationStatus.rejete:
        return const Color(0xFFEB5757);
      case JustificationStatus.unknown:
        return const Color(0xFF828282);
    }
  }
}

JustificationStatus _parseStatus(dynamic source) {
  if (source == null) return JustificationStatus.unknown;
  switch (source.toString().toLowerCase()) {
    case 'en_attente':
      return JustificationStatus.enAttente;
    case 'validé':
    case 'valide':
      return JustificationStatus.valide;
    case 'rejeté':
    case 'rejete':
      return JustificationStatus.rejete;
    default:
      return JustificationStatus.unknown;
  }
}

class Justificatif {
  final String id;
  final String studentName;
  final String className;
  final String subjectName;
  final String seanceDate;
  final String? fileUrl;
  final JustificationStatus status;
  final String? rejectionReason;
  final DateTime createdAt;

  const Justificatif({
    required this.id,
    required this.studentName,
    required this.className,
    required this.subjectName,
    required this.seanceDate,
    this.fileUrl,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
  });

  factory Justificatif.fromMap(Map<String, dynamic> map) {
    final presence = map['presences'] as Map? ?? {};
    final session = presence['sessions'] as Map? ?? {};
    final seance = session['seances'] as Map? ?? {};
    final student = presence['users'] as Map? ?? {};
    final classe = seance['classes'] as Map? ?? {};
    final matiere = seance['matieres'] as Map? ?? {};

    final firstName = student['first_name']?.toString() ?? '';
    final lastName = student['last_name']?.toString() ?? '';
    final fullName = [firstName, lastName]
        .where((s) => s.trim().isNotEmpty)
        .join(' ')
        .trim();

    final seanceDateRaw = seance['date']?.toString() ?? '';
    String formattedDate = seanceDateRaw;
    if (seanceDateRaw.isNotEmpty) {
      try {
        final d = DateTime.parse(seanceDateRaw);
        formattedDate =
            '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
      } catch (_) {}
    }

    return Justificatif(
      id: map['id']?.toString() ?? '',
      studentName: fullName.isNotEmpty ? fullName : 'Étudiant inconnu',
      className: classe['name']?.toString() ??
          classe['code']?.toString() ??
          'Classe inconnue',
      subjectName: matiere['name']?.toString() ??
          matiere['code']?.toString() ??
          'Matière inconnue',
      seanceDate: formattedDate,
      fileUrl: map['file_url']?.toString(),
      status: _parseStatus(map['status']),
      rejectionReason: map['rejection_reason']?.toString(),
      createdAt: _parseDate(map['created_at']),
    );
  }
}

DateTime _parseDate(dynamic value) {
  if (value is DateTime) return value;
  if (value is String) {
    return DateTime.tryParse(value)?.toLocal() ?? DateTime.now();
  }
  return DateTime.now();
}
