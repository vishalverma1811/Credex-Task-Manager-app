import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import '../../main.dart';
import '../models/task_model.dart';

class TaskProvider with ChangeNotifier {
  List<Task> task = [];

  List<Task> get tasks => task;

  TaskProvider() {
    loadTasks();
  }

  Future<void> loadTasks() async {
    try {
      task =  tasksBox.values.toList();
      print(task);
      notifyListeners();
    } catch (error) {
      print('Error loading tasks: $error');
    }
  }

  Future<void> addTask(Task newTask) async {
    try {
      await tasksBox.add(newTask);
      loadTasks();
    } catch (error) {
      print('Error adding task: $error');
    }
  }




  Future<void> updateTask(int index, Task updatedTask) async {
    try {

      await tasksBox.putAt(index, updatedTask);
      loadTasks();
    } catch (error) {
      print('Error updating task: $error');
    }
  }


  Future<void> deleteTask(int index) async {
    try {
      await tasksBox.deleteAt(index);
      await loadTasks();
    } catch (error) {
      print('Error deleting task: $error');
    }
  }

  Future<void> updateTaskCategory(int index, String newCategory) async {
    try {
      tasks[index].category = newCategory;
      await tasksBox.putAt(index, tasks[index]);
      notifyListeners();
    } catch (error) {
      print('Error updating task category: $error');
    }
  }
}