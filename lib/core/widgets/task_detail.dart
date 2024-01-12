import 'package:credex_task_manager/core/widgets/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../task_list.dart';
import '../models/task_model.dart';
import 'category_provider.dart';

class TaskDetailsPage extends StatefulWidget {
  final Task task;

  TaskDetailsPage({required this.task});

  @override
  _TaskDetailsPageState createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController statusController;
  late String defaultCategory;
  late String selectedCategory = '';
  //final TaskProvider taskProvider = TaskProvider();
  List<String> categories = [];
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  late DateTime selectedDate;
  final CategoryProvider categoryProvider = CategoryProvider();


  void initializeCategories() {
    for (int i = 0; i < categoryProvider.categories.length; i++) {
      categories.add(categoryProvider.categories[i].category);
    }
  }

  @override
  void initState() {
    super.initState();
    initializeCategories();
    titleController = TextEditingController(text: widget.task.title);
    descriptionController = TextEditingController(text: widget.task.description);
    statusController = TextEditingController(text: widget.task.status);
    defaultCategory = widget.task.category;
    selectedDate = widget.task.dueDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Task Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: titleController,
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
                  fontSize: 16, fontWeight: FontWeight.bold),
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
                        await _selectTime(context, selectedDate);
                      },
                      child: Icon(Icons.access_time_rounded, size: 24, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.0),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Task updatedTask = Task(
                      title: titleController.text.trim(),
                      description: descriptionController.text.trim(),
                      status: statusController.text.trim(),
                      category: selectedCategory == '' ? defaultCategory : selectedCategory,
                      dueDate: selectedDate,
                    );

                    TaskProvider().updateTask(TaskProvider().tasks.indexOf(widget.task), updatedTask);
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => TaskList()),
                    );
                  } ,
                  child: Text('Save'),
                ),
                SizedBox(width: 15,),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Are you sure?"),
                          content: Text("Do you really want to delete this task?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("No"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                TaskProvider().deleteTask(TaskProvider().tasks.indexOf(widget.task));
                                Navigator.pop(context);
                                Navigator.pop(context);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => TaskList()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: Text(
                                'Yes',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text(
                    'Delete',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
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

