import 'package:credex_task_manager/core/models/category_model.dart';
import 'package:credex_task_manager/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryStatusProvider with ChangeNotifier {
  SharedPreferences? _prefs;
  Map<String, bool>? _categoryStatusMap;

  CategoryStatusProvider() {
    _initPrefs();
  }


  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    await _initCategoryStatusMap();
  }

  Future<void> _initCategoryStatusMap() async {
    _categoryStatusMap = await _getCategoryStatusMap();
    notifyListeners();
  }

  Map<String, bool> _getCategoryStatusMap() {
    Map<String, bool> categoryStatusMap = {};

    List<String> defaultCategories = [];

    for (Category category in categoriesBox.values) {
      defaultCategories.add(category.category);
    }

    for (String category in defaultCategories) {
      categoryStatusMap[category] = _prefs?.getBool(category) ?? false;
    }

    return categoryStatusMap;
  }

  Map<String, bool>? get categoryStatusMap => _categoryStatusMap;

  bool getCategoryStatus(String category) {
    return _categoryStatusMap?[category] ?? false;
  }

  // void updateCategoryStatus(String category, bool status) {
  //   _prefs?.setBool(category, status);
  //   _categoryStatusMap?[category] = status;
  //   notifyListeners();
  // }
  void updateCategoryStatus(String category, bool status) {
    print("Updating category status: $category - $status");

    _prefs?.setBool(category, status);
    print("SharedPreferences updated.");

    _categoryStatusMap?[category] = status;
    print("_categoryStatusMap updated.");

    print("Current _categoryStatusMap: $_categoryStatusMap");

    notifyListeners();
  }
}