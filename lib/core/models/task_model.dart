// import 'package:hive/hive.dart';
// part 'task_model.g.dart';
//
// @HiveType(typeId: 0)
// class Task {
//   @HiveField(0)
//   String title;
//
//   @HiveField(1)
//   String description;
//
//   @HiveField(2)
//   String category;
//
//   @HiveField(3)
//   String status;
//
//   @HiveField(4)
//   late final DateTime dueDate;
//
//   Task({
//     required this.title,
//     required this.description,
//     required this.category,
//     required this.status,
//     required this.dueDate
//   });
//
//   factory Task.fromJson(Map<String, dynamic> json) {
//     return Task(
//         title: json['title'],
//         description: json['description'],
//         category: json['category'],
//         status: json['status'] ?? 'In Progress',
//         dueDate: json['dueDate']
//     );
//   }
// }


import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class Task {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  String category;

  @HiveField(3)
  String status;

  @HiveField(4)
  late final DateTime dueDate;

  Task({
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.dueDate,
  });

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  Map<String, dynamic> toJson() => _$TaskToJson(this);
}
