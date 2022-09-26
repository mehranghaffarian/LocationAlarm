import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationUtils {
  static final _notification = FlutterLocalNotificationsPlugin();

  static Future showNotification({
    int ID = 0,
    String title = 'location alarm',
    required String body,
    String payload = 'payload',
  }) async =>
      _notification.show(ID, title, body, await _notificationDetails(),
          payload: payload);

  static _notificationDetails() => const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel id',
          'channel name',
          // channelDescription: 'channel description',
          importance: Importance.max,
        ),
        iOS: IOSNotificationDetails(),
      );

  static showNotificationWithWatchDelay({required String body}) async {
    NotificationUtils.showNotification(
        title: 'location alarm', body: body, payload: 'junk payload');

    await Future.delayed(const Duration(seconds: 5), () {});
  }
}
