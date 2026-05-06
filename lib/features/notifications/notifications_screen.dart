import 'dart:async';
import 'package:flutter/material.dart';
import 'package:syndory_prof/data/supabase/supabase_client.dart';
import 'notification_models.dart';
import 'notification_service.dart';

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
  late final bool _useBackend;

  @override
  void initState() {
    super.initState();
    _useBackend = SupabaseClientProvider.isInitialized &&
        SupabaseClientProvider.client.auth.currentSession != null;
    
    if (_useBackend) {
      unawaited(_initNotificationsService());
    }
  }

  Future<void> _initNotificationsService() async {
    try {
      await NotificationService().initialize();
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    if (_useBackend) {
      await NotificationService().markAllAsRead();
    } else {
      // Mock UI handling
      setState(() {
        for (var i = 0; i < _mockNotifications.length; i++) {
          _mockNotifications[i] = _mockNotifications[i].copyWith(isRead: true);
        }
      });
    }
  }

  Future<void> _markAsRead(AppNotification notification) async {
    if (notification.isRead) return;

    if (_useBackend) {
      await NotificationService().markAsRead(notification);
    } else {
      setState(() {
        final index = _mockNotifications.indexOf(notification);
        if (index != -1) {
          _mockNotifications[index] = notification.copyWith(isRead: true);
        }
      });
    }
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
    return _useBackend ? _buildLiveList() : _buildMockList();
  }

  Widget _buildMockList() {
    final unreadCount = _mockNotifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        actions: [
          if (_mockNotifications.isNotEmpty && unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Tout lire',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _buildBody(_mockNotifications),
    );
  }

  Widget _buildLiveList() {
    return ValueListenableBuilder<List<AppNotification>>(
      valueListenable: NotificationService().notifications,
      builder: (context, notifications, _) {
        final unreadCount = NotificationService().unreadCount.value;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Notifications'),
            centerTitle: true,
            actions: [
              if (notifications.isNotEmpty && unreadCount > 0)
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
            onRefresh: NotificationService().loadNotifications,
            child: _buildBody(notifications),
          ),
        );
      },
    );
  }

  Widget _buildBody(List<AppNotification> notifications) {
    if (notifications.isEmpty) {
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
      itemCount: notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final notification = notifications[index];
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
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF092C4C),
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
