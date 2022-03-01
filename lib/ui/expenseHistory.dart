import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:track_my_expences/database/database.dart';
import 'package:track_my_expences/models/categoryModel.dart';
import 'package:track_my_expences/models/expenseModel.dart';
import 'package:track_my_expences/models/itemModel.dart';
import 'package:track_my_expences/ui/pdf_Viewer.dart';
import '../shared_preference/dateTimeFormat.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class expenseHistory extends StatefulWidget {
  const expenseHistory({Key? key}) : super(key: key);

  @override
  _expenseHistoryState createState() => _expenseHistoryState();
}

class _expenseHistoryState extends State<expenseHistory> {
  List<ItemModel> itemList = [];
  List<CategoryModel> categoryList = [];
  List<ExpenseModel> expenseList = [];
  var symbol = SharedPrefrencesHelper.getCurrencySymbol();
  var formattedDate = SharedPrefrencesHelper.getDateFormat();
  final dbHelper = DatabaseHelper.instance;

  DateTime currentDate = DateTime.now();
  final dropDownKey = GlobalKey<FormState>();
  ItemModel? selectedItem;
  CategoryModel? selectedCategory;
  ExpenseModel? selectedExpense;
  final pdf = pw.Document();

  void initState() {
    fetchCategories();

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
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.save,
              color: Colors.white,
            ),
            onPressed: () async {
              writeOnPdf();
              await savePdf();

              Directory documentDirectory =
                  await getApplicationDocumentsDirectory();

              String documentPath = documentDirectory.path;

              String fullPath = "$documentPath/example.pdf";

              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => PdfPreviewScreen(
              //           path: fullPath,
              //         )));
            },
          )
        ],
        centerTitle: true,
        backgroundColor: Color(0xFF1D65BD),
        // ),
        // bottomNavigationBar: BottomNavigationBar(
        //   items: const <BottomNavigationBarItem>[
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.call),
        //       label: 'Calls',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.camera),
        //       label: 'Camera',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.chat),
        //       label: 'Chats',
        //     ),
        //   ],
      ),
      body: Stack(children: [
        Form(
          key: dropDownKey,
          child: Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
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
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
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
                              fetchExpenses();
                              fetchItems();

                              if (selectedCategory!.categoryId != -1) {
                                dropDownKey.currentState!.validate();
                              }
                            });
                          },
                          items:
                              categoryList.map((CategoryModel categoryModel) {
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
                              fetchExpenses();
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
                    itemCount: expenseList.length,
                    itemBuilder: (BuildContext context, int index) {
                      var date = DateTime.parse(expenseList[index].expenseDate);
                      var showDate = DateFormat(formattedDate).format(date);
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    expenseList[index].itemName,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                        '$symbol${expenseList[index].itemPrice}',
                                        style: TextStyle(fontSize: 15),
                                      )
                                    ],
                                  ),
                                  Text(
                                    'Qty :${expenseList[index].itemQuantity}',
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
                                        '$symbol${expenseList[index].expensePrice}',
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
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Color(0xFF1D65BD),
            height: 50,
            width: 600,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0,8.0,16.0,8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total",
                    style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 20, color: Colors.white),
                  ),
Text('$symbol${getTotal()}',style: TextStyle(
    fontFamily: 'Poppins', fontSize: 20, color: Colors.white),),
                ],
              ),
            ),
          ),
        )
      ]),
    );
  }
  getTotal(){
    var total =0;
    for(var index=0;index<=expenseList.length-1;index++)
      {
        var parseTotal= int.parse(expenseList[index].expensePrice);
        total = total + parseTotal;
      }

    return total;
  }

  fetchCategories() async {
    categoryList = await dbHelper.getAllCategories('');
    var allCategory = CategoryModel("All category", -1);
    selectedCategory = allCategory;
    categoryList.sort(sortCategoryByName);
    categoryList.insert(0, allCategory);
    setState(() {});
    fetchItems();
    fetchExpenses();
  }

  fetchItems() async {
    print(selectedCategory!.categoryId);
    itemList = await dbHelper.getAllItems(selectedCategory!.categoryId);
    var allitems = ItemModel(-1, "All item", -1, '');
    selectedItem = allitems;
    itemList.insert(0, allitems);

    setState(() {});
  }

  fetchExpenses() async {
    DateTime now = DateTime(currentDate.year, currentDate.month);
    DateTime nextMonthDate = DateTime(currentDate.year, currentDate.month + 1);
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    String nextDate = DateFormat('yyyy-MM-dd').format(nextMonthDate);

    expenseList = await dbHelper.getAllExpenses(selectedCategory?.categoryId,
        selectedItem?.itemId, formattedDate, nextDate);
    getTotal();
    setState(() {});
  }

  setCurrentMonth() {
    String formattedDate = DateFormat.yMMMM().format(currentDate);
    return formattedDate;
  }

  setNextPreviousMonth(bool isNext) {
    if (isNext) {
      DateTime now = DateTime(currentDate.year, currentDate.month + 1);
      currentDate = now;
    } else {
      DateTime now = DateTime(currentDate.year, currentDate.month - 1);
      currentDate = now;
    }

    setCurrentMonth();
  }

  Comparator<CategoryModel> sortCategoryByName =
      (a, b) => a.categoryName.compareTo(b.categoryName);
  Comparator<ItemModel> sortItemByName =
      (a, b) => a.itemName.compareTo(b.itemName);
  Future savePdf() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String documentPath = documentDirectory.path;
    print('data:$documentPath');
    File receiptFile = File("$documentPath/receipt.pdf");
    receiptFile.writeAsBytesSync(List.from(await pdf.save()));
  }
  writeOnPdf() {
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(16),
      build: (pw.Context context) {
        return <pw.Widget>[
        pw.Header(
        level: 0,
        child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: <pw.Widget>[
        pw.Text('Geeksforgeeks', textScaleFactor: 2),
        ])),
        pw.Header(level: 1, text: 'What is Lorem Ipsum?'),

        // Write All the paragraph in one line.
        // For clear understanding
        // here there are line breaks.

        pw.Padding(padding: const pw.EdgeInsets.all(8)),
        pw.Table.fromTextArray(context: context, data: const <List<String>>[
        <String>['Year', 'Sample'],
        <String>['SN0', 'GFG1'],
        <String>['SN1', 'GFG2'],
        <String>['SN2', 'GFG3'],
        <String>['SN3', 'GFG4'],
        ]),
        ];
      },
    ));

}
}
