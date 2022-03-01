
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pdf/pdf.dart';
import 'package:track_my_expences/models/categoryModel.dart';
import 'package:track_my_expences/database/database.dart';
import 'package:track_my_expences/ui/items.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';




class addCategory extends StatefulWidget {
   addCategory({Key? key}) : super(key: key);

  @override
  _addCategoryState createState() => _addCategoryState();
}

class _addCategoryState extends State<addCategory> {
  List<CategoryModel> categoryList = [];
  final dbHelper = DatabaseHelper.instance;

  TextEditingController _category = TextEditingController();
 TextEditingController _categorysearch =TextEditingController();

  final formKey = GlobalKey<FormState>();
  CategoryModel? selectedCategory;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Icon customIcon = const Icon(Icons.search);

  Widget customSearchBar =const Text(
    'Category',
    style: TextStyle(fontFamily: 'Poppins', fontSize: 20)
  );
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
        title:  customSearchBar,

        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                if (customIcon.icon == Icons.search) {
                  customIcon = const Icon(Icons.cancel);
                  customSearchBar =  ListTile(
                    leading: Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 28,
                    ),
                    title: TextField(
                      controller: _categorysearch,

                      decoration: InputDecoration(
                        hintText: 'search category',

                        hintStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                        border: InputBorder.none,

                      ),
                      style: TextStyle(
                        color: Colors.white,
                      ),

                      onTap:  fetchCategories(),
                    ),
                  );
                } else {
                  customIcon =  Icon(Icons.search);
                  customSearchBar =Text(
                    'Category',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 20),
                  );
                }
              });
            },
            icon: customIcon,
          )
        ],
        centerTitle: true,
        backgroundColor: Color(0xFF1D65BD),
      ),
      body: ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            return Slidable(
              child: Container(
                color: Colors.white,
                height: 50,
                width: 375,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Text(
                        categoryList[index].categoryName,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 0.4,
                children: [
                  SlidableAction(
                    backgroundColor: Color(0xFFF6F9FF),
                    icon: Icons.edit,
                    onPressed: (context) {
                      _category.text = categoryList[index].categoryName;
                      _displayDialog(context, categoryList[index], true);
                    },
                  ),
                  SlidableAction(
                    backgroundColor: Color(0xFFF6F9FF),
                    icon: Icons.delete,
                    onPressed: (context) {
                      showAlertDialog(context, index, categoryList[index].categoryId);
                    },
                  ),
                  SlidableAction(
                    backgroundColor: Color(0xFFF6F9FF),
           icon:Icons.arrow_forward,
                    onPressed:(context){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                          builder: (context) => addItem(categoryList[index].categoryId),
                      ),

                      );
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
    categoryList = await dbHelper.getAllCategories(_categorysearch.text);
    categoryList.sort(sortByName);

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
                      if (value!.isEmpty && selectedCategory!.categoryName.contains(_category.text)) {
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
                                updateCategory(categoryModel.categoryId);
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
  Comparator<CategoryModel> sortByName = (a, b) => a.categoryName.compareTo(b.categoryName);

}
