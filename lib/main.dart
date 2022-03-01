import 'package:flutter/material.dart';
import 'package:track_my_expences/database/database.dart';
import 'package:track_my_expences/models/categoryModel.dart';
import 'package:track_my_expences/models/itemModel.dart';
import 'package:track_my_expences/shared_preference/dateTimeFormat.dart';
import 'package:track_my_expences/ui/addExpense.dart';
import 'package:track_my_expences/ui/category.dart';
import 'package:track_my_expences/ui/expenseHistory.dart';
import 'package:track_my_expences/ui/items.dart';
import 'package:track_my_expences/ui/priceHistory.dart';
import 'package:track_my_expences/ui/setting.dart';
import 'package:flutter_svg/flutter_svg.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefrencesHelper.init();

  runApp(const homePage());
}

class homePage extends StatelessWidget {
  const homePage({Key? key}) : super(key: key);

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
      home: homeScreen(),
    );
  }
}

class homeScreen extends StatefulWidget {
  const homeScreen({Key? key}) : super(key: key);

  @override
  _homeScreenState createState() => _homeScreenState();
}

class _homeScreenState extends State<homeScreen> {
  List<ItemModel> itemList = [];
  List<CategoryModel> categoryList = [];
  final dbHelper = DatabaseHelper.instance;

  @override
  void initState() {

   var existingCurrencyCode = SharedPrefrencesHelper.getCurrencyCode();
   if (existingCurrencyCode == null) {
     SharedPrefrencesHelper.setCurrencySymbol("₹");
     SharedPrefrencesHelper.setCurrencyCode("INR");
     SharedPrefrencesHelper.setDateFormat("dd/MM/yyyy");
   }

    fetchfiveItems();
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
          child:

          Column(
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
                  height: 35,
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: itemList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: InkWell(
                          child: Container(
                            height: 20,
                            width: 74,
                            // decoration: BoxDecoration(
                            //   border: Border.all(
                            //     color: Color(0xFF58638A),
                            //     width: 1,
                            //   ),
                            // ),
                            decoration: BoxDecoration(
                            border: Border.all(
                                color: Color(0xFF58638A),
                                width: 1,
                              ),
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(13.0),
                                    )),
                            child: Center(
                              child: Text(
                                '${itemList[index].itemName}',
                                style: TextStyle(
                                    fontSize: 15, fontFamily: 'Poppins'),
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => addExpense(itemList[index].categoryId,itemList[index].itemId,itemList[index].itemName,itemList[index].itemPrice),
                              ),
                            );
                          },
                        ),
                      );
                    },

                  ),
                ),
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
                          Stack(alignment: Alignment.center, children: [
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
                            ),
                          ]),
                          Text('Category',
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
                          builder: (context) => addCategory(),
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
                          builder: (context) => addItem(-1),
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
                          builder: (context) => addExpense(-1,-1,'',''),
                        ),
                      ).then((value) => {
                            fetchfiveItems(),
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
                          builder: (context) => priceHistory(-1,-1),
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
                          builder: (context) => expenseHistory(),
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
                          Stack(alignment: Alignment.center, children: [
                            Container(
                              height: 73,
                              width: 73,
                              decoration: new BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(40.0),
                                ),
                              ),
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
                            ),
                          ]),
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
                          builder: (context) =>  setting(),
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
    setState(() {});
  }
}
