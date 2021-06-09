import 'package:app/components/custom_app_bar.dart';
import 'package:app/components/drawer_list.dart';
import 'package:app/components/middleware.dart';
import 'package:app/mixins/format_price.dart';
import 'package:app/models/shift.dart';
import 'package:app/models/user.dart';
import 'package:app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class Shifts extends StatefulWidget {
  const Shifts({Key? key}) : super(key: key);

  @override
  _ShiftsState createState() => _ShiftsState();
}

class _ShiftsState extends State<Shifts> {
  // TODO => Slice data table into a component

  Future<List<Shift>> fetchShifts() async {
    var response = await http.get(Uri.parse("http://localhost:8002/api/shifts"));
    return Shift.parseShifts(response.body);
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
        child: DrawerList(index: 5),
      ),
      appBar: const CustomAppBar(),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(25),
                child: FutureBuilder<List<Shift>>(
                  future: fetchShifts(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print(snapshot);
                      return const Center(child: Text("Došlo je do greške."));
                    }
                    if (snapshot.hasData) {
                      return ShiftsList(context: context, shifts: snapshot.data);
                    } else {
                      return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.orange)));
                    }
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

class ShiftsList extends StatefulWidget {
  const ShiftsList({
    Key? key,
    required this.context,
    this.shifts
  }) : super(key: key);

  final BuildContext context;
  final List<dynamic>? shifts;

  @override
  _ShiftsListState createState() => _ShiftsListState(context: this.context, shifts: this.shifts);
}

class _ShiftsListState extends State<ShiftsList> {
  _ShiftsListState({
    required this.context,
    required this.shifts
  });

  @override
  final BuildContext context;
  List<dynamic>? shifts;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  @override
  Widget build(BuildContext context) {
    shifts = widget.shifts;
    var dts = DTS(context: context, shifts: shifts);
    return PaginatedDataTable(
        header: Row(
            children: const [
              Text('Smjene'),
              SizedBox(
                  width: 10
              ),
            ]
        ),
        columns: const [
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
    );
  }
}

class DTS extends DataTableSource with FormatPrice {
  DTS({
    required this.context,
    required this.shifts
  });

  final BuildContext context;
  final List<dynamic>? shifts;

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= shifts!.length) return null;
    final shift = shifts![index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(
          Text(shift.start)
        ),
        DataCell(
          Text('${shift.end}')
        ),
        DataCell(
          Text(shift.user.username)
        ),
        DataCell(
          Text(formatPrice(shift.gross))
        ),
      ],
    );
  }

  @override
  int get rowCount => shifts!.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}