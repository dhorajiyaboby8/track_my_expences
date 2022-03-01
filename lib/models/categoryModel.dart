import 'package:track_my_expences/database/database.dart';

class CategoryModel {
  String categoryName;
  int categoryId;

  CategoryModel(this.categoryName, this.categoryId);

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    if (categoryId > 0) {
      map[DatabaseHelper.columnCategoryId] = categoryId;
    }
    map[DatabaseHelper.columnCategoryName] = categoryName;

    return map;
  }
}
