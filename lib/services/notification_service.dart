import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// handles local notifications for tp go
// covers the "additional feature" requirement - notifications when a
// location becomes closed, under renovation, or high crowd
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // sets up the notification plugin - call this once, in main() after
  // Firebase initializes
  Future<void> init() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);

    // android 13+ requires asking for notification permission at runtime
    final androidImplementation = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();

    final iosImplementation = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await iosImplementation?.requestPermissions(alert: true, badge: true, sound: true);

    _isInitialized = true;
  }

  // shows an immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'tpgo_location_updates',
      'Location Updates',
      channelDescription: 'Notifies you when a saved or nearby location changes status',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    try {
      await _plugin.show(id, title, body, details);
    } catch (error) {
      // notification failures should never crash the app - just log it
      // ignore: avoid_print
      print('Notification failed: $error');
    }
  }

 Future<void> notifyLocationStatusChange({
  required String locationName,
  required String newStatus,
}) async {
  String body;

  if (newStatus == 'Open') {
    body = '$locationName is now open.';
  } else if (newStatus == 'Busy') {
    body = '$locationName is currently busy.';
  } else if (newStatus == 'Closed') {
    body = '$locationName is now closed.';
  } else if (newStatus == 'Under Renovation') {
    body = '$locationName is under renovation.';
  } else {
    body = '$locationName status changed to $newStatus.';
  }

  await showNotification(
    id: locationName.hashCode,
    title: 'Location update',
    body: body,
  );
}

  Future<void> notifyCrowdLevelChange({
    required String locationName,
    required String newCrowd,
  }) async {
    await showNotification(
      id: locationName.hashCode + 1,
      title: 'Crowd update',
      body: '$locationName crowd level changed to $newCrowd.',
    );
  }

  Future<void> notifyHighCrowd(String locationName) async {
    await showNotification(
      id: locationName.hashCode + 1,
      title: 'High crowd alert',
      body: '$locationName is currently very crowded.',
    );
  }

  Future<void> notifyNewLocation(String locationName) async {
    await showNotification(
      id: locationName.hashCode + 2,
      title: 'New place on campus',
      body: '$locationName was just added to TP Go!',
    );
  }
}
