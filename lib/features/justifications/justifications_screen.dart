import 'package:flutter/material.dart';
import 'package:syndory_prof/data/supabase/supabase_client.dart';
import 'justification_models.dart';
import 'justification_ui_states.dart';

enum _ScreenState { loading, error, empty, allCaughtUp, loaded }

class JustificationsScreen extends StatefulWidget {
  const JustificationsScreen({super.key});

  @override
  State<JustificationsScreen> createState() => _JustificationsScreenState();
}

class _JustificationsScreenState extends State<JustificationsScreen> {
  _ScreenState _state = _ScreenState.loading;
  List<Justificatif> _items = [];
  String? _errorMessage;
  JustificationStatus? _activeFilter;

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

    if (!SupabaseClientProvider.isInitialized) {
      setState(() {
        _state = _ScreenState.error;
        _errorMessage = 'Supabase non initialisé.';
      });
      return;
    }

    final session = SupabaseClientProvider.client.auth.currentSession;
    if (session == null) {
      setState(() {
        _state = _ScreenState.error;
        _errorMessage = 'Session expirée. Reconnectez-vous.';
      });
      return;
    }

    try {
      final professorId = session.user.id;

      final result = await SupabaseClientProvider.client
          .from('justificatifs')
          .select(
            'id, file_url, status, rejection_reason, created_at, '
            'presences('
            '  users(first_name, last_name), '
            '  sessions('
            '    seances('
            '      date, '
            '      classes(name, code), '
            '      matieres(name, code)'
            '    )'
            '  )'
            ')',
          )
          .eq('presences.sessions.seances.professor_id', professorId)
          .order('created_at', ascending: false);

      if (!mounted) return;

      final list = (result as List)
          .cast<Map<String, dynamic>>()
          .map(Justificatif.fromMap)
          .toList();

      if (list.isEmpty) {
        setState(() => _state = _ScreenState.empty);
        return;
      }

      final hasAnyPending =
          list.any((j) => j.status == JustificationStatus.enAttente);

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

  List<Justificatif> get _filtered {
    if (_activeFilter == null) return _items;
    return _items.where((j) => j.status == _activeFilter).toList();
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
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF092C4C)),
        ),
        centerTitle: true,
        actions: [
          if (_state == _ScreenState.loaded || _state == _ScreenState.allCaughtUp)
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
      (JustificationStatus.enAttente, 'En attente'),
      (JustificationStatus.valide, 'Validés'),
      (JustificationStatus.rejete, 'Rejetés'),
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
                color: isActive ? const Color(0xFF092C4C) : const Color(0xFFE0E0E0),
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
            itemBuilder: (_, i) => _JustificatifCard(item: items[i]),
          ),
        );
    }
  }
}

class _JustificatifCard extends StatelessWidget {
  final Justificatif item;
  const _JustificatifCard({required this.item});

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final status = item.status;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: status == JustificationStatus.enAttente
              ? const Color(0xFFF2994A)
              : const Color(0xFFE0E0E0),
          width: status == JustificationStatus.enAttente ? 1.5 : 1,
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
                  _initials(item.studentName),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.studentName,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF092C4C)),
                    ),
                    const SizedBox(height: 2),
                    Text(item.className, style: const TextStyle(fontSize: 12, color: Color(0xFF828282))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: status.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(status.icon, size: 13, color: status.color),
                    const SizedBox(width: 4),
                    Text(status.label, style: TextStyle(fontSize: 12, color: status.color, fontWeight: FontWeight.w700)),
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
              const Icon(Icons.menu_book_outlined, size: 14, color: Color(0xFF828282)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(item.subjectName, style: const TextStyle(fontSize: 13, color: Color(0xFF4F4F4F), fontWeight: FontWeight.w500)),
              ),
              const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF828282)),
              const SizedBox(width: 6),
              Text(item.seanceDate, style: const TextStyle(fontSize: 13, color: Color(0xFF4F4F4F), fontWeight: FontWeight.w500)),
            ],
          ),
          if (item.status == JustificationStatus.rejete &&
              item.rejectionReason != null &&
              item.rejectionReason!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFFDECEC), borderRadius: BorderRadius.circular(10)),
              child: Text(
                'Motif : ${item.rejectionReason}',
                style: const TextStyle(fontSize: 12, color: Color(0xFFEB5757), fontStyle: FontStyle.italic),
              ),
            ),
          ],
          if (item.status == JustificationStatus.enAttente) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                if (item.fileUrl != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.attach_file, size: 16),
                      label: const Text('Voir fichier'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2F80ED),
                        side: const BorderSide(color: Color(0xFF2F80ED)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                if (item.fileUrl != null) const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Rejeter'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEB5757),
                      side: const BorderSide(color: Color(0xFFEB5757)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Valider'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF219653),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
