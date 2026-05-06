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
  DateTime currentWeekStart =
      DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));

  String selectedFilter = "Toutes";

  // ─── État courant du calendrier ───────────────────────────────────────────
  // Changer cette valeur pour tester les 3 états :
  //   CalendrierEtat.normal      → vue normale avec les séances
  //   CalendrierEtat.semaineVide → semaine sans séances
  //   CalendrierEtat.erreur      → erreur de chargement
  CalendrierEtat _etat = CalendrierEtat.erreur;

  String get weekLabel {
    final weekEnd = currentWeekStart.add(const Duration(days: 6));
    return "${DateFormat('d MMM', 'fr_FR').format(currentWeekStart)} — "
        "${DateFormat('d MMM yyyy', 'fr_FR').format(weekEnd)}";
  }

  void _changeWeek(int delta) {
    setState(() {
      currentWeekStart = currentWeekStart.add(Duration(days: 7 * delta));
      // TODO : déclencher un appel API ici et mettre à jour _etat :
      //   _etat = CalendrierEtat.normal      si données reçues
      //   _etat = CalendrierEtat.semaineVide si liste vide
      //   _etat = CalendrierEtat.erreur      si erreur réseau
    });
  }

  void _reessayer() {
    setState(() {
      // TODO : relancer l'appel API et mettre à jour _etat selon la réponse
      _etat = CalendrierEtat.normal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCFCFD),
        elevation: 0,
        titleSpacing: 16,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mon calendrier',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF120046),
              ),
            ),
            Stack(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F3F3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    size: 20,
                    color: Color(0xFFB0AEC0),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Center(
                      child: Text(
                        '2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Navigation semaine ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 20),
                    color: const Color(0xFF120046),
                    onPressed: () => _changeWeek(-1),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                  Text(
                    weekLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF040042),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 20),
                    color: const Color(0xFF120046),
                    onPressed: () => _changeWeek(1),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),

          // ─── Filtres par classe ─────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip("Toutes"),
                _buildFilterChip("L3 Info"),
                _buildFilterChip("M1 Info"),
                _buildFilterChip("L2 Math"),
              ],
            ),
          ),

          // ─── Contenu principal selon l'état ────────────────────────────
          Expanded(
            child: KalenderPage(
              currentWeekStart: currentWeekStart,
              selectedFilter: selectedFilter,
              etat: _etat,
              onReessayer: _reessayer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => selectedFilter = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0D1B3E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF0D1B3E)
                  : const Color(0xFFDDDDDD),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF555555),
            ),
          ),
        ),
      ),
    );
  }
}