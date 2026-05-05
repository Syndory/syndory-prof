import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syndory_prof/data/supabase/supabase_client.dart';
import 'notification_models.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final ValueNotifier<List<AppNotification>> notifications = ValueNotifier([]);
  final ValueNotifier<int> unreadCount = ValueNotifier(0);

  RealtimeChannel? _subscription;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    if (!SupabaseClientProvider.isInitialized) {
      return;
    }

    final session = SupabaseClientProvider.client.auth.currentSession;
    if (session == null) return;

    final userId = session.user.id;

    // Load initial data
    await loadNotifications();

    // Setup realtime subscription
    _subscription = SupabaseClientProvider.client
        .channel('public:notifications')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            _handleNewNotification(payload.newRecord);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            _handleUpdatedNotification(payload.newRecord);
          },
        )
        .subscribe();

    _isInitialized = true;
  }

  void dispose() {
    _subscription?.unsubscribe();
    _subscription = null;
    _isInitialized = false;
    notifications.value = [];
    unreadCount.value = 0;
  }

  Future<void> loadNotifications() async {
    if (!SupabaseClientProvider.isInitialized) return;

    try {
      final session = SupabaseClientProvider.client.auth.currentSession;
      if (session == null) return;

      final result = await SupabaseClientProvider.client
          .from('notifications')
          .select('id,type,title,message,is_read,created_at')
          .eq('user_id', session.user.id)
          .order('created_at', ascending: false)
          .limit(50);

      if (result is List) {
        final parsed = result
            .cast<Map<String, dynamic>>()
            .map(AppNotification.fromMap)
            .toList();
        
        notifications.value = parsed;
        _updateUnreadCount();
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  void _handleNewNotification(Map<String, dynamic> record) {
    final notification = AppNotification.fromMap(record);
    final updatedList = List<AppNotification>.from(notifications.value);
    
    // Insert at the top
    updatedList.insert(0, notification);
    notifications.value = updatedList;
    _updateUnreadCount();
  }

  void _handleUpdatedNotification(Map<String, dynamic> record) {
    final updatedNotification = AppNotification.fromMap(record);
    final updatedList = List<AppNotification>.from(notifications.value);
    
    final index = updatedList.indexWhere((n) => n.id == updatedNotification.id);
    if (index != -1) {
      updatedList[index] = updatedNotification;
      notifications.value = updatedList;
      _updateUnreadCount();
    }
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.value.where((n) => !n.isRead).length;
  }

  Future<void> markAsRead(AppNotification notification) async {
    if (notification.isRead || notification.id == null) return;

    // Optimistic update
    final updatedList = List<AppNotification>.from(notifications.value);
    final index = updatedList.indexWhere((n) => n.id == notification.id);
    if (index != -1) {
      updatedList[index] = notification.copyWith(isRead: true);
      notifications.value = updatedList;
      _updateUnreadCount();
    }

    // Backend update
    if (SupabaseClientProvider.isInitialized) {
      try {
        await SupabaseClientProvider.client
            .from('notifications')
            .update({'is_read': true})
            .eq('id', notification.id!);
      } catch (e) {
        debugPrint('Error marking notification as read: $e');
      }
    }
  }

  Future<void> markAllAsRead() async {
    if (unreadCount.value == 0) return;

    // Optimistic update
    final updatedList = notifications.value.map((n) => n.copyWith(isRead: true)).toList();
    notifications.value = updatedList;
    _updateUnreadCount();

    // Backend update
    if (SupabaseClientProvider.isInitialized) {
      try {
        final session = SupabaseClientProvider.client.auth.currentSession;
        if (session == null) return;

        await SupabaseClientProvider.client
            .from('notifications')
            .update({'is_read': true})
            .eq('user_id', session.user.id)
            .eq('is_read', false);
      } catch (e) {
        debugPrint('Error marking all notifications as read: $e');
      }
    }
  }
}
