import 'package:history_zukan/models/index.dart';

// Stub implementation — flutter_local_notifications not in pubspec.
// Replace with real implementation when Firebase is configured.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  NotificationService._internal();
  factory NotificationService() => _instance;

  Future<void> initialize() async {}
  Future<void> scheduleAllNotifications(List<HistoryEvent> events) async {}
  Future<void> scheduleEventNotification(HistoryEvent event) async {}
  Future<void> cancelAllNotifications() async {}
  Future<void> cancelNotification(String eventId) async {}
  Future<void> showTestNotification() async {}
}
