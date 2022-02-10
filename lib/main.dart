import 'package:flutter/material.dart';
import 'package:track_my_expences/database/database.dart';
import 'package:track_my_expences/models/categoryModel.dart';
import 'package:track_my_expences/models/itemModel.dart';
import 'package:track_my_expences/shared_preference/datetimeformat.dart';
import 'package:track_my_expences/ui/addexpense.dart';
import 'package:track_my_expences/ui/category.dart';
import 'package:track_my_expences/ui/expensehistory.dart';
import 'package:track_my_expences/ui/items.dart';
import 'package:track_my_expences/ui/pricehistory.dart';
import 'package:track_my_expences/ui/setting.dart';
import 'package:flutter_svg/flutter_svg.dart';

Future main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefrencesHelper.init();

  runApp(const homepage());
}

class homepage extends StatelessWidget {
  const homepage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Track Expenses',
      // theme: ThemeData(
      //   brightness: Brightness.light,
      // ),
      // darkTheme: ThemeData(
      //   brightness: Brightness.dark,
      // ),
      debugShowCheckedModeBanner: false,
      home: homescreen(),
    );
  }
}

class homescreen extends StatefulWidget {
  const homescreen({Key? key}) : super(key: key);

  @override
  _homescreenState createState() => _homescreenState();
}

class _homescreenState extends State<homescreen> {
  List<ItemModel> itemList = [];
  List<CategoryModel> categoryList = [];
  final dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    fetchfiveItems();
    // fetchfiveCategories();

    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text(
          'Track Expenses',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF1D65BD),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add expense by item ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 14),
                child: Container(
                  height: 48,
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: itemList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                          child: Container(
                            height: 34,
                            width: 74,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xFF58638A),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${itemList[index].itemname}',
                                style: TextStyle(
                                    fontSize: 15, fontFamily: 'Poppins'),
                              ),
                            ),
                          ),
                        ),
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => addexpense(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              // Text(
              //   'Add expense by category ',
              //   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              // ),
              // Padding(
              //   padding: const EdgeInsets.only(top: 14, bottom: 14),
              //   child: Container(
              //     height: 48,
              //     child: ListView.builder(
              //       physics: BouncingScrollPhysics(),
              //       scrollDirection: Axis.horizontal,
              //       shrinkWrap: true,
              //       itemCount: categoryList.length,
              //       itemBuilder: (BuildContext context, int index) {
              //         return Card(
              //           clipBehavior: Clip.antiAlias,
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.all(Radius.circular(10.0)),
              //           ),
              //           child: Container(
              //             height: 34,
              //             width: 74,
              //             decoration: BoxDecoration(
              //               border: Border.all(
              //                 color: Color(0xFF58638A),
              //                 width: 1,
              //               ),
              //             ),
              //             child: Center(
              //               child: Text(
              //                 '${categoryList[index].name}',
              //                 style: TextStyle(
              //                     fontSize: 15, fontFamily: 'Poppins'),
              //               ),
              //             ),
              //           ),
              //         );
              //       },
              //     ),
              //   ),
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    child: Container(
                      height: 140,
                      width: 154,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  height: 73,
                                  width: 73,

                                  decoration: new BoxDecoration(
                                    // image: new DecorationImage(
                                    //   image: new AssetImage('assets/setting.png'),
                                    //   fit: BoxFit.cover,
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(40.0),
                                    ),


                                  ),
                                  // child: new Image.asset(
                                  //   'assets/setting.png',
                                  //   width: 40.0,
                                  //   height: 40.0,
                                  //   fit: BoxFit.cover,
                                  // ),
                                ),
                                Container(
                                  height: 40,
                                  width: 40,

                                  decoration: new BoxDecoration(
                                    image: new DecorationImage(
                                      image: new AssetImage('assets/Category.png'),
                                      fit: BoxFit.cover,


                                    ),


                                  ),
                                  // child: new Image.asset(
                                  //   'assets/setting.png',
                                  //   width: 40.0,
                                  //   height: 40.0,
                                  //   fit: BoxFit.cover,
                                  // ),
                                ),
                              ]
                          ),
                          Text('Category',
                              style: TextStyle(
                                  fontFamily: 'Poppins', fontSize: 16, color: Color(0xFF2B4394),
                                  fontWeight: FontWeight.bold))
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: Color(0xFFF6F9FF),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => category(),
                        ),
                      );
                    },
                  ),
                  InkWell(
                    child: Container(
                      height: 140,
                      width: 154,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SvgPicture.asset('assets/item1.svg'),
                          Text('Items',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  color: Color(0xFF2B4394),
                                  fontWeight: FontWeight.bold))
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: Color(0xFFF6F9FF),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => items(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    child: Container(
                      height: 140,
                      width: 154,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SvgPicture.asset(
                            'assets/Add_expense.svg',
                            height: 80,
                            width: 80,
                          ),
                          Text('Add Expense',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  color: Color(0xFF2B4394),
                                  fontWeight: FontWeight.bold))
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: Color(0xFFF6F9FF),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                    onTap: () {
                      // var lengthofitemdata=itemList.length;
                      // var lengthofcategorydata=categoryList.length;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => addexpense(),
                        ),
                      ).then((value) => {
                            // if(lengthofitemdata!=itemList.length || lengthofcategorydata!=categoryList.length)
                            //   {
                            fetchfiveItems(),
                            // fetchfiveCategories()
                            //   }
                            // else{
                            //   print('132'),
                            // }
                          });
                    },
                  ),
                  InkWell(
                    child: Container(
                      height: 140,
                      width: 154,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SvgPicture.asset(
                            'assets/pricehistory.svg',
                            height: 80,
                            width: 80,
                          ),
                          Text('Price History',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  color: Color(0xFF2B4394),
                                  fontWeight: FontWeight.bold))
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: Color(0xFFF6F9FF),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => pricehistory(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    child: Container(
                      height: 140,
                      width: 154,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SvgPicture.asset(
                            'assets/expensehistory.svg',
                            height: 80,
                            width: 80,
                          ),
                          Text('Expense History',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  color: Color(0xFF2B4394),
                                  fontWeight: FontWeight.bold))
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: Color(0xFFF6F9FF),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => expensehistory(),
                        ),
                      );
                    },
                  ),
                  InkWell(
                    child: Container(
                      height: 140,
                      width: 154,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Stack(
                              alignment: Alignment.center,
                      children: [
                        Container(
                              height: 73,
                              width: 73,

                        decoration: new BoxDecoration(
                              // image: new DecorationImage(
                              //   image: new AssetImage('assets/setting.png'),
                              //   fit: BoxFit.cover,
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(40.0),
                            ),


                        ),
                              // child: new Image.asset(
                              //   'assets/setting.png',
                              //   width: 40.0,
                              //   height: 40.0,
                              //   fit: BoxFit.cover,
                              // ),
                            ),
                        Container(
                          height: 40,
                          width: 40,

                          decoration: new BoxDecoration(
                            image: new DecorationImage(
                              image: new AssetImage('assets/setting.png'),
                              fit: BoxFit.cover,


                            ),


                          ),
                          // child: new Image.asset(
                          //   'assets/setting.png',
                          //   width: 40.0,
                          //   height: 40.0,
                          //   fit: BoxFit.cover,
                          // ),
                        ),
                      ]
                          ),
                          Text('Setting',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  color: Color(0xFF2B4394),
                                  fontWeight: FontWeight.bold))
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: Color(0xFFF6F9FF),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => setting(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  fetchfiveItems() async {
    itemList = await dbHelper.getLastItems();
    print(itemList.length);
    setState(() {});
  }

  // fetchfiveCategories() async {
  //   categoryList = await dbHelper.getLastCategory();
  //   print(categoryList.length);
  //   setState(() {});
  // }
}
