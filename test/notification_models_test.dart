import 'package:flutter_test/flutter_test.dart';
import 'package:syndory_prof/features/notifications/notification_models.dart';

void main() {
  group('NotificationModels', () {
    test('AppNotification.fromMap should correctly parse full payload', () {
      final now = DateTime.now();
      final map = {
        'id': '123-abc',
        'type': 'session_opened',
        'title': 'Test Title',
        'message': 'Test Message',
        'is_read': true,
        'created_at': now.toIso8601String(),
      };

      final notification = AppNotification.fromMap(map);

      expect(notification.id, '123-abc');
      expect(notification.category, NotificationCategory.sessionOpened);
      expect(notification.title, 'Test Title');
      expect(notification.message, 'Test Message');
      expect(notification.isRead, true);
    });

    test('AppNotification.fromMap should handle null or missing fields gracefully', () {
      final map = <String, dynamic>{};

      final notification = AppNotification.fromMap(map);

      expect(notification.id, null);
      expect(notification.category, NotificationCategory.unknown);
      expect(notification.title, 'Notification');
      expect(notification.message, '');
      expect(notification.isRead, false);
      expect(notification.createdAt, isA<DateTime>());
    });

    test('NotificationCategory parsing should map correctly', () {
      expect(NotificationCategoryParse.parse('session_opened'), NotificationCategory.sessionOpened);
      expect(NotificationCategoryParse.parse('new_resource'), NotificationCategory.newResource);
      expect(NotificationCategoryParse.parse('unknown_type'), NotificationCategory.unknown);
      expect(NotificationCategoryParse.parse(null), NotificationCategory.unknown);
    });

    test('AppNotification.copyWith should update fields', () {
      final notification = AppNotification(
        id: '1',
        category: NotificationCategory.announcement,
        title: 'Title',
        message: 'Message',
        isRead: false,
        createdAt: DateTime.now(),
      );

      final updated = notification.copyWith(isRead: true);

      expect(updated.isRead, true);
      expect(updated.id, '1');
      expect(updated.title, 'Title');
    });
  });
}
