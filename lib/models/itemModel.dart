import 'package:track_my_expences/database/database.dart';

class ItemModel {
  int categoryid;
  String itemname;
  int itemkey;
  String itemprice;

  ItemModel(this.categoryid, this.itemname, this.itemkey, this.itemprice);

  Map<String, dynamic> toMapWithoutId() {
    final map = Map<String, dynamic>();
    map[DatabaseHelper.columnCategoryId] = categoryid;
    map[DatabaseHelper.columnItemName] = itemname;
    map[DatabaseHelper.columnItemPrice] = itemprice;

    return map;
  }

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    map[DatabaseHelper.columnCategoryId] = categoryid;
    if (itemkey > 0) {
      map[DatabaseHelper.columnItemId] = itemkey;
    }
    map[DatabaseHelper.columnItemName] = itemname;
    map[DatabaseHelper.columnItemPrice] = itemprice;

    return map;
  }
}
