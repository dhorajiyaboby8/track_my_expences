import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:track_my_expences/models/categoryModel.dart';
import 'package:track_my_expences/models/expensemodel.dart';
import 'package:track_my_expences/models/itemModel.dart';

class DatabaseHelper {
  static final _databaseName = "Database.db";
  static final _databaseVersion = 1;

  static final tableCategory = "tbl_category";
  static final columnCategoryId = 'category_id';
  static final columnCategoryName = 'category_name';

  static final tableItem = "tbl_item";
  static final columnItemId = 'item_id';
  static final columnItemName = 'item_name';
  static final columnItemPrice = 'item_price';

  static final tableExpense = "tbl_expense";
  static final columnExpenseId = 'expense_id';
  static final columnExpenseDate = 'expense_date';
  static final columnDifference = 'difference';
  static final columnItemquantity = 'item_quantity';
  static final columnTotalPrice = 'total_price';
  static final columnExpenseNote = 'expense_note';


  static final tablePriceHistory = 'price_history';
  static final columnPriceHistoryId = 'pricehistory_id';

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    print('db location : ' + path);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE  $tableCategory (
            $columnCategoryId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            $columnCategoryName TEXT )
          ''');
    await db.execute('''
          CREATE TABLE  $tableItem (
            $columnCategoryId INTEGER,
            $columnItemId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            $columnItemName TEXT ,
            $columnItemPrice TEXT)
          ''');
    await db.execute('''
          CREATE TABLE  $tableExpense (
            $columnExpenseId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            $columnCategoryId INTEGER,
            $columnItemId INTEGER ,
            $columnItemName TEXT ,
            $columnExpenseDate TEXT ,
            $columnItemPrice TEXT,
            $columnDifference INTEGER,
            $columnItemquantity TEXT,
            $columnTotalPrice TEXT,
            $columnExpenseNote TEXT
            )
          ''');

  }

  // Future<int> insertCategory(Map<String, dynamic> row) async {
  //   Database? db = await instance.database;
  //   return await db!.insert(tableCategory, row);
  // }

  Future<CategoryModel> insertCategory(CategoryModel categoryModel) async {
    Database? db = await instance.database;
    // return await db!.insert(tableCategory, row);

    var Categorykey = await db!.insert(
      tableCategory,
      categoryModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    categoryModel.key = Categorykey;
    return categoryModel;
  }

  Future<List<CategoryModel>> getAllCategories() async {
    List<CategoryModel> categories = [];
    Database? db = await instance.database;
    final List<Map<String, dynamic>> allRows = await db!.query(tableCategory);
    allRows.forEach((row) => {
          categories.add(CategoryModel(
              row["$columnCategoryName"], row["$columnCategoryId"]))
        });
    return categories;
  }

  // Future<int> updateCategory(Map<String, dynamic> row) async {
  //   Database? db = await instance.database;
  //   int id = row[columnCategoryId];
  //   return await db!.update(tableCategory, row,
  //       where: '$columnCategoryId = ?', whereArgs: [id]);
  // }
  Future<int> updateCategory(CategoryModel categoryModel) async {
    Database? db = await instance.database;
    return await db!.update(
      tableCategory,
      categoryModel.toMap(),
      where: '$columnCategoryId = ?',
      whereArgs: [categoryModel.key],
    );
  }

  // Future<int> deleteCategory(int id) async {
  //   Database? db = await instance.database;
  //   return await db!
  //       .delete(tableCategory, where: '$columnCategoryId = ?', whereArgs: [id]);
  // }
  Future<int> deleteCategory(int id) async {
    Database? db = await instance.database;
    deleteItemFromCategory(id);
    return await db!
        .delete(tableCategory, where: '$columnCategoryId = ?', whereArgs: [id]);
  }

  Future<ItemModel> insertItem(ItemModel itemModel) async {
    Database? db = await instance.database;
    var itemKey = await db!.insert(
      tableItem,
      itemModel.toMap(),
    );
    print('item inserted with id $itemKey');
    itemModel.itemkey = itemKey;
    return itemModel;
  }

  Future<List<ItemModel>> getAllItems(categoryid) async {
    List<ItemModel> items = [];
    Database? db = await instance.database;
    List<Map<String, dynamic>> allRows = [];

    if (categoryid != -1) {
      allRows = await db!.query(
        tableItem,
        where: '$columnCategoryId=?',
        whereArgs: [categoryid],
      );
    } else {
      allRows = await db!.query(tableItem);
    }

    allRows.forEach((row) => {
          items.add(
            ItemModel(row["$columnCategoryId"], row["$columnItemName"],
                row["$columnItemId"], row['$columnItemPrice']),
          )
        });

    return items;
  }

  Future<List<ItemModel>> getLastItems() async {
    List<ItemModel> items = [];
    Database? db = await instance.database;
    List<Map<String, dynamic>> allRows = [];
    allRows = await db!.rawQuery(
        'SELECT * from $tableItem where $columnItemId IN (SELECT DISTINCT $columnItemId FROM $tableExpense order by $columnExpenseDate DESC limit 5)');
    allRows.forEach((row) => {
          items.add(ItemModel(row["$columnCategoryId"], row["$columnItemName"],
              row["$columnItemId"], row['$columnItemPrice']))
        });
    return items;
  }

  Future<List<CategoryModel>> getLastCategory() async {
    List<CategoryModel> categories = [];
    Database? db = await instance.database;
    List<Map<String, dynamic>> allRows = [];
    allRows = await db!.rawQuery(
        'SELECT * from $tableCategory where $columnCategoryId IN (SELECT DISTINCT $columnCategoryId  FROM $tableExpense order by $columnExpenseDate DESC limit 5)');
    allRows.forEach((row) => {
          categories.add(CategoryModel(
              row["$columnCategoryName"], row["$columnCategoryId"]))
        });

    return categories;
  }

  Future<int> updateItem(ItemModel itemModel) async {
    Database? db = await instance.database;
    return await db!.update(
      tableItem,
      itemModel.toMap(),
      where: '$columnItemId = ?',
      whereArgs: [itemModel.itemkey],
    );
  }

  Future<int> deleteItem(int id) async {
    Database? db = await instance.database;
    return await db!
        .delete(tableItem, where: '$columnItemId = ?', whereArgs: [id]);
  }

  Future<int> deleteItemFromCategory(int id) async {
    Database? db = await instance.database;
    return await db!
        .delete(tableItem, where: '$columnCategoryId = ?', whereArgs: [id]);
  }

  Future<ExpenseModel> insertExpense(ExpenseModel expenseModel) async {
    Database? db = await instance.database;
    var expenseid = await db!.insert(
      tableExpense,
      expenseModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    expenseModel.expenseid = expenseid;
    print('item inserted with id $expenseid');

    return expenseModel;
  }

  Future<List<ExpenseModel>> getAllExpenses(
      categoryid, itemid, currentdate, reviseddate,) async {
    List<ExpenseModel> expenses = [];
    Database? db = await instance.database;
    List<Map<String, dynamic>> allRows = [];

    // if (categoryid != -1 && itemid != "") {
    //   allRows = await db!.query(
    //     tableExpense,
    //     where: '$columnCategoryId=? AND $columnItemId=?',
    //     whereArgs: [categoryid, itemid],
    //   );
    // } else {
    //   allRows = await db!.query(tableExpense);
    // }

    if (itemid == -1 && categoryid == -1) {
      allRows = await db!.query(tableExpense,
          where: '$columnExpenseDate >= ? AND $columnExpenseDate <?',
          whereArgs: [currentdate, reviseddate]);
    } else if (categoryid != -1 && itemid == -1) {
      allRows = await db!.query(
        tableExpense,
        where:
            '$columnCategoryId=? AND $columnExpenseDate >= ? AND $columnExpenseDate < ?',
        whereArgs: [categoryid, currentdate, reviseddate],
      );
    } else if (itemid == null) {
      allRows = await db!.query(tableExpense,
          where: '$columnExpenseDate >= ? AND $columnExpenseDate <?',
          whereArgs: [currentdate, reviseddate]);
    } else {
      allRows = await db!.query(tableExpense,
          where:
              ' $columnItemId=? AND $columnExpenseDate >= ? AND $columnExpenseDate <?',
          whereArgs: [itemid, currentdate, reviseddate]);
    }
    allRows.forEach((row) => {
          expenses.add(ExpenseModel(
              row["$columnExpenseId"],
              row["$columnCategoryId"],
              row["$columnItemId"],
              row["$columnItemName"],
              row[columnExpenseDate],
              row[columnItemPrice],

              row["$columnItemquantity"],
              row["$columnTotalPrice"],
              row["$columnExpenseNote"]))
        });

    return expenses;
  }

  Future<int> deleteExpense(int id) async {
    Database? db = await instance.database;
    return await db!
        .delete(tableItem, where: '$columnItemId = ?', whereArgs: [id]);
  }

//   Future<PriceHistoryModel> insertpricehistory(
//       PriceHistoryModel priceHistoryModel) async {
//     Database? db = await instance.database;
// print('yduuindndndndddddd');
//     var pricehistory = await db!.insert(
//      tablePriceHistory,
//       priceHistoryModel.toMap(),
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//     priceHistoryModel.pricehistoryid = pricehistory;
//     return priceHistoryModel;
//   }
//   Future<List<PriceHistoryModel>> getAllpricehistory() async {
//     List<PriceHistoryModel> pricehistory = [];
//     Database? db = await instance.database;
//     print('1234567890');
//     final List<Map<String, dynamic>> allRows = await db!.query(tablePriceHistory);
//     allRows.forEach((row) => {
//       pricehistory.add(PriceHistoryModel(
//           row["$columnPriceHistoryId"], row["$columnItemId"],row["$columnPriceDifference"],row["$columnExpenseDate"]))
//     });
//     return pricehistory;
//   }
}
