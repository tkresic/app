import 'dart:convert';
import 'dart:io';
import 'package:app/components/custom_app_bar.dart';
import 'package:app/components/drawer_list.dart';
import 'package:app/components/loader.dart';
import 'package:app/components/middleware.dart';
import 'package:app/mixins/delete_dialog.dart';
import 'package:app/models/role.dart';
import 'package:app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/user_provider.dart';
import 'package:http/http.dart' as http;

class Users extends StatefulWidget {
  const Users({Key? key}) : super(key: key);

  @override
  _UsersState createState() => _UsersState();
}

class _UsersState extends State<Users> with DeleteDialog {

  Future<Map<dynamic, dynamic>> fetchData() async {
    var users = await http.get(
        Uri.parse("${dotenv.env['ACCOUNTS_API_URI']}/api/users"),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
    );
    String source = const Utf8Decoder().convert(users.bodyBytes);
    var roles = await http.get(Uri.parse("${dotenv.env['ACCOUNTS_API_URI']}/api/roles"));
    return {
      "users" : User.parseUsers(source),
      "roles" : Role.parseRoles(roles.body)
    };
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
        children: <Widget>[
          Expanded(
            child: FutureBuilder<Map<dynamic, dynamic>>(
              future: fetchData(),
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
                      padding: const EdgeInsets.all(25),
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
                      child: Row(
                        children: [
                          Expanded(
                            child: DataTable(
                              columns: const [
                                DataColumn(
                                  label: Text('Ime'),
                                ),
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
                                )
                              ],
                              rows: [
                                for (User user in snapshot.data!['users'])
                                  DataRow(
                                    cells: [
                                      DataCell(Text("${user.name} ${user.surname}")),
                                      DataCell(Text(user.username)),
                                      DataCell(Text(user.role.name)),
                                      DataCell(
                                        Row(
                                          children: <Widget>[
                                            const Spacer(),
                                            SizedBox(
                                              width: 30.0,
                                              height: 30.0,
                                              child: Tooltip(
                                                  message: 'Pregledaj korisnika ${user.name} ${user.surname}',
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
                                                message: 'Uredi korisnika ${user.name} ${user.surname}',
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
                                                message: 'Obriši korisnika ${user.name} ${user.surname}',
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
                                                        "Obriši korisnika ${user.name} ${user.surname}",
                                                        "Jeste li sigurni da želite obrisati korisnika ${user.name} ${user.surname}?",
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
                                  ),
                              ]
                            )
                          ),
                        ]
                      )
                    )
                  );
                } else {
                  return const Loader(message: "Dohvaćam korisnike...");
                }
              },
            )
          )
        ]
      ),
    );
  }
}