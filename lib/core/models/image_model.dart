import 'package:hive/hive.dart';

part 'image_model.g.dart';

@HiveType(typeId: 2)
class ImageModel {
  @HiveField(0)
  List<String> imagePath;

  ImageModel({
    required this.imagePath,
  });
}
