import 'dart:async';
import 'package:flutter/material.dart';
import '../classes/models/models.dart';

class SessionRecapScreen extends StatefulWidget {
  final ClassModel classInfo;

  const SessionRecapScreen({super.key, required this.classInfo});

  @override
  State<SessionRecapScreen> createState() => _SessionRecapScreenState();
}

class _SessionRecapScreenState extends State<SessionRecapScreen> {
  bool _isLoading = true;
  String _searchQuery = '';
  String _activeFilter = 'Tous';

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  void _simulateLoading() {
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF092C4C);
    const Color primaryDim = Color(0xFFE8EFF5);
    const Color secondary = Color(0xFFF2994A);
    const Color secondaryDim = Color(0xFFFEF3E7);
    const Color success = Color(0xFF27AE60);
    const Color successDim = Color(0xFFE8F8EF);
    const Color error = Color(0xFFEB5757);
    const Color errorDim = Color(0xFFFEECEC);
    const Color bg = Color(0xFFF5F7FA);
    const Color gray1 = Color(0xFF333333);
    const Color gray2 = Color(0xFF4F4F4F);
    const Color gray3 = Color(0xFF828282);
    const Color gray5 = Color(0xFFE0E0E0);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
                      bg.withOpacity(0),
                      bg.withOpacity(1),
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
                    shadowColor: primary.withOpacity(0.4),
                  ),
                  child: const Text(
                    'Valider et fermer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
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
            children: List.generate(4, (_) => _SkeletonBox(height: 80, borderRadius: 12)),
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
            children: List.generate(3, (_) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SkeletonBox(height: 64, borderRadius: 12),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final Color primary = const Color(0xFF092C4C);
    final Color gray3 = const Color(0xFF828282);
    final Color successDim = const Color(0xFFE8F8EF);
    final Color success = const Color(0xFF27AE60);
    final Color secondaryDim = const Color(0xFFFEF3E7);
    final Color secondary = const Color(0xFFF2994A);
    final Color errorDim = const Color(0xFFFEECEC);
    final Color error = const Color(0xFFEB5757);

    if (widget.classInfo.students.isEmpty) {
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
                  widget.classInfo.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF092C4C), // primary
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.classInfo.filiere} • Filière A',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF4F4F4F)),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _MetaItem(icon: Icons.calendar_today, label: 'Mar 28 Avr'),
                    const SizedBox(width: 12),
                    _MetaItem(icon: Icons.access_time, label: '10:15 - 12:15'),
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
              _StatBox(value: '42', label: 'Inscrits'),
              _StatBox(value: '28', label: 'Présents', color: success, bg: successDim),
              _StatBox(value: '12', label: 'Absents', color: error, bg: errorDim),
              _StatBox(value: '2', label: 'Retard', color: secondary, bg: secondaryDim),
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
            children: widget.classInfo.students
                .map((s) => _StudentItem(student: s))
                .toList(),
          ),
        ],
      ),
    );
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
              child: const Icon(Icons.people_outline, color: Color(0xFF828282), size: 32),
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
        boxShadow: bg == null ? const [
          BoxShadow(
            color: Color(0x0F092C4C),
            offset: Offset(0, 4),
            blurRadius: 16,
          ),
        ] : null,
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF092C4C) : Colors.white,
                  border: Border.all(
                    color: isActive ? const Color(0xFF092C4C) : const Color(0xFFE0E0E0),
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
  final StudentModel student;

  const _StudentItem({required this.student});

  @override
  Widget build(BuildContext context) {
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
              student.initials,
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
                  student.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF092C4C),
                  ),
                ),
                const Text(
                  'N° 20240123', // Static for demo
                  style: TextStyle(fontSize: 11, color: Color(0xFF828282)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F8EF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: const [
                Text(
                  'Présent',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF27AE60),
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, size: 12, color: Color(0xFF27AE60)),
              ],
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

  const _SkeletonBox({required this.height, this.width, required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0).withOpacity(0.5),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
