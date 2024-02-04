import 'dart:convert';
import 'dart:io';
import 'package:credex_task_manager/core/widgets/about.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'category_list.dart';
import 'core/models/category_model.dart';
import 'core/models/task_model.dart';
import 'core/widgets/add_task.dart';
import 'core/widgets/category_provider.dart';
import 'core/widgets/category_status_provider.dart';
import 'core/widgets/task_detail.dart';
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
  //late List<bool> categoryExpansionStates;

  @override
  void initState() {
    super.initState();
    fetchDataFromHive();
    percentageOfTasks();
    //initializeCategoryStatusList();
  }

  // void initializeCategoryStatusList() {
  //   for (Category category in categories) {
  //     bool status = CategoryStatusProvider().getCategoryStatus(category.category);
  //     if (status) {
  //       // Expand the list if the status is true
  //       _onListExpansion(category.category, true);
  //     }
  //   }
  // }

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




  Future<void> fetchDataFromHive() async {

    tasks = tasksBox.values.toList();
    categories = categoriesBox.values.toList();

    if (tasks.isEmpty) {
      // setState(() {
      //   _lists = [];
      // });
      final categoryNames = ['All Tasks','Today', ...categories.map((category) => category.category).toList()];

      setState(() {
        _lists = List.generate(categoryNames.length, (categoryIndex) {
          final categoryName = categoryNames[categoryIndex];
          final categoryTasks = (categoryName == 'All Tasks')
              ? tasks : categoryName == 'Today' ? tasks.where((task) => task.dueDate.day == DateTime.now().day && task.dueDate.month == DateTime.now().month && task.dueDate.year == DateTime.now().year).toList()
              : tasks.where((task) => task.category == categoryName).toList();

          return InnerList(
            tasks: categoryTasks,
            category: categoryName,
          );
        });
      });
    } else {
      final categoryNames = ['All Tasks','Today', ...categories.map((category) => category.category).toList()];

      setState(() {
        _lists = List.generate(categoryNames.length, (categoryIndex) {
          final categoryName = categoryNames[categoryIndex];
          final categoryTasks = (categoryName == 'All Tasks')
              ? tasks : categoryName == 'Today' ? tasks.where((task) => task.dueDate.day == DateTime.now().day && task.dueDate.month == DateTime.now().month && task.dueDate.year == DateTime.now().year).toList()
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
          title: const Text('Task Manager'),
        actions: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryList()));
                },
                tooltip: 'Categories',
                icon: Image.asset(
                  'assets/menu.png',
                  width: 24,
                  height: 24,
                ),
              ),
              IconButton(onPressed: (){
                restoreBackup ();
              }, tooltip: 'Restore Data',
                icon: Image.asset(
                  'assets/cloud.png',
                  width: 24,
                  height: 24,
                ),),
              IconButton(onPressed: (){
                taskBackup();
              }, tooltip: 'Backup Tasks and Categories',
                icon: Image.asset(
                  'assets/backup.png',
                  width: 24,
                  height: 24,
                ),
              ),
            ],
          )
        ],
        elevation: 4,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    // Your onPressed logic here
                  },
                  icon: Image.asset(
                    'assets/approved.png',
                    width: 24,
                    height: 24,
                  ),
                ),
                SizedBox(width: 10,),
                Text('Progress', style: TextStyle(
                  fontSize: 16,
                ),),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only( bottom: 8.0, left: 16.0, right: 32.0),
            child: LinearPercentIndicator(
              lineHeight: 7.0,
              barRadius: Radius.circular(10.0),
              percent: completePercetage,
              trailing: Text((completePercetage * 100).toString()+" %", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),),
              linearStrokeCap: LinearStrokeCap.roundAll,
              backgroundColor: Color(0xFFDACFC8),
              progressColor: Color(0xFF1F4F5F),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.78,
              child: DragAndDropLists(
                children: List.generate(_lists.length, (index) => _buildList(index)),
                onItemReorder: _onItemReorder,
                onListReorder: _onListReorder,
                removeTopPadding: true,

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
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddTaskPage()),
              );
            },
            child: Icon(Icons.add),
          ),
          // SizedBox(height: 16),
          // FloatingActionButton(
          //   onPressed: () {
          //     Navigator.push(context, MaterialPageRoute(builder: (context) => aboutPage()));
          //   },
          //   child: Icon(Icons.info_outline),
          // ),
        ],
      ),
    );
  }
  // void _onListExpansion(String category, bool expanded) {
  //   CategoryStatusProvider().updateCategoryStatus(category, expanded);
  // }
  _buildList(int outerIndex) {
    var innerList = _lists[outerIndex];
    int count = innerList.tasks.length;
    int totalTask = tasksBox.values.length;
    int completeTask = innerList.tasks.where((task) => task.category == 'Completed').length;
    return DragAndDropListExpansion(
      title: innerList.category == 'All Tasks' ? Text('${innerList.category} ($completeTask/$totalTask)') :Text('${innerList.category} ($count)'),
      children: List.generate(
        innerList.tasks.length,
            (index) => _buildItem(innerList.tasks[index]),
      ),
      listKey: ObjectKey(innerList.category),
      // onExpansionChanged: (expanded) {
      //   _onListExpansion(innerList.category, expanded);
      // },
    );
  }

  _buildItem(Task task) {
    Color itemColor;

    if (task.category == 'Completed') {
      itemColor = Colors.green;
    } else {
      DateTime currentDate = DateTime.now();
      DateTime taskDueDate = task.dueDate;

      if (taskDueDate.isBefore(currentDate)) {
        // Task due date is in the past
        itemColor = Colors.red;
      } else if (taskDueDate.day == currentDate.day &&
          taskDueDate.month == currentDate.month &&
          taskDueDate.year == currentDate.year) {
        // Task due date is today
        itemColor = Colors.orange;
      } else {
        // Default color for other cases
        itemColor = Colors.black;
      }
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
        if(_lists[oldListIndex].category == 'All Tasks'|| _lists[newListIndex].category == 'All Tasks'||
            _lists[oldListIndex].category == 'Today'|| _lists[newListIndex].category == 'Today'){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid Drag and Drop')),
          );
        }
        else {
          var innerList = _lists[oldListIndex];
          var innerList2 = _lists[newListIndex];
          var movedList = innerList.tasks.removeAt(oldItemIndex);
          movedList.category = innerList2.category;
          innerList2.tasks.insert(newItemIndex, movedList);
          tasks
              .where((element) =>
          element.title == innerList2.tasks[newItemIndex].title)
              .forEach((element) {
            int index = tasks.indexOf(element);
            print(index);
            tasksBox.putAt(index, element);
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