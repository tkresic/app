import 'dart:convert';
import 'dart:io';

import 'package:app/components/custom_app_bar.dart';
import 'package:app/components/drawer_list.dart';
import 'package:app/components/loader.dart';
import 'package:app/components/middleware.dart';
import 'package:app/mixins/snackbar.dart';
import 'package:app/models/branch.dart';
import 'package:app/models/company.dart';
import 'package:app/models/payment_method.dart';
import 'package:app/models/tax.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:app/models/user.dart';
import 'package:app/providers/user_provider.dart';
import 'package:http_interceptor/http/intercepted_client.dart';
import 'package:app/util/http_interceptor.dart';
import 'package:http/http.dart' as http;

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> with CustomSnackBar {

  http.Client client = InterceptedClient.build(interceptors: [
    ApiInterceptor(),
  ]);
  final companyFormKey = GlobalKey<FormState>();
  final branchFormKey = GlobalKey<FormState>();
  final taxFormKey = GlobalKey<FormState>();

  Tax tax = Tax(id: null, name: "", amount: 0);

  Future<Map<dynamic, dynamic>> fetchData() async {
    var company = await client.get(Uri.parse("${dotenv.env['CORPORATE_API_URI']}/api/company"));
    var branch = await client.get(Uri.parse("${dotenv.env['CORPORATE_API_URI']}/api/branches/1"));
    var paymentMethods = await client.get(Uri.parse("${dotenv.env['FINANCE_API_URI']}/api/payment-methods"));
    var taxes = await client.get(Uri.parse("${dotenv.env['FINANCE_API_URI']}/api/taxes"));

    return {
      "company" : Company.fromJson(json.decode(const Utf8Decoder().convert(company.bodyBytes))),
      "branch" : Branch.fromJson(json.decode(const Utf8Decoder().convert(branch.bodyBytes))),
      "paymentMethods" : PaymentMethod.parsePaymentMethods(paymentMethods.body),
      "taxes" : Tax.parseTaxes(taxes.body),
    };
  }

  void updateCompany(Company company) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    http.Response response = await client.put(
      Uri.parse("${dotenv.env['CORPORATE_API_URI']}/api/company"),
      body: json.encode({
        "name" : company.name,
        "address" : company.address,
        "pidn" : company.pidn,
        "phone" : company.phone
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Uspješno ažurirana tvrtka", Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Došlo je do greške", Colors.red));
    }
  }

  void updateBranch(Branch branch) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    http.Response response = await client.put(
      Uri.parse("${dotenv.env['CORPORATE_API_URI']}/api/branches/${branch.id}"),
      body: json.encode({
        "name" : branch.name,
        "address" : branch.address,
        "phone" : branch.phone,
        "businessPlaceLabel" : branch.businessPlaceLabel
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Uspješno ažurirana poslovnica", Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Došlo je do greške", Colors.red));
    }
  }

  void updatePaymentMethod(int paymentMethodId, bool active) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    http.Response response = await client.put(
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

  void createTax(Tax tax) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    http.Response response = await client.post(
      Uri.parse("${dotenv.env['FINANCE_API_URI']}/api/taxes"),
      body: json.encode({
        "name" : tax.name,
        "amount" : tax.amount,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Uspješno dodan novi porez", Colors.green));
    } else if (response.statusCode == 422) {
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Došlo je do validacijske greške: Ime poreza je vjerojatno već zauzeto", Colors.deepOrange));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Došlo je do greške", Colors.red));
    }

    setState(() {});
  }

  void updateTax(Tax tax) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    http.Response response = await client.put(
      Uri.parse("${dotenv.env['FINANCE_API_URI']}/api/taxes/${tax.id}"),
      body: json.encode({
        "name" : tax.name,
        "amount" : tax.amount,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Uspješno ažuriran porez", Colors.green));
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
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: [
                            Flexible(
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
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
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: const [
                                                Text("Tvrtka", style: TextStyle(fontSize: 20)),
                                              ]
                                            ),
                                            const SizedBox(height: 25),
                                            Row(
                                              children: [
                                                Form(
                                                  key: companyFormKey,
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Container(
                                                            width: MediaQuery.of(context).size.width * 0.15,
                                                            child: const Text('Ime'),
                                                          ),
                                                          Container(
                                                            width: MediaQuery.of(context).size.width * 0.25,
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
                                                                  Icons.business,
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
                                                            child: const Text('Adresa'),
                                                          ),
                                                          Container(
                                                            width: MediaQuery.of(context).size.width * 0.25,
                                                            child: TextFormField(
                                                              validator: (value) {
                                                                if (value == null || value.isEmpty) {
                                                                  return 'Molimo unesite adresu tvrtke';
                                                                }
                                                                return null;
                                                              },
                                                              onChanged: (value) => snapshot.data!['company'].address = value,
                                                              initialValue: snapshot.data!['company'].address,
                                                              cursorColor: Colors.orange,
                                                              decoration: InputDecoration(
                                                                hintText: "Unesite adresu tvrtke",
                                                                border: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(25),
                                                                ),
                                                                focusedBorder: OutlineInputBorder(
                                                                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                                                                  borderRadius: BorderRadius.circular(25),
                                                                ),
                                                                prefixIcon: const Icon(
                                                                  Icons.house,
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
                                                            child: const Text('OIB'),
                                                          ),
                                                          Container(
                                                            width: MediaQuery.of(context).size.width * 0.25,
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
                                                                  Icons.text_fields,
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
                                                            child: const Text('Telefonski broj'),
                                                          ),
                                                          Container(
                                                            width: MediaQuery.of(context).size.width * 0.25,
                                                            child: TextFormField(
                                                              validator: (value) {
                                                                if (value == null || value.isEmpty) {
                                                                  return 'Molimo unesite telefonski broj tvrtke';
                                                                }
                                                                return null;
                                                              },
                                                              onChanged: (value) => snapshot.data!['company'].phone = value,
                                                              initialValue: snapshot.data!['company'].phone,
                                                              cursorColor: Colors.orange,
                                                              decoration: InputDecoration(
                                                                hintText: "Unesite telefonski broj tvrtke",
                                                                border: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(25),
                                                                ),
                                                                focusedBorder: OutlineInputBorder(
                                                                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                                                                  borderRadius: BorderRadius.circular(25),
                                                                ),
                                                                prefixIcon: const Icon(
                                                                  Icons.phone,
                                                                  color: Colors.orange,
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ]
                                                      ),
                                                      const SizedBox(height: 25),
                                                      Row(
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
                                          ]
                                        )
                                      ),
                                      const SizedBox(width: 25),
                                      Container(
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
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: const [
                                                Text("Poslovnica", style: TextStyle(fontSize: 20)),
                                              ]
                                            ),
                                            const SizedBox(height: 25),
                                            Row(
                                              children: [
                                                Form(
                                                  key: branchFormKey,
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Container(
                                                            width: MediaQuery.of(context).size.width * 0.15,
                                                            child: const Text('Ime'),
                                                          ),
                                                          Container(
                                                            width: MediaQuery.of(context).size.width * 0.25,
                                                            child: TextFormField(
                                                              validator: (value) {
                                                                if (value == null || value.isEmpty) {
                                                                  return 'Molimo unesite ime poslovnice';
                                                                }
                                                                return null;
                                                              },
                                                              onChanged: (value) => snapshot.data!['branch'].name = value,
                                                              initialValue: snapshot.data!['branch'].name,
                                                              cursorColor: Colors.orange,
                                                              decoration: InputDecoration(
                                                                hintText: "Unesite ime poslovnice",
                                                                border: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(25),
                                                                ),
                                                                focusedBorder: OutlineInputBorder(
                                                                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                                                                  borderRadius: BorderRadius.circular(25),
                                                                ),
                                                                prefixIcon: const Icon(
                                                                  Icons.business,
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
                                                            child: const Text('Adresa'),
                                                          ),
                                                          Container(
                                                            width: MediaQuery.of(context).size.width * 0.25,
                                                            child: TextFormField(
                                                              validator: (value) {
                                                                if (value == null || value.isEmpty) {
                                                                  return 'Molimo unesite adresu poslovnice';
                                                                }
                                                                return null;
                                                              },
                                                              onChanged: (value) => snapshot.data!['branch'].address = value,
                                                              initialValue: snapshot.data!['branch'].address,
                                                              cursorColor: Colors.orange,
                                                              decoration: InputDecoration(
                                                                hintText: "Unesite adresu poslovnice",
                                                                border: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(25),
                                                                ),
                                                                focusedBorder: OutlineInputBorder(
                                                                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                                                                  borderRadius: BorderRadius.circular(25),
                                                                ),
                                                                prefixIcon: const Icon(
                                                                  Icons.house,
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
                                                            child: const Text('Telefonski broj'),
                                                          ),
                                                          Container(
                                                            width: MediaQuery.of(context).size.width * 0.25,
                                                            child: TextFormField(
                                                              validator: (value) {
                                                                if (value == null || value.isEmpty) {
                                                                  return 'Molimo unesite telefonski broj poslovnice';
                                                                }
                                                                return null;
                                                              },
                                                              onChanged: (value) => snapshot.data!['branch'].phone = value,
                                                              initialValue: snapshot.data!['branch'].phone,
                                                              cursorColor: Colors.orange,
                                                              decoration: InputDecoration(
                                                                hintText: "Unesite telefonski broj poslovnice",
                                                                border: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(25),
                                                                ),
                                                                focusedBorder: OutlineInputBorder(
                                                                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                                                                  borderRadius: BorderRadius.circular(25),
                                                                ),
                                                                prefixIcon: const Icon(
                                                                  Icons.phone,
                                                                  color: Colors.orange,
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ]
                                                      ),
                                                      const SizedBox(height: 25),
                                                      Row(
                                                        children: <Widget>[
                                                          ClipRRect(
                                                            borderRadius: BorderRadius.circular(40),
                                                            child: TextButton(
                                                              onPressed: () {
                                                                if (branchFormKey.currentState!.validate()) {
                                                                  branchFormKey.currentState!.save();
                                                                  setState(() {
                                                                    updateBranch(snapshot.data!['branch']);
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
                                          ]
                                        )
                                      ),
                                    ]
                                  ),
                                ]
                              )
                            )
                          ]
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
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
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Text("Porezi", style: TextStyle(fontSize: 20)),
                                                const SizedBox(width: 10),
                                                SizedBox(
                                                  width: 30,
                                                  child: Tooltip(
                                                    message: 'Dodaj novi porez',
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
                                                              title: const Text('Dodaj novi porez'),
                                                              content: Form(
                                                                key: taxFormKey,
                                                                child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: <Widget>[
                                                                      Row(
                                                                        children: [
                                                                          Container(
                                                                            width: 250,
                                                                            child: TextFormField(
                                                                              validator: (value) {
                                                                                if (value == null || value.isEmpty) {
                                                                                  return 'Molimo unesite ime poreza';
                                                                                }
                                                                                return null;
                                                                              },
                                                                              onSaved: (value) => tax.name = value!,
                                                                              cursorColor: Colors.orange,
                                                                              decoration: InputDecoration(
                                                                                hintText: "Ime poreza",
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
                                                                                  return 'Molimo unesite iznos poreza';
                                                                                } else if (int.parse(value) < 1 || int.parse(value) > 100) {
                                                                                  return 'Iznos poreza mora biti između 1 i 100';
                                                                                }
                                                                                return null;
                                                                              },
                                                                              keyboardType: TextInputType.number,
                                                                              onSaved: (value) => tax.amount = int.parse(value!),
                                                                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                                                              cursorColor: Colors.orange,
                                                                              decoration: InputDecoration(
                                                                                hintText: "Iznos poreza",
                                                                                border: OutlineInputBorder(
                                                                                  borderRadius: BorderRadius.circular(25),
                                                                                ),
                                                                                focusedBorder: OutlineInputBorder(
                                                                                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                                                                                  borderRadius: BorderRadius.circular(25),
                                                                                ),
                                                                                prefixIcon: const Icon(
                                                                                  Icons.confirmation_number,
                                                                                  color: Colors.orange,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          )
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
                                                                                  if (taxFormKey.currentState!.validate()) {
                                                                                    taxFormKey.currentState!.save();
                                                                                    createTax(tax);
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
                                            const SizedBox(height: 25),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                DataTable(
                                                  columns: const [
                                                    DataColumn(
                                                      label: Text('Naziv'),
                                                    ),
                                                    DataColumn(
                                                      label: Text('Iznos'),
                                                    ),
                                                    DataColumn(
                                                      label: Expanded(
                                                        child: Text('Akcije', textAlign: TextAlign.right)
                                                      )
                                                    )
                                                  ],
                                                  rows: [
                                                    for (Tax tax in snapshot.data!['taxes'])
                                                      DataRow(
                                                        cells: [
                                                          DataCell(Text("${tax.name}")),
                                                          DataCell(Text("${tax.amount}%")),
                                                          DataCell(
                                                            Row(
                                                              children: <Widget>[
                                                                const Spacer(),
                                                                SizedBox(
                                                                  width: 30.0,
                                                                  height: 30.0,
                                                                  child: Tooltip(
                                                                    message: 'Uredi porez ${tax.name}',
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
                                                                                title: const Text('Uredi porez'),
                                                                                content: Form(
                                                                                  key: taxFormKey,
                                                                                  child: Column(
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    children: <Widget>[
                                                                                      Row(
                                                                                        children: [
                                                                                          Container(
                                                                                            width: 250,
                                                                                            child: TextFormField(
                                                                                              validator: (value) {
                                                                                                if (value == null || value.isEmpty) {
                                                                                                  return 'Molimo unesite naziv poreza';
                                                                                                }
                                                                                                return null;
                                                                                              },
                                                                                              onSaved: (value) => tax.name = value!,
                                                                                              initialValue: tax.name,
                                                                                              cursorColor: Colors.orange,
                                                                                              decoration: InputDecoration(
                                                                                                hintText: "Naziv poreza",
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
                                                                                                  return 'Molimo unesite iznos poreza';
                                                                                                } else if (int.parse(value) < 1 || int.parse(value) > 100) {
                                                                                                  return 'Iznos poreza mora biti između 1 i 100';
                                                                                                }
                                                                                                return null;
                                                                                              },
                                                                                              keyboardType: TextInputType.number,
                                                                                              onSaved: (value) => tax.amount = int.parse(value!),
                                                                                              initialValue: tax.amount.toString(),
                                                                                              cursorColor: Colors.orange,
                                                                                              decoration: InputDecoration(
                                                                                                hintText: "Iznos poreza",
                                                                                                border: OutlineInputBorder(
                                                                                                  borderRadius: BorderRadius.circular(25),
                                                                                                ),
                                                                                                focusedBorder: OutlineInputBorder(
                                                                                                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                                                                                                  borderRadius: BorderRadius.circular(25),
                                                                                                ),
                                                                                                prefixIcon: const Icon(
                                                                                                  Icons.confirmation_number,
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
                                                                                                  if (taxFormKey.currentState!.validate()) {
                                                                                                    taxFormKey.currentState!.save();
                                                                                                    updateTax(tax);
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
                                              ]
                                            ),
                                          ]
                                        )
                                      ),
                                      const SizedBox(width: 25),
                                      Container(
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
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: const [
                                                Text("Načini plaćanja", style: TextStyle(fontSize: 20)),
                                              ]
                                            ),
                                            const SizedBox(height: 25),
                                            Row(
                                              children: [
                                                const SizedBox(width: 25),
                                                Container(
                                                  width: 200,
                                                  child: Column(
                                                    children: [
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
                                      ),
                                    ]
                                  ),
                                ]
                              )
                            )
                          ]
                        ),
                      ],
                    ),
                  );
                } else {
                  return const Loader(message: "Dohvaćam postavke...");
                }
              },
            )
          )
        ]
      ),
    );
  }
}