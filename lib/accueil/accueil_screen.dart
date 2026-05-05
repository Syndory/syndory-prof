import 'package:flutter/material.dart';

import 'accueil_error.dart';
import 'accueil_repository.dart';
import 'models/seance_du_jour.dart';

class AccueilScreen extends StatefulWidget {
  const AccueilScreen({super.key});

  @override
  State<AccueilScreen> createState() => _AccueilScreenState();
}

class _AccueilScreenState extends State<AccueilScreen> {
  late Future<AccueilData> _future;

  @override
  void initState() {
    super.initState();
    _future = AccueilRepository().fetchAccueilData();
  }

  void _reload() => setState(() {
        _future = AccueilRepository().fetchAccueilData();
      });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AccueilData>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return NoConnectionPage(onRetry: _reload);
        }
        return _AccueilContent(data: snap.requireData, onRefresh: _reload);
      },
    );
  }
}

// ---------------------------------------------------------------------------

class _AccueilContent extends StatelessWidget {
  const _AccueilContent({required this.data, required this.onRefresh});

  final AccueilData data;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _GreetingHeader(firstName: data.professorFirstName),
          ),
          if (data.seances.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(),
            )
          else ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              sliver: SliverToBoxAdapter(
                child: Text(
                  "SÉANCES D'AUJOURD'HUI",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList.separated(
                itemCount: data.seances.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _SeanceCard(seance: data.seances[i]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.firstName});

  final String firstName;

  static String _formatDate(DateTime dt) {
    const days = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];
    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return '${days[dt.weekday - 1]} ${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bonjour, $firstName',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(DateTime.now()),
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _SeanceCard extends StatelessWidget {
  const _SeanceCard({required this.seance});

  final SeanceDuJour seance;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${seance.startTime} – ${seance.endTime}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
              if (seance.isExam) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
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
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            seance.matiereName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            seance.salleName != null
                ? '${seance.className} · ${seance.salleName}'
                : seance.className,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.check_circle_outline, size: 48, color: Color(0xFF9CA3AF)),
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
    );
  }
}
