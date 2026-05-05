import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syndory_prof/features/calendrier/kalender.dart';
import 'navigationbar.dart' hide NavigationBar;

class Calendrier extends StatefulWidget {
  const Calendrier({super.key});

  @override
  State<Calendrier> createState() => _CalendrierState();
}

class _CalendrierState extends State<Calendrier> {
  DateTime currentWeekStart = DateTime.now()
      .subtract(Duration(days: DateTime.now().weekday - 1));

  String selectedFilter = "Toutes";

  String get weekLabel {
    final weekEnd = currentWeekStart.add(const Duration(days: 6));
    return "${DateFormat('d MMM', 'fr_FR').format(currentWeekStart)} — "
           "${DateFormat('d MMM yyyy', 'fr_FR').format(weekEnd)}";
  }

  void _changeWeek(int delta) {
    setState(() {
      currentWeekStart = currentWeekStart.add(Duration(days: 7 * delta));
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 252, 253),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mon Calendrier',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 18, 0, 70),
              ),
            ),
            Stack(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color.fromARGB(255, 253, 253, 253),
                  child: const Icon(Icons.notifications, size: 28, color: Color.fromARGB(255, 225, 223, 223)),
                ),
                // Badge de notification
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: const Text(
                      '2',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      body: Column(
        children: [
          // Barre de navigation semaine
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changeWeek(-1),
                ),
                Text(
                  weekLabel,
                  style: const TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 4, 0, 66),
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _changeWeek(1),
                ),
              ],
            ),
          ),

          // Barre de filtres
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip("Toutes"),
                _buildFilterChip("L3 Info"),
                _buildFilterChip("M1 Info"),
                _buildFilterChip("L2 Math"),
              ],
            ),
          ),

          // Calendrier (sera relié à kalender.dart)
          Expanded(
            child: KalenderPage(
              currentWeekStart: currentWeekStart,
              selectedFilter: selectedFilter,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: selectedFilter == label,
        onSelected: (selected) {
          setState(() {
            selectedFilter = label;
          });
        },
      ),
    );
  }
}
