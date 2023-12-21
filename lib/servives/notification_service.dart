import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/models/task_model.dart';


class NotificationManager {
  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid =
    const AndroidInitializationSettings('credex_logo');

    DarwinInitializationSettings initializationIos =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) {},
    );
    InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationIos);
    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );
  }

  Future<void> simpleNotificationShow(Task task) async {
    AndroidNotificationDetails androidNotificationDetails = const AndroidNotificationDetails(
      'Channel_id',
      'Channel_title',
      priority: Priority.high,
      importance: Importance.max,
      icon: 'credex_logo',
      channelShowBadge: true,
      largeIcon: DrawableResourceAndroidBitmap('credex_logo'),
    );

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails);

    DateTime duedate = task.dueDate;
    String date = duedate.toString();
    String notificationTitle = task.title;
    String notificationBody = 'Category:' + task.category + '\nDue Date:' +
        date;

    await notificationsPlugin.show(
        0, notificationTitle, notificationBody, notificationDetails);
  }

  Future<void> multipleTaskNotifications(List<Task> tasks) async {
    AndroidNotificationDetails androidNotificationDetails =
    const AndroidNotificationDetails(
      'Channel_id',
      'Channel_title',
      priority: Priority.high,
      importance: Importance.max,
      groupKey: 'taskMessages',
    );

    NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);

    for (int i = 0; i < tasks.length; i++) {
      Task task = tasks[i];
      await Future.delayed(
        Duration(milliseconds: i * 1000),
            () {
          simpleNotificationShow(task);
        },
      );
    }

    List<String> lines = tasks.map((task) => task.title).toList();

    InboxStyleInformation inboxStyleInformation = InboxStyleInformation(
      lines,
      contentTitle: '${lines.length} tasks due',
      summaryText: 'Task Notification',
    );

    AndroidNotificationDetails androidNotificationSpecific =
    AndroidNotificationDetails(
      'groupChannelId',
      'groupChannelTitle',
      styleInformation: inboxStyleInformation,
      groupKey: 'taskMessages',
      setAsGroupSummary: true,
    );

    NotificationDetails platformChannelSpecific =
    NotificationDetails(android: androidNotificationSpecific);

    await Future.delayed(
      Duration(hours: 4),
          () async {
        await notificationsPlugin.show(
          tasks.length + 1,
          'Task Notifications',
          '${lines.length} tasks due',
          platformChannelSpecific,
        );
      },
    );
  }

  Future<void> schedulePeriodicNotification(List<Task> tasks) async {
    DateTime currentDate = DateTime.now();
    List<Task> todayTasks = tasks.where((task) {
      return task.dueDate.year == currentDate.year &&
          task.dueDate.month == currentDate.month &&
          task.dueDate.day == currentDate.day &&
          task.category != 'Completed';
    }).toList();

    multipleTaskNotifications(todayTasks);
    // for (Task task in todayTasks) {
    //   await simpleNotificationShow(task);
    // }
  }
}