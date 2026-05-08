import 'package:flutter/material.dart';
import '../classes/models/models.dart';
import '../../data/repositories/classes_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/models/student_model.dart';

class SessionRecapScreen extends StatefulWidget {
  final ClassModel classInfo;
  final String? sessionId;

  const SessionRecapScreen({
    super.key,
    required this.classInfo,
    this.sessionId,
  });

  @override
  State<SessionRecapScreen> createState() => _SessionRecapScreenState();
}

class _SessionRecapScreenState extends State<SessionRecapScreen> {
  bool _isLoading = true;
  String _searchQuery = '';
  String _activeFilter = 'Tous';
  
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _presences = [];
  Map<String, dynamic>? _sessionDetails;

  @override
  void initState() {
    super.initState();
    _fetchRecapData();
  }

  Future<void> _fetchRecapData() async {
    try {
      // 1. Fetch class students
      final studentsData = await ClassesRepository.getStudentsForClass(widget.classInfo.id);
      
      // 2. Fetch session details and presences if sessionId is provided
      if (widget.sessionId != null) {
        final details = await SessionRepository.getSessionDetails(widget.sessionId!);
        final presences = await SessionRepository.getSessionPresences(widget.sessionId!);
        
        if (mounted) {
          setState(() {
            _sessionDetails = details;
            _presences = presences;
          });
        }
      }

      if (mounted) {
        setState(() {
          _students = studentsData;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[Recap] Error fetching data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF092C4C);
    const Color bg = Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _CircularButton(
                            icon: Icons.arrow_back,
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Récapitulatif',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF092C4C), // primary
                              letterSpacing: -0.18,
                            ),
                          ),
                        ],
                      ),
                      _CircularButton(
                        icon: Icons.notifications_none,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: _isLoading ? _buildSkeleton() : _buildContent(),
                ),
              ],
            ),
          ),

          // Bottom Action
          if (!_isLoading)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      bg.withValues(alpha: 0),
                      bg.withValues(alpha: 1),
                      bg,
                    ],
                    stops: const [0, 0.4, 1],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to dashboard or home
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    elevation: 8,
                    shadowColor: primary.withValues(alpha: 0.4),
                  ),
                  child: const Text(
                    'Valider et fermer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _SkeletonBox(height: 120, borderRadius: 24),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2,
            children: List.generate(
              4,
              (_) => _SkeletonBox(height: 80, borderRadius: 12),
            ),
          ),
          const SizedBox(height: 24),
          _SkeletonBox(height: 48, borderRadius: 99),
          const SizedBox(height: 12),
          Row(
            children: [
              _SkeletonBox(height: 32, width: 60, borderRadius: 99),
              const SizedBox(width: 8),
              _SkeletonBox(height: 32, width: 80, borderRadius: 99),
            ],
          ),
          const SizedBox(height: 24),
          Column(
            children: List.generate(
              3,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SkeletonBox(height: 64, borderRadius: 12),
              ),
            ),
          ),
        ],
      ),
    );
  Widget _buildContent() {
    final Color successDim = const Color(0xFFE8F8EF);
    final Color success = const Color(0xFF27AE60);
    final Color secondaryDim = const Color(0xFFFEF3E7);
    final Color secondary = const Color(0xFFF2994A);
    final Color errorDim = const Color(0xFFFEECEC);
    final Color error = const Color(0xFFEB5757);

    final seance = _sessionDetails?['seances'];
    final matiereName = seance?['matieres']?['name'] ?? (widget.classInfo.subjects.isNotEmpty ? widget.classInfo.subjects.first : 'Matière');
    final startTime = seance?['start_time']?.toString().substring(0, 5) ?? '--:--';
    final endTime = seance?['end_time']?.toString().substring(0, 5) ?? '--:--';
    
    // Stats
    final totalInscrits = _students.length;
    final presentCount = _presences.where((p) => p['status'] == 'present').length;
    final lateCount = _presences.where((p) => p['status'] == 'late').length;
    final absentCount = totalInscrits - _presences.length;

    // Filtered students list
    final List<Map<String, dynamic>> combinedList = _students.map((student) {
      final userId = student['users']['id'];
      final presence = _presences.firstWhere(
        (p) => p['student_id'] == userId,
        orElse: () => {'status': 'absent'},
      );
      return {
        ...student,
        'status': presence['status'],
      };
    }).where((s) {
      final name = '${s['users']['first_name']} ${s['users']['last_name']}'.toLowerCase();
      final matchesSearch = name.contains(_searchQuery.toLowerCase());
      
      if (_activeFilter == 'Tous') return matchesSearch;
      if (_activeFilter == 'Présents') return matchesSearch && s['status'] == 'present';
      if (_activeFilter == 'Absents') return matchesSearch && s['status'] == 'absent';
      if (_activeFilter == 'Retard') return matchesSearch && s['status'] == 'late';
      return matchesSearch;
    }).toList();

    if (_students.isEmpty && !_isLoading) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
      child: Column(
        children: [
          // Recap Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.white, Color(0xFFFAFCFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F092C4C),
                  offset: Offset(0, 4),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  matiereName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF092C4C), // primary
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.classInfo.title} • ${widget.classInfo.filiere}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4F4F4F),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _MetaItem(
                      icon: Icons.calendar_today, 
                      label: _sessionDetails?['opened_at'] != null 
                        ? _formatDate(DateTime.parse(_sessionDetails!['opened_at']))
                        : 'Aujourd\'hui'
                    ),
                    const SizedBox(width: 12),
                    _MetaItem(icon: Icons.access_time, label: '$startTime - $endTime'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Stats Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: [
              _StatBox(value: '$totalInscrits', label: 'Inscrits'),
              _StatBox(
                value: '$presentCount',
                label: 'Présents',
                color: success,
                bg: successDim,
              ),
              _StatBox(
                value: '$absentCount',
                label: 'Absents',
                color: error,
                bg: errorDim,
              ),
              _StatBox(
                value: '$lateCount',
                label: 'Retard',
                color: secondary,
                bg: secondaryDim,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Tools
          _SearchBar(onChanged: (val) => setState(() => _searchQuery = val)),
          const SizedBox(height: 12),
          _Filters(
            activeFilter: _activeFilter,
            onFilterChanged: (filter) => setState(() => _activeFilter = filter),
          ),

          const SizedBox(height: 24),

          // Student List
          Column(
            children: combinedList
                .map((s) => _StudentItem(studentData: s))
                .toList(),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
    final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return '${days[date.weekday - 1]} ${date.day} ${months[date.month - 1]}';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0F092C4C),
                    offset: Offset(0, 4),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Icon(
                Icons.people_outline,
                color: Color(0xFF828282),
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aucun étudiant',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF092C4C),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Il n\'y a aucun étudiant inscrit dans cette classe.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF4F4F4F),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircularButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CircularButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F092C4C),
            offset: Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF092C4C), size: 20),
        onPressed: onPressed,
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF828282)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF828282),
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color? color;
  final Color? bg;

  const _StatBox({
    required this.value,
    required this.label,
    this.color,
    this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: bg == null
            ? const [
                BoxShadow(
                  color: Color(0x0F092C4C),
                  offset: Offset(0, 4),
                  blurRadius: 16,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: color ?? const Color(0xFF092C4C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4F4F4F),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFFBDBDBD), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: 'Rechercher un étudiant...',
                hintStyle: TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;

  const _Filters({required this.activeFilter, required this.onFilterChanged});

  @override
  Widget build(BuildContext context) {
    final filters = ['Tous', 'Présents', 'Absents', 'Retard'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isActive = activeFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onFilterChanged(f),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF092C4C) : Colors.white,
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFF092C4C)
                        : const Color(0xFFE0E0E0),
                  ),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : const Color(0xFF4F4F4F),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StudentItem extends StatelessWidget {
  final Map<String, dynamic> studentData;

  const _StudentItem({required this.studentData});

  @override
  Widget build(BuildContext context) {
    final user = studentData['users'] as Map<String, dynamic>;
    final firstName = user['first_name'] as String? ?? '';
    final lastName = user['last_name'] as String? ?? '';
    final name = '$firstName $lastName';
    final status = studentData['status'] as String? ?? 'absent';
    
    final initials = (firstName.isNotEmpty ? firstName[0] : '') + (lastName.isNotEmpty ? lastName[0] : '');

    Color statusColor;
    Color statusBg;
    String statusLabel;

    switch (status) {
      case 'present':
        statusColor = const Color(0xFF27AE60);
        statusBg = const Color(0xFFE8F8EF);
        statusLabel = 'Présent';
        break;
      case 'late':
        statusColor = const Color(0xFFF2994A);
        statusBg = const Color(0xFFFEF3E7);
        statusLabel = 'Retard';
        break;
      default:
        statusColor = const Color(0xFFEB5757);
        statusBg = const Color(0xFFFEECEC);
        statusLabel = 'Absent';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            offset: Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFE8EFF5),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF092C4C),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF092C4C),
                  ),
                ),
                Text(
                  'N° ${user['id'].toString().substring(0, 8)}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF828282)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const _SkeletonBox({
    required this.height,
    this.width,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
