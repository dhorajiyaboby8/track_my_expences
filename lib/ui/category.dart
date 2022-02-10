import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:track_my_expences/models/categoryModel.dart';
import 'package:track_my_expences/database/database.dart';

class category extends StatefulWidget {
  const category({Key? key}) : super(key: key);

  @override
  _categoryState createState() => _categoryState();
}

class _categoryState extends State<category> {
  List<CategoryModel> categoryList = [];
  final dbHelper = DatabaseHelper.instance;

  TextEditingController _category = TextEditingController();
  final formKey = GlobalKey<FormState>();
  CategoryModel? selectedCategory;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    fetchCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Category',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF1D65BD),
      ),
      body: ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            return Slidable(
              child: Container(
                color: Colors.white,
                height: 74,
                width: 375,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          categoryList[index].name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
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
                      _category.text = categoryList[index].name;
                      _displayDialog(context, categoryList[index], true);
                    },
                  ),
                  SlidableAction(
                    backgroundColor: Color(0xFFF6F9FF),
                    icon: Icons.delete,
                    onPressed: (context) {
                      showAlertDialog(context, index, categoryList[index].key);
                    },
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) =>
              Divider(height: 1, color: Colors.black),
          itemCount: categoryList.length),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF1D65BD),
        onPressed: () {
          _category.clear();
          _displayDialog(context, CategoryModel("", -99));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void insertCategory() async {
    CategoryModel categoryModel = CategoryModel(_category.text, 0);
    final id = await dbHelper.insertCategory(categoryModel);
    print(id);
    categoryList.clear();
    fetchCategories();
  }

  fetchCategories() async {
    categoryList = await dbHelper.getAllCategories();
    categoryList.sort(sortByName);
    // data.reversed.toList();

    setState(() {});
  }

  void updateCategory(int key) async {
    CategoryModel categoryModel = CategoryModel(_category.text, key);
    final rowsAffected = await dbHelper.updateCategory(categoryModel);
    print('updated $rowsAffected row(s)');
    categoryList.clear();
    fetchCategories();
  }

  showAlertDialog(BuildContext context, num, int key) {
    // set up the button
    Widget continueButton = TextButton(
      child: Text("Cancel", style: TextStyle(color: Color(0xFF1D65BD))),
      onPressed: () {
        Navigator.of(_scaffoldKey.currentContext!).pop();
      },
    );
    Widget okButton = TextButton(
      child: Text("OK", style: TextStyle(color: Colors.black)),
      onPressed: () {
        setState(() {
          deleteCategory(key);
          categoryList.removeAt(num);
        });
        Navigator.pop(_scaffoldKey.currentContext!);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        "Delete",
        style: TextStyle(
          color: Colors.black,
        ),
      ),
      content: Text(
          "Are you sure to delete this category? \n\nIf you delete this category then all data related to this category will be delete",
          style: TextStyle(
            color: Color(0xFF1D65BD),
          )),
      actions: [
        continueButton,
        okButton,
      ],
    );

    // show the dialog

    showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (context) {
        return alert;
      },
    );
  }

  _displayDialog(BuildContext context, CategoryModel categoryModel,
      [bool isEdit = false]) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: Text('Add Category'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  TextFormField(
                    controller: _category,
                    textCapitalization: TextCapitalization.words,
                    cursorColor: Colors.black,
                    validator: (value) {
                      if(isEdit == true){
                      if (value!.isEmpty && selectedCategory!.name.contains(_category.text)) {
                        return "Please enter Category or category already added";
                      } else {
                        return null;
                      }
                      }
                      else{
                        if (value!.isEmpty  ) {
                          return "Please enter Category ";
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
                  SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 17,
                              color: Color(0xFF1D65BD),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              if (isEdit) {
                                updateCategory(categoryModel.key);
                              } else {
                                insertCategory();
                              }

                              Navigator.of(context).pop();
                              _category.clear();
                            }
                          },
                          child: Text(
                            isEdit ? 'Save' : 'Add',
                            style: TextStyle(fontSize: 17, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void deleteCategory(int id) async {
    final rowsDeleted = await dbHelper.deleteCategory(id);
    print('deleted $rowsDeleted row(s): row $id');
  }

  // int compareMyCustomClass(CategoryModel a, CategoryModel b) {
  //   var a0 = a.name;
  //   var b0 = b.name;
  //   return a0.compareTo(b0);
  // }
  Comparator<CategoryModel> sortByName = (a, b) => a.name.compareTo(b.name);
}
