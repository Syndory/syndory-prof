import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';

// Enum pour représenter l'état du calendrier
enum CalendrierEtat { normal, semaineVide, erreur }

class KalenderPage extends StatefulWidget {
  final String selectedFilter;
  final DateTime currentWeekStart;
  final CalendrierEtat etat;
  final VoidCallback? onReessayer;

  const KalenderPage({
    super.key,
    required this.selectedFilter,
    required this.currentWeekStart,
    this.etat = CalendrierEtat.normal,
    this.onReessayer,
  });

  @override
  State<KalenderPage> createState() => _KalenderPageState();
}

class _KalenderPageState extends State<KalenderPage> {
  late DefaultEventsController eventsController;
  late CalendarController calendarController;

  @override
  void initState() {
    super.initState();
    eventsController = DefaultEventsController();
    calendarController = CalendarController();
  }

  @override
  void didUpdateWidget(KalenderPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentWeekStart != widget.currentWeekStart ||
        oldWidget.selectedFilter != widget.selectedFilter) {
      // TODO : relancer le chargement des événements
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.etat) {
      case CalendrierEtat.semaineVide:
        return _buildSemaineVide();
      case CalendrierEtat.erreur:
        return _buildErreur();
      case CalendrierEtat.normal:
        return _buildCalendrier();
    }
  }

  // ─── État normal : grille calendrier ─────────────────────────────────────
  Widget _buildCalendrier() {
    return CalendarView(
      eventsController: eventsController,
      calendarController: calendarController,
      viewConfiguration: MultiDayViewConfiguration.week(),
      callbacks: CalendarCallbacks(
        onEventCreate: (event) {
          eventsController.addEvent(event);
          return event;
        },
      ),
      header: CalendarHeader(),
      body: CalendarBody(),
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
            // Icône sparkle dans un cercle gris clair — fidèle maquette
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
            // Triangle warning rouge dans cercle rouge très clair — fidèle maquette
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
            // Bouton Réessayer — fond sombre, coins arrondis, pleine largeur
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

// ─── Classe modèle d'un événement ────────────────────────────────────────────
class Event {
  final String title;
  final String? description;
  final Color? color;

  Event({required this.title, this.description, this.color});

  Event copyWith({String? title, String? description, Color? color}) {
    return Event(
      title: title ?? this.title,
      description: description ?? this.description,
      color: color ?? this.color,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Event &&
        other.title == title &&
        other.description == description &&
        other.color == color;
  }

  @override
  int get hashCode => Object.hash(title, description, color);
}