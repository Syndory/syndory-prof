import 'package:flutter/material.dart';
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

  // Mock Data
  final List<ClassModel> _classes = [
    ClassModel(
      title: 'L3 Informatique',
      filiere: 'Sciences & Technologies',
      studentCount: 42,
      subjects: ['Développement Web', 'Algorithmie II'],
      attendanceRate: 94,
      students: [
        const StudentModel(
          name: 'Alice Bernard',
          email: 'alice.bernard@univ.edu',
          initials: 'AB',
          attendanceRate: 95,
        ),
        const StudentModel(
          name: 'Julien Dupont',
          email: 'julien.dupont@univ.edu',
          initials: 'JD',
          attendanceRate: 72,
        ),
        const StudentModel(
          name: 'Marie Leroy',
          email: 'marie.leroy@univ.edu',
          initials: 'ML',
          attendanceRate: 45,
        ),
        const StudentModel(
          name: 'Thomas Martin',
          email: 'thomas.martin@univ.edu',
          initials: 'TM',
          attendanceRate: 100,
        ),
      ],
    ),
    ClassModel(
      title: 'M1 Ingénierie Logicielle',
      filiere: 'Master Informatique',
      studentCount: 28,
      subjects: ['Architecture Cloud'],
      attendanceRate: 78,
      students: [
        const StudentModel(
          name: 'Marc Lefebvre',
          email: 'marc.lefebvre@univ.edu',
          initials: 'ML',
          attendanceRate: 88,
        ),
        const StudentModel(
          name: 'Sophie Petit',
          email: 'sophie.petit@univ.edu',
          initials: 'SP',
          attendanceRate: 92,
        ),
      ],
    ),
    ClassModel(
      title: 'L2 Math-Info',
      filiere: 'Sciences & Technologies',
      studentCount: 65,
      subjects: ['Bases de données', 'Systèmes'],
      attendanceRate: 88,
      students: [
        const StudentModel(
          name: 'Jean Rochefort',
          email: 'jean.rochefort@univ.edu',
          initials: 'JR',
          attendanceRate: 82,
        ),
      ],
    ),
    const ClassModel(
      title: 'L1 Architecture',
      filiere: 'Sciences & Technologies',
      studentCount: 0,
      subjects: ['Dessin Technique'],
      attendanceRate: 0,
      students: [],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _simulateInitialLoad();
  }

  void _simulateInitialLoad() {
    // 1. Initial loading for 1.5s
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        // 2. Fail the first time to show the error state
        setState(() {
          _state = ClassesUiState.error;
        });
      }
    });
  }

  void _onRetry() {
    setState(() {
      _state = ClassesUiState.loading;
    });

    // 3. Retry loading for a shorter time (0.8s)
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        // 4. Succeed and show data
        setState(() {
          _state = ClassesUiState.loaded;
        });
      }
    });
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
