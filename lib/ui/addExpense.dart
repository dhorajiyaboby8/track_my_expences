import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:track_my_expences/database/database.dart';
import 'package:track_my_expences/models/categoryModel.dart';
import 'package:track_my_expences/models/expenseModel.dart';
import 'package:track_my_expences/models/itemModel.dart';
import "package:intl/intl.dart";
import 'package:track_my_expences/models/priceHistoryModel.dart';
import 'package:track_my_expences/shared_preference/dateTimeFormat.dart';

class addExpense extends StatefulWidget {
  @override
  _addExpenseState createState() => _addExpenseState();
  String itemName;
  String itemPrice;
  int categoryId;
  int itemId;

  addExpense(this.categoryId, this.itemId, this.itemName, this.itemPrice);
}

class _addExpenseState extends State<addExpense> {
  List<CategoryModel> categoryList = [];
  List<ItemModel> itemList = [];
  List<ExpenseModel> expenseList = [];

  final dbHelper = DatabaseHelper.instance;
  CategoryModel? selectedCategory;
  ItemModel? selectedItem;

  final dropDownKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  var dateFormat = SharedPrefrencesHelper.getDateFormat();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _itemPrice = TextEditingController();
  TextEditingController _itemQuantity = TextEditingController();
  TextEditingController _totalPrice = TextEditingController();
  TextEditingController _expenseNote = TextEditingController();

  void initState() {
    fetchCategory();
    _itemPrice.text = widget.itemPrice.toString();

    _dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Expense',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF1D65BD),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: dropDownKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Center(
                  child: DropdownButtonFormField<CategoryModel>(
                    hint: Text("Select Category"),
                    value: selectedCategory,
                    validator: (value) {
                      if (value == null) {
                        return "Please select category to add Expense";
                      }
                    },
                    onChanged: (value) {
                      setState(() {
                        print(value?.categoryName);
                        print(value?.categoryId);
                        print(categoryList.length);
                        selectedCategory = value!;
                        _itemPrice.clear();
                        _totalPrice.clear();
                        _itemQuantity.clear();
                        selectedItem = null;
                        fetchItems();
                      });
                    },
                    items: categoryList.map((CategoryModel categoryModel) {
                      return DropdownMenuItem<CategoryModel>(
                        value: categoryModel,
                        child: Row(
                          children: <Widget>[
                            Text(
                              categoryModel.categoryName,
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                DropdownButtonFormField<ItemModel>(
                  hint: Text(
                    "Select Item",
                  ),
                  value: selectedItem,
                  validator: (value) {
                    if (value == null) {
                      return "Please select item for add expense";
                    }
                  },
                  onChanged: (value) {
                    setState(() {
                      selectedItem = value!;
                      _itemPrice.text = selectedItem!.itemPrice;
                      // fetchItem();
                      // if (selectedItem!.categoryid != -1) {
                      //   dropdownKey1.currentState!.validate();
                      // }
                    });
                  },
                  items: itemList.map((ItemModel itemModel) {
                    return DropdownMenuItem<ItemModel>(
                      value: itemModel,
                      child: Row(
                        children: <Widget>[
                          Text(
                            itemModel.itemName,
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  cursorColor: Colors.black,
                  readOnly: true,
                  controller: _dateController,
                  decoration: InputDecoration(
                    floatingLabelStyle: TextStyle(color: Colors.black),
                    labelText: 'Date',
                  ),
                  onTap: () async {
                    await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    ).then((selectedDate) {
                      if (selectedDate != null) {
                        _dateController.text =
                            DateFormat('yyyy-MM-dd').format(selectedDate);
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter date.';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  cursorColor: Colors.black,
                  autofocus: false,
                  controller: _itemPrice,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    floatingLabelStyle: TextStyle(color: Colors.black),
                    labelText: 'Item Price',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Date cannot be empty';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  cursorColor: Colors.black,
                  controller: _itemQuantity,
                  maxLength: 3,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    floatingLabelStyle: TextStyle(color: Colors.black),
                    labelText: 'Item Quantity',
                    counterText: "",
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return ' Please enter Quantity of the Item';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                    cursorColor: Colors.black,
                    readOnly: true,
                    controller: _totalPrice,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      floatingLabelStyle: TextStyle(color: Colors.black),
                      labelText: 'Total Price',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Totalprice cannot be empty';
                      }
                      return null;
                    },
                    onTap: () async {
                      var intprice = int.parse(_itemPrice.text);
                      var intquantity = int.parse(_itemQuantity.text);
                      var totalprice = intprice * intquantity;
                      print(totalprice);
                      setState(() {
                        _totalPrice.text = totalprice.toString();
                      });
                    }),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  cursorColor: Colors.black,
                  controller: _expenseNote,
                  minLines: 4,
                  maxLines: 10,
                  decoration: InputDecoration(
                    floatingLabelStyle: TextStyle(color: Colors.black),
                    labelText: 'Notes',
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 40,
                  width: 330,
                  child: TextButton(
                      style: TextButton.styleFrom(
                        primary: Colors.deepOrangeAccent,
                        backgroundColor: Color(0xFF1D65BD),
                      ),
                      onPressed: () {
                        if (dropDownKey.currentState!.validate()) {
                          insertExpense();
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        'Save',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontFamily: 'poppins'),
                      )),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  fetchCategory() async {
    categoryList = await dbHelper.getAllCategories('');
    for (var index = 0; index <= categoryList.length - 1; index++) {
      if (widget.categoryId == categoryList[index].categoryId) {
        selectedCategory = categoryList[index];
        break;
      }
    }
    fetchItems();
    categoryList.sort(sortByCategory);
    setState(() {});
  }

  fetchItems() async {
    itemList = await dbHelper.getAllItems(selectedCategory?.categoryId);

    for (var j = 0; j <= itemList.length - 1; j++) {
      if (widget.itemId == itemList[j].itemId) {
        print(itemList[j].itemName);
        print(widget.itemName);
        selectedItem = itemList[j];
        break;
      }
    }
  }

  statusIndicator() {
    var itemPrice = int.parse(selectedItem!.itemPrice);
    var newItemPrice = int.parse(_itemPrice.text);

    int difference = newItemPrice - itemPrice;
    return difference;
  }

  void insertExpense() async {
    if (selectedItem?.itemPrice != _itemPrice.text) {
      insertPriceChange();

      updateItem(selectedItem!.itemId, selectedItem!.categoryId);
    }
    ExpenseModel expenseModel = ExpenseModel(
        0,
        selectedItem!.categoryId,
        selectedItem!.itemId,
        selectedItem!.itemName.toString(),
        _dateController.text.toString(),
        _itemPrice.text.toString(),
        _itemQuantity.text.toString(),
        _totalPrice.text.toString(),
        _expenseNote.text.toString());
    final expenseDetail = await dbHelper.insertExpense(expenseModel);
  }

  Future<String?> getStringFromPrefrences() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    String? value = _prefs.getString("string");
    return value;
  }

  Comparator<CategoryModel> sortByCategory =
      (a, b) => a.categoryName.compareTo(b.categoryName);
  Comparator<ItemModel> sortByItem = (a, b) => a.itemName.compareTo(b.itemName);

  void updateItem(int key, int categoryId) async {
    ItemModel itemModel = ItemModel(
        categoryId, selectedItem!.itemName, key, _itemPrice.text.toString());
    final rowsAffected = await dbHelper.updateItem(itemModel);
    print('updated $rowsAffected row(s)');
    itemList.clear();
    fetchItems();
  }

  void insertPriceChange() async {
    print('insertPriceChange');
    var changeDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    PriceHistoryModel priceHistoryModel = PriceHistoryModel(
        0,
        selectedItem!.itemId,
        selectedItem!.itemPrice,
        _itemPrice.text.toString(),
        changeDate);
    final id = await dbHelper.insertPriceChange(priceHistoryModel);
  }
}
