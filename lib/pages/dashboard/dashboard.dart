import 'dart:convert';
import 'dart:io';
import 'package:app/components/loader.dart';
import 'package:app/mixins/snackbar.dart';
import 'package:app/models/payment_method.dart';
import 'package:app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:app/components/custom_app_bar.dart';
import 'package:app/components/drawer_list.dart';
import 'package:app/components/middleware.dart';
import 'package:app/mixins/format_price.dart';
import 'package:app/models/product.dart';
import 'package:app/models/user.dart';
import 'package:http_interceptor/http/intercepted_client.dart';
import 'package:app/util/http_interceptor.dart';
import 'package:http/http.dart' as http;

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with FormatPrice {

  http.Client client = InterceptedClient.build(interceptors: [
    ApiInterceptor(),
  ]);

  Future<Map<dynamic, dynamic>> fetchData() async {
    var products = await client.get(Uri.parse("${dotenv.env['SHOP_API_URI']}/api/dashboard"));
    var paymentMethods = await client.get(Uri.parse("${dotenv.env['FINANCE_API_URI']}/api/payment-methods?active=1"));
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
              return const Center(child: Text("Do??lo je do gre??ke. Mikroservis vjerojatno nije u funkciji."));
            } else {
              return const Center(child: Text("Do??lo je do gre??ke."));
            }
          }
          if (snapshot.hasData) {
            return DashboardComponentWidget(products: snapshot.data!["products"], paymentMethods: snapshot.data!["paymentMethods"], user: user, client: client);
          } else {
            return const Loader(message: "Dohva??am proizvode...");
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
    required this.client,
  }) : super(key: key);

  Map<dynamic, dynamic> products;
  List<PaymentMethod> paymentMethods;
  User user;
  http.Client client;

  @override
  _DashboardComponentWidgetState createState() => _DashboardComponentWidgetState(products: products, paymentMethods: paymentMethods, user: user, client: client);
}

class _DashboardComponentWidgetState extends State<DashboardComponentWidget> with FormatPrice, CustomSnackBar {
  _DashboardComponentWidgetState({
    required this.products,
    required this.paymentMethods,
    required this.user,
    required this.client,
  });

  Map<dynamic, dynamic> products;
  List<PaymentMethod> paymentMethods;
  User user;
  http.Client client;

  final List<Product> cart = <Product>[];
  int sum = 0;
  int selectedPaymentMethodId = 0;

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
      "surname" : user.surname,
      "email" : user.email,
      "role" : user.role,
    };

    http.Response response = await client.post(
      Uri.parse("${dotenv.env['FINANCE_API_URI']}/api/bills"),
      body: json.encode({
        "user" : userData,
        "products" : cart,
        "payment_method_id" : selectedPaymentMethodId,
        "cash_register_id" : dotenv.env['CASH_REGISTER_ID'],
      })
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Uspje??no kreiran novi ra??un", Colors.green));
    } else if (response.statusCode == 422) {
      Map<String, dynamic> data = jsonDecode(response.body);

      String errors = "";

      data.forEach((k,v) => {
        for (final e in data[k]) {
          errors += e
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Do??lo je do validacijske gre??ke: $errors", Colors.deepOrange));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Do??lo je do gre??ke", Colors.red));
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
                                  controller: ScrollController(initialScrollOffset: 0),
                                  crossAxisCount: 3,
                                  childAspectRatio: 2.5,
                                  children: List.generate(products[key][subKey].length, (index) {
                                    return Container(
                                      margin: const EdgeInsets.all(5),
                                      padding: const EdgeInsets.all(5),
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
                                      child: InkWell(
                                        onTap: () {
                                          _addToCart(products[key][subKey][index]);
                                        },
                                        child: ListTile(
                                          leading: Image.network(
                                            products[key][subKey][index].image,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Image.asset("assets/images/Logo.png");
                                            },
                                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return const Padding(
                                                padding: EdgeInsets.only(left: 15.0),
                                                child: SizedBox(
                                                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.orange)),
                                                  height: 20.0,
                                                  width: 20.0,
                                                )
                                              );
                                            },
                                            width: 50,
                                          ),
                                          title: Text('${products[key][subKey][index].name}'),
                                          subtitle: Text(formatPrice(products[key][subKey][index].price))
                                        ),
                                      )
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
                          controller: ScrollController(initialScrollOffset: 0),
                          child: DataTable(
                            columns: const <DataColumn>[
                              DataColumn(
                                label: Text('Naziv'),
                              ),
                              DataColumn(
                                label: Text('Cijena'),
                              ),
                              DataColumn(
                                label: Text('Koli??ina'),
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
                                        Image.network(
                                          "${product.image}",
                                          errorBuilder: (context, error, stackTrace) {
                                            return Image.asset("assets/images/Logo.png");
                                          },
                                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return const Padding(
                                              padding: EdgeInsets.only(left: 15.0),
                                              child: SizedBox(
                                                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.orange)),
                                                height: 20.0,
                                                width: 20.0,
                                              )
                                            );
                                          },
                                          width: 50,
                                        ),
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
                          child: Text("Ko??arica je trenutno prazna.", textAlign: TextAlign.center),
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
                            const Text('Na??in pla??anja'),
                            const Spacer(),
                            paymentMethods.isEmpty ?
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                              child: const Text('Nema aktivnih na??ina pla??anja')
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