import 'package:track_my_expences/database/database.dart';

class ItemModel {
  int categoryId;
  String itemName;
  int itemId;
  String itemPrice;

  ItemModel(this.categoryId, this.itemName, this.itemId, this.itemPrice);

  Map<String, dynamic> toMapWithoutId() {
    final map = Map<String, dynamic>();
    map[DatabaseHelper.columnCategoryId] = categoryId;
    map[DatabaseHelper.columnItemName] = itemName;
    map[DatabaseHelper.columnItemPrice] = itemPrice;

    return map;
  }

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    map[DatabaseHelper.columnCategoryId] = categoryId;
    if (itemId > 0) {
      map[DatabaseHelper.columnItemId] = itemId;
    }
    map[DatabaseHelper.columnItemName] = itemName;
    map[DatabaseHelper.columnItemPrice] = itemPrice;

    return map;
  }
}
