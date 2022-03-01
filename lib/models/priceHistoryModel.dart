import 'package:track_my_expences/database/database.dart';
import 'package:track_my_expences/models/itemModel.dart';

class PriceHistoryModel {
  int id;
  int itemId;

  String oldPrice;
  String newPrice;
  String changeDate;
  List <ItemModel> ?itemModel;


  PriceHistoryModel( this.id,this.itemId, this.oldPrice,
      this.newPrice, this.changeDate,[this.itemModel]);

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();

    if (id > 0) {
      map[DatabaseHelper.columnId] = id;
    }


    map[DatabaseHelper.columnItemId] = itemId;


    map[DatabaseHelper.columnItemPrice] = oldPrice;
    map[DatabaseHelper.columnNewPrice] = newPrice;
    map[DatabaseHelper.columnChangeDate] = changeDate;

    return map;
  }
}
