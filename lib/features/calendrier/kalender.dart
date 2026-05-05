import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';

class KalenderPage extends StatefulWidget{
  const KalenderPage({super.key, required String selectedFilter, required DateTime currentWeekStart});

  @override
  // ignore: library_private_types_in_public_api
  State<KalenderPage> createState() => _KalenderPageState();
}

class _KalenderPageState extends State<KalenderPage>{
    final eventsController = DefaultEventsController();
    final calendarController = CalendarController();

    @override
      void initState() {
      super.initState();
    }
  @override
  Widget build(BuildContext context) {
    return CalendarView(eventsController: eventsController, 
    calendarController: calendarController, 
    viewConfiguration: MultiDayViewConfiguration.singleDay(),
    callbacks: CalendarCallbacks(
      onEventCreate: (event) {
        eventsController.addEvent(event);
        return event;
      },
      ),
      header: CalendarHeader(),
      body: CalendarBody()
    );
    
  }
}

// Classe pour représenter un événement dans le calendrier
class Event {
  final String title;
  final String? description;
  final Color? color;

  Event({required this.title, this.description, this.color});

  Event copyWith({
    String? title,
    String? description,
    Color? color,
  }) {
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
