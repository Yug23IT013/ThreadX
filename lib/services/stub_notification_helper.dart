/// Stub notification helper for non-web platforms (Android, iOS, Windows, etc.)
/// This provides the same interface as WebNotificationHelper but does nothing on mobile
class WebNotificationHelper {
  static bool _permissionGranted = false;

  /// Request notification permission (stub for mobile - uses native APIs instead)
  static Future<bool> requestPermission() async {
    return false; // Mobile uses native permission APIs
  }

  /// Check if notifications are supported (always false for this stub)
  static bool isSupported() {
    return false;
  }

  /// Check current permission status (stub)
  static String getPermissionStatus() {
    return 'not-supported';
  }

  /// Show a web notification (stub - not used on mobile)
  static Future<void> showNotification({
    required String title,
    required String body,
    String? icon,
    String? tag,
    void Function()? onClick,
  }) async {
    // Mobile uses flutter_local_notifications instead
  }

  /// Show a notification with bigText style (stub)
  static Future<void> showBigTextNotification({
    required String title,
    required String body,
    String? bigText,
    String? icon,
    String? tag,
    void Function()? onClick,
  }) async {
    // Mobile uses flutter_local_notifications instead
  }
}
