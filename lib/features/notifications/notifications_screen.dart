import 'package:flutter/material.dart';
import 'package:syndory_prof/data/supabase/supabase_client.dart';

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

  AppNotification copyWith({
    bool? isRead,
  }) {
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

extension NotificationCategoryParse on NotificationCategoryExtension {
  static NotificationCategory parse(dynamic source) {
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

final List<AppNotification> _mockNotifications = [
  AppNotification(
    id: null,
    category: NotificationCategory.sessionOpened,
    title: 'Nouvelle séance publiée',
    message: 'Une séance pour la classe 3ème A a été publiée. Vérifiez votre planning.',
    isRead: false,
    createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
  ),
  AppNotification(
    id: null,
    category: NotificationCategory.newResource,
    title: 'Ressource partagée',
    message: 'Un nouveau document a été ajouté à votre cours de mathématiques.',
    isRead: false,
    createdAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 20)),
  ),
  AppNotification(
    id: null,
    category: NotificationCategory.examReminder,
    title: 'Rappel examen',
    message: 'Rappel : préparation de l’examen de physique demain à 9h.',
    isRead: true,
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
  ),
  AppNotification(
    id: null,
    category: NotificationCategory.announcement,
    title: 'Annonce importante',
    message: 'Le service informatique effectue une maintenance cette nuit.',
    isRead: true,
    createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 6)),
  ),
];

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  late final bool _useBackend;
  List<AppNotification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _useBackend = SupabaseClientProvider.isInitialized &&
        SupabaseClientProvider.client.auth.currentSession != null;
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (!_useBackend) {
      setState(() {
        _notifications = List<AppNotification>.from(_mockNotifications);
        _isLoading = false;
      });
      return;
    }

    try {
      final result = await SupabaseClientProvider.client
          .from('notifications')
          .select('id,type,title,message,is_read,created_at')
          .order('created_at', ascending: false)
          .limit(50);

      if (result is List) {
        _notifications = result
            .cast<Map<String, dynamic>>()
            .map(AppNotification.fromMap)
            .toList();
      } else {
        _notifications = List<AppNotification>.from(_mockNotifications);
      }
    } catch (error) {
      _errorMessage = 'Impossible de charger les notifications.';
      _notifications = List<AppNotification>.from(_mockNotifications);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAllAsRead() async {
    if (_useBackend) {
      try {
        await SupabaseClientProvider.client
            .from('notifications')
            .update({'is_read': true})
            .eq('is_read', false);
      } catch (_) {
        // Ignorer l’erreur de mise à jour, on met à jour localement.
      }
    }

    setState(() {
      _notifications = _notifications
          .map((notification) => notification.copyWith(isRead: true))
          .toList();
    });
  }

  Future<void> _markAsRead(AppNotification notification) async {
    if (notification.isRead) {
      return;
    }

    if (_useBackend && notification.id != null) {
      try {
        await SupabaseClientProvider.client
            .from('notifications')
            .update({'is_read': true})
            .eq('id', notification.id);
      } catch (_) {
        // Ne bloque pas l’affichage.
      }
    }

    setState(() {
      _notifications = _notifications.map((item) {
        if (item.id == notification.id && notification.id != null) {
          return item.copyWith(isRead: true);
        }
        if (item.id == null && item == notification) {
          return item.copyWith(isRead: true);
        }
        return item;
      }).toList();
    });
  }

  int get _unreadCount {
    return _notifications.where((notification) => !notification.isRead).length;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inSeconds < 60) {
      return 'À l’instant';
    }
    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    }
    if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    }
    if (difference.inDays == 1) {
      return 'Hier';
    }
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        actions: [
          if (_notifications.isNotEmpty && _unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Tout lire',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_notifications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(
            child: Text(
              'Aucune notification pour le moment.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Color(0xFF828282)),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _notifications.length + (_errorMessage != null ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (_errorMessage != null && index == 0) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE6E6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Color(0xFFB00020)),
            ),
          );
        }

        final notification = _notifications[
            index - (_errorMessage != null ? 1 : 0)];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    return InkWell(
      onTap: () => _markAsRead(notification),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : const Color(0xFFEAF3FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: notification.isRead
                ? const Color(0xFFE0E0E0)
                : const Color(0xFF2F80ED),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: notification.isRead
                    ? Colors.transparent
                    : const Color(0xFF2F80ED),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        notification.category.icon,
                        size: 18,
                        color: notification.category.color,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF092C4C),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification.message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4F4F4F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: notification.category.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          notification.category.label,
                          style: TextStyle(
                            fontSize: 12,
                            color: notification.category.color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        _formatDate(notification.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF828282),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
