import 'package:credex_task_manager/core/widgets/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../task_list.dart';
import '../models/task_model.dart';
import 'category_provider.dart';

class AddTaskPage extends StatefulWidget {
  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final CategoryProvider categoryProvider = CategoryProvider();

  @override
  void initState() {
    super.initState();
    initializeCategories();
  }

  void initializeCategories() {
    for (int i = 0; i < categoryProvider.categories.length; i++) {
      categories.add(categoryProvider.categories[i].category);
    }
  }


  List<String> categories = [];
  String defaultCategory = 'In Progress';
  String selectedCategory = '';

  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  DateTime selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 16, 0);


  @override
  Widget build(BuildContext context) {
    // final taskProvider = Provider.of<TaskProvider>(context);

    for(int i = 0; i < categories.length; i++){
      print(categories[i]);
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller:  titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: statusController,
              decoration: InputDecoration(labelText: 'Status'),
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: defaultCategory,
              onChanged: (value) {
                selectedCategory = value!;
              },
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              "Due date of Task",
              style: TextStyle(
                fontSize: 16,),
            ),
            TextField(
              controller: dateController,
              readOnly: true,
              decoration: InputDecoration(
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        '${selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : ''}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.36),
                    GestureDetector(
                      onTap: () async {
                        final DateTime currentDate = DateTime.now();
                        DateTime dateOnly = DateTime(currentDate.year, currentDate.month, currentDate.day,);

                        final DateTime? datePicked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: dateOnly,
                          lastDate: DateTime(2100),
                        );
                        await validate_date(context, datePicked!, dateOnly);
                      },
                      child: Icon(Icons.date_range_rounded, size: 24, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            TextField(
              controller: timeController,
              readOnly: true,
              decoration: InputDecoration(
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        '${selectedDate != null ? DateFormat('HH:mm').format(selectedDate!) : ''}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.36),
                    GestureDetector(
                      onTap: () async {
                        await _selectTime(context);
                      },
                      child: Icon(Icons.access_time_rounded, size: 24, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                final String title = titleController.text.trim();
                final String description = descriptionController.text.trim();
                final String status = statusController.text.trim();
                final String categoryToAdd = selectedCategory == "" ? defaultCategory : selectedCategory;
                final DateTime dueDate = selectedDate;

                print(categoryToAdd);
                if (title.isNotEmpty && description.isNotEmpty && status.isNotEmpty) {
                  if(TaskProvider().tasks.any((task) => task.title.compareTo(title) == 0)){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Task with the same title already exists'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  else{
                    TaskProvider().addTask(
                      Task(
                          title: title,
                          description: description,
                          category: categoryToAdd,
                          status: status,
                          dueDate: dueDate,
                          imageId: const Uuid().v4()),
                    );

                    titleController.clear();
                    descriptionController.clear();
                    statusController.clear();
                    dateController.clear();

                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => TaskList()),
                    );
                  }
                }
                else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill in all fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> validate_date(BuildContext context, DateTime datePicked, DateTime dateOnly) async {
    if (datePicked != null && datePicked != selectedDate) {
      if (datePicked == dateOnly || datePicked.isAfter(dateOnly)) {
        setState(() {
          selectedDate = datePicked;
        });

        print('valid date');
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Invalid Date Selection'),
              content: Text('Please select a date in the future.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> _selectTime(BuildContext context, [DateTime? initialTime]) async {
    final TimeOfDay? timePicked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialTime ?? DateTime.now().add(Duration(hours: 1))),
    );

    if (timePicked != null) {
      DateTime selectedDateTime = DateTime(
        selectedDate?.year ?? DateTime.now().year,
        selectedDate?.month ?? DateTime.now().month,
        selectedDate?.day ?? DateTime.now().day,
        timePicked.hour,
        timePicked.minute,
      );

      setState(() {
        selectedDate = selectedDateTime;
        dateController.text = DateFormat('yyyy-MM-dd HH:mm').format(selectedDate);
      });
    }
  }
}
