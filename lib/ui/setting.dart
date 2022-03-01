import 'package:flutter/material.dart';
import 'package:track_my_expences/shared_preference/dateTimeFormat.dart';
import 'package:currency_picker/currency_picker.dart';

class setting extends StatefulWidget {
  const setting({Key? key}) : super(key: key);

  @override
  _settingState createState() => _settingState();
}

class _settingState extends State<setting> {
  final dropDownKey = GlobalKey<FormState>();

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Setting',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF1D65BD),
      ),
      body: Form(
          key: dropDownKey,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Column(children: [
                Container(
                    color: Colors.white,
                    height: 50,
                    width: 375,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Icon(Icons.beach_access),
                          // SizedBox(width: 10),
                          Text('Date format',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              )),

                          InkWell(
                              child: Text(getDateFormat()),
                              onTap: () {
                                _popupDialog(context);
                              })
                        ],
                      ),
                    )),
                Divider(
                  height: 1,
                ),
                Container(
                    color: Colors.white,
                    height: 50,
                    width: 375,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Icon(Icons.beach_access),
                          // SizedBox(width: 10),
                          Text('Currency',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              )),

                          InkWell(
                              child: Text(getCurrency()),
                              onTap: () {
                                showCurrencyPicker(
                                  context: context,
                                  showFlag: true,
                                  showCurrencyName: true,
                                  showCurrencyCode: true,
                                  onSelect: (Currency currency) {
                                    SharedPrefrencesHelper.setCurrencySymbol(
                                        currency.symbol);
                                    SharedPrefrencesHelper.setCurrencyCode(
                                        currency.code);

                                    setState(() {});
                                  },
                                );
                              })
                        ],
                      ),
                    )),
              ]),
            ),
          )),
    );
  }

  // show the dialog

  void _popupDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Date Format'),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  children: [
                    InkWell(
                      child: Container(
                        height: 40,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'MM/dd/yyyy',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      onTap: () {
                        SharedPrefrencesHelper.setDateFormat('MM/dd/yyyy');

                        setState(() {});
                        Navigator.pop(context);
                      },
                    ),

                    InkWell(
                      child: Container(
                        height: 40,
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'yyyy/MM/dd',
                              style: TextStyle(fontSize: 16),
                            )),
                      ),
                      onTap: () {
                        SharedPrefrencesHelper.setDateFormat('yyyy/MM/dd');

                        setState(() {});
                        Navigator.pop(context);
                      },
                    ),

                    InkWell(
                      child: Container(
                        height: 40,
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'dd/MM/yyyy',
                              style: TextStyle(fontSize: 16),
                            )),
                      ),
                      onTap: () {
                        SharedPrefrencesHelper.setDateFormat('dd/MM/yyyy');

                        setState(() {});
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  getCurrency() {
    var currency =  SharedPrefrencesHelper.getCurrencySymbol();
    var currencyCode = SharedPrefrencesHelper.getCurrencyCode();
    return "$currencyCode ($currency)";
  }

  getDateFormat() {

    return SharedPrefrencesHelper.getDateFormat();
  }
}
