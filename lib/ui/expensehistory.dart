import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:track_my_expences/database/database.dart';
import 'package:track_my_expences/models/categoryModel.dart';
import 'package:track_my_expences/models/expensemodel.dart';
import 'package:track_my_expences/models/itemModel.dart';

import '../shared_preference/datetimeformat.dart';

class expensehistory extends StatefulWidget {
  const expensehistory({Key? key}) : super(key: key);

  @override
  _expensehistoryState createState() => _expensehistoryState();
}

class _expensehistoryState extends State<expensehistory> {
  List<ItemModel> itemList = [];
  List<CategoryModel> categoryList = [];
  List<ExpenseModel> expenseList = [];
  var symbol = SharedPrefrencesHelper.getcurrency();

  final dbHelper = DatabaseHelper.instance;
  DateTime currentdate = DateTime.now();
  final dropdownKey = GlobalKey<FormState>();
  ItemModel? selectedItem;
  CategoryModel? selectedCategory;
  ExpenseModel? selectedexpense;

  void initState() {
    fetchCategory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expense History',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF1D65BD),
      ),
      body: Form(
        key: dropdownKey,
        child: Padding(
          padding: const EdgeInsets.only(top: 10,bottom: 10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        setNextPreviousMonth(false);
                        fetchExpenses();
                        setState(() {});
                      },
                      icon: Icon(Icons.arrow_back),
                    ),
                    Text(
                      setCurrentMonth(),
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () {
                        setNextPreviousMonth(true);
                        fetchExpenses();
                        setState(() {});
                      },
                      icon: Icon(Icons.arrow_forward),
                    )
                  ],
                ),
                DropdownButtonFormField<CategoryModel>(
                  value: selectedCategory,
                  validator: (value) {
                    if (value!.key == -1) {
                      return "Please select category for add item";
                    }
                  },
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                      selectedItem!.itemkey = -1;
                      fetchExpenses();
                      fetchItems();

                      if (selectedCategory!.key != -1) {
                        dropdownKey.currentState!.validate();
                      }
                    });
                  },
                  items: categoryList.map((CategoryModel categoryModel) {
                    return DropdownMenuItem<CategoryModel>(
                      value: categoryModel,
                      child: Row(
                        children: <Widget>[
                          Text(
                            categoryModel.name,
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                DropdownButtonFormField<ItemModel>(
                  value: selectedItem,
                  onChanged: (value) {
                    setState(() {
                      selectedItem = value!;
                      fetchExpenses();
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
                ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: expenseList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      height: 70,
                      width: 375,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  expenseList[index].itemname,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                Text(
                                  expenseList[index].expensedate,
                                  style: TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'price : ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                    Text(
                                      '$symbol${expenseList[index].itemprice}',
                                      style: TextStyle(fontSize: 15),
                                    )
                                  ],
                                ),
                                Text(
                                  'Qty :${expenseList[index].itemquantity}',
                                  style: TextStyle(fontSize: 15),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Total : ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                    Text(
                                      '$symbol${expenseList[index].itemtotalprice}',
                                      style: TextStyle(fontSize: 15),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      Divider(height: 1, color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  fetchCategory() async {
    categoryList = await dbHelper.getAllCategories();
    var allCategory = CategoryModel("All category", -1);
    selectedCategory = allCategory;
    categoryList.sort(sortCategoryByName);
    categoryList.insert(0, allCategory);
    setState(() {});
    fetchItems();
    fetchExpenses();
  }

  fetchItems() async {
    print(selectedCategory!.key);
    itemList = await dbHelper.getAllItems(selectedCategory!.key);
    var allitems = ItemModel(-1, "All item", -1, '');
    selectedItem = allitems;
    itemList.insert(0, allitems);

    setState(() {});
  }

  fetchExpenses() async {
    DateTime now = DateTime(currentdate.year, currentdate.month);
    DateTime nextmonthdate = DateTime(currentdate.year, currentdate.month + 1);
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    String nextdate = DateFormat('yyyy-MM-dd').format(nextmonthdate);

    expenseList = await dbHelper.getAllExpenses(
        selectedCategory?.key, selectedItem?.itemkey, formattedDate, nextdate);

    setState(() {});
  }

  setCurrentMonth() {
    String formattedDate = DateFormat.yMMMM().format(currentdate);
    return formattedDate;
  }

  setNextPreviousMonth(bool isNext) {
    if (isNext) {
      DateTime now = DateTime(currentdate.year, currentdate.month + 1);
      currentdate = now;
    } else {
      DateTime now = DateTime(currentdate.year, currentdate.month - 1);
      currentdate = now;
    }

    setCurrentMonth();

  }

  Comparator<CategoryModel> sortCategoryByName =
      (a, b) => a.name.compareTo(b.name);
  Comparator<ItemModel> sortItemByName =
      (a, b) => a.itemname.compareTo(b.itemname);
}
