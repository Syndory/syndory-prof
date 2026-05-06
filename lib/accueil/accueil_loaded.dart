import 'package:flutter/material.dart';

// ─── Modèles ───────────────────────────────────────────────────────────────

enum SeanceStatus { aVenir, enCours, termine }

extension SeanceStatusX on SeanceStatus {
  String get label => switch (this) {
        SeanceStatus.aVenir => 'À VENIR',
        SeanceStatus.enCours => 'EN COURS',
        SeanceStatus.termine => 'TERMINÉ',
      };

  Color get badgeColor => switch (this) {
        SeanceStatus.aVenir => const Color(0xFF1565C0),
        SeanceStatus.enCours => const Color(0xFF27AE60),
        SeanceStatus.termine => const Color(0xFF9E9E9E),
      };
}

class SeanceItem {
  final String id;
  final String matiereName;
  final String className;
  final String? salleName;
  final DateTime date;
  final String startTime;
  final String endTime;
  final bool isExam;

  const SeanceItem({
    required this.id,
    required this.matiereName,
    required this.className,
    this.salleName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isExam,
  });

  SeanceStatus get status {
    final now = DateTime.now();
    final sp = startTime.split(':');
    final ep = endTime.split(':');
    final start = DateTime(
        date.year, date.month, date.day, int.parse(sp[0]), int.parse(sp[1]));
    final end = DateTime(
        date.year, date.month, date.day, int.parse(ep[0]), int.parse(ep[1]));
    if (now.isBefore(start)) return SeanceStatus.aVenir;
    if (now.isAfter(end)) return SeanceStatus.termine;
    return SeanceStatus.enCours;
  }

  String get location =>
      salleName != null ? '$className • $salleName' : className;

  factory SeanceItem.fromJson(Map<String, dynamic> json) {
    final s = json['start_time'] as String;
    final e = json['end_time'] as String;
    return SeanceItem(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: s.length >= 5 ? s.substring(0, 5) : s,
      endTime: e.length >= 5 ? e.substring(0, 5) : e,
      matiereName:
          (json['matieres'] as Map<String, dynamic>)['name'] as String,
      className:
          (json['classes'] as Map<String, dynamic>)['name'] as String,
      salleName: json['salles'] != null
          ? (json['salles'] as Map<String, dynamic>)['name'] as String?
          : null,
      isExam: json['is_exam'] as bool? ?? false,
    );
  }
}

class ClasseData {
  final String id;
  final String nom;
  final int studentCount;

  const ClasseData({
    required this.id,
    required this.nom,
    required this.studentCount,
  });
}

class AccueilLoadedData {
  final String firstName;
  final String lastName;
  final int pendingJustificatifs;
  final List<SeanceItem> todaySeances;
  final List<ClasseData> classes;

  const AccueilLoadedData({
    required this.firstName,
    required this.lastName,
    required this.pendingJustificatifs,
    required this.todaySeances,
    required this.classes,
  });

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l';
  }

  String get fullName => '$firstName $lastName';
}

// ─── Constantes ────────────────────────────────────────────────────────────

const _kNavy = Color(0xFF1C3D7A);
const _kOrange = Color(0xFFE87720);
const _kGreen = Color(0xFF27AE60);

const _kClassColors = [
  Color(0xFF1C3D7A),
  Color(0xFFE87720),
  Color(0xFF1C3D7A),
  Color(0xFF7B1FA2),
  Color(0xFFE53935),
  Color(0xFF0097A7),
];

// ─── Page chargée ──────────────────────────────────────────────────────────

class AccueilLoadedPage extends StatelessWidget {
  const AccueilLoadedPage({
    super.key,
    required this.data,
    required this.onRefresh,
  });

  final AccueilLoadedData data;
  final VoidCallback onRefresh;

  static String _monthAbbr(int month) {
    const m = [
      'JAN.', 'FÉV.', 'MAR.', 'AVR.', 'MAI.', 'JUN.',
      'JUL.', 'AOÛ.', 'SEP.', 'OCT.', 'NOV.', 'DÉC.',
    ];
    return m[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            sliver: SliverToBoxAdapter(child: _buildTodaySection()),
          ),
          if (data.classes.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 28, 0, 40),
              sliver: SliverToBoxAdapter(child: _buildClassesSection()),
            ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration:
                const BoxDecoration(color: _kNavy, shape: BoxShape.circle),
            child: Center(
              child: Text(
                data.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bonjour,',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
                Text(
                  data.fullName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  size: 20,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              if (data.pendingJustificatifs > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: _kOrange,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${data.pendingJustificatifs}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Section Aujourd'hui ───────────────────────────────────────────────────
  Widget _buildTodaySection() {
    final now = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Aujourd'hui" à gauche, "28 AVR." à droite
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const Text(
              "Aujourd'hui",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
              ),
            ),
            Text(
              '${now.day} ${_monthAbbr(now.month)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (data.todaySeances.isEmpty)
          const _EmptyState()
        else
          for (int i = 0; i < data.todaySeances.length; i++) ...[
            _SeanceCard(seance: data.todaySeances[i]),
            if (i < data.todaySeances.length - 1) const SizedBox(height: 10),
          ],
      ],
    );
  }

  // ── Section Mes classes ───────────────────────────────────────────────────
  Widget _buildClassesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 20),
          child: Text(
            'Mes classes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: data.classes.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _ClasseCard(
              classe: data.classes[i],
              color: _kClassColors[i % _kClassColors.length],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Carte séance ──────────────────────────────────────────────────────────

class _SeanceCard extends StatelessWidget {
  const _SeanceCard({required this.seance});

  final SeanceItem seance;

  @override
  Widget build(BuildContext context) {
    final s = seance.status;
    final isEnCours = s == SeanceStatus.enCours;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // Bordure verte complète pour EN COURS, sinon ombre légère
        border: isEnCours
            ? Border.all(color: _kGreen, width: 1.5)
            : null,
        boxShadow: isEnCours
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colonne heure gauche
          SizedBox(
            width: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seance.startTime,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  seance.endTime,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Contenu droite
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        seance.matiereName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusBadge(status: s),
                    if (seance.isExam) ...[
                      const SizedBox(width: 6),
                      const _ExamBadge(),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  seance.location,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final SeanceStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: status.badgeColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _ExamBadge extends StatelessWidget {
  const _ExamBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'EXAMEN',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Color(0xFFB45309),
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─── Carte classe ──────────────────────────────────────────────────────────

class _ClasseCard extends StatelessWidget {
  const _ClasseCard({required this.classe, required this.color});

  final ClasseData classe;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            classe.nom,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            '${classe.studentCount} étudiants',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── État vide ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline,
                size: 48, color: Color(0xFF9CA3AF)),
            SizedBox(height: 16),
            Text(
              'Aucune séance aujourd\'hui',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Profitez de votre journée libre !',
              style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
      ),
    );
  }
}
