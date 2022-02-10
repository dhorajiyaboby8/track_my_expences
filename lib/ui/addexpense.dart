import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:track_my_expences/database/database.dart';
import 'package:track_my_expences/models/categoryModel.dart';
import 'package:track_my_expences/models/expensemodel.dart';
import 'package:track_my_expences/models/itemModel.dart';
import "package:intl/intl.dart";
import 'package:track_my_expences/shared_preference/datetimeformat.dart';

class addexpense extends StatefulWidget {
  const addexpense({Key? key}) : super(key: key);

  @override
  _addexpenseState createState() => _addexpenseState();
}

class _addexpenseState extends State<addexpense> {
  List<CategoryModel> categoryList = [];
  List<ItemModel> itemList = [];
  List<ExpenseModel> expenseList = [];

  final dbHelper = DatabaseHelper.instance;
  late CategoryModel category;
  CategoryModel? selectedCategory;
  ItemModel? selectedItem;

  final dropdownKey1 = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
 var dateformat =SharedPrefrencesHelper.getdateformat();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _itemPrice = TextEditingController();
  TextEditingController _itemQuantity = TextEditingController();
  TextEditingController _totalprice = TextEditingController();
  TextEditingController _itemnotes = TextEditingController();

  void initState() {
    fetchCategory();
    print(dateformat);
    _dateController.text = DateFormat(dateformat).format(selectedDate);
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
          key: dropdownKey1,
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
                        selectedCategory = value!;
                        _itemPrice.clear();
                        _totalprice.clear();
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
                              categoryModel.name,
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
                    style: TextStyle(color: Colors.black),
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
                      _itemPrice.text = selectedItem!.itemprice;
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
                            itemModel.itemname,
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
                            DateFormat(dateformat).format(selectedDate);
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
                    controller: _totalprice,
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
                        _totalprice.text = totalprice.toString();
                      });
                    }),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  cursorColor: Colors.black,
                  controller: _itemnotes,
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
                        if (dropdownKey1.currentState!.validate()) {
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
    categoryList = await dbHelper.getAllCategories();

    categoryList.sort(sortByCategory);
    setState(() {});
  }

  fetchItems() async {
    print(selectedCategory!.key);
    itemList = await dbHelper.getAllItems(selectedCategory!.key);

    setState(() {});
  }
  statusindicator() {
    var itemprice = int.parse(selectedItem!.itemprice);
    var newitemprice = int.parse(_itemPrice.text);

    int difference = newitemprice - itemprice;
    return difference;
  }
  void insertExpense() async {
    print(selectedItem!.itemname);
    ExpenseModel expenseModel = ExpenseModel(
        0,
        selectedItem!.categoryid,
        selectedItem!.itemkey,
        selectedItem!.itemname.toString(),
        _dateController.text.toString(),
        _itemPrice.text.toString(),
        _itemQuantity.text.toString(),
        _totalprice.text.toString(),
        _itemnotes.text.toString());
    final expensedetail = await dbHelper.insertExpense(expenseModel);
    print(expensedetail);
  }
  Future<String?> getStringFromPrefrences() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    String? value = _prefs.getString("string");
    return value;

  }

  Comparator<CategoryModel> sortByCategory = (a, b) => a.name.compareTo(b.name);
  Comparator<ItemModel> sortByItem = (a, b) => a.itemname.compareTo(b.itemname);
}
