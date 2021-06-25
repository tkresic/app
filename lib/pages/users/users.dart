import 'dart:convert';
import 'dart:io';
import 'package:app/components/custom_app_bar.dart';
import 'package:app/components/drawer_list.dart';
import 'package:app/components/loader.dart';
import 'package:app/components/middleware.dart';
import 'package:app/mixins/delete_dialog.dart';
import 'package:app/mixins/snackbar.dart';
import 'package:app/models/role.dart';
import 'package:app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/user_provider.dart';
import 'package:http_interceptor/http/intercepted_client.dart';
import 'package:app/util/http_interceptor.dart';
import 'package:http/http.dart' as http;

class Users extends StatefulWidget {
  const Users({Key? key}) : super(key: key);

  @override
  _UsersState createState() => _UsersState();
}

class _UsersState extends State<Users> with DeleteDialog, CustomSnackBar {

  http.Client client = InterceptedClient.build(interceptors: [
    ApiInterceptor(),
  ]);
  final _formKey = GlobalKey<FormState>();
  User userCreate = User(id: null, roleId: null, role: null, email: '', surname: '', username: '', name: '');
  List<dynamic>? roles;

  Future<Map<dynamic, dynamic>> fetchData() async {
    var users = await client.get(
        Uri.parse("${dotenv.env['ACCOUNTS_API_URI']}/api/users"),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
    );
    String source = const Utf8Decoder().convert(users.bodyBytes);
    var rls = await client.get(Uri.parse("${dotenv.env['ACCOUNTS_API_URI']}/api/roles"));

    roles = Role.parseRoles(rls.body);

    return {
      "users" : User.parseUsers(source),
      "roles" : roles
    };
  }

  void createUser(User user) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    Role findRole(int? id) => roles!.firstWhere((role) => role.id == id);
    Role role = findRole(user.roleId);

    http.Response response = await client.post(
      Uri.parse("${dotenv.env['ACCOUNTS_API_URI']}/api/users"),
      body: json.encode({
        "username" : user.username,
        "name" : user.name,
        "surname" : user.surname,
        "email" : user.email,
        "role" : role,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Uspješno dodan novi korisnik", Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Došlo je do greške. Korisničko ime je vjerojatno već zauzeto", Colors.red));
    }

    setState(() {});
  }

  void updateUser(User user) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    Role findRole(int? id) => roles!.firstWhere((role) => role.id == id);
    Role role = findRole(user.roleId);

    http.Response response = await client.put(
      Uri.parse("${dotenv.env['ACCOUNTS_API_URI']}/api/users/${user.id}"),
      body: json.encode({
        "username" : user.username,
        "name" : user.name,
        "surname" : user.surname,
        "email" : user.email,
        "role" : role,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Uspješno ažuriran korisnik", Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Došlo je do greške", Colors.red));
    }

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
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 20.0),
                                child: Text('Korisnici', style: TextStyle(color: Colors.black, fontSize: 20))
                              ),
                              const SizedBox(width: 10),
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
                                      userCreate.roleId = null;
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Dodaj novog korisnika'),
                                            content: Form(
                                              key: _formKey,
                                              child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    Row(
                                                      children: [
                                                        Container(
                                                          width: 250,
                                                          child: DropdownButtonFormField(
                                                            value: userCreate.roleId,
                                                            decoration: InputDecoration(
                                                              border: OutlineInputBorder(
                                                                borderSide: const BorderSide(color: Colors.orange, width: 2.0),
                                                                borderRadius: BorderRadius.circular(25.0),
                                                              ),
                                                              focusedBorder: OutlineInputBorder(
                                                                borderSide: const BorderSide(color: Colors.orange, width: 2.0),
                                                                borderRadius: BorderRadius.circular(25.0),
                                                              ),
                                                            ),
                                                            focusColor: Colors.transparent,
                                                            hint: const Text('Odaberite ulogu'),
                                                            isExpanded: true,
                                                            onChanged: (value) {
                                                              userCreate.roleId = int.parse(value.toString());
                                                            },
                                                            validator: (value) {
                                                              if (value == null) {
                                                                return 'Molimo odaberite ulogu';
                                                              }
                                                              return null;
                                                            },
                                                            items: roles!.map((role){
                                                              return DropdownMenuItem(
                                                                value: role.id.toString(),
                                                                child: Text(role.name)
                                                              );
                                                            }).toList(),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 25),
                                                        Container(
                                                          width: 250,
                                                          child: TextFormField(
                                                            validator: (value) {
                                                              if (value == null || value.isEmpty) {
                                                                return 'Molimo unesite korisničko ime';
                                                              }
                                                              return null;
                                                            },
                                                            onSaved: (value) => userCreate.username = value!,
                                                            cursorColor: Colors.orange,
                                                            decoration: InputDecoration(
                                                              hintText: "Korisničko ime",
                                                              border: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(25),
                                                              ),
                                                              focusedBorder: OutlineInputBorder(
                                                                borderSide: const BorderSide(color: Colors.orange, width: 2),
                                                                borderRadius: BorderRadius.circular(25),
                                                              ),
                                                              prefixIcon: const Icon(
                                                                Icons.person,
                                                                color: Colors.orange,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ]
                                                    ),
                                                    const SizedBox(height: 20),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          width: 250,
                                                          child: TextFormField(
                                                            validator: (value) {
                                                              if (value == null || value.isEmpty) {
                                                                return 'Molimo unesite ime korisnika';
                                                              }
                                                              return null;
                                                            },
                                                            onSaved: (value) => userCreate.name = value!,
                                                            cursorColor: Colors.orange,
                                                            decoration: InputDecoration(
                                                              hintText: "Ime korisnika",
                                                              border: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(25),
                                                              ),
                                                              focusedBorder: OutlineInputBorder(
                                                                borderSide: const BorderSide(color: Colors.orange, width: 2),
                                                                borderRadius: BorderRadius.circular(25),
                                                              ),
                                                              prefixIcon: const Icon(
                                                                Icons.short_text,
                                                                color: Colors.orange,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 25),
                                                        Container(
                                                          width: 250,
                                                          child: TextFormField(
                                                            validator: (value) {
                                                              if (value == null || value.isEmpty) {
                                                                return 'Molimo unesite prezime korisnika';
                                                              }
                                                              return null;
                                                            },
                                                            onSaved: (value) => userCreate.surname = value!,
                                                            cursorColor: Colors.orange,
                                                            decoration: InputDecoration(
                                                              hintText: "Prezime korisnika",
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
                                                        )
                                                      ]
                                                    ),
                                                    const SizedBox(height: 20),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          width: 528,
                                                          child: TextFormField(
                                                            validator: (value) {
                                                              if (value == null || value.isEmpty) {
                                                                return 'Molimo unesite email korisnika';
                                                              }
                                                              return null;
                                                            },
                                                            onSaved: (value) => userCreate.email = value!,
                                                            cursorColor: Colors.orange,
                                                            decoration: InputDecoration(
                                                              hintText: "Email korisnika",
                                                              border: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(25),
                                                              ),
                                                              focusedBorder: OutlineInputBorder(
                                                                borderSide: const BorderSide(color: Colors.orange, width: 2),
                                                                borderRadius: BorderRadius.circular(25),
                                                              ),
                                                              prefixIcon: const Icon(
                                                                Icons.email,
                                                                color: Colors.orange,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ]
                                                    ),
                                                    const SizedBox(height: 20),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [
                                                        Container(
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.circular(40),
                                                            child: TextButton(
                                                              onPressed: () {
                                                                if (_formKey.currentState!.validate()) {
                                                                  _formKey.currentState!.save();
                                                                  createUser(userCreate);
                                                                  Navigator.of(context).pop();
                                                                }
                                                              },
                                                              child: const Text('Dodaj'),
                                                              style: TextButton.styleFrom(
                                                                padding: const EdgeInsets.fromLTRB(100, 20, 100, 20),
                                                                primary: Colors.white,
                                                                backgroundColor: Colors.orange,
                                                                textStyle: const TextStyle(fontSize: 18),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      ]
                                                    )
                                                  ]
                                              ),
                                            ),
                                          );
                                        });
                                    },
                                    child: const Text('+'),
                                    backgroundColor: Colors.orange,
                                    elevation: 3,
                                    hoverElevation: 4,
                                  )
                                )
                              ),
                            ]
                          ),
                          const SizedBox(height: 15),
                          Row(
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
                                          DataCell(Text(user.role!.name)),
                                          DataCell(
                                            Row(
                                              children: <Widget>[
                                                const Spacer(),
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
                                                        showDialog(
                                                            context: context,
                                                            builder: (BuildContext context) {
                                                              return AlertDialog(
                                                                title: const Text('Uredi korisnika'),
                                                                content: Form(
                                                                  key: _formKey,
                                                                  child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: <Widget>[
                                                                      Row(
                                                                        children: [
                                                                          Container(
                                                                            width: 250,
                                                                            child: DropdownButtonFormField(
                                                                              value: user.roleId.toString(),
                                                                              decoration: InputDecoration(
                                                                                border: OutlineInputBorder(
                                                                                  borderSide: const BorderSide(color: Colors.orange, width: 2.0),
                                                                                  borderRadius: BorderRadius.circular(25.0),
                                                                                ),
                                                                                focusedBorder: OutlineInputBorder(
                                                                                  borderSide: const BorderSide(color: Colors.orange, width: 2.0),
                                                                                  borderRadius: BorderRadius.circular(25.0),
                                                                                ),
                                                                              ),
                                                                              focusColor: Colors.transparent,
                                                                              hint: const Text('Odaberite ulogu'),
                                                                              isExpanded: true,
                                                                              onChanged: (value) {
                                                                                user.roleId = int.parse(value.toString());
                                                                              },
                                                                              validator: (value) {
                                                                                if (value == null) {
                                                                                  return 'Molimo odaberite ulogu';
                                                                                }
                                                                                return null;
                                                                              },
                                                                              items: roles!.map((role){
                                                                                return DropdownMenuItem(
                                                                                  value: role.id.toString(),
                                                                                  child: Text(role.name)
                                                                                );
                                                                              }).toList(),
                                                                            ),
                                                                          ),
                                                                          const SizedBox(width: 25),
                                                                          Container(
                                                                            width: 250,
                                                                            child: TextFormField(
                                                                              validator: (value) {
                                                                                if (value == null || value.isEmpty) {
                                                                                  return 'Molimo unesite korisničko ime';
                                                                                }
                                                                                return null;
                                                                              },
                                                                              onSaved: (value) => user.username = value!,
                                                                              initialValue: user.username,
                                                                              cursorColor: Colors.orange,
                                                                              decoration: InputDecoration(
                                                                                hintText: "Korisničko ime",
                                                                                border: OutlineInputBorder(
                                                                                  borderRadius: BorderRadius.circular(25),
                                                                                ),
                                                                                focusedBorder: OutlineInputBorder(
                                                                                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                                                                                  borderRadius: BorderRadius.circular(25),
                                                                                ),
                                                                                prefixIcon: const Icon(
                                                                                  Icons.person,
                                                                                  color: Colors.orange,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ]
                                                                      ),
                                                                      const SizedBox(height: 20),
                                                                      Row(
                                                                        children: [
                                                                          Container(
                                                                            width: 250,
                                                                            child: TextFormField(
                                                                              validator: (value) {
                                                                                if (value == null || value.isEmpty) {
                                                                                  return 'Molimo unesite ime korisnika';
                                                                                }
                                                                                return null;
                                                                              },
                                                                              onSaved: (value) => user.name = value!,
                                                                              initialValue: user.name,
                                                                              cursorColor: Colors.orange,
                                                                              decoration: InputDecoration(
                                                                                hintText: "Ime korisnika",
                                                                                border: OutlineInputBorder(
                                                                                  borderRadius: BorderRadius.circular(25),
                                                                                ),
                                                                                focusedBorder: OutlineInputBorder(
                                                                                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                                                                                  borderRadius: BorderRadius.circular(25),
                                                                                ),
                                                                                prefixIcon: const Icon(
                                                                                  Icons.short_text,
                                                                                  color: Colors.orange,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const SizedBox(width: 25),
                                                                          Container(
                                                                            width: 250,
                                                                            child: TextFormField(
                                                                              validator: (value) {
                                                                                if (value == null || value.isEmpty) {
                                                                                  return 'Molimo unesite prezime korisnika';
                                                                                }
                                                                                return null;
                                                                              },
                                                                              onSaved: (value) => user.surname = value!,
                                                                              initialValue: user.surname,
                                                                              cursorColor: Colors.orange,
                                                                              decoration: InputDecoration(
                                                                                hintText: "Prezime korisnika",
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
                                                                        ]
                                                                      ),
                                                                      const SizedBox(height: 20),
                                                                      Row(
                                                                        children: [
                                                                          Container(
                                                                            width: 528,
                                                                            child: TextFormField(
                                                                              validator: (value) {
                                                                                if (value == null || value.isEmpty) {
                                                                                  return 'Molimo unesite email korisnika';
                                                                                }
                                                                                return null;
                                                                              },
                                                                              onSaved: (value) => user.email = value!,
                                                                              initialValue: user.email,
                                                                              cursorColor: Colors.orange,
                                                                              decoration: InputDecoration(
                                                                                hintText: "Email korisnika",
                                                                                border: OutlineInputBorder(
                                                                                  borderRadius: BorderRadius.circular(25),
                                                                                ),
                                                                                focusedBorder: OutlineInputBorder(
                                                                                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                                                                                  borderRadius: BorderRadius.circular(25),
                                                                                ),
                                                                                prefixIcon: const Icon(
                                                                                  Icons.email,
                                                                                  color: Colors.orange,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ]
                                                                      ),
                                                                      const SizedBox(height: 20),
                                                                      Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                        children: [
                                                                          Container(
                                                                            child: ClipRRect(
                                                                              borderRadius: BorderRadius.circular(40),
                                                                              child: TextButton(
                                                                                onPressed: () {
                                                                                  if (_formKey.currentState!.validate()) {
                                                                                    _formKey.currentState!.save();
                                                                                    updateUser(user);
                                                                                    Navigator.of(context).pop();
                                                                                  }
                                                                                },
                                                                                child: const Text('Spremi'),
                                                                                style: TextButton.styleFrom(
                                                                                  padding: const EdgeInsets.fromLTRB(95, 20, 95, 20),
                                                                                  primary: Colors.white,
                                                                                  backgroundColor: Colors.orange,
                                                                                  textStyle: const TextStyle(fontSize: 18),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ]
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                        );
                                                      },
                                                      child: const Icon(Icons.edit, size: 15.0),
                                                      backgroundColor: Colors.blue,
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
                            ],
                          ),
                          const SizedBox(height: 30),
                          Row(
                            children: const [
                               Padding(
                                padding: EdgeInsets.only(left: 20.0),
                                child: Text('Uloge', style: TextStyle(color: Colors.black, fontSize: 20))
                              ),
                            ]
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: DataTable(
                                  columns: const [
                                    DataColumn(
                                      label: Text('Ime'),
                                    ),
                                  ],
                                  rows: [
                                    for (Role role in snapshot.data!['roles'])
                                      DataRow(
                                        cells: [
                                          DataCell(Text(role.name)),
                                        ],
                                      ),
                                  ]
                                )
                              ),
                            ],
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