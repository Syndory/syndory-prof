import 'package:flutter/material.dart';
import 'dashboard_widgets.dart';

/// Dashboard Professeur - Aucun cours aujourd'hui SANS prochaine séance
class DashboardWithoutNextSessionScreen extends StatelessWidget {
  const DashboardWithoutNextSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // Sticky header
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFFF5F7FA),
            elevation: 0,
            toolbarHeight: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                children: [
                  const DashboardHeader(
                    userInitials: 'ML',
                    userName: 'Marie Laurent',
                    notificationCount: 2,
                  ),
                  // Gradient background
                  Container(
                    height: 1,
                    color: Colors.transparent,
                  ),
                ],
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Justificatifs card
                const JustificatifCard(
                  count: 2,
                ),

                // Today section - Empty state
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(
                        title: "Aujourd'hui",
                        date: '28 avr.',
                      ),
                      const SizedBox(height: 16),
                      EmptyState(
                        title: 'Aucun cours programmé',
                        subtitle: 'Profitez de votre journée libre.',
                        icon: Icons.star_outline,
                      ),
                    ],
                  ),
                ),

                // My classes section
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(
                        title: 'Mes classes',
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ClassCard(
                              className: 'L3 Informatique',
                              studentCount: 42,
                            ),
                            const SizedBox(width: 12),
                            ClassCard(
                              className: 'M1 Informatique',
                              studentCount: 28,
                              gradientStart: const Color(0xFFF2994A),
                              gradientEnd: const Color(0xFFD37A2D),
                            ),
                            const SizedBox(width: 12),
                            ClassCard(
                              className: 'L2 Mathématiques',
                              studentCount: 56,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Calendrier',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Mes cours',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            activeIcon: Icon(Icons.folder),
            label: 'Ressources',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
