import 'package:flutter/material.dart';

import 'widgets/class_card.dart';

class ClassesScreen extends StatelessWidget {
  const ClassesScreen({super.key});

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

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              children: const [
                ClassCard(
                  title: 'L3 Informatique',
                  filiere: 'Sciences & Technologies',
                  studentCount: 42,
                  subjects: ['Développement Web', 'Algorithmie II'],
                  attendanceRate: 94,
                ),
                ClassCard(
                  title: 'M1 Ingénierie Logicielle',
                  filiere: 'Master Informatique',
                  studentCount: 28,
                  subjects: ['Architecture Cloud'],
                  attendanceRate: 78,
                ),
                ClassCard(
                  title: 'L2 Math-Info',
                  filiere: 'Sciences & Technologies',
                  studentCount: 65,
                  subjects: ['Bases de données', 'Systèmes'],
                  attendanceRate: 88,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
