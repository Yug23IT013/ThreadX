import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Web-specific notification helper using browser's Notification API
class WebNotificationHelper {
  static bool _permissionGranted = false;

  /// Request notification permission from the browser
  static Future<bool> requestPermission() async {
    if (!kIsWeb) return false;

    try {
      final permission = await html.Notification.requestPermission();
      _permissionGranted = permission == 'granted';
      return _permissionGranted;
    } catch (e) {
      print('Error requesting notification permission: $e');
      return false;
    }
  }

  /// Check if notifications are supported in the browser
  static bool isSupported() {
    if (!kIsWeb) return false;
    return html.Notification.supported;
  }

  /// Check current permission status
  static String getPermissionStatus() {
    if (!kIsWeb || !html.Notification.supported) return 'not-supported';
    return html.Notification.permission ?? 'default';
  }

  /// Show a web notification using browser's Notification API
  static Future<void> showNotification({
    required String title,
    required String body,
    String? icon,
    String? tag,
    void Function()? onClick,
  }) async {
    if (!kIsWeb || !html.Notification.supported) {
      print('Web notifications not supported');
      return;
    }

    // Check permission
    if (html.Notification.permission != 'granted') {
      final granted = await requestPermission();
      if (!granted) {
        print('Notification permission denied');
        return;
      }
    }

    try {
      final notification = html.Notification(
        title,
        body: body,
        icon: icon ?? '/icons/Icon-192.png',
        tag: tag,
      );

      // Handle click event
      if (onClick != null) {
        notification.onClick.listen((_) {
          onClick();
          notification.close();
        });
      }

      // Auto-close after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        notification.close();
      });
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  /// Show notification with custom options
  static Future<void> showAdvancedNotification({
    required String title,
    required String body,
    String? icon,
    String? tag,
    void Function()? onClick,
    void Function()? onClose,
    void Function()? onError,
  }) async {
    if (!kIsWeb || !html.Notification.supported) {
      print('Web notifications not supported');
      return;
    }

    if (html.Notification.permission != 'granted') {
      final granted = await requestPermission();
      if (!granted) return;
    }

    try {
      final notification = html.Notification(
        title,
        body: body,
        icon: icon ?? '/icons/Icon-192.png',
        tag: tag,
      );

      if (onClick != null) {
        notification.onClick.listen((_) {
          onClick();
          notification.close();
        });
      }

      if (onClose != null) {
        notification.onClose.listen((_) => onClose());
      }

      if (onError != null) {
        notification.onError.listen((_) => onError());
      }

      // Auto-close after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        notification.close();
      });
    } catch (e) {
      print('Error showing advanced notification: $e');
    }
  }

  /// Show a simple toast-like notification
  static Future<void> showToast({
    required String title,
    required String message,
  }) async {
    await showNotification(
      title: title,
      body: message,
    );
  }

  /// Show notification for new thread (ThreadX specific)
  static Future<void> notifyNewThread({
    required String threadTitle,
    required String authorName,
    void Function()? onNavigate,
  }) async {
    await showNotification(
      title: 'New Thread Posted',
      body: '$authorName posted: $threadTitle',
      icon: '/icons/Icon-192.png',
      tag: 'new-thread',
      onClick: onNavigate,
    );
  }

  /// Show notification for new comment (ThreadX specific)
  static Future<void> notifyNewComment({
    required String threadTitle,
    required String commenterName,
    required String comment,
    void Function()? onNavigate,
  }) async {
    await showNotification(
      title: 'New Comment on "$threadTitle"',
      body: '$commenterName: $comment',
      icon: '/icons/Icon-192.png',
      tag: 'new-comment',
      onClick: onNavigate,
    );
  }

  /// Show notification for trending thread (ThreadX specific)
  static Future<void> notifyThreadPopular({
    required String threadTitle,
    required int voteCount,
    void Function()? onNavigate,
  }) async {
    await showNotification(
      title: '🔥 Your Thread is Trending!',
      body: '"$threadTitle" has reached $voteCount votes!',
      icon: '/icons/Icon-192.png',
      tag: 'trending-thread',
      onClick: onNavigate,
    );
  }
}
