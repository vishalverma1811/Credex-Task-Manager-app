import 'dart:io';

import 'package:credex_task_manager/core/models/image_model.dart';
import 'package:credex_task_manager/core/widgets/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../task_list.dart';
import '../models/task_model.dart';
import 'category_provider.dart';

class TaskDetailsPage extends StatefulWidget {
  final Task task;
  final ImageModel images;

  TaskDetailsPage({required this.task, required this.images});

  @override
  _TaskDetailsPageState createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController statusController;
  late String defaultCategory;
  late String imagesId;
  late String selectedCategory = '';

  //final TaskProvider taskProvider = TaskProvider();
  List<String> categories = [];
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  late DateTime selectedDate;
  final CategoryProvider categoryProvider = CategoryProvider();

  // late List<XFile> images = [];
  List<String> imagePath = [];

  void initializeCategories() {
    for (int i = 0; i < categoryProvider.categories.length; i++) {
      categories.add(categoryProvider.categories[i].category);
    }
  }

  void _deleteImage(int index) {
    setState(() {
      if (imagePath.length == 1) {
        imagePath = [];
      } else {
        imagePath.removeAt(index);
      }
    });
    Navigator.of(context).pop(); // Close the dialog
  }

  @override
  void initState() {
    super.initState();
    initializeCategories();
    titleController = TextEditingController(text: widget.task.title);
    descriptionController =
        TextEditingController(text: widget.task.description);
    statusController = TextEditingController(text: widget.task.status);
    defaultCategory = widget.task.category;
    selectedDate = widget.task.dueDate;
    imagesId = widget.task.imageId;
    imagePath = [...widget.images.imagePath];
  }

  void _showImageDialog(
      BuildContext context, List<String> imagePaths, int initialIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.only(top: 20),
          child: Stack(children: [
            PhotoViewGallery.builder(
              itemCount: imagePaths.length,
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: FileImage(File(imagePaths[index])),
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 4,
                );
              },
              scrollPhysics: BouncingScrollPhysics(),
              backgroundDecoration: BoxDecoration(
                color: Colors.black,
              ),
              pageController: PageController(initialPage: initialIndex),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _deleteImage(initialIndex);
                },
              ),
            ),
          ]),
        );
      },
    );
  }

  Future<void> getImageFromSource(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);

      if (pickedFile == null) {
        // User canceled the image picking
        return;
      }

      // images.add(pickedFile);
      imagePath.add(pickedFile.path);
      setState(() {});
      // You can use the pickedFile.path to access the image file path
      print("Image path: ${pickedFile.path}");

      // Do something with the image, such as displaying it in your UI
      // Example: Display the image in an Image widget
      // File imageFile = File(pickedFile.path);
      // Image.file(imageFile);
    } catch (e) {
      print("Error picking or capturing image: $e");
    }
  }

  Future<void> _showImageSourceDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Choose the source of the image:'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Get.back();

                getImageFromSource(ImageSource.gallery);
              },
              child: Text('Pick from Gallery'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                getImageFromSource(ImageSource.camera);
              },
              child: Text('Capture Image'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    imagePath = [];
    setState(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Task Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
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
                  Row(
                    children: [
                      Text(
                        "Add Reference",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Center(
                        child: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            _showImageSourceDialog(context);
                          },
                        ),
                      ),
                    ],
                  ),
                  imagePath.length != 0
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 18.0),
                          child: Container(
                            width: double.infinity,
                            height: 180,
                            padding: EdgeInsets.all(10),
                            child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8.0,
                                mainAxisSpacing: 4.0,
                              ),
                              itemCount: imagePath.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    _showImageDialog(context, imagePath, index);
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    // Adjust the radius as needed

                                    child: Image.file(
                                      File(imagePath[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      : Container(),
                  Text(
                    "Due date of Task",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.36),
                          GestureDetector(
                            onTap: () async {
                              final DateTime currentDate = DateTime.now();
                              DateTime dateOnly = DateTime(
                                currentDate.year,
                                currentDate.month,
                                currentDate.day,
                              );

                              final DateTime? datePicked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: dateOnly,
                                lastDate: DateTime(2100),
                              );
                              await validate_date(
                                  context, datePicked!, dateOnly);
                            },
                            child: Icon(Icons.date_range_rounded,
                                size: 24, color: Colors.black),
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
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.36),
                          GestureDetector(
                            onTap: () async {
                              await _selectTime(context, selectedDate);
                            },
                            child: Icon(Icons.access_time_rounded,
                                size: 24, color: Colors.black),
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
                              category: selectedCategory == ''
                                  ? defaultCategory
                                  : selectedCategory,
                              dueDate: selectedDate,
                              imageId: imagesId);

                          TaskProvider().updateTask(
                              TaskProvider().tasks.indexOf(widget.task),
                              updatedTask);
                          // if(imagePath.length > 0) {
                          TaskProvider().addImages(
                              imagesId, ImageModel(imagePath: imagePath));
                          // }
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => TaskList()),
                          );
                        },
                        child: Text('Save'),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Are you sure?"),
                                content: Text(
                                    "Do you really want to delete this task?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("No"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      TaskProvider().deleteTask(
                                          TaskProvider()
                                              .tasks
                                              .indexOf(widget.task),
                                          imagesId);
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => TaskList()),
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

