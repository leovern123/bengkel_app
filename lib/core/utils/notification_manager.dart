import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

enum NotificationType { success, warning, info, system }

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  final NotificationType type;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'time': time.toIso8601String(),
        'type': type.index,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'],
        title: json['title'],
        body: json['body'],
        time: DateTime.parse(json['time']),
        type: NotificationType.values[json['type']],
      );
}

class NotificationManager {
  static const String _storageKey = 'app_notifications';
  static List<AppNotification> _notifications = [];

  static Future<void> addNotification({
    required String title,
    required String body,
    required NotificationType type,
  }) async {
    final newNotif = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      time: DateTime.now(),
      type: type,
    );

    _notifications.insert(0, newNotif);
    await _saveToStorage();
  }

  static Future<List<AppNotification>> getNotifications() async {
    if (_notifications.isEmpty) {
      await _loadFromStorage();
    }
    return _notifications;
  }

  static Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_notifications.map((n) => n.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  static Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString(_storageKey);
    if (encoded != null) {
      final List<dynamic> decoded = jsonDecode(encoded);
      _notifications = decoded.map((item) => AppNotification.fromJson(item)).toList();
    }
  }

  static Future<void> clearAll() async {
    _notifications.clear();
    await _saveToStorage();
  }
}
