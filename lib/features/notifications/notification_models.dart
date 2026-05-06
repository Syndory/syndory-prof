import 'package:flutter/material.dart';

enum NotificationCategory {
  sessionOpened,
  newResource,
  scheduleUpdate,
  justificationStatus,
  announcement,
  examReminder,
  sessionCancelled,
  unknown,
}

extension NotificationCategoryExtension on NotificationCategory {
  String get label {
    switch (this) {
      case NotificationCategory.sessionOpened:
        return 'Séance ouverte';
      case NotificationCategory.newResource:
        return 'Nouvelle ressource';
      case NotificationCategory.scheduleUpdate:
        return 'Planning';
      case NotificationCategory.justificationStatus:
        return 'Justification';
      case NotificationCategory.announcement:
        return 'Annonce';
      case NotificationCategory.examReminder:
        return 'Rappel examen';
      case NotificationCategory.sessionCancelled:
        return 'Séance annulée';
      case NotificationCategory.unknown:
        return 'Notification';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationCategory.sessionOpened:
        return Icons.play_circle_outline;
      case NotificationCategory.newResource:
        return Icons.menu_book_outlined;
      case NotificationCategory.scheduleUpdate:
        return Icons.schedule_outlined;
      case NotificationCategory.justificationStatus:
        return Icons.event_note_outlined;
      case NotificationCategory.announcement:
        return Icons.campaign_outlined;
      case NotificationCategory.examReminder:
        return Icons.alarm_outlined;
      case NotificationCategory.sessionCancelled:
        return Icons.cancel_outlined;
      case NotificationCategory.unknown:
        return Icons.notifications_outlined;
    }
  }

  Color get color {
    switch (this) {
      case NotificationCategory.sessionOpened:
        return const Color(0xFF2F80ED);
      case NotificationCategory.newResource:
        return const Color(0xFF219653);
      case NotificationCategory.scheduleUpdate:
        return const Color(0xFF9B51E0);
      case NotificationCategory.justificationStatus:
        return const Color(0xFFF2994A);
      case NotificationCategory.announcement:
        return const Color(0xFF56CCF2);
      case NotificationCategory.examReminder:
        return const Color(0xFFEB5757);
      case NotificationCategory.sessionCancelled:
        return const Color(0xFF828282);
      case NotificationCategory.unknown:
        return const Color(0xFF4F4F4F);
    }
  }
}

NotificationCategory _parseNotificationCategory(dynamic source) {
  if (source == null) {
    return NotificationCategory.unknown;
  }

  final value = source.toString().toLowerCase();
  switch (value) {
    case 'session_opened':
      return NotificationCategory.sessionOpened;
    case 'new_resource':
      return NotificationCategory.newResource;
    case 'schedule_update':
      return NotificationCategory.scheduleUpdate;
    case 'justification_status':
      return NotificationCategory.justificationStatus;
    case 'announcement':
      return NotificationCategory.announcement;
    case 'exam_reminder':
      return NotificationCategory.examReminder;
    case 'session_cancelled':
      return NotificationCategory.sessionCancelled;
    default:
      return NotificationCategory.unknown;
  }
}

class AppNotification {
  final String? id;
  final NotificationCategory category;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.category,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      category: category,
      title: title,
      message: message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id']?.toString(),
      category: _parseNotificationCategory(map['type']),
      title: map['title']?.toString() ?? 'Notification',
      message: map['message']?.toString() ?? '',
      isRead: map['is_read'] == true,
      createdAt: _parseDate(map['created_at']),
    );
  }
}

class NotificationCategoryParse {
  static NotificationCategory parse(dynamic source) {
    return _parseNotificationCategory(source);
  }
}

DateTime _parseDate(dynamic value) {
  if (value is DateTime) {
    return value;
  }
  if (value is String) {
    return DateTime.tryParse(value)?.toLocal() ?? DateTime.now();
  }
  return DateTime.now();
}
