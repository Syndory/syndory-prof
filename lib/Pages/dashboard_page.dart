import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

///  Skeleton widget
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 182, 3, 3),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Future<List<Map<String, dynamic>>> fetchSeances() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('seances')
        .select()
        .eq('professor_id', supabase.auth.currentUser!.id);
    return response;
  }

  Future<List<Map<String, dynamic>>> fetchClasses() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('classes')
        .select()
        .eq('professor_id', supabase.auth.currentUser!.id);
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: 390,
          height: 844,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 116, 158, 221),
            borderRadius: BorderRadius.circular(44),
            border: Border.all(color: const Color(0xFF1D1D1D), width: 8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 80,
                offset: Offset(0, 40),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFF092C4C),
                          child: const Text("ML",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 236, 51, 51),
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("Bonjour,", style: TextStyle(color: Colors.grey)),
                            Text("Professeur",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF092C4C))),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              // Section "Aujourd'hui"
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Aujourd'hui",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF092C4C))),
                      const SizedBox(height: 8),

                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: fetchSeances(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            // Skeleton en attendant
                            return Column(
                              children: [
                                SkeletonBox(width: double.infinity, height: 80, radius: 16),
                                const SizedBox(height: 12),
                                SkeletonBox(width: double.infinity, height: 80, radius: 16),
                                const SizedBox(height: 12),
                                SkeletonBox(width: double.infinity, height: 80, radius: 16),
                              ],
                            );
                          } else if (snapshot.hasError) {
                            return Text("Erreur: ${snapshot.error}");
                          } else {
                            final seances = snapshot.data ?? [];
                            return Column(
                              children: seances.map((seance) {
                                return CourseCard(
                                  status: seance['status'] ?? "À venir",
                                  start: seance['start_time'] ?? "--:--",
                                  end: seance['end_time'] ?? "--:--",
                                  subject: seance['matiere_id']?.toString() ?? "Matière inconnue",
                                  meta: "Classe ${seance['class_id'] ?? 'N/A'} • Salle ${seance['salle_id'] ?? 'N/A'}",
                                  statusColor: seance['status'] == "En cours"
                                      ? Colors.green
                                      : seance['status'] == "Terminé"
                                          ? Colors.grey
                                          : Colors.blue,
                                );
                              }).toList(),
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 24),
                      const Text("Mes classes",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF092C4C))),
                      const SizedBox(height: 12),

                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: fetchClasses(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Row(
                              children: [
                                SkeletonBox(width: 140, height: 100, radius: 16),
                                const SizedBox(width: 12),
                                SkeletonBox(width: 140, height: 100, radius: 16),
                                const SizedBox(width: 12),
                                SkeletonBox(width: 140, height: 100, radius: 16),
                              ],
                            );
                          } else if (snapshot.hasError) {
                            return Text("Erreur: ${snapshot.error}");
                          } else {
                            final classes = snapshot.data ?? [];
                            return SizedBox(
                              height: 120,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: classes.map((classe) {
                                  return ClassCard(
                                    title: classe['nom'] ?? "Classe inconnue",
                                    subtitle: "${classe['nb_etudiants'] ?? 0} étudiants",
                                  );
                                }).toList(),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Navigation
              BottomNavigationBar(
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
                  BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Calendrier"),
                  BottomNavigationBarItem(icon: Icon(Icons.book), label: "Mes cours"),
                  BottomNavigationBarItem(icon: Icon(Icons.folder), label: "Ressources"),
                  BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
                ],
                currentIndex: 0,
                selectedItemColor: const Color(0xFF092C4C),
                unselectedItemColor: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widgets réutilisables
class CourseCard extends StatelessWidget {
  final String status, start, end, subject, meta;
  final Color statusColor;

  const CourseCard({
    super.key,
    required this.status,
    required this.start,
    required this.end,
    required this.subject,
    required this.meta,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(start, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(end, style: const TextStyle(color: Colors.grey)),
          ],
        ),
        title: Text(subject,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF092C4C))),
        subtitle: Text(meta),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1), 
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(status,
              style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class ClassCard extends StatelessWidget {
  final String title, subtitle;
  final Color color;

  const ClassCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.color = const Color(0xFF092C4C),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
