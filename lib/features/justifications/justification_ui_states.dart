import 'package:flutter/material.dart';

class JustificationSkeletonList extends StatefulWidget {
  const JustificationSkeletonList({super.key});

  @override
  State<JustificationSkeletonList> createState() =>
      _JustificationSkeletonListState();
}

class _JustificationSkeletonListState extends State<JustificationSkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.9).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, __) => _SkeletonCard(opacity: _anim.value),
        );
      },
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final double opacity;
  const _SkeletonCard({required this.opacity});

  Widget _box({double width = double.infinity, double height = 14}) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Opacity(
                opacity: opacity,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0E0E0),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(height: 16),
                    const SizedBox(height: 6),
                    _box(width: 140, height: 12),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _box(width: 72, height: 28),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _box(width: 100, height: 12),
              const SizedBox(width: 12),
              _box(width: 80, height: 12),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _box(width: 90, height: 32),
              const SizedBox(width: 8),
              _box(width: 90, height: 32),
            ],
          ),
        ],
      ),
    );
  }
}

class JustificationEmptyState extends StatelessWidget {
  const JustificationEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF3FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.inbox_outlined, size: 44, color: Color(0xFF2F80ED)),
              ),
              const SizedBox(height: 20),
              const Text(
                'Aucun justificatif',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF092C4C)),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Vos étudiants n\'ont soumis aucun justificatif pour le moment.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF828282), height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class JustificationAllCaughtUpState extends StatelessWidget {
  const JustificationAllCaughtUpState({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F8F0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline, size: 44, color: Color(0xFF219653)),
              ),
              const SizedBox(height: 20),
              const Text(
                'Tout est traité !',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF092C4C)),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Vous avez traité tous les justificatifs en attente. Revenez plus tard.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF828282), height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class JustificationErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const JustificationErrorState({super.key, this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: Color(0xFFFDECEC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.wifi_off_outlined, size: 44, color: Color(0xFFEB5757)),
              ),
              const SizedBox(height: 20),
              const Text(
                'Erreur de chargement',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF092C4C)),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  message ?? 'Impossible de charger les justificatifs.\nVérifiez votre connexion.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF828282), height: 1.5),
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Réessayer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF092C4C),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
