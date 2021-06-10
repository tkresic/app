import 'package:app/components/custom_app_bar.dart';
import 'package:app/components/drawer_list.dart';
import 'package:app/components/middleware.dart';
import 'package:app/mixins/format_price.dart';
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
  // TODO => Slice data table into a component

  Future<List<Bill>> fetchBills() async {
    var response = await http.get(Uri.parse("${dotenv.env['FINANCE_API_URI']}/api/bills"));
    return Bill.parseBills(response.body);
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
                  return const Center(child: Text("Došlo je do greške."));
                }
                if (snapshot.hasData) {
                  return SingleChildScrollView(
                    child: Container(
                      margin: const EdgeInsets.all(25),
                      child: BillsList(context: context, bills: snapshot.data)
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
    this.bills
  }) : super(key: key);

  final BuildContext context;
  final List<dynamic>? bills;

  @override
  _BillsListState createState() => _BillsListState(context: context, bills: bills);
}

class _BillsListState extends State<BillsList> {
  _BillsListState({
    required this.context,
    required this.bills
  });

  @override
  final BuildContext context;
  List<dynamic>? bills;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  @override
  Widget build(BuildContext context) {
    bills = widget.bills;
    var dts = DTS(context: context, bills: bills);
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

class DTS extends DataTableSource with FormatPrice {
  DTS({
    required this.context,
    required this.bills
  });

  final BuildContext context;
  final List<dynamic>? bills;

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
            Text('${bill.user.username}')
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
                          // TODO => Push to view
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
                        // TODO => Modal to delete
                      },
                      child: const Icon(Icons.restore, size: 15.0),
                      backgroundColor: Colors.red,
                      elevation: 3,
                      hoverElevation: 4,
                    ),
                  ),
                ),
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