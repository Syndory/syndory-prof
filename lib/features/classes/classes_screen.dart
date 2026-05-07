import 'dart:async';

import 'package:flutter/material.dart';
import '../../data/repositories/classes_repository.dart';
import '../justifications/domain/justification_model.dart';
import '../justifications/data/justification_repository.dart';
import '../justifications/presentation/widgets/justification_card.dart';
import '../justifications/presentation/pages/justification_detail_page.dart';
import 'models/models.dart';
import '../session/pre_session_screen.dart';
import 'widgets/class_card.dart';
import 'widgets/class_skeleton.dart';
import 'widgets/state_box.dart';
import '../notifications/notifications_screen.dart';

enum ClassesUiState { loading, empty, error, loaded }

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  ClassesUiState _state = ClassesUiState.loading;
  List<ClassModel> _classes = [];
  List<Justification> _justifications = [];
  int _pendingJustificationsCount = 0;
  int _selectedSubTab = 0;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() {
      _state = ClassesUiState.loading;
    });

    try {
      final results = await Future.wait([
        ClassesRepository.getProfessorClasses(),
        JustificationRepository().fetchAll(),
      ]);

      final rawClasses = results[0] as List<Map<String, dynamic>>;
      final allJustifs = results[1] as List<Justification>;

      if (mounted) {
        setState(() {
          _justifications = allJustifs;
          _pendingJustificationsCount = allJustifs
              .where((j) => j.status == JustificationStatus.pending)
              .length;

          _classes = rawClasses.map((item) {
            return ClassModel(
              id: item['id'] as String,
              title: item['name'] as String,
              filiere: item['filiere_name'] as String,
              subjects: List<String>.from(item['subjects'] as List),
              studentCount: item['student_count'] as int? ?? 0,
              attendanceRate:
                  (item['attendance_rate'] as num?)?.toDouble() ?? 0.0,
              students:
                  [], // TODO: Fetch real students if needed for drill-down
            );
          }).toList();

          _state = _classes.isEmpty
              ? ClassesUiState.empty
              : ClassesUiState.loaded;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = ClassesUiState.error;
        });
      }
    }
  }

  void _onRetry() {
    _loadClasses();
  }

  void _onSubTabSelected(int index) {
    if (_selectedSubTab == index) return;
    setState(() {
      _selectedSubTab = index;
    });
  }

  Widget _buildJustificationSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 20,
          width: 120,
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(
          2,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
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
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16,
                          width: 140,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 12,
                          width: 180,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 12,
                          width: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJustificationsContent() {
    // État de chargement
    if (_state == ClassesUiState.loading) {
      return RefreshIndicator(
        onRefresh: _loadClasses,
        color: const Color(0xFF092C4C),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [_buildJustificationSkeleton()],
        ),
      );
    }

    final pendingItems = _justifications
        .where((j) => j.status == JustificationStatus.pending)
        .toList();
    final processedItems = _justifications
        .where((j) => j.status != JustificationStatus.pending)
        .toList();

    // État "Tout est à jour" - aucun justificatif du tout
    if (_justifications.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadClasses,
        color: const Color(0xFF092C4C),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(9999),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F092C4C),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    size: 40,
                    color: Color(0xFF828282),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Tout est à jour !',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF092C4C),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Aucun justificatif n\'est en attente de traitement pour vos cours.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4F4F4F),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadClasses,
      color: const Color(0xFF092C4C),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _buildJustificationSection(
            title: 'En attente',
            count: pendingItems.length,
            items: pendingItems,
            emptyMessage: 'Aucun justificatif en attente.',
            showSectionIfEmpty: true,
          ),
          const SizedBox(height: 24),
          _buildJustificationSection(
            title: 'Traités récemment',
            count: null,
            items: processedItems,
            emptyMessage: 'Aucun justificatif traité pour le moment.',
            dimmed: true,
          ),
        ],
      ),
    );
  }

  Widget _buildJustificationSection({
    required String title,
    required List<Justification> items,
    required String emptyMessage,
    int? count,
    bool dimmed = false,
    bool showSectionIfEmpty = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
        const SizedBox(height: 16),
        if (items.isEmpty)
          if (showSectionIfEmpty)
            // Pour la section "En attente" - affichage simple du message
            Text(
              emptyMessage,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF828282),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            )
          else
            // Pour les sections normales - affichage dans une boîte
            Container(
              width: double.infinity,
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
              child: Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF828282),
                  height: 1.5,
                ),
              ),
            )
        else
          ...items.map(
            (item) => Opacity(
              opacity: dimmed ? 0.8 : 1,
              child: JustificatifCard(
                item: item,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          JustificationDetailPage(justification: item),
                    ),
                  );
                  if (result == true && mounted) {
                    _loadClasses();
                  }
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent() {
    if (_selectedSubTab == 1) {
      return _buildJustificationsContent();
    }
    switch (_state) {
      case ClassesUiState.loading:
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          children: const [ClassSkeleton(), ClassSkeleton()],
        );
      case ClassesUiState.empty:
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          children: const [
            StateBox(
              icon: Icons.school_outlined,
              title: 'Aucune classe assignée',
              description:
                  'Vous n\'avez pas de classe affectée pour le moment. Veuillez contacter l\'administration en cas de besoin.',
            ),
          ],
        );
      case ClassesUiState.error:
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          children: [
            StateBox(
              icon: Icons.error_outline,
              iconColor: const Color(0xFFEB5757), // --error
              title: 'Erreur de chargement',
              description:
                  'Impossible de charger vos classes suite à un problème de connexion.',
              buttonText: 'Réessayer',
              onButtonPressed: _onRetry,
            ),
          ],
        );
      case ClassesUiState.loaded:
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          children: _classes
              .map(
                (classModel) => GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PreSessionScreen(classInfo: classModel),
                      ),
                    );
                  },
                  child: ClassCard(
                    title: classModel.title,
                    filiere: classModel.filiere,
                    studentCount: classModel.studentCount,
                    subjects: classModel.subjects,
                    attendanceRate: classModel.attendanceRate,
                  ),
                ),
              )
              .toList(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // --bg from HTML
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        title: const Text(
          'Mes classes',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF092C4C),
            letterSpacing: -0.44, // -0.02em
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 24),
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
                BoxShadow(
                  color: Color(0x0A092C4C),
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_none,
                color: Color(0xFF4F4F4F),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Subtabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _onSubTabSelected(0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedSubTab == 0
                            ? const Color(0xFF092C4C)
                            : Colors.white,
                        border: Border.all(
                          color: _selectedSubTab == 0
                              ? const Color(0xFF092C4C)
                              : const Color(0xFFE0E0E0),
                        ),
                        borderRadius: BorderRadius.circular(9999),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0F092C4C),
                            offset: Offset(0, 4),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Mes Classes',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _selectedSubTab == 0
                              ? Colors.white
                              : const Color(0xFF4F4F4F),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _onSubTabSelected(1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedSubTab == 1
                            ? const Color(0xFF092C4C)
                            : Colors.white,
                        border: Border.all(
                          color: _selectedSubTab == 1
                              ? const Color(0xFF092C4C)
                              : const Color(0xFFE0E0E0),
                        ),
                        borderRadius: BorderRadius.circular(9999),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x05000000), // 0.02 opacity
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
                            'Justificatifs',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _selectedSubTab == 1
                                  ? Colors.white
                                  : const Color(0xFF4F4F4F),
                            ),
                          ),
                          if (_pendingJustificationsCount > 0)
                            Positioned(
                              top: -8,
                              right: -8,
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
                                      color: Color(0x4DEB5757), // 0.3 opacity
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '$_pendingJustificationsCount',
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
                ),
              ],
            ),
          ),

          // Content Area
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }
}
