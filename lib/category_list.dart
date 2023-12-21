import 'package:credex_task_manager/task_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/models/category_model.dart';
import 'core/models/task_model.dart';
import 'core/widgets/category_provider.dart';
import 'core/widgets/task_provider.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({Key? key}) : super(key: key);

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  final TaskProvider taskProvider = TaskProvider();
  final CategoryProvider categoryProvider = CategoryProvider();
  late List<Category> categories = categoryProvider.categories;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Category List'),
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TaskList()));
        }, icon: Icon(Icons.arrow_back)),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          print(categories);
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              Category category = categories[index];
              return Card(
                child: ListTile(
                  title: Text(category.category),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _showDeleteDialog(context, index);
                    },
                  ),
                  onTap: () {
                    _showEditDialog(context, index, category.category);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    TextEditingController controller = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Category'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: 'Category Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String categoryName = controller.text.trim();
                if (categoryName.isNotEmpty) {
                  Category newCategory = Category(category: categoryName);
                  categories.add(newCategory);
                  await categoryProvider.addCategory(newCategory);
                  Navigator.pop(context);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CategoryList()));
                }
                else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please Enter Category Name'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditDialog(BuildContext context, int index, String category) async {
    TextEditingController controller = TextEditingController(text: category);

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Category'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: 'Category Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String updatedCategoryName = controller.text.trim();
                if (updatedCategoryName.isNotEmpty) {
                  Category updatedCategory = Category(category: updatedCategoryName);
                  categories[index] = updatedCategory;
                  await categoryProvider.updateCategory(index, updatedCategory);

                  List<Task> tasksToUpdate = taskProvider.tasks.where((task) => task.category == category).toList();
                  for (Task task in tasksToUpdate) {
                    int taskIndex = taskProvider.tasks.indexOf(task);
                    taskProvider.updateTaskCategory(taskIndex, updatedCategoryName);
                  }

                  Navigator.pop(context);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CategoryList()));
                }
                else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please Enter Updated Category Name'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTasksForCategory(String category, TaskProvider taskProvider) async {
    List<Task> tasksToDelete = taskProvider.tasks.where((task) => task.category == category).toList();

    for (Task task in tasksToDelete) {
      int index = taskProvider.tasks.indexOf(task);
      await taskProvider.deleteTask(index);
    }
  }


  Future<void> _showDeleteDialog(BuildContext context, int index) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Category'),
          content: Text('Are you sure you want to delete this category?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String categoryToDelete = categoryProvider.categories[index].category;
                await _deleteTasksForCategory(categoryToDelete, taskProvider);

                await categoryProvider.deleteCategory(index);
                categories.removeAt(index);
                Navigator.pop(context);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CategoryList()));
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
