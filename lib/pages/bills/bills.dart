import 'package:app/components/custom_app_bar.dart';
import 'package:app/components/drawer_list.dart';
import 'package:app/components/middleware.dart';
import 'package:app/components/text_field_container.dart';
import 'package:app/mixins/format_price.dart';
import 'package:app/models/bill.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app/models/user.dart';
import 'package:app/providers/user_provider.dart';

class Bills extends StatefulWidget {
  const Bills({Key? key}) : super(key: key);

  @override
  _BillsState createState() => _BillsState();
}

class _BillsState extends State<Bills> {
  // TODO => Slice data table into a component
  var dts = DTS();
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  String _search = "";

  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<UserProvider>(context).user;

    if (user == null) {
      return Middleware();
    }

    return Scaffold(
      drawerScrimColor: Colors.transparent,
      drawer: Drawer(
        child: DrawerList(index: 3),
      ),
      appBar: CustomAppBar(),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.all(25),
                child: PaginatedDataTable(
                  header: Row(
                    children: [
                      Text('Računi'),
                      SizedBox(
                        width: 10
                      ),
                      Spacer(),
                      SizedBox(
                        width: 400,
                        child: TextFieldContainer(
                          child: TextFormField(
                            onSaved: (value) => _search = value!,
                            cursorColor: Colors.orange,
                            decoration: InputDecoration(
                              hintText: "Pretražite račune",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.orange, width: 2),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.orange,
                                ),
                              ),
                            )
                          ),
                        )
                      ]
                    ),
                  columns: [
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
                )
              )
            )
          )
        ]
      ),
    );
  }
}

class DTS extends DataTableSource with FormatPrice {
  // TODO => Fetch data.
  final List<Bill> bills = Bill.getData();

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= bills.length) return null;
    final bill = bills[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(
          Text('${bill.number}')
        ),
        DataCell(
          Text('${formatPrice(bill.gross)}')
        ),
        DataCell(
          Text('${bill.paymentMethod}')
        ),
        DataCell(
          Text('${bill.billedAt}')
        ),
        DataCell(
          Row(
            children: <Widget>[
              Spacer(),
              SizedBox(
                width: 30.0,
                height: 30.0,
                child: Tooltip(
                  message: 'Pregledaj račun ${bill.number}',
                  textStyle: TextStyle(color: Colors.black, fontSize: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    onPressed: () {
                      // TODO => Push to view
                    },
                    child: Icon(Icons.preview, size: 15.0),
                    backgroundColor: Colors.orange,
                    elevation: 3,
                    hoverElevation: 4,
                  )
                ),
              ),
              SizedBox(
                width: 5.0
              ),
              SizedBox(
                width: 30.0,
                height: 30.0,
                child: Tooltip(
                  message: 'Storniraj račun ${bill.number}',
                  textStyle: TextStyle(color: Colors.black, fontSize: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    onPressed: () {
                      // TODO => Modal to delete
                    },
                    child: Icon(Icons.restore, size: 15.0),
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
  int get rowCount => bills.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}