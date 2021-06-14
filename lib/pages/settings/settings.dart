import 'dart:convert';
import 'dart:io';

import 'package:app/components/custom_app_bar.dart';
import 'package:app/components/drawer_list.dart';
import 'package:app/components/middleware.dart';
import 'package:app/mixins/snackbar.dart';
import 'package:app/models/company.dart';
import 'package:app/models/payment_method.dart';
import 'package:app/models/tax.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:app/models/user.dart';
import 'package:app/providers/user_provider.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> with CustomSnackBar {

  final companyFormKey = GlobalKey<FormState>();

  Future<Map<dynamic, dynamic>> fetchData() async {
    var company = await http.get(Uri.parse("${dotenv.env['CORPORATE_API_URI']}/api/company"));
    var paymentMethods = await http.get(Uri.parse("${dotenv.env['FINANCE_API_URI']}/api/payment-methods"));
    var taxes = await http.get(Uri.parse("${dotenv.env['FINANCE_API_URI']}/api/taxes"));

    return {
      "company" : Company.fromJson(jsonDecode(company.body)),
      "paymentMethods" : PaymentMethod.parsePaymentMethods(paymentMethods.body),
      "taxes" : Tax.parseTaxes(taxes.body),
    };
  }

  void updateCompany(Company company) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // TODO => Append token for authentication/authorization check.
    http.Response response = await http.put(
      Uri.parse("${dotenv.env['CORPORATE_API_URI']}/api/company/${company.id}"),
      body: json.encode({
        "name" : company.name,
        "pidn" : company.pidn,
        "street" : company.street,
        "number" : company.number,
        "postalCode" : company.postalCode,
        "city" : company.city,
        "phone" : company.phone,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Uspješno ažurirane postavke", Colors.green));
    } else {
      print(response.body);
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Došlo je do greške", Colors.red));
    }
  }

  void updatePaymentMethod(int paymentMethodId, bool active) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // TODO => Append token for authentication/authorization check.
    http.Response response = await http.put(
      Uri.parse("${dotenv.env['FINANCE_API_URI']}/api/payment-methods/$paymentMethodId"),
      body: json.encode({
        "active" : active,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Uspješno ažuriran način plaćanja", Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Došlo je do greške", Colors.red));
    }
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
        child: DrawerList(index: 6),
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
                        children: <Widget>[
                          Form(
                            key: companyFormKey,
                            child: Row(
                              children: [
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: const [
                                          Text("Postavke", style: TextStyle(fontSize: 20)),
                                        ]
                                      ),
                                      const SizedBox(height: 25),
                                      Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.15,
                                            child: const Text('Ime tvrtke'),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.7,
                                            child: TextFormField(
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Molimo unesite ime tvrtke';
                                                }
                                                return null;
                                              },
                                              onChanged: (value) => snapshot.data!['company'].name = value,
                                              initialValue: snapshot.data!['company'].name,
                                              cursorColor: Colors.orange,
                                              decoration: InputDecoration(
                                                hintText: "Unesite ime tvrtke",
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
                                          )
                                        ]
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.15,
                                            child: const Text('OIB tvrtke'),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.7,
                                            child: TextFormField(
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Molimo unesite OIB tvrtke';
                                                }
                                                return null;
                                              },
                                              onChanged: (value) => snapshot.data!['company'].pidn = value,
                                              initialValue: snapshot.data!['company'].pidn,
                                              cursorColor: Colors.orange,
                                              decoration: InputDecoration(
                                                hintText: "Unesite OIB tvrtke",
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
                                          )
                                        ]
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.15,
                                            child: const Text('Ulica objekta'),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.7,
                                            child: TextFormField(
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Molimo unesite ulicu objekta';
                                                }
                                                return null;
                                              },
                                              onChanged: (value) => snapshot.data!['company'].street = value,
                                              initialValue: snapshot.data!['company'].street,
                                              cursorColor: Colors.orange,
                                              decoration: InputDecoration(
                                                hintText: "Unesite ulicu objekta",
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
                                          )
                                        ]
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.15,
                                            child: const Text('Poštanski broj objekta'),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.7,
                                            child: TextFormField(
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Molimo unesite poštanski broj objekta';
                                                }
                                                return null;
                                              },
                                              onChanged: (value) => snapshot.data!['company'].postalCode = value,
                                              initialValue: snapshot.data!['company'].postalCode,
                                              cursorColor: Colors.orange,
                                              decoration: InputDecoration(
                                                hintText: "Unesite poštanski broj objekta",
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
                                          )
                                        ]
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.15,
                                            child: const Text('Broj objekta'),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.7,
                                            child: TextFormField(
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Molimo unesite broj objekta';
                                                }
                                                return null;
                                              },
                                              onChanged: (value) => snapshot.data!['company'].number = value,
                                              initialValue: snapshot.data!['company'].number,
                                              cursorColor: Colors.orange,
                                              decoration: InputDecoration(
                                                hintText: "Unesite broj objekta",
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
                                          )
                                        ]
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.15,
                                            child: const Text('Grad objekta'),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.7,
                                            child: TextFormField(
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Molimo unesite grad objekta';
                                                }
                                                return null;
                                              },
                                              onChanged: (value) => snapshot.data!['company'].city = value,
                                              initialValue: snapshot.data!['company'].city,
                                              cursorColor: Colors.orange,
                                              decoration: InputDecoration(
                                                hintText: "Unesite ime grad objekta",
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
                                          )
                                        ]
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.15,
                                            child: const Text('Telefonski broj objekta'),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.7,
                                            child: TextFormField(
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Molimo unesite telefonski broj objekta';
                                                }
                                                return null;
                                              },
                                              onChanged: (value) => snapshot.data!['company'].phone = value,
                                              initialValue: snapshot.data!['company'].phone,
                                              cursorColor: Colors.orange,
                                              decoration: InputDecoration(
                                                hintText: "Unesite telefonski broj objekta",
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
                                          )
                                        ]
                                      ),
                                      const SizedBox(height: 25),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(40),
                                            child: TextButton(
                                              onPressed: () {
                                                if (companyFormKey.currentState!.validate()) {
                                                  companyFormKey.currentState!.save();
                                                  setState(() {
                                                    updateCompany(snapshot.data!['company']);
                                                  });
                                                }
                                              },
                                              child: const Text('Spremi'),
                                              style: TextButton.styleFrom(
                                                padding: const EdgeInsets.fromLTRB(80, 20, 80, 20),
                                                primary: Colors.white,
                                                backgroundColor: Colors.orange,
                                                textStyle: const TextStyle(fontSize: 18),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ]
                                  )
                                )
                              ]
                            )
                          ),
                          const SizedBox(height: 25),
                          Row(
                            children: [
                              Flexible(
                                child: Column(
                                  children: [
                                    Row(
                                      children: const [
                                        Text("Financije", style: TextStyle(fontSize: 20)),
                                      ]
                                    ),
                                    const SizedBox(height: 25),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 250,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: const [
                                                  Text('Porezi')
                                                ]
                                              ),
                                              const SizedBox(height: 10),
                                              DataTable(
                                                columns: const [
                                                  DataColumn(
                                                    label: Text('Naziv'),
                                                  ),
                                                  DataColumn(
                                                    label: Text('Iznos'),
                                                  ),
                                                ],
                                                rows: [
                                                  for (Tax tax in snapshot.data!['taxes'])
                                                    DataRow(
                                                      cells: [
                                                        DataCell(Text("${tax.name}")),
                                                        DataCell(Text("${tax.amount}%")),
                                                      ],
                                                    ),
                                                ]
                                              )
                                            ]
                                          ),
                                        ),
                                        const SizedBox(width: 25),
                                        Container(
                                          width: 250,
                                          child: Column(
                                            children: [
                                              Row(
                                                children: const [
                                                  Text('Načini plaćanja')
                                                ]
                                              ),
                                              const SizedBox(height: 10),
                                              for (PaymentMethod pm in snapshot.data!['paymentMethods'])
                                                Row(
                                                  children: [
                                                    Text(pm.name),
                                                    Switch(
                                                      value: pm.active,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          updatePaymentMethod(pm.id, value);
                                                        });
                                                      },
                                                      activeTrackColor: Colors.orangeAccent,
                                                      activeColor: Colors.orange,
                                                    )
                                                  ]
                                                ),
                                            ]
                                          ),
                                        ),
                                      ]
                                    ),
                                  ]
                                )
                              )
                            ]
                          )
                        ],
                      ),
                    )
                  );
                } else {
                  return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.orange)));
                }
              },
            )
          )
        ]
      ),
    );
  }
}