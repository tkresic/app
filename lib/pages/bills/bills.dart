import 'dart:convert';
import 'dart:io';

import 'package:app/components/custom_app_bar.dart';
import 'package:app/components/drawer_list.dart';
import 'package:app/components/middleware.dart';
import 'package:app/mixins/format_price.dart';
import 'package:app/mixins/snackbar.dart';
import 'package:app/models/bill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'package:app/models/user.dart';
import 'package:app/providers/user_provider.dart';
import 'package:http/http.dart' as http;

class Bills extends StatefulWidget {
  const Bills({Key? key}) : super(key: key);

  @override
  _BillsState createState() => _BillsState();
}

class _BillsState extends State<Bills> {

  Future<List<Bill>> fetchBills() async {
    var response = await http.get(Uri.parse("${dotenv.env['FINANCE_API_URI']}/api/bills"));
    return Bill.parseBills(response.body);
  }

  void callback() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<UserProvider>(context).user;

    if (user == null) {
      return const Middleware();
    }

    return Scaffold(
      drawerScrimColor: Colors.transparent,
      drawer: const Drawer(
        child: DrawerList(index: 3),
      ),
      appBar: const CustomAppBar(),
      body: Row(
        children: <Widget>[
          Expanded(
            child: FutureBuilder<List<Bill>>(
              future: fetchBills(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  if (snapshot.error.runtimeType == SocketException) {
                    return const Center(child: Text("Došlo je do greške. Mikroservis vjerojatno nije u funkciji."));
                  } else {
                    return const Center(child: Text("Došlo je do greške."));
                  }
                }
                if (snapshot.hasData) {
                  return SingleChildScrollView(
                    child: Container(
                      margin: const EdgeInsets.all(25),
                      child: BillsList(context: context, callback: callback, bills: snapshot.data, user: user)
                    )
                  );
                } else {
                  return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.orange)));
                }
              }
            )
          )
        ]
      ),
    );
  }
}

class BillsList extends StatefulWidget {
  const BillsList({
    Key? key,
    required this.context,
    required this.callback,
    this.bills,
    required this.user,
  }) : super(key: key);

  final BuildContext context;
  final Function callback;
  final List<dynamic>? bills;
  final User user;

  @override
  _BillsListState createState() => _BillsListState(context: context, callback: callback, bills: bills, user: user);
}

class _BillsListState extends State<BillsList> {
  _BillsListState({
    required this.context,
    required this.callback,
    required this.bills,
    required this.user,
  });

  @override
  final BuildContext context;
  Function callback;
  List<dynamic>? bills;
  User user;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  @override
  Widget build(BuildContext context) {
    bills = widget.bills;
    var dts = DTS(context: context, callback: callback, bills: bills, user: user);

    return PaginatedDataTable(
        header: Row(
            children: const [
              Text('Računi'),
              SizedBox(
                width: 10
              ),
              Spacer(),
            ]
        ),
        columns: const [
          DataColumn(
            label: Text('Broj'),
          ),
          DataColumn(
            label: Text('Iznos'),
          ),
          DataColumn(
            label: Text('Način plaćanja'),
          ),
          DataColumn(
            label: Text('Zaposlenik'),
          ),
          DataColumn(
            label: Text('Datum'),
          ),
          DataColumn(
            label: Expanded(
              child: Text('Akcije', textAlign: TextAlign.right)
            )
          ),
        ],
        source: dts,
        rowsPerPage: _rowsPerPage,
        showFirstLastButtons: true,
        onRowsPerPageChanged: (r) {
          setState(() {
            _rowsPerPage = r!;
          });
        }
    );
  }
}

class DTS extends DataTableSource with FormatPrice, CustomSnackBar {
  DTS({
    required this.context,
    required this.callback,
    required this.bills,
    required this.user,
  });

  final BuildContext context;
  Function callback;
  final List<dynamic>? bills;
  final User user;
  final _formKey = GlobalKey<FormState>();
  String restoringReason = "";

  void restoreBill(int billId) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final userData = {
      "id" : user.id,
      "username" : user.username,
      "name" : user.name,
    };

    // TODO => Append token for authentication/authorization check.
    http.Response response = await http.put(
      Uri.parse("${dotenv.env['FINANCE_API_URI']}/api/bills/$billId"),
      body: json.encode({
        "user" : userData,
        "restoring_reason" : restoringReason,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Uspješno storniran račun", Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Došlo je do greške", Colors.red));
    }

    callback();
  }

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= bills!.length) return null;
    final bill = bills![index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(
            Text('${bill.number}')
        ),
        DataCell(
            Text(formatPrice(bill.gross))
        ),
        DataCell(
            Text('${bill.paymentMethod.name}')
        ),
        DataCell(
            Text('${bill.user.name}')
        ),
        DataCell(
            Text('${bill.createdAt}')
        ),
        DataCell(
            Row(
              children: <Widget>[
                const Spacer(),
                SizedBox(
                  width: 30.0,
                  height: 30.0,
                  child: Tooltip(
                      message: 'Pregledaj račun ${bill.number}',
                      textStyle: const TextStyle(color: Colors.black, fontSize: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: FloatingActionButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context)
                            {
                              return AlertDialog(
                                  title: const Text('Pregled računa'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Row(
                                        children: [
                                          bill.restoredBill != null ?
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.warning, size: 20.0, color: Colors.red),
                                                Text(" Ovaj račun je storno računa pod brojem ${bill.restoredBill.number}.")
                                              ],
                                            )
                                          )
                                          :
                                          const SizedBox(height: 0),
                                          bill.restoredByBill != null ?
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.warning, size: 20.0, color: Colors.red),
                                                Text(" Ovaj račun je storniran s računom pod brojem ${bill.restoredByBill.number}.")
                                              ],
                                            )
                                          )
                                          :
                                          const SizedBox(height: 0),
                                        ]
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: 250,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text("Način plaćanja: ${bill.paymentMethod.name}")
                                            ),
                                          ),
                                          const SizedBox(width: 25),
                                          Container(
                                            width: 250,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text("Izdao: ${bill.user.name}")
                                            ),
                                          ),
                                        ]
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: 250,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text("Oznaka: ${bill.label}")
                                            ),
                                          ),
                                          const SizedBox(width: 25),
                                          Container(
                                            width: 250,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text("Broj: ${bill.number}")
                                            ),
                                          ),
                                        ]
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: 250,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text("Datum: ${bill.createdAt}")
                                            ),
                                          ),
                                          const SizedBox(width: 25),
                                          Container(
                                            width: 250,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text("Iznos: ${formatPrice(bill.gross)}")
                                            ),
                                          ),
                                        ]
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            constraints: const BoxConstraints(minHeight: 100, maxHeight: 225),
                                            child: Card(
                                              child: SingleChildScrollView(
                                                child: DataTable(
                                                  columns: const [
                                                    DataColumn(
                                                      label: Text('Proizvod'),
                                                    ),
                                                    DataColumn(
                                                      label: Text('Cijena'),
                                                    ),
                                                    DataColumn(
                                                      label: Text('Količina'),
                                                    ),
                                                    DataColumn(
                                                      label: Text('Ukupno'),
                                                    ),
                                                  ],
                                                  rows: [
                                                    for (var product in bill.products)
                                                      DataRow(
                                                        cells: [
                                                          DataCell(
                                                            Row(
                                                              children: [
                                                                Image.network("${product.image}", width: 45),
                                                                const SizedBox(width: 10),
                                                                Text("${product.name}")
                                                              ],
                                                            )
                                                          ),
                                                          DataCell(Text(formatPrice(product.price))),
                                                          DataCell(Text("${product.quantity}")),
                                                          DataCell(Text(formatPrice(product.price * product.quantity))),
                                                        ],
                                                      ),
                                                  ]
                                                )
                                              )
                                            ),
                                          ),
                                        ]
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(40),
                                            child: TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('U redu'),
                                              style: TextButton.styleFrom(
                                                padding: const EdgeInsets.fromLTRB(90, 20, 90, 20),
                                                primary: Colors.white,
                                                backgroundColor: Colors.orange,
                                                textStyle: const TextStyle(fontSize: 18),
                                              ),
                                            ),
                                          )
                                        ]
                                      ),
                                    ]
                                  )
                                );
                            });
                        },
                        child: const Icon(Icons.preview, size: 15.0),
                        backgroundColor: Colors.orange,
                        elevation: 3,
                        hoverElevation: 4,
                      )
                  ),
                ),
                const SizedBox(
                  width: 5.0
                ),
                bill.gross > 0 && bill.restoredByBill == null ?
                  SizedBox(
                    width: 30.0,
                    height: 30.0,
                    child: Tooltip(
                      message: 'Storniraj račun ${bill.number}',
                      textStyle: const TextStyle(color: Colors.black, fontSize: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: FloatingActionButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Storniraj račun'),
                                  content: Form(
                                    key: _formKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Molimo unesite razlog storniranja';
                                              }
                                              return null;
                                            },
                                            onSaved: (value) => restoringReason = value!,
                                            cursorColor: Colors.orange,
                                            decoration: InputDecoration(
                                              hintText: "Razlog storniranja",
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(color: Colors.orange, width: 2),
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                              prefixIcon: const Icon(
                                                Icons.text_fields,
                                                color: Colors.orange,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(40),
                                          child: TextButton(
                                            onPressed: () {
                                              if (_formKey.currentState!.validate()) {
                                                _formKey.currentState!.save();
                                                restoreBill(bill.id);
                                                Navigator.of(context).pop();
                                              }
                                            },
                                            child: const Text('Storniraj'),
                                            style: TextButton.styleFrom(
                                              padding: const EdgeInsets.fromLTRB(105, 20, 105, 20),
                                              primary: Colors.white,
                                              backgroundColor: Colors.red,
                                              textStyle: const TextStyle(fontSize: 18),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        },
                        child: const Icon(Icons.restore, size: 15.0),
                        backgroundColor: Colors.red,
                        elevation: 3,
                        hoverElevation: 4,
                      ),
                    ),
                  )
                  :
                  const SizedBox(width: 0)
              ],
            )
        ),
      ],
    );
  }

  @override
  int get rowCount => bills!.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}