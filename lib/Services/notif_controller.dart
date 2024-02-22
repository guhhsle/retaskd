import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:retaskd/Classes/task.dart';

import '../theme/colors.dart';

class NotificationController {
  static Future<void> initializeLocalNotifications() async {
    await AwesomeNotifications().initialize(
      'resource://drawable/ic_launcher',
      [
        NotificationChannel(
          channelKey: 'scheduled-tasks',
          channelName: 'Scheduled',
          channelDescription: 'Scheduled tasks',
          playSound: true,
          onlyAlertOnce: false,
          groupAlertBehavior: GroupAlertBehavior.All,
          importance: NotificationImportance.High,
          defaultPrivacy: NotificationPrivacy.Private,
          defaultColor: Colors.deepPurple,
          ledColor: Colors.deepPurple,
        )
      ],
      debug: true,
    );
  }

  static Future<void> scheduleNewNotification(Task task) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      isAllowed = await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    if (!isAllowed) return;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        summary: task.title,
        id: -1,
        channelKey: 'scheduled-tasks',
        title: task.title,
        category: NotificationCategory.Reminder,
        body: task.description,
        notificationLayout: NotificationLayout.Messaging,
        color: darkColors[task.color],
        payload: {'notificationId': '1234567890'},
      ),
      actionButtons: [
        NotificationActionButton(key: 'REDIRECT', label: 'Redirect'),
        NotificationActionButton(
          key: 'DISMISS',
          label: 'Dismiss',
          isDangerousOption: true,
        )
      ],
      schedule: NotificationCalendar.fromDate(
        allowWhileIdle: true,
        date: task.due.subtract(Duration(minutes: task.notif)),
      ),
    );
  }

  static Future<void> cancelNotifications() async {
    await AwesomeNotifications().cancelAll();
  }
}
