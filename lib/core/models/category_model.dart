// import 'package:hive/hive.dart';
//
// part 'category_model.g.dart';
//
// @HiveType(typeId: 1)
// class Category extends HiveObject {
//   @HiveField(0)
//   late String category;
//
//   Category({required this.category});
// }

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'category_model.g.dart';

@JsonSerializable()
@HiveType(typeId: 1)
class Category extends HiveObject {
  @HiveField(0)
  late String category;

  Category({required this.category});

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
