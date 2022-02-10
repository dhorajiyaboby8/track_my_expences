import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:track_my_expences/models/categoryModel.dart';
import 'package:track_my_expences/database/database.dart';
import 'package:track_my_expences/models/itemModel.dart';
import 'package:track_my_expences/shared_preference/datetimeformat.dart';

class items extends StatefulWidget {
  const items({Key? key}) : super(key: key);

  @override
  _itemsState createState() => _itemsState();
}

class _itemsState extends State<items> {
  List<ItemModel> itemList = [];
  late ItemModel dataofitem;
  List<CategoryModel> categoryList = [];
  TextEditingController _items = TextEditingController();
  TextEditingController _price = TextEditingController();

  CategoryModel? selectedCategory;
  ItemModel? selectedItems;
  var symbol = SharedPrefrencesHelper.getcurrency();
  final dbHelper = DatabaseHelper.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final formKey = GlobalKey<FormState>();
  final dropdownKey = GlobalKey<FormState>();

  void initState() {
    fetchCategory();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Items',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF1D65BD),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Form(
          key: dropdownKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10, top: 10),
                child: Center(
                  child: DropdownButtonFormField<CategoryModel>(
                    value: selectedCategory,
                    validator: (value) {
                      if (value!.key == -1) {
                        return "Please select category for add item";
                      }
                    },
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
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
                ),
              ),
              ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: itemList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Slidable(
                    child: Container(
                      color: Colors.white,
                      height: 74,
                      width: 375,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              itemList[index].itemname,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text(
                              '$symbol${itemList[index].itemprice}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      extentRatio: 0.30,
                      children: [
                        SlidableAction(
                          backgroundColor: Color(0xFFF6F9FF),
                          icon: Icons.edit,
                          onPressed: (context) {
                            _items.text = itemList[index].itemname;
                            _price.text = itemList[index].itemprice;
                            _displayAddEditItemDialog(
                                context, itemList[index], true);
                          },
                        ),
                        SlidableAction(
                          backgroundColor: Color(0xFFF6F9FF),
                          icon: Icons.delete,
                          onPressed: (context) {
                            showAlertDialog(
                                context, index, itemList[index].itemkey);
                          },
                        ),
                      ],
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF1D65BD),
        onPressed: () async {
          if (dropdownKey.currentState!.validate()) {
            if (selectedCategory!.key != -1) {
              _items.clear();
              _price.clear();

              _displayAddEditItemDialog(
                  context, ItemModel(selectedCategory!.key, "", 46, ''));
            } else {
              return null;
            }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  showAlertDialog(BuildContext context, num, int key) {
    // set up the button
    Widget continueButton = TextButton(
      child: Text("Cancel",
          style: TextStyle(
            color: Color(0xFF1D65BD),
          )),
      onPressed: () {
        Navigator.of(_scaffoldKey.currentContext!).pop();
      },
    );
    Widget okButton = TextButton(
      child: Text("OK", style: TextStyle(color: Colors.black)),
      onPressed: () {
        setState(() {
          deleteItem(key);
          itemList.removeAt(num);
        });

        Navigator.of(_scaffoldKey.currentContext!).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        "Delete",
        style: TextStyle(color: Colors.black),
      ),
      content:
          Text("Are you sure?", style: TextStyle(color: Color(0xFF1D65BD))),
      actions: [
        continueButton,
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _displayAddEditItemDialog(BuildContext context, ItemModel itemModel,
      [bool isEdit = false]) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: Text('Add Item'),
            content: Form(
              key: formKey,
              child: Column(children: <Widget>[
                TextFormField(
                  textCapitalization: TextCapitalization.words,
                  controller: _items,
                  cursorColor: Colors.black,
                  validator: (value) {
                    if (isEdit == true) {
                      if (value!.isEmpty &&
                          selectedItems!.itemname.contains(_items.text)) {
                        return "Please enter Item or item already added";
                      } else {
                        return null;
                      }
                    } else {
                      if (value!.isEmpty) {
                        return "Please enter Item or item already added";
                      } else {
                        return null;
                      }
                    }
                  },
                  decoration: InputDecoration(
                    floatingLabelStyle: TextStyle(color: Colors.black),
                    fillColor: Colors.black,
                    labelText: 'Enter name',

                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),

                    // Focus Color underline
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                TextFormField(
                  controller: _price,
                  maxLength: 5,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  // Only numbers can be entered
                  cursorColor: Colors.black,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter Price";
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    counterText: "",
                    floatingLabelStyle: TextStyle(color: Colors.black),
                    fillColor: Colors.black,
                    labelText: 'Enter price',

                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),

                    // Focus Color underline
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                        child: Text(
                          'Cancel',
                          style:
                              TextStyle(fontSize: 17, color: Color(0xFF1D65BD)),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            if (isEdit) {
                              updateItem(
                                  itemModel.itemkey, itemModel.categoryid);
                            } else {
                              insertItem();
                            }

                            Navigator.of(context).pop();

                            _items.clear();
                          }
                        },
                        child: Text(
                          isEdit ? 'Save' : 'Add',
                          style: TextStyle(fontSize: 17, color: Colors.black),
                        ),
                      )
                    ]),
              ]),
            ),
          );
        });
  }

  fetchCategory() async {
    categoryList = await dbHelper.getAllCategories();
    var allCategory = CategoryModel("All category", -1);
    selectedCategory = allCategory;
    categoryList.sort(sortCategoryByName);
    categoryList.insert(0, allCategory);
    setState(() {});
    fetchItems();
  }

  void deleteItem(int id) async {
    final rowsDeleted = await dbHelper.deleteItem(id);
    print('deleted $rowsDeleted row(s): row $id');
  }

  // void updateItem(int key, String name, String price) async {
  //   Map<String, dynamic> row = {
  //     DatabaseHelper.columnItemId: key,
  //     DatabaseHelper.columnItemName: name,
  //     DatabaseHelper.columnItemPrice: price,
  //   };
  //   final rowsAffected = await dbHelper.updateItem(row);
  //   print('updated $rowsAffected row(s)');
  //   itemdata.clear();
  //   fetchItem();
  // }
  void updateItem(int key, int categoryId) async {
    ItemModel itemModel = ItemModel(
        categoryId, _items.text.toString(), key, _price.text.toString());
    final rowsAffected = await dbHelper.updateItem(itemModel);
    print('updated $rowsAffected row(s)');
    itemList.clear();
    fetchItems();
  }

  fetchItems() async {
    print(selectedCategory!.key);

    itemList = await dbHelper.getAllItems(selectedCategory!.key);

    // itemList.clear();

    setState(() {});
  }

  // void insertItem() async {
  //   Map<String, dynamic> row = {
  //     DatabaseHelper.columnCategoryId: selectedUser!.key,
  //     DatabaseHelper.columnItemName: _items.text,
  //     DatabaseHelper.columnItemPrice: _price.text,
  //   };
  //
  //   final id = await dbHelper.insertItem(row);
  //   print(selectedUser!.name);
  //   print(id);
  // }
  void insertItem() async {
    ItemModel itemModel = ItemModel(selectedCategory!.key,
        _items.text.toString(), 0, _price.text.toString());

    final id = await dbHelper.insertItem(itemModel);
    fetchItems();
  }

  Comparator<CategoryModel> sortCategoryByName =
      (a, b) => a.name.compareTo(b.name);
  Comparator<ItemModel> sortItemByName =
      (a, b) => a.itemname.compareTo(b.itemname);
}
