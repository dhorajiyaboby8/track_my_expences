import 'package:track_my_expences/database/database.dart';

class ExpenseModel {
  int expenseid;
  int categoryid;
  int itemkey;
  String itemname;
  String expensedate;
  String itemprice;

  String itemquantity;
  String itemtotalprice;
  String expensenote;

  ExpenseModel(
      this.expenseid,
      this.categoryid,
      this.itemkey,
      this.itemname,
      this.expensedate,
      this.itemprice,
      this.itemquantity,
      this.itemtotalprice,
      this.expensenote);

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    if (expenseid > 0) {
      map[DatabaseHelper.columnExpenseId] = expenseid;
    }
    map[DatabaseHelper.columnCategoryId] = categoryid;
    map[DatabaseHelper.columnItemId] = itemkey;
    map[DatabaseHelper.columnItemName] = itemname;
    map[DatabaseHelper.columnExpenseDate] = expensedate;
    map[DatabaseHelper.columnItemPrice] = itemprice;

    map[DatabaseHelper.columnItemquantity] = itemquantity;
    map[DatabaseHelper.columnTotalPrice] = itemtotalprice;
    map[DatabaseHelper.columnExpenseNote] = expensenote;

    return map;
  }
}
