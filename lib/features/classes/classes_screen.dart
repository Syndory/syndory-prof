import 'dart:async';

import 'package:flutter/material.dart';
import '../../data/repositories/classes_repository.dart';
import 'effectifs_screen.dart';
import 'models/models.dart';
import 'widgets/class_card.dart';
import 'widgets/class_skeleton.dart';
import 'widgets/state_box.dart';

enum ClassesUiState { loading, empty, error, loaded }

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  ClassesUiState _state = ClassesUiState.loading;
  List<ClassModel> _classes = [];

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
      final rawClasses = await ClassesRepository.getProfessorClasses();
      
      if (mounted) {
        setState(() {
          _classes = rawClasses.map((item) {
            return ClassModel(
              title: item['name'] as String,
              filiere: item['filiere_name'] as String,
              subjects: List<String>.from(item['subjects'] as List),
              studentCount: 0, // TODO: Fetch real student count
              attendanceRate: 0, // TODO: Fetch real attendance rate
              students: [], // TODO: Fetch real students
            );
          }).toList();
          
          _state = _classes.isEmpty ? ClassesUiState.empty : ClassesUiState.loaded;
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

  Widget _buildContent() {
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
                            EffectifsScreen(classInfo: classModel),
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
                // TODO: Handle notifications
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
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF092C4C),
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
                    child: const Text(
                      'Mes Classes',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE0E0E0)),
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
                        const Text(
                          'Justificatifs',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4F4F4F),
                          ),
                        ),
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
                                  color: Color(0x4DEB5757), // 0.3 opacity
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Text(
                              '3',
                              style: TextStyle(
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
