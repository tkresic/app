import 'package:app/components/custom_app_bar.dart';
import 'package:app/components/drawer_list.dart';
import 'package:app/components/middleware.dart';
import 'package:app/mixins/delete_dialog.dart';
import 'package:app/mixins/format_price.dart';
import 'package:app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'package:app/providers/user_provider.dart';

class Users extends StatefulWidget {
  const Users({Key? key}) : super(key: key);

  @override
  _UsersState createState() => _UsersState();
}

class _UsersState extends State<Users> {

  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  @override
  Widget build(BuildContext context) {
    var dts = DTS(context: context);

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
                child: PaginatedDataTable(
                  header: Row(
                    children: [
                      const Text('Korisnici'),
                      const SizedBox(
                          width: 10
                      ),
                      SizedBox(
                          width: 30,
                          child: Tooltip(
                              message: 'Dodaj novog korisnika',
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
                                  // TODO => Create new user
                                },
                                child: const Text('+'),
                                backgroundColor: Colors.orange,
                                elevation: 3,
                                hoverElevation: 4,
                              )
                          )
                      ),
                      const Spacer(),
                    ]
                  ),
                  columns: const [
                    DataColumn(
                      label: Text('Korisničko ime'),
                    ),
                    DataColumn(
                      label: Text('Uloga'),
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

class DTS extends DataTableSource with FormatPrice, DeleteDialog {
  DTS({
    required this.context,
  });

  // TODO => Fetch data.
  final List<User> users = [];
  final BuildContext context;

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= users.length) return null;
    final user = users[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(
            Text(user.username)
        ),
        DataCell(
            Text('${user.type}')
        ),
        DataCell(
          Row(
            children: <Widget>[
              const Spacer(),
              SizedBox(
                width: 30.0,
                height: 30.0,
                child: Tooltip(
                  message: 'Pregledaj korisnika ${user.name}',
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
                  message: 'Uredi korisnika ${user.name}',
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
                      // TODO => Push to edit
                    },
                    child: const Icon(Icons.edit, size: 15.0),
                    backgroundColor: Colors.blue,
                    elevation: 3,
                    hoverElevation: 4,
                  ),
                ),
              ),
              const SizedBox(
                width: 5.0
              ),
              SizedBox(
                width: 30.0,
                height: 30.0,
                child: Tooltip(
                  message: 'Obriši korisnika ${user.name}',
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
                      deleteDialog(
                          context,
                          "Obriši korisnika ${user.name}",
                          "Jeste li sigurni da želite obrisati korisnika ${user.name}?",
                          "${dotenv.env['ACCOUNTS_API_URI']}/api/users/${user.id}",
                          "Uspješno izbrisan korisnik"
                      );
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
  int get rowCount => users.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}