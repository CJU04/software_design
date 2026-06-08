import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vetcare_connect/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  bool _isInitialized = false;
  bool _notificationsEnabled = true;
  String? _fcmToken;

  bool get isInitialized => _isInitialized;
  bool get notificationsEnabled => _notificationsEnabled;
  String? get fcmToken => _fcmToken;

  NotificationProvider() {
    _loadNotificationPreference();
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _notificationService.initialize();
      _fcmToken = _notificationService.fcmToken;

      _notificationService.onTokenRefreshed = (newToken) {
        _fcmToken = newToken;
        notifyListeners();
      };

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing notifications: $e');
      }
    }
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);

    if (_notificationsEnabled) {
      await _notificationService.initialize();
    } else {
      await _notificationService.cancelAllNotifications();
    }

    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    if (_notificationsEnabled == enabled) return;

    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);

    if (_notificationsEnabled) {
      await _notificationService.initialize();
    } else {
      await _notificationService.cancelAllNotifications();
    }

    notifyListeners();
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_notificationsEnabled) return;
    await _notificationService.showNotification(
      title: title,
      body: body,
      payload: payload,
    );
  }

  Future<void> showAppointmentReminder({
    required String appointmentId,
    required String petName,
    required String date,
    required String time,
  }) async {
    if (!_notificationsEnabled) return;
    await _notificationService.showAppointmentReminder(
      appointmentId: appointmentId,
      petName: petName,
      date: date,
      time: time,
    );
  }
}
