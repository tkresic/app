import 'dart:convert';
import 'dart:io';

import 'package:app/components/custom_app_bar.dart';
import 'package:app/components/drawer_list.dart';
import 'package:app/components/middleware.dart';
import 'package:app/mixins/current_date_time_string.dart';
import 'package:app/mixins/format_price.dart';
import 'package:app/mixins/snackbar.dart';
import 'package:app/models/shift.dart';
import 'package:app/models/user.dart';
import 'package:app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class Shifts extends StatefulWidget {
  const Shifts({Key? key}) : super(key: key);

  @override
  _ShiftsState createState() => _ShiftsState();
}

class _ShiftsState extends State<Shifts> {

  Future<List<Shift>> fetchShifts() async {
    var response = await http.get(Uri.parse("${dotenv.env['FINANCE_API_URI']}/api/shifts"));
    return Shift.parseShifts(response.body);
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
        child: DrawerList(index: 4),
      ),
      appBar: const CustomAppBar(),
      body: Row(
        children: <Widget>[
          Expanded(
            child: FutureBuilder<List<Shift>>(
              future: fetchShifts(),
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
                      child: ShiftsList(context: context, callback: callback, shifts: snapshot.data, user: user)
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

class ShiftsList extends StatefulWidget {
  const ShiftsList({
    Key? key,
    required this.context,
    required this.callback,
    this.shifts,
    required this.user,
  }) : super(key: key);

  final BuildContext context;
  final Function callback;
  final List<dynamic>? shifts;
  final User user;

  @override
  _ShiftsListState createState() => _ShiftsListState(context: context, callback: callback, shifts: shifts, user: user);
}

class _ShiftsListState extends State<ShiftsList> with CustomSnackBar, CurrentDateTimeString {
  _ShiftsListState({
    required this.context,
    required this.callback,
    required this.shifts,
    required this.user,
  });

  @override
  final BuildContext context;
  Function callback;
  List<dynamic>? shifts;
  User user;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  void startShift() async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final userData = {
      "id" : user.id,
      "username" : user.username,
      "name" : user.name,
    };

    // TODO => Append token for authentication/authorization check.
    http.Response response = await http.post(
      Uri.parse("${dotenv.env['FINANCE_API_URI']}/api/shifts"),
      body: json.encode({
        "user" : userData,
        "start" : getCurrentDateTimeString(),
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Uspješno započeta nova smjena", Colors.green));
    } else if (response.statusCode == 422) {
      Map<String, dynamic> data = jsonDecode(response.body);

      String errors = "";

      data.forEach((k,v) => {
        for (final e in data[k]) {
          errors += e
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Došlo je do validacijske greške: $errors", Colors.deepOrange));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Došlo je do greške", Colors.red));
    }

    callback();
  }

  Future <Widget> fetchLatestShift() async {
    var response = await http.get(Uri.parse("${dotenv.env['FINANCE_API_URI']}/api/shifts/latest"));
    if (response.body != "false") {
      Shift shift = Shift.fromJson(jsonDecode(response.body).cast<String,dynamic>());
      return Text("Smjena započeta u ${shift.start}", style: const TextStyle(fontSize: 14));
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: TextButton(
          onPressed: () {
            startShift();
          },
          child: const Text('Započni smjenu'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
            primary: Colors.white,
            backgroundColor: Colors.orange,
            textStyle: const TextStyle(fontSize: 14),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    shifts = widget.shifts;
    var dts = DTS(context: context, callback: callback, user: user, shifts: shifts);

    return PaginatedDataTable(
        header: Row(
          children: [
            const Text('Smjene'),
            const Spacer(),
            FutureBuilder <dynamic> (
                future: fetchLatestShift(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    if (snapshot.error.runtimeType == SocketException) {
                      return const Center(child: Text("Došlo je do greške. Mikroservis vjerojatno nije u funkciji."));
                    } else {
                      return const Center(child: Text("Došlo je do greške."));
                    }
                  }
                  if (snapshot.hasData) {
                    return snapshot.data;
                  } else {
                    return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.orange)));
                  }
                }
            )
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
            label: Text('Zaposlenik'),
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

class DTS extends DataTableSource with FormatPrice, CustomSnackBar, CurrentDateTimeString {
  DTS({
    required this.context,
    required this.callback,
    required this.user,
    required this.shifts
  });

  final BuildContext context;
  final Function callback;
  final User user;
  final List<dynamic>? shifts;

  void endShift(int shiftId) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final userData = {
      "id" : user.id,
      "username" : user.username,
      "name" : user.name,
    };

    // TODO => Append token for authentication/authorization check.
    http.Response response = await http.put(
      Uri.parse("${dotenv.env['FINANCE_API_URI']}/api/shifts/$shiftId"),
      body: json.encode({
        "user" : userData,
        "end" : getCurrentDateTimeString(),
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Uspješno završena smjena", Colors.green));
    } else if (response.statusCode == 422) {
      Map<String, dynamic> data = jsonDecode(response.body);

      String errors = "";

      data.forEach((k,v) => {
        for (final e in data[k]) {
          errors += e
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Došlo je do validacijske greške: $errors", Colors.deepOrange));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Došlo je do greške", Colors.red));
    }

    callback();
  }

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
          shift.end == '/' ?
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: TextButton(
              onPressed: () {
                endShift(shift.id);
              },
              child: const Text('Završi smjenu'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                primary: Colors.white,
                backgroundColor: Colors.orange,
                textStyle: const TextStyle(fontSize: 14),
              ),
            ),
          )
          :
          Text('${shift.end}')
        ),
        DataCell(
          Text(shift.user.name)
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