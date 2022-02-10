import 'package:track_my_expences/database/database.dart';

class CategoryModel {
  String name;
  int key;

  CategoryModel(this.name, this.key);

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    if (key > 0) {
      map[DatabaseHelper.columnCategoryId] = key;
    }
    map[DatabaseHelper.columnCategoryName] = name;

    return map;
  }
}
