import 'package:flutter/material.dart';
import '../../main.dart';
import '../models/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  List<Category> category = [];

  List<Category> get categories => category;

  CategoryProvider() {
    _initCategoryBox();
  }

  Future<void> _initCategoryBox() async {
    category = categoriesBox.values.toList();
    List<String> defaultCategories = ['Open', 'In Progress', 'Stuck', 'Completed'];
    if (categoriesBox.isEmpty) {
      await addDefaultCategories(defaultCategories);
    }
    notifyListeners();
  }

  Future<void> addDefaultCategories(List<String> defaultCategories) async {
    for (String categoryName in defaultCategories) {
      addCategory(Category(category: categoryName));
    }
  }

  Future<void> addCategory(Category newCategory) async {
    await categoriesBox.add(newCategory);
    notifyListeners();
  }

  Future<void> updateCategory(int index, Category updatedCategory) async {
    await categoriesBox.putAt(index, updatedCategory);
    notifyListeners();
  }

  Future<void> deleteCategory(int index) async {
    await categoriesBox.deleteAt(index);
    notifyListeners();
  }

}
