import 'package:flutter/material.dart';
import 'models/models.dart';
import 'widgets/student_card.dart';
import 'widgets/state_box.dart';

class EffectifsScreen extends StatefulWidget {
  final ClassModel classInfo;

  const EffectifsScreen({super.key, required this.classInfo});

  @override
  State<EffectifsScreen> createState() => _EffectifsScreenState();
}

class _EffectifsScreenState extends State<EffectifsScreen> {
  late TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StudentModel> get _filteredStudents {
    if (_searchQuery.isEmpty) {
      return widget.classInfo.students;
    }
    return widget.classInfo.students
        .where(
          (student) =>
              student.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final students = _filteredStudents;
    final isClassEmpty = widget.classInfo.students.isEmpty;
    final isSearchEmpty = students.isEmpty && _searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // --bg
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24, top: 8, bottom: 8),
          child: Container(
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
              icon: const Icon(
                Icons.arrow_back,
                color: Color(0xFF092C4C),
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          widget.classInfo.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF092C4C),
            letterSpacing: -0.18,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 24, top: 8, bottom: 8),
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
              icon: const Icon(
                Icons.notifications_none,
                color: Color(0xFF4F4F4F),
                size: 20,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFE8EFF5)],
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
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF092C4C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.classInfo.filiere,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4F4F4F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.people_alt_outlined,
                              size: 14,
                              color: Color(0xFF092C4C),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.classInfo.studentCount.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF092C4C),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ...widget.classInfo.subjects.map(
                        (subject) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  offset: const Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            child: Text(
                              subject,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF092C4C),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tools Bar (only if class is not empty)
            if (!isClassEmpty) ...[
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(9999),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: Color(0xFFBDBDBD),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                            decoration: const InputDecoration(
                              hintText: 'Rechercher par nom...',
                              hintStyle: TextStyle(
                                color: Color(0xFFBDBDBD),
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text(
                        'Tri par :',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF828282),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {},
                        child: const Row(
                          children: [
                            Text(
                              'Nom A→Z',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF092C4C),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xFF092C4C),
                              size: 12,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // Student List or Empty States
            if (isClassEmpty)
              const StateBox(
                icon: Icons.people_outline,
                title: 'Aucun étudiant',
                description:
                    'Aucun étudiant n\'est inscrit dans cette classe pour le moment.',
              )
            else if (isSearchEmpty)
              StateBox(
                icon: Icons.search,
                title: 'Aucun résultat',
                description: 'Aucun étudiant correspondant à "$_searchQuery".',
              )
            else
              Column(
                children: students
                    .map((student) => StudentCard(student: student))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
