import 'dart:convert';
import 'dart:io';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'category_list.dart';
import 'core/models/category_model.dart';
import 'core/models/task_model.dart';
import 'core/widgets/add_task.dart';
import 'core/widgets/category_provider.dart';
import 'core/widgets/task_detail.dart';
import 'core/widgets/task_provider.dart';
import 'main.dart';

class TaskList extends StatefulWidget {
  const TaskList({Key? key}) : super(key: key);

  @override
  State createState() => _ListTileExample();
}

class InnerList {
  String category;
  List<Task> tasks;

  InnerList({
    required this.category,
    required this.tasks,
  });
}


class _ListTileExample extends State<TaskList> with RestorationMixin {
  final TaskProvider taskProvider = TaskProvider();
  final CategoryProvider categoryProvider = CategoryProvider();
  List<InnerList> _lists = [];
  late List<Task> tasks;
  late List<Category> categories;

  // Restoration properties
  final RestorableInt _selectedTabIndex = RestorableInt(0);

  @override
  String get restorationId => 'taskList';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedTabIndex, 'selected_tab_index');
  }


  @override
  void initState() {
    super.initState();
    fetchDataFromHive();
  }


  // void checkDueDateAndScheduleNotification(NotificationManager notificationManager) {
  //   for(Task task in tasks){
  //     DateTime dueDate = task.dueDate;
  //
  //     if (isDueDateToday(dueDate)) {
  //       notificationManager.scheduleNotification(
  //         task.title,
  //         'Your task is due today!',
  //         dueDate,
  //       );
  //     }
  //   }
  // }
  //
  // bool isDueDateToday(DateTime dueDate) {
  //   DateTime now = DateTime.now();
  //   return dueDate.year == now.year && dueDate.month == now.month && dueDate.day == now.day;
  // }

  Future<void> fetchDataFromHive() async {

    tasks = tasksBox.values.toList();
    categories = categoriesBox.values.toList();

    if (tasks.isEmpty) {
      setState(() {
        _lists = [];
      });
    } else {
      final categoryNames = ['All Tasks', ...categories.map((category) => category.category).toList()];

      setState(() {
        _lists = List.generate(categoryNames.length, (categoryIndex) {
          final categoryName = categoryNames[categoryIndex];
          final categoryTasks = (categoryName == 'All Tasks')
              ? tasks
              : tasks.where((task) => task.category == categoryName).toList();

          return InnerList(
            tasks: categoryTasks,
            category: categoryName,
          );
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List'),
        actions: [
          Row(
            children: [
              IconButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryList()));
              }, icon: Icon(Icons.category_outlined)),
              IconButton(onPressed: (){
                restoreTaskBackup();
              }, icon: Icon(Icons.restore)),
              IconButton(onPressed: (){
                taskBackup();
                categoryBackup();
              }, icon: Icon(Icons.backup_outlined)),
            ],
          )
        ],
        elevation: 4,
      ),
      body: DragAndDropLists(
        children: List.generate(_lists.length, (index) => _buildList(index)),
        onItemReorder: _onItemReorder,
        onListReorder: _onListReorder,
        // listGhost is mandatory when using expansion tiles to prevent multiple widgets using the same globalkey
        listGhost: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 100.0),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(7.0),
              ),
              child: const Icon(Icons.add_box),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  _buildList(int outerIndex) {
    var innerList = _lists[outerIndex];
    return DragAndDropListExpansion(
      title: Text('${innerList.category}'),
      children: List.generate(
        innerList.tasks.length,
            (index) => _buildItem(innerList.tasks[index]),
      ),
      listKey: ObjectKey(innerList.category),
    );
  }

  _buildItem(Task task) {
    int taskdate = task.dueDate.day;
    int currentDate = DateTime.now().day;
    int taskMonth = task.dueDate.month;
    int currentMonth =  DateTime.now().month;

    Color itemColor;
    if (task.category == 'Completed') {
      itemColor = Colors.green;
    } else {
      itemColor = taskdate == currentDate && taskMonth == currentMonth
          ? Colors.orange
          : (taskdate < currentDate && taskMonth == currentMonth ? Colors.red : Colors.black);
    }
    return DragAndDropItem(
      child: ListTile(
        title: Text(task.title, style: TextStyle(color: itemColor),),
        onTap: () {
          print(task.title);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskDetailsPage(task: task)),
          );
        },
      ),
    );
  }


  _onItemReorder(int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {
      if (oldListIndex == newListIndex) {

        var innerList = _lists[oldListIndex];
        var movedList = innerList.tasks.removeAt(oldItemIndex);
        innerList.tasks.insert(newItemIndex, movedList);

        List<Task> listToAdd = innerList.tasks;
        for( Task task in listToAdd){
          print(task.title);
        }

        int i =0;
        tasks.where((element) =>
        element.category == _lists[oldListIndex].category)
            .forEach((element1) {
          tasksBox.putAt(tasks.indexOf(element1), listToAdd[i]);
          i++;

        });

        print(tasks.length);



        for( Task task in listToAdd){
          print(task.title);
        }


      } else {
        var innerList = _lists[oldListIndex];
        var innerList2 = _lists[newListIndex];
        var movedList = innerList.tasks.removeAt(oldItemIndex);
        innerList2.tasks.insert(newItemIndex, movedList);
        innerList2.tasks[newItemIndex].category = innerList2.category;
        print(innerList2.tasks[newItemIndex].category);
        print(innerList2.tasks[newItemIndex].title);

        tasks.where((element) =>
        element.title == innerList2.tasks[newItemIndex].title)
            .forEach((element) {
          tasksBox.deleteAt(tasks.indexOf(element));
          tasksBox.add(innerList2.tasks[newItemIndex]);
        });
      }
    });
  }

  _onListReorder(int oldListIndex, int newListIndex) {
    setState(() {
      var movedList = _lists.removeAt(oldListIndex);
      _lists.insert(newListIndex, movedList);

      List<String> categoryToAdd = [];
      for (int i = 0; i < _lists.length; i++) {
        var innerList = _lists[i];
        categoryToAdd.add(innerList.category);
      }
      categoryToAdd.removeWhere((category) => category == 'All Tasks');
      print(categoryToAdd);
      categoriesBox.deleteAll(categoriesBox.keys);
      for(String i in categoryToAdd){
        categoriesBox.add(Category(category: i));
      }
    });
  }
  //create backup of tasks
  Future taskBackup() async {
    if (tasksBox.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No Tasks Stored.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Creating task backup...')),
    );
    Map map = tasksBox
        .toMap()
        .map((key, value) => MapEntry(key.toString(), value));
    String json = jsonEncode(map);
    Directory dir = await _tasksDirectory();
    String formattedDate = DateTime.now()
        .toString()
        .replaceAll('.', '-')
        .replaceAll(' ', '-')
        .replaceAll(':', '-');
    String path = '${dir.path}$formattedDate.json';
    File backupFile = File(path);
    await backupFile.writeAsString(json);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backup saved in folder Tasks')),
    );
  }
  Future _tasksDirectory() async {
    const String pathExt = 'Tasks';

    Directory? directory;
    try {
      directory = await getExternalStorageDirectory()!;
      directory = Directory('${directory?.path}/$pathExt');
      if (!(await directory.exists())) {
        directory = await directory.create(recursive: true);
      }
    } catch (e) {
      print('Error accessing external storage: $e');
    }

    return directory;
  }

  //create backup of category
  Future categoryBackup() async {
    if (categoriesBox.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No Category Stored.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Creating Category backup...')),
    );
    Map map = categoriesBox
        .toMap()
        .map((key, value) => MapEntry(key.toString(), value));
    String json = jsonEncode(map);
    Directory dir = await _categoryDirectory();
    String formattedDate = DateTime.now()
        .toString()
        .replaceAll('.', '-')
        .replaceAll(' ', '-')
        .replaceAll(':', '-');
    String path = '${dir.path}$formattedDate.json';
    File backupFile = File(path);
    await backupFile.writeAsString(json);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backup saved in folder Category')),
    );
  }
  Future _categoryDirectory() async {
    const String pathExt = 'Category';

    Directory? directory;
    try {
      directory = await getExternalStorageDirectory()!;
      directory = Directory('${directory?.path}/$pathExt');
      if (!(await directory.exists())) {
        directory = await directory.create(recursive: true);
      }
    } catch (e) {
      print('Error accessing external storage: $e');
    }

    return directory;
  }


  //restore task backup
  Future<void> restoreTaskBackup() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Restoring backup...')),
    );

    FilePickerResult? file = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (file != null) {
      File backupFile = File(file.files.single.path!);

      if (!backupFile.existsSync()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid backup file')),
        );
        return;
      }

      try {
        String jsonContent = await backupFile.readAsString();
        Map<String, dynamic> backupMap = jsonDecode(jsonContent);

        // Clear existing tasks
        tasksBox.clear();

        // Restore tasks from backup
        backupMap.forEach((key, value) {
          Task task = Task.fromJson(value);
          tasksBox.put(int.parse(key), task);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restored Successfully...')),
        );
      } catch (e) {
        print('Error restoring backup: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error restoring backup')),
        );
      }
    }
  }

}
