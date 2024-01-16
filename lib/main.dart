import 'package:credex_task_manager/core/models/image_model.dart';
import 'package:credex_task_manager/servives/notification_service.dart';
import 'package:credex_task_manager/task_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'core/models/category_model.dart';
import 'core/models/task_model.dart';
import 'core/widgets/category_provider.dart';
import 'core/widgets/task_provider.dart';

late final tasksBox;
late final imageBox;
late final categoriesBox;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationManager().initNotification();
  NotificationManager notificationManager = NotificationManager();
  var directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(ImageModelAdapter());

  tasksBox = await Hive.openBox<Task>('Tasks');
  imageBox = await Hive.openBox<ImageModel>('imageBox');

  List<Task> tasks = tasksBox.values.toList();
  await notificationManager.schedulePeriodicNotification(tasks);
  Hive.registerAdapter(CategoryAdapter());
  categoriesBox = await Hive.openBox<Category>('Categories');
  runApp(MultiProvider(
    providers: [
      //ChangeNotifierProvider(create: (context) => CategoryStatusProvider()),
      ChangeNotifierProvider(create: (context) => TaskProvider()),
      ChangeNotifierProvider(create: (context) => CategoryProvider()),
        ],
        child: MyApp(),
      )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF3AA8C1)),
        useMaterial3: true,
      ),
      home: TaskList(),
    );
  }
}
