import 'package:flutter/material.dart';
import 'package:track_my_expences/shared_preference/datetimeformat.dart';
import 'package:currency_picker/currency_picker.dart';

class setting extends StatefulWidget {
  const setting({Key? key}) : super(key: key);

  @override
  _settingState createState() => _settingState();
}

class _settingState extends State<setting> {
  final dropdownKey = GlobalKey<FormState>();
  var date = 'dd/mm/yyyy';

  dynamic _handleGenderChange(value) {
    Navigator.pop(context);

    setState(() {});
  }

  var countydata ;
  var countrydata= 'INR';

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
          key: dropdownKey,
          child: Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
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
                          Text('  Date format',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              )),

                          InkWell(
                              child: Text(date),
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
                          Text('  Currency',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              )),

                          InkWell(
                              child: Text(countrydata),
                              onTap: () {
                                showCurrencyPicker(
                                  context: context,
                                  showFlag: true,
                                  showCurrencyName: true,
                                  showCurrencyCode: true,
                                  onSelect: (Currency currency) {
                                    countydata = currency.symbol;
                                    countrydata = currency.code;
                                    SharedPrefrencesHelper.setcurrency(
                                        countydata);
                                    SharedPrefrencesHelper.setcurrencycode(
                                        countrydata);

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
            title: Text('Dateformat'),
            actions: <Widget>[
              Column(
                children: [
                  Row(
                    children: [
                      Radio(
                          value: 'yyyy/mm/dd',
                          groupValue: date,
                          onChanged: _handleGenderChange),
                      Text('yyyy/mm/dd')
                    ],
                  ),
                  Row(
                    children: [
                      Radio(
                          value: 'mm/dd/yyyy',
                          groupValue: date,
                          onChanged: _handleGenderChange),
                      Text('mm/dd/yyyy')
                    ],
                  ),
                  Row(
                    children: [
                      Radio(
                          value: 'dd/mm/yyyy',
                          groupValue: date,
                          onChanged: _handleGenderChange),
                      Text('dd/mm/yyyy')
                    ],
                  ),
                ],
              ),
            ],
          );
        });
  }
}
