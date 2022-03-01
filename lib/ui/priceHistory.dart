import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:track_my_expences/database/database.dart';
import 'package:track_my_expences/models/categoryModel.dart';
import 'package:track_my_expences/models/expenseModel.dart';
import 'package:track_my_expences/models/itemModel.dart';
import 'package:track_my_expences/shared_preference/dateTimeFormat.dart';

import '../models/priceHistoryModel.dart';

class priceHistory extends StatefulWidget {

  int categoryId;
  int itemId;
  priceHistory(this.categoryId, this.itemId);

  @override
  _priceHistoryState createState() => _priceHistoryState();

}

class _priceHistoryState extends State<priceHistory> {
  List<ItemModel> itemList = [];
  List<CategoryModel> categoryList = [];
  List<ExpenseModel> expenseList = [];
  final dbHelper = DatabaseHelper.instance;
  List<PriceHistoryModel> priceChangeList = [];
  DateTime currentdate = DateTime.now();
  final dropdownKey = GlobalKey<FormState>();
  var symbol = SharedPrefrencesHelper.getCurrencySymbol();
  var formattingdate = SharedPrefrencesHelper.getDateFormat();

  ItemModel? selectedItem;
  CategoryModel? selectedCategory;

  void initState() {
    fetchCategories();

    fetchPriceChange();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Price History',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF1D65BD),
      ),
      body: Form(
        key: dropdownKey,
        child: Padding(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        setNextPreviousMonth(false);
                        fetchPriceChange();
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
                        fetchPriceChange();
                        setState(() {});
                      },
                      icon: Icon(Icons.arrow_forward),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 175,
                      child: DropdownButtonFormField<CategoryModel>(
                        value: selectedCategory,
                        validator: (value) {
                          if (value!.categoryId == -1) {
                            return "Please select category for add item";
                          }
                        },
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                            selectedItem!.itemId = -1;
                            fetchPriceChange();
                            fetchItems();

                            if (selectedCategory!.categoryId != -1) {
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
                                  categoryModel.categoryName,
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                Container(
                  width: 175,
                  child: DropdownButtonFormField<ItemModel>(
                    value: selectedItem,
                    onChanged: (value) {
                      setState(() {
                        selectedItem = value!;
                        fetchPriceChange();
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
                ),
                  ],
                ),
                ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: priceChangeList.length,
                  itemBuilder: (BuildContext context, int index) {
                    var date =
                        DateTime.parse(priceChangeList[index].changeDate);
                    var showDate = DateFormat(formattingdate).format(date);
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
                                  '',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                Text(
                                  showDate,
                                  style: TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                difference(priceChangeList[index].oldPrice,
                                            priceChangeList[index].newPrice) >
                                        0
                                    ? Text(
                                        '$symbol${difference(priceChangeList[index].oldPrice, priceChangeList[index].newPrice)}',
                                        style: TextStyle(
                                            fontSize: 15, color: Colors.green),
                                      )
                                    : Text(
                                        '$symbol${difference(priceChangeList[index].oldPrice, priceChangeList[index].newPrice)}',
                                        style: TextStyle(
                                            fontSize: 15, color: Colors.red),
                                      ),
                                statusIndicator(priceChangeList[index].oldPrice,
                                    priceChangeList[index].newPrice),
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

  fetchCategories() async {
    categoryList = await dbHelper.getAllCategories('');
    var allCategory = CategoryModel("All category", -1);
    selectedCategory = allCategory;
    categoryList.sort(sortCategoryByName);
    categoryList.insert(0, allCategory);
    for (var index = 0; index <= categoryList.length - 1; index++) {
      if (widget.categoryId == categoryList[index].categoryId) {
        selectedCategory = categoryList[index];
        break;
      }
    }
    setState(() {});
    fetchItems();
  }

  fetchItems() async {
    print(selectedCategory!.categoryId);
    itemList = await dbHelper.getAllItems(selectedCategory!.categoryId);
    var allitems = ItemModel(-1, "All item", -1, '');
    selectedItem = allitems;
    itemList.insert(0, allitems);
    for (var j = 0; j <= itemList.length - 1; j++) {
      if (widget.itemId == itemList[j].itemId) {

        selectedItem = itemList[j];
        break;
      }
    }

    setState(() {});
  }

  difference(oldprice, newprice) {
    var a = int.parse(newprice);
    var b = int.parse(oldprice);

    var difference = a - b;
    return difference;
    // if (difference > 0) {
    //   return Text(
    //     '$difference',
    //     style: TextStyle(color: Colors.green),
    //   );
    // } else {
    //   return Text(
    //     '$difference',
    //     style: TextStyle(color: Colors.red),
    //   );
    // }
  }

  statusIndicator(oldprice, newprice) {
    var a = int.parse(newprice);
    var b = int.parse(oldprice);

    var difference = a - b;

    if (difference > 0) {
      return Icon(Icons.arrow_upward, color: Colors.green);
    } else {
      return Icon(Icons.arrow_downward, color: Colors.red);
    }
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
      (a, b) => a.categoryName.compareTo(b.categoryName);
  Comparator<ItemModel> sortItemByName =
      (a, b) => a.itemName.compareTo(b.itemName);

  fetchPriceChange() async {
    DateTime now = DateTime(currentdate.year, currentdate.month);
    DateTime nextmonthdate = DateTime(currentdate.year, currentdate.month + 1);
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    String nextdate = DateFormat('yyyy-MM-dd').format(nextmonthdate);
    priceChangeList = await dbHelper.getAllPriceChange(
        selectedCategory?.categoryId,
        selectedItem?.itemId,
        formattedDate,
        nextdate);

    setState(() {});
  }
}
