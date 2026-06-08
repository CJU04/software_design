import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  Function(String?, Map<String?, String?>)? onMessageReceived;
  Function(String?)? onTokenRefreshed;

  Future<void> initialize() async {
    await _requestPermission();
    await _initializeLocalNotifications();
    await _getToken();
    await _subscribeToTopics();
    _setupMessageHandlers();
  }

  Future<void> _requestPermission() async {
    if (Platform.isIOS) {
      final iosPermission = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      if (kDebugMode) {
        print('IOS Permission status: ${iosPermission.authorizationStatus}');
      }
    } else if (Platform.isAndroid) {
      final androidPermission = await _firebaseMessaging.requestPermission();
      if (kDebugMode) {
        print('Android Permission status: ${androidPermission.authorizationStatus}');
      }
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
  }

  void _onNotificationResponse(NotificationResponse response) {
    if (kDebugMode) {
      print('Notification tapped: ${response.payload}');
    }
    final payload = response.payload;
    if (payload != null && onMessageReceived != null) {
      onMessageReceived!(payload, {});
    }
  }

  Future<void> _getToken() async {
    _fcmToken = await _firebaseMessaging.getToken();
    if (kDebugMode) {
      print('FCM Token: $_fcmToken');
    }
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      if (kDebugMode) {
        print('FCM Token refreshed: $newToken');
      }
      onTokenRefreshed?.call(newToken);
    });
  }

  Future<void> _subscribeToTopics() async {
    try {
      await _firebaseMessaging.subscribeToTopic('appointments');
      await _firebaseMessaging.subscribeToTopic('general');
      if (kDebugMode) {
        print('Subscribed to FCM topics');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error subscribing to topics: $e');
      }
    }
  }

  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    _firebaseMessaging.getInitialMessage().then(_handleInitialMessage);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Foreground message received: ${message.messageId}');
    }
    _showLocalNotification(message);
    onMessageReceived?.call(message.messageId, message.data.cast<String?, String?>());
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('Message opened app: ${message.messageId}');
    }
    onMessageReceived?.call(message.messageId, message.data.cast<String?, String?>());
  }

  void _handleInitialMessage(RemoteMessage? message) {
    if (message != null && kDebugMode) {
      debugPrint('Initial message: ${message.messageId}');
      onMessageReceived?.call(message.messageId, message.data.cast<String?, String?>());
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final androidDetails = AndroidNotificationDetails(
      'furfectcare_notifications',
      'FurfectCare Notifications',
      channelDescription: 'General notifications from FurfectCare',
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotificationsPlugin.show(
      id: message.hashCode,
      title: message.notification?.title ?? 'FurfectCare',
      body: message.notification?.body ?? 'You have a new notification',
      notificationDetails: details,
      payload: message.data['screen'] ?? '',
    );
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'furfectcare_notifications',
      'FurfectCare Notifications',
      channelDescription: 'General notifications from FurfectCare',
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotificationsPlugin.show(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  Future<void> showAppointmentReminder({
    required String appointmentId,
    required String petName,
    required String date,
    required String time,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'appointments',
      'Appointment Reminders',
      channelDescription: 'Notifications for upcoming appointments',
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotificationsPlugin.show(
      id: appointmentId.hashCode,
      title: 'Upcoming Appointment',
      body: 'Your pet $petName has an appointment on $date at $time',
      notificationDetails: details,
      payload: 'appointment:$appointmentId',
    );
  }

  Future<void> cancelNotification(int id) async {
    await _localNotificationsPlugin.cancel(id: id);
  }

  Future<void> cancelAllNotifications() async {
    await _localNotificationsPlugin.cancelAll();
  }

  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    // This would typically use Firebase Cloud Functions
    // For now, we'll use local notifications as a demonstration
    await showNotification(
      title: title,
      body: body,
      payload: data?['screen'] ?? '',
    );
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print('Background message: ${message.messageId}');
  }
}
