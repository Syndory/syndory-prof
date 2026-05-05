import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

enum SeanceDisplayStatus { aVenir, enCours, termine }

extension SeanceDisplayStatusX on SeanceDisplayStatus {
  String get label {
    switch (this) {
      case SeanceDisplayStatus.aVenir:
        return 'À VENIR';
      case SeanceDisplayStatus.enCours:
        return 'EN COURS';
      case SeanceDisplayStatus.termine:
        return 'TERMINÉ';
    }
  }

  Color get color {
    switch (this) {
      case SeanceDisplayStatus.aVenir:
        return AppColors.blueBadge;
      case SeanceDisplayStatus.enCours:
        return AppColors.primary;
      case SeanceDisplayStatus.termine:
        return AppColors.greyBadge;
    }
  }
}

class SeanceModel {
  const SeanceModel({
    required this.id,
    required this.matiereName,
    required this.className,
    this.salleName,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  final String id;
  final String matiereName;
  final String className;
  final String? salleName;
  final String date;
  final String startTime;
  final String endTime;

  String get _startHhmm =>
      startTime.length >= 5 ? startTime.substring(0, 5) : startTime;
  String get _endHhmm =>
      endTime.length >= 5 ? endTime.substring(0, 5) : endTime;

  String get displayStartTime => _startHhmm;
  String get displayEndTime => _endHhmm;

  String get locationLabel {
    if (salleName != null && salleName!.isNotEmpty) {
      return '$className • $salleName';
    }
    return className;
  }

  SeanceDisplayStatus get displayStatus {
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    if (date != todayStr) {
      return DateTime.parse(date).isBefore(now)
          ? SeanceDisplayStatus.termine
          : SeanceDisplayStatus.aVenir;
    }

    final sp = _startHhmm.split(':');
    final ep = _endHhmm.split(':');
    final start = DateTime(
        now.year, now.month, now.day, int.parse(sp[0]), int.parse(sp[1]));
    final end = DateTime(
        now.year, now.month, now.day, int.parse(ep[0]), int.parse(ep[1]));

    if (now.isBefore(start)) return SeanceDisplayStatus.aVenir;
    if (now.isAfter(end)) return SeanceDisplayStatus.termine;
    return SeanceDisplayStatus.enCours;
  }

  factory SeanceModel.fromMap(Map<String, dynamic> map) {
    final matiere = map['matieres'] as Map<String, dynamic>?;
    final classe = map['classes'] as Map<String, dynamic>?;
    final salle = map['salles'] as Map<String, dynamic>?;
    return SeanceModel(
      id: map['id'] as String,
      matiereName: matiere?['name'] as String? ?? '',
      className: classe?['name'] as String? ?? '',
      salleName: salle?['name'] as String?,
      date: map['date'] as String,
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
    );
  }
}

class ActiveSessionModel {
  const ActiveSessionModel({
    required this.id,
    required this.matiereName,
    required this.className,
    required this.openedAt,
  });

  final String id;
  final String matiereName;
  final String className;
  final DateTime openedAt;

  factory ActiveSessionModel.fromMap(Map<String, dynamic> map) {
    final seance = map['seances'] as Map<String, dynamic>?;
    final matiere = seance?['matieres'] as Map<String, dynamic>?;
    final classe = seance?['classes'] as Map<String, dynamic>?;
    return ActiveSessionModel(
      id: map['id'] as String,
      matiereName: matiere?['name'] as String? ?? '',
      className: classe?['name'] as String? ?? '',
      openedAt: DateTime.parse(map['opened_at'] as String),
    );
  }
}

class ClasseModel {
  const ClasseModel({
    required this.id,
    required this.nom,
    required this.studentCount,
  });

  final String id;
  final String nom;
  final int studentCount;
}

class HomePageData {
  const HomePageData({
    required this.firstName,
    required this.lastName,
    required this.pendingJustificatifs,
    required this.todaySeances,
    this.activeSession,
    required this.classes,
  });

  final String firstName;
  final String lastName;
  final int pendingJustificatifs;
  final List<SeanceModel> todaySeances;
  final ActiveSessionModel? activeSession;
  final List<ClasseModel> classes;

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l';
  }

  String get fullName => '$firstName $lastName';
}
