import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    try {
      // Request Android 13+ notification permission
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      // Fix: icon name should not have @mipmap/ prefix
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('ic_launcher');

      const InitializationSettings initSettings =
          InitializationSettings(android: androidSettings);

      // v20+ uses named parameter 'settings'
      await _notificationsPlugin.initialize(settings: initSettings);
      debugPrint('NotificationService initialized successfully.');
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  /// Display a local notification immediately.
  static Future<void> showNotification(String title, String body) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'antigravity_alerts',
        'Match Alerts',
        channelDescription: 'Notifications for new matches and activity',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );

      // v20+ uses named parameters for show()
      await _notificationsPlugin.show(
        id: DateTime.now().millisecond,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(android: androidDetails),
      );
      debugPrint('Notification shown successfully: $title');
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  /// Subscribe to Supabase Realtime and fire a local notification
  /// whenever a new row is inserted into the `notifications` table
  /// that targets the current user.
  static void startListening() {
    final currentUserId =
        Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == null) return;

    Supabase.instance.client
        .channel('public:notifications')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          callback: (payload) {
            final newRecord = payload.newRecord;
            if (newRecord['user_id'] == currentUserId) {
              showNotification(
                newRecord['title'] ?? 'New Notification',
                newRecord['body'] ?? '',
              );
            }
          },
        )
        .subscribe();
  }
}
