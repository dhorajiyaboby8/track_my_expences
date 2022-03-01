import 'package:track_my_expences/database/database.dart';

class ExpenseModel {
  int expenseId;
  int categoryId;
  int itemId;
  String itemName;
  String expenseDate;
  String itemPrice;

  String itemQuantity;
  String expensePrice;
  String expenseNote;

  ExpenseModel(
      this.expenseId,
      this.categoryId,
      this.itemId,
      this.itemName,
      this.expenseDate,
      this.itemPrice,
      this.itemQuantity,
      this.expensePrice,
      this.expenseNote);

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    if (expenseId > 0) {
      map[DatabaseHelper.columnExpenseId] = expenseId;
    }
    map[DatabaseHelper.columnCategoryId] = categoryId;
    map[DatabaseHelper.columnItemId] = itemId;
    map[DatabaseHelper.columnItemName] = itemName;
    map[DatabaseHelper.columnExpenseDate] = expenseDate;
    map[DatabaseHelper.columnItemPrice] = itemPrice;

    map[DatabaseHelper.columnItemquantity] = itemQuantity;
    map[DatabaseHelper.columnTotalPrice] = expensePrice;
    map[DatabaseHelper.columnExpenseNote] = expenseNote;

    return map;
  }
}
