import 'package:flutter/material.dart';
import 'justification_model.dart';
import 'justification_repository.dart';
import 'justification_ui_states.dart';
import 'justification_detail_page.dart';

enum _ScreenState { loading, error, empty, allCaughtUp, loaded }

class JustificationsScreen extends StatefulWidget {
  const JustificationsScreen({super.key});

  @override
  State<JustificationsScreen> createState() => _JustificationsScreenState();
}

class _JustificationsScreenState extends State<JustificationsScreen> {
  final _repo = const JustificationRepository();

  _ScreenState _state = _ScreenState.loading;
  List<JustificationModel> _items = [];
  String? _errorMessage;
  JustificationStatut? _activeFilter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _state = _ScreenState.loading;
      _errorMessage = null;
    });

    try {
      final list = await _repo.fetchAll();

      if (!mounted) return;

      if (list.isEmpty) {
        setState(() => _state = _ScreenState.empty);
        return;
      }

      final hasAnyPending = list.any(
        (j) => j.statut == JustificationStatut.enAttente,
      );

      setState(() {
        _items = list;
        _state = hasAnyPending ? _ScreenState.loaded : _ScreenState.allCaughtUp;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _ScreenState.error;
        _errorMessage = 'Impossible de charger les justificatifs.';
      });
    }
  }

  List<JustificationModel> get _filtered {
    if (_activeFilter == null) return _items;
    return _items.where((j) => j.statut == _activeFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Justificatifs',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF092C4C),
          ),
        ),
        centerTitle: true,
        actions: [
          if (_state == _ScreenState.loaded ||
              _state == _ScreenState.allCaughtUp)
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF4F4F4F)),
              onPressed: _load,
            ),
        ],
      ),
      body: Column(
        children: [
          if (_state == _ScreenState.loaded) _buildFilterBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = [
      (null, 'Tous'),
      (JustificationStatut.enAttente, 'En attente'),
      (JustificationStatut.valide, 'Validés'),
      (JustificationStatut.rejete, 'Rejetés'),
    ];

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: filters.map((f) {
          final isActive = _activeFilter == f.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(f.$2),
              selected: isActive,
              onSelected: (_) => setState(() => _activeFilter = f.$1),
              selectedColor: const Color(0xFF092C4C),
              labelStyle: TextStyle(
                color: isActive ? Colors.white : const Color(0xFF4F4F4F),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isActive
                    ? const Color(0xFF092C4C)
                    : const Color(0xFFE0E0E0),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case _ScreenState.loading:
        return const JustificationSkeletonList();
      case _ScreenState.error:
        return JustificationErrorState(message: _errorMessage, onRetry: _load);
      case _ScreenState.empty:
        return const JustificationEmptyState();
      case _ScreenState.allCaughtUp:
        return const JustificationAllCaughtUpState();
      case _ScreenState.loaded:
        final items = _filtered;
        if (items.isEmpty) {
          return const Center(
            child: Text(
              'Aucun justificatif dans cette catégorie.',
              style: TextStyle(fontSize: 14, color: Color(0xFF828282)),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: _load,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) =>
                _JustificatifCard(item: items[i], onReviewed: _load),
          ),
        );
    }
  }
}

class _JustificatifCard extends StatelessWidget {
  final JustificationModel item;
  final VoidCallback onReviewed;

  const _JustificatifCard({required this.item, required this.onReviewed});

  Color get _statusColor {
    switch (item.statut) {
      case JustificationStatut.enAttente:
        return const Color(0xFFF2994A);
      case JustificationStatut.valide:
        return const Color(0xFF219653);
      case JustificationStatut.rejete:
        return const Color(0xFFEB5757);
    }
  }

  IconData get _statusIcon {
    switch (item.statut) {
      case JustificationStatut.enAttente:
        return Icons.hourglass_empty_outlined;
      case JustificationStatut.valide:
        return Icons.check_circle_outline;
      case JustificationStatut.rejete:
        return Icons.cancel_outlined;
    }
  }

  String get _statusLabel {
    switch (item.statut) {
      case JustificationStatut.enAttente:
        return 'En attente';
      case JustificationStatut.valide:
        return 'Validé';
      case JustificationStatut.rejete:
        return 'Rejeté';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => JustificationDetailPage(justification: item),
          ),
        );
        onReviewed();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: item.statut == JustificationStatut.enAttente
                ? const Color(0xFFF2994A)
                : const Color(0xFFE0E0E0),
            width: item.statut == JustificationStatut.enAttente ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF092C4C),
                  child: Text(
                    item.studentInitials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.studentFullName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF092C4C),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.matiereNom ?? 'Matière inconnue',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF828282),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon, size: 13, color: _statusColor),
                      const SizedBox(width: 4),
                      Text(
                        _statusLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: _statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Color(0xFF828282),
                ),
                const SizedBox(width: 6),
                Text(
                  item.dateAbsenceDisplay,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4F4F4F),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.access_time_outlined,
                  size: 14,
                  color: Color(0xFF828282),
                ),
                const SizedBox(width: 6),
                Text(
                  item.creneauxDisplay,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4F4F4F),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (item.statut == JustificationStatut.rejete &&
                item.rejectionReason != null &&
                item.rejectionReason!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDECEC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Motif : ${item.rejectionReason}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFEB5757),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
            if (item.statut == JustificationStatut.enAttente) ...[
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.chevron_right, color: Color(0xFF828282), size: 20),
                  Text(
                    'Voir détails',
                    style: TextStyle(fontSize: 12, color: Color(0xFF828282)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
