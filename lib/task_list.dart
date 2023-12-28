import 'dart:convert';
import 'dart:io';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'category_list.dart';
import 'core/models/category_model.dart';
import 'core/models/task_model.dart';
import 'core/widgets/add_task.dart';
import 'core/widgets/category_provider.dart';
import 'core/widgets/task_detail.dart';
import 'core/widgets/task_provider.dart';
import 'main.dart';
import 'package:lecle_downloads_path_provider/lecle_downloads_path_provider.dart';

class TaskList extends StatefulWidget {
  const TaskList({Key? key}) : super(key: key);

  @override
  State createState() => _ListTile();
}

class InnerList {
  String category;
  List<Task> tasks;

  InnerList({
    required this.category,
    required this.tasks,
  });
}


class _ListTile extends State<TaskList> {
  final CategoryProvider categoryProvider = CategoryProvider();
  List<InnerList> _lists = [];
  late List<Task> tasks;
  late List<Category> categories;
  double completePercetage = 0;

  @override
  void initState() {
    super.initState();
    fetchDataFromHive();
    percentageOfTasks();
  }

  double percentageOfTasks(){
    int completeTaskCount = 0;
    for (Task task in tasksBox.values) {
      if (task.category == 'Completed') {
        completeTaskCount++;
      }
    }
    int totalTaskCount = tasksBox.values.length;
    print(totalTaskCount);
    completePercetage = totalTaskCount > 0 ? double.parse((completeTaskCount/ totalTaskCount).toStringAsFixed(1)) : 0;
    print(completeTaskCount);
    return completePercetage;
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
              CircularPercentIndicator(
                radius: 20.0,
                lineWidth: 4.0,
                percent: completePercetage,
                center: Text((completePercetage * 100).toString()),
                progressColor: Colors.indigoAccent,
              ),
              SizedBox(width: 25,),
              IconButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryList()));
              }, tooltip: 'Categories',
                  icon: Icon(Icons.category_outlined)),
              IconButton(onPressed: (){
                restoreBackup ();
              }, tooltip: 'Restore Data',
                  icon: Icon(Icons.restore)),
              IconButton(onPressed: (){
                taskBackup();
              }, tooltip: 'Backup Tasks and Categories',
                  icon: Icon(Icons.backup_outlined)),
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
      } else {
        if(_lists[oldListIndex].category == 'All Tasks'|| _lists[newListIndex].category == 'All Tasks'){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid Drag and Drop')),
          );
        }
        else{
          var innerList = _lists[oldListIndex];
          var innerList2 = _lists[newListIndex];
          var movedList = innerList.tasks.removeAt(oldItemIndex);
          innerList2.tasks.insert(newItemIndex, movedList);
          innerList2.tasks[newItemIndex].category = innerList2.category;

          tasks.where((element) =>
          element.title == innerList2.tasks[newItemIndex].title)
              .forEach((element) {
            tasksBox.deleteAt(tasks.indexOf(element));
            tasksBox.add(innerList2.tasks[newItemIndex]);
          });
        }
      }

      //update percentage
      percentageOfTasks();
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
  Future<void> taskBackup() async {
    if (tasksBox.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No Tasks Stored.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Creating backup...')),
    );

    Map map = tasksBox.toMap().map((key, value) => MapEntry(key.toString(), value));
    String json = jsonEncode(map);

    Directory? dir;
    try {
      String downloadsPath = (await DownloadsPath.downloadsDirectory())?.path ?? "";
      dir = Directory(downloadsPath);
    } catch (e) {
      print('Error accessing downloads directory: $e');
      return;
    }

    String formattedDate = DateTime.now()
        .toString()
        .replaceAll('.', '-')
        .replaceAll(' ', '-')
        .replaceAll(':', '-');
    String path = '${dir.path}/TasksBackup_$formattedDate.json';

    File backupFile = File(path);
    await backupFile.writeAsString(json);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backup saved in Downloads folder')),
    );
  }


  Future<void> restoreBackup() async {
    setState(() async {
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
          tasksBox.deleteAll(tasksBox.keys);

          // Restore tasks from backup
          backupMap.forEach((key, value) {
            Task task = Task.fromJson(value);
            tasksBox.put(int.parse(key), task);
          });

          //restore category
          List<String> defaultCategories = ['Open', 'In Progress', 'Stuck', 'Completed'];
          List<String> categoryBackup = [];

          //adding all default categories
          for(String i in defaultCategories){
            categoryBackup.add(i);
          }

          //adding category other than default
          for (Task task in tasksBox.values) {
            if(task.category != 'Open' && task.category != 'In Progress' && task.category != 'Stuck' && task.category != 'Completed'){
              categoryBackup.add(task.category);
              print(task.category);
            }
          }

          categoriesBox.deleteAll(categoriesBox.keys);
          for (String i in categoryBackup) {
            categoriesBox.add(Category(category: i));
          }

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

      fetchDataFromHive();
      percentageOfTasks();
    });
  }
}



// Future<void> restoreBackup() async {
//   ScaffoldMessenger.of(context).showSnackBar(
//     const SnackBar(content: Text('Restoring backup...')),
//   );
//
//   List<FilePickerResult?> files = [];
//   for(int i =0; i < 2; i++){
//     FilePickerResult? file = await FilePicker.platform.pickFiles(
//       type: FileType.any,
//       allowMultiple: true,
//     );
//     files.add(file);
//     if(i < 1){
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select exactly 2 files')),
//       );
//     }
//   }
//
//   // if (files == null || files.length != 2) {
//   //   ScaffoldMessenger.of(context).showSnackBar(
//   //     const SnackBar(content: Text('Please select exactly 2 files')),
//   //   );
//   //   return;
//   // }
//
//   File? tasksBackupFile;
//   File? categoryBackupFile;
//
//   for (FilePickerResult? file in files) {
//     if (file != null) {
//       File backupFile = File(file.files.single.path!);
//
//       if (!backupFile.existsSync()) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Invalid backup file')),
//         );
//         return;
//       }
//
//       String fileName = backupFile.uri.pathSegments.last;
//
//       if (fileName.startsWith('Tasks')) {
//         tasksBackupFile = backupFile;
//       } else if (fileName.startsWith('Category')) {
//         categoryBackupFile = backupFile;
//       }
//     }
//   }
//
//   if (tasksBackupFile == null || categoryBackupFile == null) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Please select both Tasks and Category backup files')),
//     );
//     return;
//   }
//
//   try {
//     // Clear existing tasks and categories
//     tasksBox.deleteAll();
//     categoriesBox.deleteAll();
//
//     // Restore tasks from Tasks backup file
//     String tasksJsonContent = await tasksBackupFile.readAsString();
//     Map<String, dynamic> tasksBackupMap = jsonDecode(tasksJsonContent);
//     tasksBackupMap.forEach((key, value) {
//       Task task = Task.fromJson(value);
//       tasksBox.put(int.parse(key), task);
//     });
//
//     // Restore categories from Category backup file
//     String categoryJsonContent = await categoryBackupFile.readAsString();
//     Map<String, dynamic> categoryBackupMap = jsonDecode(categoryJsonContent);
//     categoryBackupMap.forEach((key, value) {
//       Category category = Category.fromJson(value);
//       categoriesBox.put(int.parse(key), category);
//     });
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Restored Successfully...')),
//     );
//   } catch (e) {
//     print('Error restoring backup: $e');
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Error restoring backup')),
//     );
//   }
// }