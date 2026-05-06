// lib/features/justifications/justification_model.dart

enum JustificationStatut { enAttente, valide, rejete }

extension JustificationStatutX on JustificationStatut {
  static JustificationStatut fromString(String? s) {
    switch (s) {
      case 'valide':
        return JustificationStatut.valide;
      case 'rejete':
        return JustificationStatut.rejete;
      default:
        return JustificationStatut.enAttente;
    }
  }

  String toApiString() {
    switch (this) {
      case JustificationStatut.valide:
        return 'valide';
      case JustificationStatut.rejete:
        return 'rejete';
      case JustificationStatut.enAttente:
        return 'en_attente';
    }
  }
}

class JustificationModel {
  final String id;
  final String studentId;
  final String? presenceId;
  final JustificationStatut statut;
  final String? fileUrl;
  final String? reason;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? reviewedAt;

  // Données jointes (via select imbriqué)
  final String? studentFirstName;
  final String? studentLastName;
  final String? studentEmail;
  final String? matiereNom;
  final String? seanceDate;     // ISO date string
  final String? seanceDebut;    // HH:mm
  final String? seanceFin;      // HH:mm

  const JustificationModel({
    required this.id,
    required this.studentId,
    this.presenceId,
    required this.statut,
    this.fileUrl,
    this.reason,
    this.rejectionReason,
    required this.createdAt,
    this.reviewedAt,
    this.studentFirstName,
    this.studentLastName,
    this.studentEmail,
    this.matiereNom,
    this.seanceDate,
    this.seanceDebut,
    this.seanceFin,
  });

  String get studentFullName {
    final parts = [studentFirstName, studentLastName]
        .where((p) => p != null && p.trim().isNotEmpty)
        .join(' ');
    return parts.isNotEmpty ? parts : (studentEmail ?? 'Étudiant');
  }

  String get studentInitials {
    final f = studentFirstName?.trim() ?? '';
    final l = studentLastName?.trim() ?? '';
    if (f.isNotEmpty && l.isNotEmpty) {
      return '${f[0]}${l[0]}'.toUpperCase();
    }
    if (f.isNotEmpty) return f.substring(0, f.length.clamp(0, 2)).toUpperCase();
    final email = studentEmail ?? '';
    return email.isNotEmpty
        ? email.substring(0, email.length.clamp(0, 2)).toUpperCase()
        : '?';
  }

  /// Formatte la date d'absence lisiblement, ex: "28 avr. 2026"
  String get dateAbsenceDisplay {
    if (seanceDate == null) return '–';
    try {
      final dt = DateTime.parse(seanceDate!);
      final mois = [
        '', 'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
        'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
      ];
      return '${dt.day} ${mois[dt.month]} ${dt.year}';
    } catch (_) {
      return seanceDate!;
    }
  }

  String get creneauxDisplay {
    if (seanceDebut == null || seanceFin == null) return '–';
    return '$seanceDebut – $seanceFin';
  }

  factory JustificationModel.fromJson(Map<String, dynamic> json) {
    // Le select imbriqué retourne les relations comme des objets imbriqués.
    // Exemple : presences -> sessions -> seances -> matieres
    //           student_id -> users
    final userMap = json['users'] as Map<String, dynamic>?;
    final presenceMap = json['presences'] as Map<String, dynamic>?;
    final sessionMap = presenceMap?['sessions'] as Map<String, dynamic>?;
    final seanceMap = sessionMap?['seances'] as Map<String, dynamic>?;
    final matiereMap = seanceMap?['matieres'] as Map<String, dynamic>?;

    return JustificationModel(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      presenceId: json['presence_id'] as String?,
      statut: JustificationStatutX.fromString(json['status'] as String?),
      fileUrl: json['file_url'] as String?,
      reason: json['reason'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      studentFirstName: userMap?['first_name'] as String?,
      studentLastName: userMap?['last_name'] as String?,
      studentEmail: userMap?['email'] as String?,
      matiereNom: matiereMap?['name'] as String? ?? matiereMap?['nom'] as String?,
      seanceDate: seanceMap?['date'] as String?,
      seanceDebut: seanceMap?['start_time'] as String?,
      seanceFin: seanceMap?['end_time'] as String?,
    );
  }
}