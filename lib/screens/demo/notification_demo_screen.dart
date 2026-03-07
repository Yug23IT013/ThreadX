import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../services/notification_service.dart';
import '../../services/web_notification_helper.dart';

class NotificationDemoScreen extends StatefulWidget {
  const NotificationDemoScreen({super.key});

  @override
  State<NotificationDemoScreen> createState() => _NotificationDemoScreenState();
}

class _NotificationDemoScreenState extends State<NotificationDemoScreen> {
  final NotificationService _notificationService = NotificationService();
  String? _fcmToken;
  List<PendingNotificationRequest> _pendingNotifications = [];

  @override
  void initState() {
    super.initState();
    _loadFCMToken();
    _loadPendingNotifications();
  }

  Future<void> _loadFCMToken() async {
    final token = await _notificationService.getFCMToken();
    setState(() {
      _fcmToken = token;
    });
  }

  Future<void> _loadPendingNotifications() async {
    final pending = await _notificationService.getPendingNotifications();
    setState(() {
      _pendingNotifications = pending;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Demo'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Platform Info Banner
            if (kIsWeb) _buildWebPlatformInfo(),
            if (!kIsWeb) _buildMobilePlatformInfo(),
            const SizedBox(height: 16),
            
            // FCM Token Display
            _buildSectionTitle('Firebase Cloud Messaging'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Device FCM Token:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _fcmToken ?? 'Loading...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Use this token to send test push notifications from Firebase Console',
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Local Notifications Section
            _buildSectionTitle('Local Notifications'),
            _buildNotificationButton(
              'Instant Notification',
              'Shows notification immediately',
              Icons.notifications_active,
              Colors.blue,
              _showInstantNotification,
            ),
            if (!kIsWeb) _buildNotificationButton(
              'Scheduled Notification (5s)',
              'Shows notification after 5 seconds',
              Icons.schedule,
              Colors.orange,
              _showScheduledNotification,
            ),
            if (kIsWeb) _buildDisabledNotificationButton(
              'Scheduled Notification (5s)',
              'Not supported on web - requires server',
              Icons.schedule,
              Colors.grey,
            ),
            if (!kIsWeb) _buildNotificationButton(
              'Daily Reminder (8 AM)',
              'Sets daily notification at 8:00 AM',
              Icons.alarm,
              Colors.purple,
              _showDailyNotification,
            ),
            if (kIsWeb) _buildDisabledNotificationButton(
              'Daily Reminder (8 AM)',
              'Not supported on web - requires server',
              Icons.alarm,
              Colors.grey,
            ),
            const SizedBox(height: 24),

            // Thread-specific Notifications
            _buildSectionTitle('ThreadX Notifications'),
            _buildNotificationButton(
              'New Thread Posted',
              'Simulates a new thread notification',
              Icons.article,
              Colors.green,
              _showNewThreadNotification,
            ),
            _buildNotificationButton(
              'New Comment',
              'Simulates a comment notification',
              Icons.comment,
              Colors.teal,
              _showNewCommentNotification,
            ),
            _buildNotificationButton(
              'Thread Trending',
              'Simulates a popular thread notification',
              Icons.trending_up,
              Colors.red,
              _showTrendingThreadNotification,
            ),
            const SizedBox(height: 24),

            // Topic Subscriptions
            _buildSectionTitle('FCM Topic Subscriptions'),
            Row(
              children: [
                Expanded(
                  child: _buildNotificationButton(
                    'Subscribe to "threads"',
                    'Get notified about new threads',
                    Icons.subscriptions,
                    Colors.indigo,
                    () => _subscribeToTopic('threads'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildNotificationButton(
                    'Subscribe to "comments"',
                    'Get notified about new comments',
                    Icons.subscriptions,
                    Colors.cyan,
                    () => _subscribeToTopic('comments'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Pending Notifications (Mobile Only)
            if (!kIsWeb) ...[
              _buildSectionTitle('Pending Scheduled Notifications'),
              Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total: ${_pendingNotifications.length}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          onPressed: _loadPendingNotifications,
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Refresh',
                        ),
                      ],
                    ),
                    if (_pendingNotifications.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('No pending notifications'),
                      )
                    else
                      ..._pendingNotifications.map((notification) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            leading: const Icon(Icons.schedule, size: 20),
                            title: Text(
                              notification.title ?? 'No title',
                              style: const TextStyle(fontSize: 14),
                            ),
                            subtitle: Text(
                              notification.body ?? 'No body',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.cancel, size: 20),
                              onPressed: () => _cancelNotification(notification.id),
                            ),
                          )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ], // End mobile-only section

            // Cancel All (Mobile Only)
            if (!kIsWeb) _buildNotificationButton(
              'Cancel All Notifications',
              'Clears all pending notifications',
              Icons.cancel,
              Colors.grey,
              _cancelAllNotifications,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNotificationButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[400]),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onPressed,
      ),
    );
  }

  Widget _buildDisabledNotificationButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      color: Colors.grey.withOpacity(0.1),
      child: ListTile(
        enabled: false,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(color: Colors.grey),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Icon(Icons.block, size: 16, color: Colors.grey),
      ),
    );
  }

  // Notification Actions
  Future<void> _showInstantNotification() async {
    await _notificationService.showInstantNotification(
      title: '✨ Instant Notification',
      body: 'This notification appeared immediately!',
      payload: 'home',
    );
    _showSnackBar('Instant notification sent!');
  }

  Future<void> _showScheduledNotification() async {
    final scheduledTime = DateTime.now().add(const Duration(seconds: 5));
    await _notificationService.scheduleNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '⏰ Scheduled Notification',
      body: 'This notification was scheduled 5 seconds ago',
      scheduledTime: scheduledTime,
      payload: 'home',
    );
    _showSnackBar('Notification scheduled for 5 seconds from now');
    await _loadPendingNotifications();
  }

  Future<void> _showDailyNotification() async {
    await _notificationService.scheduleDailyNotification(
      id: 999,
      title: '☀️ Good Morning!',
      body: 'Check out the latest threads on ThreadX',
      hour: 8,
      minute: 0,
      payload: 'home',
    );
    _showSnackBar('Daily notification set for 8:00 AM');
    await _loadPendingNotifications();
  }

  Future<void> _showNewThreadNotification() async {
    await _notificationService.notifyNewThread(
      threadTitle: 'What are your thoughts on Flutter 3.0?',
      threadId: 'demo_thread_123',
      authorName: 'John Doe',
    );
    _showSnackBar('New thread notification sent!');
  }

  Future<void> _showNewCommentNotification() async {
    await _notificationService.notifyNewComment(
      threadTitle: 'Best practices for state management',
      threadId: 'demo_thread_456',
      commenterName: 'Jane Smith',
      comment: 'I think Provider is great for simple apps!',
    );
    _showSnackBar('New comment notification sent!');
  }

  Future<void> _showTrendingThreadNotification() async {
    await _notificationService.notifyThreadPopular(
      threadTitle: 'Your awesome thread',
      threadId: 'demo_thread_789',
      voteCount: 100,
    );
    _showSnackBar('Trending thread notification sent!');
  }

  Future<void> _subscribeToTopic(String topic) async {
    await _notificationService.subscribeToTopic(topic);
    _showSnackBar('Subscribed to "$topic" topic!');
  }

  Future<void> _cancelNotification(int id) async {
    await _notificationService.cancelNotification(id);
    _showSnackBar('Notification cancelled');
    await _loadPendingNotifications();
  }

  Future<void> _cancelAllNotifications() async {
    await _notificationService.cancelAllNotifications();
    _showSnackBar('All notifications cancelled');
    await _loadPendingNotifications();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Platform Info Widgets
  Widget _buildWebPlatformInfo() {
    final supported = kIsWeb ? WebNotificationHelper.isSupported() : false;
    final permission = kIsWeb ? WebNotificationHelper.getPermissionStatus() : 'unknown';
    
    return Card(
      color: Colors.blue.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.language, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Running on Web Browser',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Notifications Supported', supported ? 'Yes ✅' : 'No ❌'),
            _buildInfoRow('Permission Status', permission),
            const SizedBox(height: 8),
            Text(
              'Note: Scheduled notifications require server-side solution on web',
              style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey[400]),
            ),
            if (permission != 'granted' && supported) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  final granted = await WebNotificationHelper.requestPermission();
                  setState(() {});
                  _showSnackBar(granted ? 'Permission granted!' : 'Permission denied');
                },
                icon: Icon(Icons.notifications_active),
                label: Text('Request Permission'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMobilePlatformInfo() {
    return Card(
      color: Colors.green.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.phone_android, color: Colors.green),
            const SizedBox(width: 8),
            Text(
              'Running on Mobile Platform',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: value.contains('✅') ? Colors.green : 
                     value.contains('❌') ? Colors.red : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
