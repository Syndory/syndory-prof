import 'package:flutter/material.dart';

import '../../../../app/navigation/main_shell.dart';
import '../../../notifications/notifications_screen.dart';
import '../../domain/justification_model.dart';
import '../justification_controller.dart';
import 'justification_detail_page.dart';

class JustificationListPage extends StatefulWidget {
  const JustificationListPage({super.key});

  @override
  State<JustificationListPage> createState() => _JustificationListPageState();
}

class _JustificationListPageState extends State<JustificationListPage> {
  final JustificationController _controller = JustificationController();

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openShell(int index) {
    if (index == 2) {
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => MainShell(initialIndex: index)),
      (route) => false,
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month';
  }

  String _statusLabel(JustificationStatus status) {
    switch (status) {
      case JustificationStatus.pending:
        return 'Attente';
      case JustificationStatus.approved:
        return 'Validé';
      case JustificationStatus.rejected:
        return 'Refusé';
    }
  }

  Color _statusForeground(JustificationStatus status) {
    switch (status) {
      case JustificationStatus.pending:
        return const Color(0xFFF2994A);
      case JustificationStatus.approved:
        return const Color(0xFF27AE60);
      case JustificationStatus.rejected:
        return const Color(0xFFEB5757);
    }
  }

  Color _statusBackground(JustificationStatus status) {
    switch (status) {
      case JustificationStatus.pending:
        return const Color(0xFFFEF3E7);
      case JustificationStatus.approved:
        return const Color(0xFFE8F8EF);
      case JustificationStatus.rejected:
        return const Color(0xFFFEECEC);
    }
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Justificatifs',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF092C4C),
              letterSpacing: -0.02,
            ),
          ),
          Row(
            children: [
              _IconButton(
                icon: Icons.refresh_rounded,
                onPressed: _controller.load,
              ),
              const SizedBox(width: 8),
              _IconButton(
                icon: Icons.notifications_none,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubTabs(int pendingCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Row(
        children: [
          Expanded(
            child: _PillTab(
              label: 'Mes Classes',
              active: false,
              onTap: () => _openShell(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _PillTab(
              label: 'Justificatifs',
              active: true,
              badge: pendingCount,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {int? count}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF092C4C),
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF828282),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildJustificationItem(Justification item, {bool dimmed = false}) {
    final statusColor = _statusForeground(item.status);
    final statusBg = _statusBackground(item.status);

    return Opacity(
      opacity: dimmed ? 0.8 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F092C4C),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
            BoxShadow(
              color: Color(0x0A092C4C),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.transparent),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => JustificationDetailPage(justification: item),
                ),
              );
              if (result == true) {
                _controller.load();
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFE8EFF5),
                    child: Text(
                      item.initials,
                      style: const TextStyle(
                        color: Color(0xFF092C4C),
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
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
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF092C4C),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Absence du ${_formatDate(item.date)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF828282),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Cours : ${item.subjectName}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4F4F4F),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      _statusLabel(item.status),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingContent() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      children: [
        _buildSectionTitle('En attente', count: 0),
        const _LoadingCard(),
        const SizedBox(height: 24),
        _buildSectionTitle('Traités récemment'),
        const _LoadingCard(),
      ],
    );
  }

  Widget _buildErrorContent(String? error) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 80,
                  color: Color(0xFFEB5757),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Oups ! Une erreur est survenue',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF092C4C),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  error ??
                      'Impossible de charger les justificatifs. Vérifiez votre connexion.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF828282),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _controller.load,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF092C4C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(JustificationState state) {
    if (state.status == JustificationStateStatus.loading ||
        state.status == JustificationStateStatus.initial) {
      return _buildLoadingContent();
    }

    if (state.status == JustificationStateStatus.error) {
      return _buildErrorContent(state.error);
    }

    final pendingItems = _controller.pendingItems;
    final processedItems = _controller.processedItems;

    return RefreshIndicator(
      onRefresh: _controller.load,
      color: const Color(0xFF092C4C),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        children: [
          _buildSectionTitle('En attente', count: pendingItems.length),
          if (pendingItems.isEmpty)
            _EmptySectionCard(
              title: 'Tout est en ordre !',
              description: 'Aucun justificatif en attente pour le moment.',
              icon: Icons.assignment_turned_in_outlined,
            )
          else
            ...pendingItems.map(_buildJustificationItem),
          const SizedBox(height: 24),
          _buildSectionTitle('Traités récemment'),
          if (processedItems.isEmpty)
            _EmptySectionCard(
              title: 'Aucun justificatif traité',
              description:
                  'Les justificatifs validés ou refusés apparaîtront ici.',
              icon: Icons.history_rounded,
            )
          else
            ...processedItems.map(
              (item) => _buildJustificationItem(item, dimmed: true),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 2,
      onTap: _openShell,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF092C4C),
      unselectedItemColor: const Color(0xFFBDBDBD),
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_outlined),
          activeIcon: Icon(Icons.calendar_month),
          label: 'Calendrier',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_outlined),
          activeIcon: Icon(Icons.menu_book),
          label: 'Mes cours',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.folder_outlined),
          activeIcon: Icon(Icons.folder),
          label: 'Ressources',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(color: Color(0xFFF5F7FA)),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildTopBar(),
                    _buildSubTabs(_controller.pendingItems.length),
                    Expanded(
                      child: ValueListenableBuilder<JustificationState>(
                        valueListenable: _controller,
                        builder: (context, state, child) {
                          return _buildContent(state);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomNav()),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _IconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F092C4C),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x0A092C4C),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 20,
        icon: Icon(icon, color: const Color(0xFF4F4F4F)),
        onPressed: onPressed,
      ),
    );
  }
}

class _PillTab extends StatelessWidget {
  final String label;
  final bool active;
  final int? badge;
  final VoidCallback onTap;

  const _PillTab({
    required this.label,
    required this.active,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(9999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF092C4C) : Colors.white,
            borderRadius: BorderRadius.circular(9999),
            border: active
                ? Border.all(color: const Color(0xFF092C4C))
                : Border.all(color: const Color(0xFFE0E0E0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x05000000),
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : const Color(0xFF4F4F4F),
                ),
              ),
              if (badge != null)
                Positioned(
                  top: -6,
                  right: -16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEB5757),
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(
                        color: const Color(0xFFF5F7FA),
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x4DEB5757),
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      '$badge',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySectionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _EmptySectionCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F092C4C),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFE8EFF5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF092C4C), size: 36),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF092C4C),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4F4F4F),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F092C4C),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        children: [
          _LoadingAvatar(),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LoadingBar(widthFactor: 0.65),
                SizedBox(height: 8),
                _LoadingBar(widthFactor: 0.45, height: 10),
                SizedBox(height: 8),
                _LoadingBar(widthFactor: 0.55, height: 10),
              ],
            ),
          ),
          SizedBox(width: 12),
          _LoadingBadge(),
        ],
      ),
    );
  }
}

class _LoadingAvatar extends StatelessWidget {
  const _LoadingAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _LoadingBar extends StatelessWidget {
  final double widthFactor;
  final double height;

  const _LoadingBar({this.widthFactor = 1, this.height = 12});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
    );
  }
}

class _LoadingBadge extends StatelessWidget {
  const _LoadingBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(9999),
      ),
    );
  }
}
