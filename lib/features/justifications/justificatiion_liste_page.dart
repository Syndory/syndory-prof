// lib/features/justifications/justification_list_page.dart

import 'package:flutter/material.dart';
import 'justification_model.dart';
import 'justification_repository.dart';
import 'justification_detail_page.dart';

class JustificationListPage extends StatefulWidget {
  const JustificationListPage({super.key});

  @override
  State<JustificationListPage> createState() => _JustificationListPageState();
}

class _JustificationListPageState extends State<JustificationListPage>
    with SingleTickerProviderStateMixin {
  // ── État ──────────────────────────────────────────────────────────────────

  late TabController _tabController;
  final _repo = const JustificationRepository();

  bool _loading = true;
  String? _errorMessage;
  List<JustificationModel> _all = [];

  // ── Cycle de vie ─────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Données ───────────────────────────────────────────────────────────────

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final data = await _repo.fetchAll();
      if (!mounted) return;
      setState(() {
        _all = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _loading = false;
      });
    }
  }

  List<JustificationModel> get _enAttente =>
      _all.where((j) => j.statut == JustificationStatut.enAttente).toList();

  List<JustificationModel> get _traites =>
      _all.where((j) => j.statut != JustificationStatut.enAttente).toList();

  // ── Navigation ────────────────────────────────────────────────────────────

  Future<void> _openDetail(JustificationModel justification) async {
    final reviewed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => JustificationDetailPage(justification: justification),
      ),
    );
    if (reviewed == true) _load();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Justificatifs',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF092C4C),
            ),
          ),
          if (!_loading)
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF4F4F4F)),
              onPressed: _load,
            ),
        ],
      ),
    );
  }

  // ── Tab bar ───────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    final pendingCount = _enAttente.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EFF5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF092C4C),
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF4F4F4F),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        tabs: [
          const Tab(text: 'Mes Classes'),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Justificatifs'),
                if (pendingCount > 0) ...[
                  const SizedBox(width: 6),
                  _Badge(count: pendingCount),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Corps ─────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    return TabBarView(
      controller: _tabController,
      children: [
        // Onglet "Mes Classes" – placeholder (autre équipe)
        const _PlaceholderTab(label: 'Mes Classes'),
        // Onglet "Justificatifs"
        _buildJustificatifsTab(),
      ],
    );
  }

  Widget _buildJustificatifsTab() {
    if (_loading) return const _LoadingState();
    if (_errorMessage != null) return _ErrorState(message: _errorMessage!, onRetry: _load);

    return RefreshIndicator(
      onRefresh: _load,
      color: const Color(0xFF092C4C),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          // ── En attente ───────────────────────────────────────────────────
          _SectionHeader(
            title: 'En attente',
            count: _enAttente.length,
          ),
          const SizedBox(height: 10),
          if (_enAttente.isEmpty)
            const _EmptySection(message: 'Aucun justificatif en attente')
          else
            ..._enAttente.map(
              (j) => _JustificationCard(
                justification: j,
                onTap: () => _openDetail(j),
              ),
            ),

          const SizedBox(height: 24),

          // ── Traités récemment ────────────────────────────────────────────
          const _SectionHeader(title: 'Traités récemment'),
          const SizedBox(height: 10),
          if (_traites.isEmpty)
            const _EmptySection(message: 'Aucun justificatif traité récemment')
          else
            ..._traites.map(
              (j) => _JustificationCard(
                justification: j,
                onTap: () => _openDetail(j),
              ),
            ),
        ],
      ),
    );
  }

  // ── Bottom navigation ─────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 2, // "Mes cours"
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF092C4C),
      unselectedItemColor: const Color(0xFFBDBDBD),
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 11,
      ),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_outlined),
          label: 'Calendrier',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_outlined),
          label: 'Mes cours',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.folder_open_outlined),
          label: 'Ressources',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profil',
        ),
      ],
    );
  }
}

// ─── Widgets internes ─────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFEB5757),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int? count;
  const _SectionHeader({required this.title, this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF092C4C),
          ),
        ),
        if (count != null && count! > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EFF5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF092C4C),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _EmptySection extends StatelessWidget {
  final String message;
  const _EmptySection({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF092C4C)),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded,
                size: 48, color: Color(0xFFEB5757)),
            const SizedBox(height: 12),
            const Text(
              'Erreur de chargement',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Color(0xFF092C4C),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF828282), fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF092C4C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999)),
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String label;
  const _PlaceholderTab({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: const TextStyle(color: Color(0xFFBDBDBD)),
      ),
    );
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────────

class _JustificationCard extends StatelessWidget {
  final JustificationModel justification;
  final VoidCallback onTap;

  const _JustificationCard({
    required this.justification,
    required this.onTap,
  });

  Color _avatarColor(String name) {
    const colors = [
      Color(0xFF3B82F6),
      Color(0xFF8B5CF6),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFF092C4C),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final j = justification;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: _avatarColor(j.studentFullName),
              child: Text(
                j.studentInitials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    j.studentFullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF092C4C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Absence le ${j.dateAbsenceDisplay}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF828282),
                    ),
                  ),
                  if (j.matiereNom != null)
                    Text(
                      'Cours : ${j.matiereNom}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF828282),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Badge statut
            _StatutBadge(statut: j.statut),
          ],
        ),
      ),
    );
  }
}

class _StatutBadge extends StatelessWidget {
  final JustificationStatut statut;
  const _StatutBadge({required this.statut});

  @override
  Widget build(BuildContext context) {
    switch (statut) {
      case JustificationStatut.enAttente:
        return _badge('ATTENTE', const Color(0xFFEA580C), const Color(0xFFFFF7ED));
      case JustificationStatut.valide:
        return _badge('VALIDÉ', const Color(0xFF16A34A), const Color(0xFFF0FDF4));
      case JustificationStatut.rejete:
        return _badge('REFUSÉ', const Color(0xFFDC2626), const Color(0xFFFFF1F2));
    }
  }

  Widget _badge(String label, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}