import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ─── Enum état du calendrier ──────────────────────────────────────────────────
enum CalendrierEtat { normal, semaineVide, erreur }

// ─── Modèle d'un cours ────────────────────────────────────────────────────────
class CoursCalendrier {
  final String titre;
  final String sousInfo; // ex: "M1 Info • Amphi C"
  final String? badge;   // ex: "AUJOURD'HUI", "EN COURS"
  final Color couleur;
  final int jourSemaine; // 1=Lun, 2=Mar, ... 6=Sam
  final double heureDebut; // ex: 8.0 pour 08:00, 9.5 pour 09:30
  final double heureFin;

  const CoursCalendrier({
    required this.titre,
    required this.sousInfo,
    this.badge,
    required this.couleur,
    required this.jourSemaine,
    required this.heureDebut,
    required this.heureFin,
  });
}

// ─── Widget principal ─────────────────────────────────────────────────────────
class KalenderPage extends StatefulWidget {
  final String selectedFilter;
  final DateTime currentWeekStart;
  final CalendrierEtat etat;
  final VoidCallback? onReessayer;
  final List<CoursCalendrier> cours;

  const KalenderPage({
    super.key,
    required this.selectedFilter,
    required this.currentWeekStart,
    this.etat = CalendrierEtat.normal,
    this.onReessayer,
    this.cours = const [],
  });

  @override
  State<KalenderPage> createState() => _KalenderPageState();
}

class _KalenderPageState extends State<KalenderPage> {
  // Heures affichées : 08:00 → 18:00
  static const double _heureDebut = 8.0;
  static const double _heureFin = 18.0;
  static const double _largeurColJour = 52.0;
  static const double _largeurHeure = 80.0;
  static const double _hauteurLigne = 72.0;

  // Jours affichés : Lun → Sam
  static const List<String> _joursAbr = ['LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM'];

  @override
  Widget build(BuildContext context) {
    switch (widget.etat) {
      case CalendrierEtat.semaineVide:
        return _buildSemaineVide();
      case CalendrierEtat.erreur:
        return _buildErreur();
      case CalendrierEtat.normal:
        return _buildGrille();
    }
  }

  // ─── Grille calendrier custom ───────────────────────────────────────────────
  Widget _buildGrille() {
    final today = DateTime.now();
    final nombreHeures = (_heureFin - _heureDebut).toInt();
    final largeurTotale = _largeurHeure * nombreHeures;

    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Colonne fixe des jours ──
          SizedBox(
            width: _largeurColJour,
            child: Column(
              children: [
                // Espace en-tête heures
                const SizedBox(height: 28),
                // Lignes des jours
                ...List.generate(6, (index) {
                  final jourDate = widget.currentWeekStart.add(Duration(days: index));
                  final estAujourdhui = jourDate.year == today.year &&
                      jourDate.month == today.month &&
                      jourDate.day == today.day;

                  return Container(
                    height: _hauteurLigne,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFEEEEEE)),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _joursAbr[index],
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9E9E9E),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        estAujourdhui
                            ? Container(
                                width: 30,
                                height: 30,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0D1B3E),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${jourDate.day}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            : Text(
                                '${jourDate.day}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D1B3E),
                                ),
                              ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // ── Zone scrollable horizontalement ──
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: largeurTotale,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête des heures
                    SizedBox(
                      height: 28,
                      child: Row(
                        children: List.generate(nombreHeures, (i) {
                          final heure = _heureDebut.toInt() + i;
                          return SizedBox(
                            width: _largeurHeure,
                            child: Text(
                              '${heure.toString().padLeft(2, '0')}:00',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF9E9E9E),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    // Lignes des jours avec blocs de cours
                    ...List.generate(6, (jourIndex) {
                      final coursDuJour = widget.cours.where(
                        (c) => c.jourSemaine == jourIndex + 1,
                      ).toList();

                      return Container(
                        height: _hauteurLigne,
                        width: largeurTotale,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Color(0xFFEEEEEE)),
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Lignes verticales des heures
                            ...List.generate(nombreHeures, (i) {
                              return Positioned(
                                left: i * _largeurHeure,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  width: 1,
                                  color: const Color(0xFFF0F0F0),
                                ),
                              );
                            }),

                            // Blocs de cours
                            ...coursDuJour.map((cours) {
                              final left = (cours.heureDebut - _heureDebut) * _largeurHeure;
                              final width = (cours.heureFin - cours.heureDebut) * _largeurHeure - 4;
                              return Positioned(
                                left: left + 2,
                                top: 6,
                                bottom: 6,
                                width: width,
                                child: _buildBlocCours(cours),
                              );
                            }),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlocCours(CoursCalendrier cours) {
    return Container(
      decoration: BoxDecoration(
        color: cours.couleur.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border(
          left: BorderSide(color: cours.couleur, width: 3),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            cours.titre,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: cours.couleur,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            cours.sousInfo,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF666666),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (cours.badge != null)
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: cours.couleur.withOpacity(0.2),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                cours.badge!,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: cours.couleur,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── État semaine vide ────────────────────────────────────────────────────

  Widget _buildSemaineVide() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F0F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 30,
                color: Color(0xFFAAAAAA),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Semaine vide',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Aucune séance n\'est programmée pour vous cette semaine.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF888888),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── État erreur ──────────────────────────────────────────────────────────
  Widget _buildErreur() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFFDECEC),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_rounded,
                size: 32,
                color: Color(0xFFE53935),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Impossible de charger',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Une erreur est survenue lors de la récupération de votre calendrier.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF888888),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onReessayer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D1B3E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Réessayer',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}