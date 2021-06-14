import 'dart:convert';
import 'dart:io';
import 'package:app/components/loader.dart';
import 'package:app/mixins/snackbar.dart';
import 'package:app/models/payment_method.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:app/components/custom_app_bar.dart';
import 'package:app/components/drawer_list.dart';
import 'package:app/components/middleware.dart';
import 'package:app/mixins/format_price.dart';
import 'package:app/models/product.dart';
import 'package:app/models/user.dart';
import 'package:app/providers/user_provider.dart';
import 'package:http/http.dart' as http;

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with FormatPrice {

  Future<Map<dynamic, dynamic>> fetchData() async {
    var products = await http.get(Uri.parse("${dotenv.env['SHOP_API_URI']}/api/dashboard"));
    var paymentMethods = await http.get(Uri.parse("${dotenv.env['FINANCE_API_URI']}/api/payment-methods?active=1"));
    return {
      "products" : Product.parseGroupedData(products.body),
      "paymentMethods" : PaymentMethod.parsePaymentMethods(paymentMethods.body)
    };
  }

  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<UserProvider>(context).user;

    if (user == null) {
      return const Middleware();
    }

    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const Drawer(
        child: DrawerList(index: 0),
      ),
      drawerScrimColor: Colors.transparent,
      body: FutureBuilder<Map<dynamic, dynamic>>(
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
            return DashboardComponentWidget(products: snapshot.data!["products"], paymentMethods: snapshot.data!["paymentMethods"], user: user);
          } else {
            return const Loader(message: "Dohvaćam proizvode...");
          }
        },
      )
    );
  }
}

class DashboardComponentWidget extends StatefulWidget {
  DashboardComponentWidget({
    Key? key,
    required this.products,
    required this.paymentMethods,
    required this.user,
  }) : super(key: key);

  Map<dynamic, dynamic> products;
  List<PaymentMethod> paymentMethods;
  User user;

  @override
  _DashboardComponentWidgetState createState() => _DashboardComponentWidgetState(products: products, paymentMethods: paymentMethods, user: user);
}

class _DashboardComponentWidgetState extends State<DashboardComponentWidget> with FormatPrice, CustomSnackBar {
  _DashboardComponentWidgetState({
    required this.products,
    required this.paymentMethods,
    required this.user,
  });

  Map<dynamic, dynamic> products;
  List<PaymentMethod> paymentMethods;
  User user;

  final List<Product> cart = <Product>[];
  int sum = 0;
  int selectedPaymentMethodId = 1;

  void _addToCart(Product product) {
    setState(() {
      final index = cart.indexWhere((element) => element.id == product.id);
      sum += product.price;
      if (index >= 0) {
        cart[index].quantity++;
      } else {
        product.quantity++;
        cart.insert(0, product);
      }
    });
  }

  void _removeFromCart(Product product) {
    setState(() {
      final index = cart.indexWhere((element) => element.id == product.id);
      if (index >= 0) {
        sum -= product.price * product.quantity;
        product.quantity = 0;
        cart.removeAt(index);
      }
    });
  }

  void _changeQuantity(Product product, String operation) {
    setState(() {
      final index = cart.indexWhere((element) => element.id == product.id);
      if (index >= 0) {
        if (operation == 'increment') {
          sum += product.price;
          cart[index].quantity++;
        } else if (operation == 'decrement') {
          sum -= product.price;
          if (product.quantity > 1) {
            cart[index].quantity--;
          } else {
            cart.removeAt(index);
          }
        }
      }
    });
  }

  void clearCart() {
    setState(() {
      for (var product in cart) {
        product.quantity = 0;
      }
      sum = 0;
      cart.clear();
    });
  }

  void createBill() async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final userData = {
      "id" : user.id,
      "username" : user.username,
      "name" : user.name,
    };

    // TODO => Append token for authentication/authorization check.
    http.Response response = await http.post(
      Uri.parse("${dotenv.env['FINANCE_API_URI']}/api/bills"),
      body: json.encode({
        "user" : userData,
        "products" : cart,
        "payment_method_id" : selectedPaymentMethodId,
        "cash_register_label" : dotenv.env['CASH_REGISTER_LABEL'],
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Uspješno kreiran novi račun", Colors.green));
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

    setState(() {
      clearCart();
      selectedPaymentMethodId = paymentMethods.isNotEmpty ? paymentMethods[0].id : 0;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: DefaultTabController(
            initialIndex: 0,
            length: products.length,
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                elevation: 0,
                bottom: PreferredSize(
                  preferredSize: const Size(0, 0),
                  child: ColoredBox(
                    color: Colors.orange,
                    child: TabBar(
                      tabs: <Widget>[
                        for (String key in products.keys)
                          Tab(
                              text: key
                          )
                      ],
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black,
                      indicatorColor: Colors.white,
                    ),
                  ),
                ),
              ),
              body: TabBarView(
                children: <Widget>[
                  for (String key in products.keys)
                    DefaultTabController(
                      initialIndex: 0,
                      length: products[key].length,
                      child: Scaffold(
                        appBar: AppBar(
                          automaticallyImplyLeading: false,
                          elevation: 1,
                          bottom: PreferredSize(
                            preferredSize: const Size(0, 0),
                            child: ColoredBox(
                              color: Colors.orange,
                              child: TabBar(
                                isScrollable: true,
                                tabs: <Widget>[
                                  for (String subKey in products[key].keys)
                                    Tab(
                                      text: subKey,
                                    ),
                                ],
                                labelColor: Colors.white,
                                unselectedLabelColor: Colors.black,
                                indicatorColor: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        body: TabBarView(
                          children: <Widget>[
                            for (String subKey in products[key].keys)
                              Container(
                                margin: const EdgeInsets.only(top: 10),
                                child: GridView.count(
                                  crossAxisCount: 3,
                                  childAspectRatio: 2.5,
                                  children: List.generate(products[key][subKey].length, (index) {
                                    return InkWell(
                                      onTap: () {
                                        _addToCart(products[key][subKey][index]);
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.all(5),
                                        child: ListTile(
                                            leading: ClipRRect(
                                                borderRadius: BorderRadius.circular(8.0),
                                                child: Image.network(products[key][subKey][index].image, width: 50)
                                            ),
                                            title: Text('${products[key][subKey][index].name}'),
                                            subtitle: Text(formatPrice(products[key][subKey][index].price))
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(5),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 2,
                                              blurRadius: 2,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              )
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          )
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD2D2D2))
            ),
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: Row(
                    crossAxisAlignment: cart.isNotEmpty ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: cart.isNotEmpty ? SingleChildScrollView(
                          child: DataTable(
                            columns: const <DataColumn>[
                              DataColumn(
                                label: Text('Naziv'),
                              ),
                              DataColumn(
                                label: Text('Cijena'),
                              ),
                              DataColumn(
                                label: Text('Količina'),
                              ),
                              DataColumn(
                                label: Expanded(
                                  child: Text('Ukupno', textAlign: TextAlign.right)
                                )
                              ),
                            ],
                            rows: <DataRow>[
                              for (var product in cart) DataRow(
                                cells: <DataCell>[
                                  DataCell(
                                    Row(
                                      children: <Widget>[
                                        Image.network("${product.image}", width: 50),
                                        const SizedBox(width: 10),
                                        Text("${product.name}")
                                      ],
                                    )
                                  ),
                                  DataCell(
                                      Text(formatPrice(product.price))
                                  ),
                                  DataCell(
                                      Row(
                                        children: <Widget>[
                                          Container(
                                              margin: const EdgeInsets.only(right: 10.0),
                                              width: 20,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  _changeQuantity(product, 'decrement');
                                                },
                                                child: const Text("-"),
                                                style: ElevatedButton.styleFrom(
                                                    primary: Colors.orange,
                                                    padding: const EdgeInsets.all(0)
                                                ),
                                              )
                                          ),
                                          Flexible(
                                            child: Container(
                                              margin: const EdgeInsets.only(right: 10.0),
                                              child: Text('${product.quantity}'),
                                            ),
                                          ),
                                          Container(
                                              margin: const EdgeInsets.only(right: 10.0),
                                              width: 22,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  _changeQuantity(product, 'increment');
                                                },
                                                child: const Text("+"),
                                                style: ElevatedButton.styleFrom(
                                                    primary: Colors.orange,
                                                    padding: const EdgeInsets.all(0)
                                                ),
                                              )
                                          ),
                                          Container(
                                              margin: const EdgeInsets.only(right: 10.0),
                                              width: 22,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  _removeFromCart(product);
                                                },
                                                child: const Text("x"),
                                                style: ElevatedButton.styleFrom(
                                                    primary: Colors.orange,
                                                    padding: const EdgeInsets.all(0)
                                                ),
                                              )
                                          ),
                                        ],
                                      )
                                  ),
                                  DataCell(
                                      Row(
                                        children: <Widget>[
                                          const Spacer(),
                                          Text(formatPrice(product.price * product.quantity))
                                        ],
                                      )
                                  ),
                                ],
                              ),
                            ],
                          )
                        )
                        :
                        const Center(
                          child: Text("Košarica je trenutno prazna.", textAlign: TextAlign.center),
                        ),
                      )
                    ]
                  )
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    constraints: const BoxConstraints.expand(),
                    padding: const EdgeInsets.all(10.0),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Color(0xFFD2D2D2)),
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: [
                            const Text('Način plaćanja'),
                            const Spacer(),
                            paymentMethods.isEmpty ?
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                              child: const Text('Nema aktivnih načina plaćanja')
                            )
                            : const Text(""),
                            for (PaymentMethod pm in paymentMethods)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                child: ChoiceChip(
                                  label: Text(pm.name),
                                  selected: selectedPaymentMethodId == pm.id,
                                  selectedColor: Colors.orange,
                                  pressElevation: 0,
                                  labelStyle: const TextStyle(color: Colors.white),
                                  onSelected: (bool selected) {
                                    setState(() {
                                      selectedPaymentMethodId = pm.id;
                                    });
                                  },
                                )
                              )
                          ]
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: <Widget>[
                            const Text('Ukupno'),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                              child: Text(formatPrice(sum, symbol: 'HRK')),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: <Widget>[
                            ElevatedButton(
                              onPressed: (cart.isNotEmpty) ? () =>  clearCart() : null,
                              child: const Text("Odustani"),
                              style: ElevatedButton.styleFrom(primary: Colors.orange),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                              child: ElevatedButton(
                                onPressed: (cart.isNotEmpty && selectedPaymentMethodId != 0) ? () =>  createBill() : null,
                                child: const Text("Naplati"),
                                style: ElevatedButton.styleFrom(primary: Colors.orange),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                )
              ],
            ),
          )
        ),
      ],
    );
  }
}