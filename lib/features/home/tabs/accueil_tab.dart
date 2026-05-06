import 'dart:async';
import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/supabase/supabase_client.dart';
import '../data/home_models.dart';
import '../data/home_repository.dart';

class AccueilTab extends StatefulWidget {
  const AccueilTab({super.key});

  @override
  State<AccueilTab> createState() => _AccueilTabState();
}

class _AccueilTabState extends State<AccueilTab> {
  late Future<HomePageData> _future;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) => _load());
  }

  void _load() {
    setState(() {
      _future = SupabaseClientProvider.isInitialized
          ? HomeRepository().fetchHomeData()
          : Future.error('Supabase non configuré. Lance l\'app avec --dart-define.');
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HomePageData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppColors.greyBadge),
                  const SizedBox(height: 12),
                  Text(snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                      onPressed: _load, child: const Text('Réessayer')),
                ],
              ),
            ),
          );
        }
        return _buildContent(snapshot.data!);
      },
    );
  }

  Widget _buildContent(HomePageData data) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => _load(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        children: [
          _buildHeader(data),
          const SizedBox(height: 20),
          if (data.activeSession != null) ...[
            _SessionBanner(session: data.activeSession!),
            const SizedBox(height: 12),
          ],
          if (data.pendingJustificatifs > 0) ...[
            _JustificatifsBanner(count: data.pendingJustificatifs),
            const SizedBox(height: 24),
          ],
          _buildAujourdhuiSection(data.todaySeances),
          if (data.todaySeances.isEmpty && data.nextSeance != null) ...[
            const SizedBox(height: 24),
            _buildProchaineSeanceSection(data.nextSeance!),
          ],
          const SizedBox(height: 24),
          _buildMesClassesSection(data.classes),
        ],
      ),
    );
  }

  Widget _buildHeader(HomePageData data) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.navyBlue,
          child: Text(
            data.initials,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bonjour,',
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
              Text(data.fullName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 17)),
            ],
          ),
        ),
        _NotificationBell(count: data.pendingJustificatifs),
      ],
    );
  }

  Widget _buildAujourdhuiSection(List<SeanceModel> seances) {
    final now = DateTime.now();
    const mois = [
      'JAN', 'FÉV', 'MAR', 'AVR', 'MAI', 'JUN',
      'JUL', 'AOU', 'SEP', 'OCT', 'NOV', 'DÉC'
    ];
    final dateLabel = '${now.day} ${mois[now.month - 1]}.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Aujourd'hui",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(dateLabel,
                style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 12),
        if (seances.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.auto_awesome_outlined, size: 36, color: Colors.grey),
                  SizedBox(height: 10),
                  Text('Aucun cours programmé',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  SizedBox(height: 4),
                  Text('Profitez de votre journée libre.',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
          )
        else
          ...seances.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SeanceCard(seance: s),
              )),
      ],
    );
  }

  Widget _buildProchaineSeanceSection(SeanceModel seance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Prochaine séance',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        _ProchaineSeanceCard(seance: seance),
      ],
    );
  }

  Widget _buildMesClassesSection(List<ClasseModel> classes) {
    const cardColors = [AppColors.navyBlue, AppColors.orange];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mes classes',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        if (classes.isEmpty)
          const Text('Aucune classe assignée',
              style: TextStyle(color: Colors.grey))
        else
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: classes.length,
              itemBuilder: (context, i) => _ClasseCard(
                classe: classes[i],
                color: cardColors[i % cardColors.length],
              ),
            ),
          ),
      ],
    );
  }
}

// ── Notification bell avec badge numérique ─────────────────────────────────

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.notifications_outlined,
              size: 22, color: Colors.black87),
        ),
        if (count > 0)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.orange,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                '$count',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Bannière session en cours ──────────────────────────────────────────────

class _SessionBanner extends StatefulWidget {
  const _SessionBanner({required this.session});
  final ActiveSessionModel session;

  @override
  State<_SessionBanner> createState() => _SessionBannerState();
}

class _SessionBannerState extends State<_SessionBanner> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(
        const Duration(seconds: 30), (_) => setState(() => _now = DateTime.now()));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = _now.hour.toString().padLeft(2, '0');
    final m = _now.minute.toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Session en cours',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                const SizedBox(height: 3),
                Text(
                  '${widget.session.matiereName} • ${widget.session.className}',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('$h:$m',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

// ── Bannière justificatifs ─────────────────────────────────────────────────

class _JustificatifsBanner extends StatelessWidget {
  const _JustificatifsBanner({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.description_outlined,
                  color: AppColors.orange, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$count justificatif${count > 1 ? 's' : ''} en attente',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  const Text('Appuyez pour les traiter',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Carte séance ───────────────────────────────────────────────────────────

class _SeanceCard extends StatelessWidget {
  const _SeanceCard({required this.seance});
  final SeanceModel seance;

  @override
  Widget build(BuildContext context) {
    final status = seance.displayStatus;
    final isEnCours = status == SeanceDisplayStatus.enCours;

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Accent gauche vert pour EN COURS
            Container(
              width: 4,
              color: isEnCours ? AppColors.primary : Colors.transparent,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Colonne horaire
                    SizedBox(
                      width: 44,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(seance.displayStartTime,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(seance.displayEndTime,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Contenu
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  seance.matiereName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _StatusBadge(status: status),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(seance.locationLabel,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Badge statut ───────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final SeanceDisplayStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: status.color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.label,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2),
      ),
    );
  }
}

// ── Carte prochaine séance ─────────────────────────────────────────────────

class _ProchaineSeanceCard extends StatelessWidget {
  const _ProchaineSeanceCard({required this.seance});
  final SeanceModel seance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(seance.displayDayName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(seance.displayStartTime,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: Colors.grey.shade200,
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(seance.matiereName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(seance.locationLabel,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Carte classe ───────────────────────────────────────────────────────────

class _ClasseCard extends StatelessWidget {
  const _ClasseCard({required this.classe, required this.color});
  final ClasseModel classe;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              classe.nom,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${classe.studentCount} étudiant${classe.studentCount > 1 ? 's' : ''}',
            style: const TextStyle(
                color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
