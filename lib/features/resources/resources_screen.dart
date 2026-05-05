import 'package:flutter/material.dart';
import 'resources_models.dart';


const List<SubjectResource> _demoSubjects = [
  SubjectResource(
    id: '1',
    title: 'Bases de données',
    documentCount: 7,
    classTags: ['L3 SI', 'M1 Data'],
    lastUploadLabel: 'Dernier upload : 28 avr.',
  ),
  SubjectResource(
    id: '2',
    title: 'Réseaux',
    documentCount: 3,
    classTags: ['L3 SI'],
    lastUploadLabel: 'Dernier upload : 9 avr.',
  ),
  SubjectResource(
    id: '3',
    title: 'Microéconomie',
    documentCount: 12,
    classTags: ['L1 Éco', 'L2 Éco'],
    lastUploadLabel: 'Dernier ajout : TD 4',
  ),
  SubjectResource(
    id: '4',
    title: 'Théorie des Graphes',
    documentCount: 0,
    classTags: ['M1 Informatique'],
    lastUploadLabel: null,
  ),
];


const Color _primaryBlue = Color(0xFF1A2E5A);
const Color _accentOrange = Color(0xFFF57C2B);
const Color _tagBlueBg = Color(0xFFE8F0FE);
const Color _tagBlueText = Color(0xFF1A2E5A);
const Color _badgeBlueBg = Color(0xFF1A2E5A);
const Color _cardBg = Colors.white;
const Color _scaffoldBg = Color(0xFFF4F5F7);
const Color _skeletonBase = Color(0xFFE0E4EA);


class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  ResourcesUiState _uiState = ResourcesUiState.loading;
  List<SubjectResource> _subjects = [];

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources() async {
    // Simule un chargement de 1.2s puis affiche les données.
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() {
      _subjects = _demoSubjects;
      _uiState = _subjects.isEmpty
          ? ResourcesUiState.empty
          : ResourcesUiState.loaded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            _AppBar(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      floatingActionButton: _AddFab(),
      bottomNavigationBar: _BottomNav(),
    );
  }

  Widget _buildBody() {
    return switch (_uiState) {
      ResourcesUiState.loading => const _SkeletonList(),
      ResourcesUiState.empty   => const _EmptyState(),
      ResourcesUiState.loaded  => _SubjectList(subjects: _subjects),
    };
  }
}

                   
class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Ressources',
            style: TextStyle(
              color: _primaryBlue,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: _primaryBlue,
                  size: 20,
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class _SubjectList extends StatelessWidget {
  final List<SubjectResource> subjects;
  const _SubjectList({required this.subjects});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: subjects.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _SubjectCard(subject: subjects[i]),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final SubjectResource subject;
  const _SubjectCard({required this.subject});

  @override
  Widget build(BuildContext context) {
    final bool hasDocuments = subject.documentCount > 0;

    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        subject.title,
                        style: const TextStyle(
                          color: _primaryBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _DocumentBadge(count: subject.documentCount),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: subject.classTags
                      .map((tag) => _ClassTag(label: tag))
                      .toList(),
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      hasDocuments
                          ? (subject.lastUploadLabel ?? '')
                          : 'Aucun document publié',
                      style: TextStyle(
                        color: hasDocuments
                            ? Colors.grey.shade500
                            : Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    ),
                    if (hasDocuments)
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                        size: 18,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DocumentBadge extends StatelessWidget {
  final int count;
  const _DocumentBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: _badgeBlueBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count document${count > 1 ? 's' : ''}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ClassTag extends StatelessWidget {
  final String label;
  const _ClassTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: _tagBlueBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _tagBlueText,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}


class _SkeletonList extends StatefulWidget {
  const _SkeletonList();

  @override
  State<_SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<_SkeletonList>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _shimmer = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (_, _) => ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, _) => _SkeletonCard(opacity: _shimmer.value),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final double opacity;
  const _SkeletonCard({required this.opacity});

  Widget _box({double? width, double height = 14, double radius = 8}) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: _skeletonBase,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
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
              _box(width: 140, height: 16),
              const Spacer(),
              _box(width: 80, height: 22, radius: 20),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _box(width: 60),
              const SizedBox(width: 8),
              _box(width: 80),
            ],
          ),
          const SizedBox(height: 14),
          _box(height: 1, radius: 0),
          const SizedBox(height: 12),
          _box(width: 160, height: 12),
        ],
      ),
    );
  }
}


class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFEEEFF2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu_book_outlined,
                size: 32,
                color: Color(0xFF8A93A2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucune matière',
              style: TextStyle(
                color: _primaryBlue,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Vous n'avez aucune matière assignée. Les ressources s'afficheront ici une fois vos cours configurés.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF8A93A2),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _AddFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {},
      backgroundColor: _accentOrange,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    );
  }
}


class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_outlined,        label: 'Accueil',    active: false),
              _NavItem(icon: Icons.calendar_today_outlined, label: 'Calendrier', active: false),
              _NavItem(icon: Icons.layers_outlined,      label: 'Mes cours',  active: false),
              _NavItem(icon: Icons.folder_outlined,      label: 'Ressources', active: true),
              _NavItem(icon: Icons.person_outline,       label: 'Profil',     active: false),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? _primaryBlue : Colors.grey.shade400;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}