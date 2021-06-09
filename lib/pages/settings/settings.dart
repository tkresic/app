import 'dart:convert';

import 'package:app/components/custom_app_bar.dart';
import 'package:app/components/drawer_list.dart';
import 'package:app/components/middleware.dart';
import 'package:app/models/company.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:app/models/user.dart';
import 'package:app/providers/user_provider.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  Future<Company> fetchCompany() async {
    var response = await http.get(Uri.parse("http://localhost:8080/api/company"));
    return Company.fromJson(jsonDecode(response.body));
  }

  final _formKey = GlobalKey<FormState>();
  bool enabled = false;

  _showDialog(BuildContext context) {
    // TODO => Save settings. Slice snackbar
    final snackBar = SnackBar(
      width: 300.0,
      behavior: SnackBarBehavior.floating,
      content: Text("Spremam postavke..."),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<UserProvider>(context).user;

    if (user == null) {
      return Middleware();
    }

    return Scaffold(
      drawerScrimColor: Colors.transparent,
      drawer: Drawer(
        child: DrawerList(index: 6),
      ),
      appBar: CustomAppBar(),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.all(25),
                padding: EdgeInsets.all(25),
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "Postavke",
                          style: TextStyle(fontSize: 20),
                        ),
                      ]
                    ),
                    SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: FutureBuilder<Company>(
                        future: fetchCompany(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            print(snapshot.error);
                            return Center(child: Text("Došlo je do greške."));
                          }
                          if (snapshot.hasData) {
                            return SingleChildScrollView(
                              child: Container(
                                margin: EdgeInsets.all(25),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.15,
                                          child: Text('Ime tvrtke'),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.7,
                                          child: TextFormField(
                                            enabled: enabled,
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Molimo unesite ime tvrtke';
                                              }
                                              return null;
                                            },
                                            onSaved: (value) => snapshot.data!.name = value!,
                                            initialValue: snapshot.data!.name,
                                            cursorColor: Colors.orange,
                                            decoration: InputDecoration(
                                              hintText: "Unesite ime tvrtke",
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.orange, width: 2),
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                              prefixIcon: Icon(
                                                Icons.person,
                                                color: Colors.orange,
                                              ),
                                            ),
                                          ),
                                        )
                                      ]
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.15,
                                            child: Text('OIB tvrtke'),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.7,
                                            child: TextFormField(
                                              enabled: enabled,
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Molimo unesite OIB tvrtke';
                                                }
                                                return null;
                                              },
                                              onSaved: (value) => snapshot.data!.pidn = value!,
                                              initialValue: snapshot.data!.pidn,
                                              cursorColor: Colors.orange,
                                              decoration: InputDecoration(
                                                hintText: "Unesite OIB tvrtke",
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(25),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.orange, width: 2),
                                                  borderRadius: BorderRadius.circular(25),
                                                ),
                                                prefixIcon: Icon(
                                                  Icons.person,
                                                  color: Colors.orange,
                                                ),
                                              ),
                                            ),
                                          )
                                        ]
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.15,
                                            child: Text('Ulica objekta'),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.7,
                                            child: TextFormField(
                                              enabled: enabled,
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Molimo unesite ulicu objekta';
                                                }
                                                return null;
                                              },
                                              onSaved: (value) => snapshot.data!.street = value!,
                                              initialValue: snapshot.data!.street,
                                              cursorColor: Colors.orange,
                                              decoration: InputDecoration(
                                                hintText: "Unesite ulicu objekta",
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(25),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.orange, width: 2),
                                                  borderRadius: BorderRadius.circular(25),
                                                ),
                                                prefixIcon: Icon(
                                                  Icons.person,
                                                  color: Colors.orange,
                                                ),
                                              ),
                                            ),
                                          )
                                        ]
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.15,
                                            child: Text('Poštanski broj objekta'),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.7,
                                            child: TextFormField(
                                              enabled: enabled,
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Molimo unesite poštanski broj objekta';
                                                }
                                                return null;
                                              },
                                              onSaved: (value) => snapshot.data!.postalCode = value!,
                                              initialValue: snapshot.data!.postalCode,
                                              cursorColor: Colors.orange,
                                              decoration: InputDecoration(
                                                hintText: "Unesite poštanski broj objekta",
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(25),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.orange, width: 2),
                                                  borderRadius: BorderRadius.circular(25),
                                                ),
                                                prefixIcon: Icon(
                                                  Icons.person,
                                                  color: Colors.orange,
                                                ),
                                              ),
                                            ),
                                          )
                                        ]
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.15,
                                            child: Text('Broj objekta'),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.7,
                                            child: TextFormField(
                                              enabled: enabled,
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Molimo unesite broj objekta';
                                                }
                                                return null;
                                              },
                                              onSaved: (value) => snapshot.data!.number = value!,
                                              initialValue: snapshot.data!.number,
                                              cursorColor: Colors.orange,
                                              decoration: InputDecoration(
                                                hintText: "Unesite broj objekta",
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(25),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.orange, width: 2),
                                                  borderRadius: BorderRadius.circular(25),
                                                ),
                                                prefixIcon: Icon(
                                                  Icons.person,
                                                  color: Colors.orange,
                                                ),
                                              ),
                                            ),
                                          )
                                        ]
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.15,
                                            child: Text('Grad objekta'),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.7,
                                            child: TextFormField(
                                              enabled: enabled,
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Molimo unesite grad objekta';
                                                }
                                                return null;
                                              },
                                              onSaved: (value) => snapshot.data!.city = value!,
                                              initialValue: snapshot.data!.city,
                                              cursorColor: Colors.orange,
                                              decoration: InputDecoration(
                                                hintText: "Unesite ime grad objekta",
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(25),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.orange, width: 2),
                                                  borderRadius: BorderRadius.circular(25),
                                                ),
                                                prefixIcon: Icon(
                                                  Icons.person,
                                                  color: Colors.orange,
                                                ),
                                              ),
                                            ),
                                          )
                                        ]
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.15,
                                            child: Text('Telefonski broj objekta'),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.7,
                                            child: TextFormField(
                                              enabled: enabled,
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Molimo unesite telefonski broj objekta';
                                                }
                                                return null;
                                              },
                                              onSaved: (value) => snapshot.data!.phone = value!,
                                              initialValue: snapshot.data!.phone,
                                              cursorColor: Colors.orange,
                                              decoration: InputDecoration(
                                                hintText: "Unesite telefonski broj objekta",
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(25),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.orange, width: 2),
                                                  borderRadius: BorderRadius.circular(25),
                                                ),
                                                prefixIcon: Icon(
                                                  Icons.person,
                                                  color: Colors.orange,
                                                ),
                                              ),
                                            ),
                                          )
                                        ]
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        enabled ? ClipRRect(
                                          borderRadius: BorderRadius.circular(40),
                                          child: TextButton(
                                            onPressed: () {
                                              setState(() {
                                                enabled = false;
                                                _formKey.currentState!.reset();
                                              });
                                            },
                                            child: Text(
                                              'Odustani',
                                            ),
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.fromLTRB(80, 20, 80, 20),
                                              primary: Colors.white,
                                              backgroundColor: Colors.grey,
                                              textStyle: TextStyle(fontSize: 18),
                                            ),
                                          ),
                                        ) : Text(''),
                                        SizedBox(width: 50), // give it width
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(40),
                                          child: TextButton(
                                            onPressed: () {
                                              if (!enabled) {
                                                setState(() {
                                                  enabled = true;
                                                });
                                              } else {
                                                // TODO => Send API and save
                                                setState(() {
                                                  enabled = false;
                                                });
                                              }
                                            },
                                            child: Text(enabled ? 'Spremi' : 'Uredi'),
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.fromLTRB(80, 20, 80, 20),
                                              primary: Colors.white,
                                              backgroundColor: Colors.orange,
                                              textStyle: TextStyle(fontSize: 18),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            );
                          } else {
                            return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.orange)));
                          }
                        },
                      )
                    ),
                  ]
                )
              )
            )
          )
        ]
      ),
    );
  }
}