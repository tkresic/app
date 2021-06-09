import 'package:flutter/material.dart';
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
  Future<Map> fetchGroupedData() async {
    var response = await http.get(Uri.parse("http://localhost:8000/api/dashboard"));
    return Product.parseGroupedData(response.body);
  }

  final List<Product> cart = <Product>[];
  int _sum = 0;
  int _selectedPaymentMethod = 1;

  void _addToCart(Product product) {
    setState(() {
      final index = cart.indexWhere((element) => element.id == product.id);
      _sum += product.price;
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
        _sum -= product.price * product.quantity;
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
          _sum += product.price;
          cart[index].quantity++;
        } else if (operation == 'decrement') {
          _sum -= product.price;
          if (product.quantity > 1) {
            cart[index].quantity--;
          } else {
            cart.removeAt(index);
          }
        }
      }
    });
  }

  void _clearCart() {
    setState(() {
      for (var product in cart) {
        product.quantity = 0;
      }
      _sum = 0;
      cart.clear();
    });
  }

  void _finishPurchase() {
    setState(() {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _clearCart();
      _selectedPaymentMethod = 1;

      // TODO => Finish purchase. Slice snackbar
      final snackBar = SnackBar(
        width: 300.0,
        behavior: SnackBarBehavior.floating,
        content: Text("Uspješno kreiran novi račun"),
        backgroundColor: Colors.green,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<UserProvider>(context).user;

    if (user == null) {
      return Middleware();
    }

    return Scaffold(
      appBar: CustomAppBar(),
      drawer: Drawer(
        child: DrawerList(index: 0),
      ),
      drawerScrimColor: Colors.transparent,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: FutureBuilder<Map<dynamic, dynamic>>(
              future: fetchGroupedData(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return Center(child: Text("Došlo je do greške."));
                }
                if (snapshot.hasData){
                  return DefaultTabController(
                    initialIndex: 0,
                    length: snapshot.data!.length,
                    child: Scaffold(
                      appBar: AppBar(
                        automaticallyImplyLeading: false,
                        elevation: 0,
                        bottom: PreferredSize(
                          preferredSize: Size(0, 0),
                          child: ColoredBox(
                            color: Colors.orange,
                            child: TabBar(
                              tabs: <Widget>[
                                for (String key in snapshot.data!.keys)
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
                          for (String key in snapshot.data!.keys)
                            DefaultTabController(
                              initialIndex: 0,
                              length: snapshot.data![key].length,
                              child: Scaffold(
                                appBar: AppBar(
                                  automaticallyImplyLeading: false,
                                  elevation: 1,
                                  bottom: PreferredSize(
                                    preferredSize: Size(0, 0),
                                    child: ColoredBox(
                                      color: Colors.orange,
                                      child: TabBar(
                                        isScrollable: true,
                                        tabs: <Widget>[
                                          for (String subKey in snapshot.data![key].keys)
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
                                    for (String subKey in snapshot.data![key].keys)
                                      Container(
                                        margin: EdgeInsets.only(top: 10),
                                        child: GridView.count(
                                          crossAxisCount: 3,
                                          childAspectRatio: 2.5,
                                          children: List.generate(snapshot.data![key][subKey].length, (index) {
                                            return InkWell(
                                              onTap: () {
                                                _addToCart(snapshot.data![key][subKey][index]);
                                              },
                                              child: Container(
                                                margin: EdgeInsets.all(5),
                                                child: ListTile(
                                                    leading: ClipRRect(
                                                        borderRadius: BorderRadius.circular(8.0),
                                                        child: Image.network(snapshot.data![key][subKey][index].image, width: 50)
                                                    ),
                                                    title: Text('${snapshot.data![key][subKey][index].name}'),
                                                    subtitle: Text('${formatPrice(snapshot.data![key][subKey][index].price)}')
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(5),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey.withOpacity(0.5),
                                                      spreadRadius: 2,
                                                      blurRadius: 2,
                                                      offset: Offset(0, 1),
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
                  );
                } else {
                  return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.orange)));
                }
              },
            )
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFD2D2D2))
              ),
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: Row(
                      crossAxisAlignment: cart.length > 0 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: cart.length > 0 ? SingleChildScrollView(
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
                                          Image.network(product.image, width: 50),
                                          SizedBox(width: 10),
                                          Text(product.name)
                                        ],
                                      )
                                    ),
                                    DataCell(
                                        Text('${formatPrice(product.price)}')
                                    ),
                                    DataCell(
                                        Row(
                                          children: <Widget>[
                                            Container(
                                              margin: EdgeInsets.only(right: 10.0),
                                              width: 20,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  _changeQuantity(product, 'decrement');
                                                },
                                                child: Text("-"),
                                                style: ElevatedButton.styleFrom(
                                                  primary: Colors.orange,
                                                  padding: EdgeInsets.all(0)
                                                ),
                                              )
                                            ),
                                            Flexible(
                                              child: Container(
                                                margin: EdgeInsets.only(right: 10.0),
                                                child: Text('${product.quantity}'),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(right: 10.0),
                                              width: 22,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  _changeQuantity(product, 'increment');
                                                },
                                                child: Text("+"),
                                                style: ElevatedButton.styleFrom(
                                                  primary: Colors.orange,
                                                  padding: EdgeInsets.all(0)
                                                ),
                                              )
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(right: 10.0),
                                              width: 22,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  _removeFromCart(product);
                                                },
                                                child: Text("x"),
                                                style: ElevatedButton.styleFrom(
                                                  primary: Colors.orange,
                                                  padding: EdgeInsets.all(0)
                                                ),
                                              )
                                            ),
                                          ],
                                        )
                                    ),
                                    DataCell(
                                      Row(
                                        children: <Widget>[
                                          Spacer(),
                                          Text('${formatPrice(product.price * product.quantity)}')
                                        ],
                                      )
                                    ),
                                  ],
                                ),
                              ],
                            )
                            )
                          :
                          Center(
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
                      constraints: BoxConstraints.expand(),
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFFD2D2D2)),
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: [
                              Text('Način plaćanja'),
                              Spacer(),
                              ChoiceChip(
                                label: Text('Gotovina'),
                                selected: _selectedPaymentMethod == 1,
                                selectedColor: Colors.orange,
                                pressElevation: 0,
                                labelStyle: TextStyle(color: Colors.white),
                                onSelected: (bool selected) {
                                  setState(() {
                                    _selectedPaymentMethod = 1;
                                  });
                                },
                              ),
                              SizedBox(width: 10),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                child: ChoiceChip(
                                  label: Text('Kartica'),
                                  selected: _selectedPaymentMethod == 2,
                                  selectedColor: Colors.orange,
                                  pressElevation: 0,
                                  labelStyle: TextStyle(color: Colors.white),
                                  onSelected: (bool selected) {
                                    setState(() {
                                      _selectedPaymentMethod = 2;
                                    });
                                  },
                                ),
                              )
                            ]
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: <Widget>[
                              Text('Ukupno'),
                              Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                child: Text('${formatPrice(_sum, symbol: 'HRK')}'),
                              )
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: <Widget>[
                              ElevatedButton(
                                onPressed: (cart.isNotEmpty) ? () =>  _clearCart() : null,
                                child: Text("Odustani"),
                                style: ElevatedButton.styleFrom(primary: Colors.orange),
                              ),
                              Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                child: ElevatedButton(
                                  onPressed: (cart.isNotEmpty) ? () =>  _finishPurchase() : null,
                                  child: Text("Naplati"),
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
      ),
    );
  }
}