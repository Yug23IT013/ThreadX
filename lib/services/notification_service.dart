import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'stub_notification_helper.dart';

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Global navigation key for navigation from notifications
  static GlobalKey<NavigatorState>? navigatorKey;

  // Notification channels
  static const String _channelId = 'threadx_high_importance_channel';
  static const String _channelName = 'ThreadX Notifications';
  static const String _channelDescription = 'Notifications for threads, comments, and updates';

  bool _isInitialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (kIsWeb) {
      // Web-specific initialization
      print('Initializing notifications for Web...');
      await _initializeWebNotifications();
    } else {
      // Mobile initialization
      // Initialize timezone
      tz.initializeTimeZones();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Initialize Firebase Cloud Messaging
      await _initializeFirebaseMessaging();
    }

    _isInitialized = true;
    print('Notification Service initialized successfully');
  }

  /// Initialize web notifications
  Future<void> _initializeWebNotifications() async {
    if (!kIsWeb) return;

    // Request notification permission
    final granted = await WebNotificationHelper.requestPermission();
    if (granted) {
      print('Web notification permission granted');
    } else {
      print('Web notification permission denied');
    }

    // Initialize FCM for web
    try {
      await _initializeFirebaseMessaging();
    } catch (e) {
      print('FCM initialization for web failed: $e');
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize with callback for notification taps
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    await _createNotificationChannel();
  }

  /// Create Android notification channel
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Initialize Firebase Cloud Messaging
  Future<void> _initializeFirebaseMessaging() async {
    // Request permission for iOS
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('FCM Permission status: ${settings.authorizationStatus}');

    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Listen to token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      print('FCM Token refreshed: $newToken');
      // TODO: Send token to your backend server
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background message taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Check if app was opened from terminated state via notification
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  /// Handle foreground FCM messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Foreground message received: ${message.messageId}');
    
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    // Show local notification when app is in foreground
    if (notification != null && android != null) {
      await showInstantNotification(
        title: notification.title ?? 'ThreadX',
        body: notification.body ?? '',
        payload: message.data['route'] ?? '',
      );
    }
  }

  /// Handle notification tap from background/terminated state
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Notification opened: ${message.messageId}');
    print('Data: ${message.data}');
    
    // Navigate based on payload
    String? route = message.data['route'];
    String? threadId = message.data['threadId'];
    
    if (route != null && navigatorKey?.currentContext != null) {
      _navigateToScreen(route, threadId);
    }
  }

  /// Handle local notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    
    if (response.payload != null && response.payload!.isNotEmpty) {
      final parts = response.payload!.split('|');
      final route = parts.isNotEmpty ? parts[0] : '';
      final threadId = parts.length > 1 ? parts[1] : null;
      
      _navigateToScreen(route, threadId);
    }
  }

  /// Navigate to specific screen based on route
  void _navigateToScreen(String route, String? threadId) {
    if (navigatorKey?.currentContext == null) return;

    switch (route) {
      case 'thread_detail':
        if (threadId != null) {
          // Navigate to thread detail screen
          // Navigator.pushNamed(context, '/thread_detail', arguments: threadId);
          print('Navigate to thread detail: $threadId');
        }
        break;
      case 'profile':
        // Navigate to profile
        print('Navigate to profile');
        break;
      case 'home':
        // Navigate to home
        print('Navigate to home');
        break;
      default:
        print('Unknown route: $route');
    }
  }

  /// Show instant notification
  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // Use web notifications if on web platform
    if (kIsWeb) {
      await WebNotificationHelper.showNotification(
        title: title,
        body: body,
        onClick: payload != null ? () {
          final parts = payload.split('|');
          final route = parts.isNotEmpty ? parts[0] : '';
          final data = parts.length > 1 ? parts[1] : null;
          _navigateToScreen(route, data);
        } : null,
      );
      return;
    }

    // Mobile notifications
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Schedule notification for future time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    // Web doesn't support scheduled notifications natively
    if (kIsWeb) {
      print('Scheduled notifications not supported on web platform');
      print('Consider using a server-side solution for scheduled web notifications');
      return;
    }
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Schedule daily notification at specific time
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
      0,
    );

    // If scheduled time is before now, add one day
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    if (kIsWeb) {
      print('Individual notification cancel not supported on web');
      return;
    }
    await _localNotifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (kIsWeb) {
      print('Cancel all notifications not supported on web');
      return;
    }
    await _localNotifications.cancelAll();
  }

  /// Get all pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (kIsWeb) {
      print('Pending notifications not available on web');
      return [];
    }
    return await _localNotifications.pendingNotificationRequests();
  }

  /// Show notification for new thread
  Future<void> notifyNewThread({
    required String threadTitle,
    required String threadId,
    required String authorName,
  }) async {
    await showInstantNotification(
      title: 'New Thread Posted',
      body: '$authorName posted: $threadTitle',
      payload: 'thread_detail|$threadId',
    );
  }

  /// Show notification for new comment
  Future<void> notifyNewComment({
    required String threadTitle,
    required String threadId,
    required String commenterName,
    required String comment,
  }) async {
    await showInstantNotification(
      title: 'New Comment on "$threadTitle"',
      body: '$commenterName: $comment',
      payload: 'thread_detail|$threadId',
    );
  }

  /// Show notification for thread vote threshold
  Future<void> notifyThreadPopular({
    required String threadTitle,
    required String threadId,
    required int voteCount,
  }) async {
    await showInstantNotification(
      title: '🔥 Your Thread is Trending!',
      body: '"$threadTitle" has reached $voteCount votes!',
      payload: 'thread_detail|$threadId',
    );
  }

  /// Get FCM token for current device
  Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  /// Subscribe to FCM topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }

  /// Unsubscribe from FCM topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('Unsubscribed from topic: $topic');
  }
}
