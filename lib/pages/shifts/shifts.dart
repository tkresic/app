import 'package:app/components/custom_app_bar.dart';
import 'package:app/components/drawer_list.dart';
import 'package:app/components/middleware.dart';
import 'package:app/components/text_field_container.dart';
import 'package:app/mixins/format_price.dart';
import 'package:app/models/shift.dart';
import 'package:app/models/user.dart';
import 'package:app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Shifts extends StatefulWidget {
  const Shifts({Key? key}) : super(key: key);

  @override
  _ShiftsState createState() => _ShiftsState();
}

class _ShiftsState extends State<Shifts> {
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
        child: DrawerList(index: 5),
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
                      Text('Smjene'),
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
                              hintText: "Pretražite smjene",
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
                      label: Text('Početak'),
                    ),
                    DataColumn(
                      label: Text('Kraj'),
                    ),
                    DataColumn(
                      label: Text('Korisnik'),
                    ),
                    DataColumn(
                      label: Text('Prihod'),
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
  final List<Shift> shifts = Shift.getData();

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= shifts.length) return null;
    final shift = shifts[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(
          Text('${shift.start}')
        ),
        DataCell(
          Text('${shift.end}')
        ),
        DataCell(
          Text('${shift.user}')
        ),
        DataCell(
          Text('${formatPrice(shift.income)}')
        ),
      ],
    );
  }

  @override
  int get rowCount => shifts.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}