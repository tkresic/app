import 'dart:async';
import 'dart:io';
import 'package:app/components/custom_app_bar.dart';
import 'package:app/components/drawer_list.dart';
import 'package:app/components/loader.dart';
import 'package:app/components/middleware.dart';
import 'package:app/components/text_field_container.dart';
import 'package:app/mixins/delete_dialog.dart';
import 'package:app/mixins/format_price.dart';
import 'package:app/mixins/snackbar.dart';
import 'package:app/models/product.dart';
import 'package:app/models/subcategory.dart';
import 'package:app/models/tax.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:app/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/providers/user_provider.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:http_interceptor/http/intercepted_client.dart';
import 'package:app/util/http_interceptor.dart';
import 'package:http/http.dart' as http;

class Products extends StatefulWidget {
  const Products({Key? key}) : super(key: key);

  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> {

  http.Client client = InterceptedClient.build(interceptors: [
    ApiInterceptor(),
  ]);

  List<dynamic> subcategories = [];
  List<dynamic> taxes = [];
  String search = "";

  Future<Map<String, List>> fetchData() async {
    String uri = "${dotenv.env['SHOP_API_URI']}/api/products";
    if (search.isNotEmpty) {
      uri += "?search=$search";
      var products = await client.get(Uri.parse(uri));
      return {
        "products" : Product.parseProducts(products.body),
        "subcategories" : subcategories,
        "taxes" : taxes,
      };
    }

    var products = await client.get(Uri.parse(uri));
    var subctgrs = await client.get(Uri.parse("${dotenv.env['SHOP_API_URI']}/api/subcategories"));
    var txs = await client.get(Uri.parse("${dotenv.env['FINANCE_API_URI']}/api/taxes"));

    subcategories = Subcategory.parseSubcategories(subctgrs.body);
    taxes = Tax.parseTaxes(txs.body);

    return {
      "products" : Product.parseProducts(products.body),
      "subcategories" : subcategories,
      "taxes" : taxes,
    };
  }

  void callback(String value) {
    setState(() {
      search = value;
    });
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
        child: DrawerList(index: 2),
      ),
      appBar: const CustomAppBar(),
      body: Row(
        children: <Widget>[
          Expanded(
            child: FutureBuilder<Map<String, List>>(
              future: fetchData(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  if (snapshot.error.runtimeType == SocketException) {
                    return const Center(child: Text("Došlo je do greške. Mikroservis vjerojatno nije u funkciji."));
                  } else {
                    return const Center(child: Text("Došlo je do greške"));
                  }
                }
                if (snapshot.hasData) {
                  return SingleChildScrollView(
                    child: Container(
                      margin: const EdgeInsets.all(25),
                      child: ProductsList(context: context, subcategories: snapshot.data!["subcategories"], products: snapshot.data!["products"], taxes: snapshot.data!["taxes"], callback: callback)
                    )
                  );
                } else {
                  return const Loader(message: "Dohvaćam proizvode...");
                }
              },
            )
          )
        ]
      ),
    );
  }
}

class ProductsList extends StatefulWidget {
  const ProductsList({
    Key? key,
    required this.context,
    required this.callback,
    this.subcategories,
    this.products,
    this.taxes,
  }) : super(key: key);

  final BuildContext context;
  final List<dynamic>? subcategories;
  final List<dynamic>? products;
  final List<dynamic>? taxes;
  final Function callback;

  @override
  _ProductsListState createState() => _ProductsListState(context: context, callback: callback, subcategories: subcategories, products: products, taxes: taxes);
}

class _ProductsListState extends State<ProductsList> with CustomSnackBar, FormatPrice {
  _ProductsListState({
    required this.context,
    required this.callback,
    required this.subcategories,
    required this.products,
    required this.taxes,
  });

  final _formKey = GlobalKey<FormState>();
  Product product = Product(price: 0, cost: 0, quantity: 0);

  @override
  final BuildContext context;
  Function callback;
  List<dynamic>? subcategories;
  List<dynamic>? products;
  List<dynamic>? taxes;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  FilePickerCross? file;

  void createProduct(Product product) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    http.MultipartFile? image;

    if (file != null) {
      image = file!.toMultipartFile(filename: file!.fileName);
    }

    var request = http.MultipartRequest(
      "POST",
      Uri.parse("${dotenv.env['SHOP_API_URI']}/api/products"),
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("accessToken");
    request.headers["Authorization"] = "Bearer " + token!;

    Tax findTax(int? id) => taxes!.firstWhere((tax) => tax.id == id);
    Tax tax = findTax(product.taxId);

    request.fields['tax[id]'] = "${tax.id}";
    request.fields['tax[name]'] = "${tax.name}";
    request.fields['tax[amount]'] = "${tax.amount}";
    request.fields["name"] = product.name!;
    request.fields["sku"] = product.sku!;
    request.fields["price"] = product.price.toString();
    request.fields["cost"] = product.cost.toString();
    request.fields["subcategory_id"] = product.subcategoryId.toString();

    if (image != null) {
      request.files.add(image);
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Uspješno dodan novi proizvod", Colors.green));
    } else if (response.statusCode == 422) {
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Došlo je do validacijske greške: Ime ili inventarni broj proizvoda su vjerojatno već zauzeti", Colors.deepOrange));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Došlo je do greške", Colors.red));
    }

    image = null;
    file = null;

    callback("");
  }

  void uploadFile() async {
    file = await FilePickerCross.importFromStorage(
        type: FileTypeCross.image,
        fileExtension: 'png, jpg, jpeg, bmp'
    );
  }

  final _debouncer = Debouncer(milliseconds: 250);

  @override
  Widget build(BuildContext context) {

    product.subcategoryId = null;
    product.taxId = null;
    subcategories = widget.subcategories;
    products = widget.products;
    taxes = widget.taxes;
    var dts = DTS(context: context, callback: callback, subcategories: subcategories, products: products, taxes: taxes);

    return PaginatedDataTable(
        header: Row(
          children: [
            const Text('Proizvodi'),
            const SizedBox(
              width: 10
            ),
            SizedBox(
              width: 30,
              child: Tooltip(
                message: 'Dodaj novi proizvod',
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
                              title: const Text('Dodaj novi proizvod'),
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
                                            value: product.subcategoryId,
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
                                            hint: const Text('Odaberite potkategoriju'),
                                            isExpanded: true,
                                            onChanged: (value) {
                                              product.subcategoryId = int.parse(value.toString());
                                            },
                                            validator: (value) {
                                              if (value == null) {
                                                return 'Molimo odaberite potkategoriju';
                                              }
                                              return null;
                                            },
                                            items: subcategories!.map((subcategory){
                                              return DropdownMenuItem(
                                                  value: subcategory.id.toString(),
                                                  child: Text(subcategory.name)
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                        const SizedBox(width: 25),
                                        Container(
                                          width: 250,
                                          child: DropdownButtonFormField(
                                            value: product.taxId,
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
                                            hint: const Text('Odaberite porez'),
                                            isExpanded: true,
                                            onChanged: (value) {
                                              product.taxId = int.parse(value.toString());
                                            },
                                            validator: (value) {
                                              if (value == null) {
                                                return 'Molimo odaberite porez';
                                              }
                                              return null;
                                            },
                                            items: taxes!.map((tax){
                                              return DropdownMenuItem(
                                                  value: tax.id.toString(),
                                                  child: Text(tax.name)
                                              );
                                            }).toList(),
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
                                                return 'Molimo unesite ime proizvoda';
                                              }
                                              return null;
                                            },
                                            onSaved: (value) => product.name = value!,
                                            cursorColor: Colors.orange,
                                            decoration: InputDecoration(
                                              hintText: "Ime proizvoda",
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(color: Colors.orange, width: 2),
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                              prefixIcon: const Icon(
                                                Icons.liquor,
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
                                                return 'Molimo unesite inventarni broj proizvoda';
                                              }
                                              return null;
                                            },
                                            onSaved: (value) => product.sku = value!,
                                            cursorColor: Colors.orange,
                                            decoration: InputDecoration(
                                              hintText: "Inventarni broj proizvoda",
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
                                      children: [
                                        Container(
                                          width: 250,
                                          child: TextFormField(
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Molimo unesite prodajnu cijenu proizvoda';
                                              }
                                              return null;
                                            },
                                            inputFormatters: [
                                              CurrencyTextInputFormatter(
                                                locale: 'hr',
                                                decimalDigits: 2,
                                                symbol: 'HRK ',
                                              )
                                            ],
                                            keyboardType: TextInputType.number,
                                            onSaved: (value) => product.price = unFormatPrice(value),
                                            cursorColor: Colors.orange,
                                            decoration: InputDecoration(
                                              hintText: "Prodajna cijena proizvoda",
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(color: Colors.orange, width: 2),
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                              prefixIcon: const Icon(
                                                Icons.money,
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
                                                return 'Molimo unesite nabavnu cijenu proizvoda';
                                              }
                                              return null;
                                            },
                                            inputFormatters: [
                                              CurrencyTextInputFormatter(
                                                locale: 'hr',
                                                decimalDigits: 2,
                                                symbol: 'HRK ',
                                              )
                                            ],
                                            keyboardType: TextInputType.number,
                                            onSaved: (value) => product.cost = unFormatPrice(value),
                                            cursorColor: Colors.orange,
                                            decoration: InputDecoration(
                                              hintText: "Nabavna cijena proizvoda",
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(color: Colors.orange, width: 2),
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                              prefixIcon: const Icon(
                                                Icons.monetization_on,
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
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(40),
                                            child: TextButton(
                                              onPressed: () {
                                                uploadFile();
                                              },
                                              child: const Text('Priloži sliku'),
                                              style: TextButton.styleFrom(
                                                padding: const EdgeInsets.fromLTRB(80, 20, 80, 20),
                                                primary: Colors.white,
                                                backgroundColor: Colors.orange,
                                                textStyle: const TextStyle(fontSize: 18),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 25),
                                        Container(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(40),
                                            child: TextButton(
                                              onPressed: () {
                                                if (_formKey.currentState!.validate()) {
                                                  _formKey.currentState!.save();
                                                  createProduct(product);
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
            const Spacer(),
            SizedBox(
              width: 400,
              child: TextFieldContainer(
                child: TextFormField(
                  onChanged: (value) {
                    _debouncer.run(() {
                      setState(() {
                        callback(value);
                      });
                    });
                  },
                  cursorColor: Colors.orange,
                  decoration: InputDecoration(
                    hintText: "Pretražite proizvode",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.orange, width: 2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.orange,
                    ),
                  ),
                )
              ),
            )
          ]
        ),
        columns: const [
          DataColumn(
            label: Text('Naziv'),
          ),
          DataColumn(
            label: Text('Cijena'),
          ),
          DataColumn(
            label: Text('Potkategorija'),
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
    );
  }
}

class DTS extends DataTableSource with FormatPrice, DeleteDialog, CustomSnackBar {
  DTS({
    required this.context,
    required this.callback,
    required this.subcategories,
    required this.products,
    required this.taxes,
  });

  final _formKey = GlobalKey<FormState>();
  final BuildContext context;
  Function callback;
  List<dynamic>? subcategories;
  final List<dynamic>? products;
  final List<dynamic>? taxes;
  FilePickerCross? file;

  void uploadFile() async {
    file = await FilePickerCross.importFromStorage(
        type: FileTypeCross.image,
        fileExtension: 'png, jpg, jpeg, bmp'
    );
  }

  void updateProduct(Product product) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    http.MultipartFile? image;

    if (file != null) {
      image = file!.toMultipartFile(filename: file!.fileName);
    }

    var request = http.MultipartRequest(
      "POST",
      Uri.parse("${dotenv.env['SHOP_API_URI']}/api/products/${product.id}"),
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("accessToken");
    request.headers["Authorization"] = "Bearer " + token!;

    Tax findTax(int? id) => taxes!.firstWhere((tax) => tax.id == id);
    Tax tax = findTax(product.taxId);

    request.fields['tax[id]'] = "${tax.id}";
    request.fields['tax[name]'] = "${tax.name}";
    request.fields['tax[amount]'] = "${tax.amount}";

    request.fields["name"] = product.name!;
    request.fields["sku"] = product.sku!;
    request.fields["price"] = product.price.toString();
    request.fields["cost"] = product.cost.toString();
    request.fields["subcategory_id"] = product.subcategoryId.toString();

    if (image != null) {
      request.files.add(image);
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Uspješno ažuriran proizvod", Colors.green));
    } else if (response.statusCode == 422) {
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Došlo je do validacijske greške: Ime ili inventarni broj proizvoda su vjerojatno već zauzeti", Colors.deepOrange));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Došlo je do greške", Colors.red));
    }

    callback("");
  }

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= products!.length) return null;
    final product = products![index];

    return DataRow.byIndex(
      index: index,
      cells: [
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
          Text("${product.subcategory!.name}")
        ),
        DataCell(
          Row(
            children: <Widget>[
              const Spacer(),
              SizedBox(
                width: 30.0,
                height: 30.0,
                child: Tooltip(
                    message: 'Pregledaj proizvod ${product.name}',
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
                          builder: (BuildContext context)
                        {
                          return AlertDialog(
                            title: const Text('Pregled proizvoda'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Image.network("${product.image}", width: 200)
                                  ]
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Container(
                                      width: 250,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("Ime: ${product.name}")
                                      ),
                                    ),
                                    const SizedBox(width: 25),
                                    Container(
                                      width: 250,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("Potkategorija: ${product.subcategory!.name}")
                                      ),
                                    ),
                                  ]
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 250,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("Kategorija: ${product.subcategory!.category!.name}")
                                      ),
                                    ),
                                    const SizedBox(width: 25),
                                    Container(
                                      width: 250,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("Prodajna cijena: ${formatPrice(product.price)}")
                                      ),
                                    ),
                                  ]
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 250,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("Nabavna cijena: ${formatPrice(product.cost)}")
                                      ),
                                    ),
                                    const SizedBox(width: 25),
                                    Container(
                                      width: 250,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("Inventarni broj: ${product.sku}")
                                      ),
                                    ),
                                  ]
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 250,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("Porez: ${product.tax.name} (${product.tax.amount}%)")
                                      ),
                                    ),
                                  ]
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(40),
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('U redu'),
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.fromLTRB(90, 20, 90, 20),
                                          primary: Colors.white,
                                          backgroundColor: Colors.orange,
                                          textStyle: const TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    ),
                                  ]
                                ),
                              ]
                            )
                          );
                        });
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
                  message: 'Uredi proizvod ${product.name}',
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
                            title: const Text('Uredi proizvod'),
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
                                          value: product.subcategoryId.toString(),
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
                                          hint: const Text('Odaberite potkategoriju'),
                                          isExpanded: true,
                                          onChanged: (value) {
                                            product.subcategoryId = int.parse(value.toString());
                                          },
                                          validator: (value) {
                                            if (value == null) {
                                              return 'Molimo odaberite potkategoriju';
                                            }
                                            return null;
                                          },
                                          items: subcategories!.map((subcategory){
                                            return DropdownMenuItem(
                                                value: subcategory.id.toString(),
                                                child: Text(subcategory.name)
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      const SizedBox(width: 25),
                                      Container(
                                        width: 250,
                                        child: DropdownButtonFormField(
                                          value: product.taxId.toString(),
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
                                          hint: const Text('Odaberite porez'),
                                          isExpanded: true,
                                          onChanged: (value) {
                                            product.taxId = int.parse(value.toString());
                                          },
                                          validator: (value) {
                                            if (value == null) {
                                              return 'Molimo odaberite porez';
                                            }
                                            return null;
                                          },
                                          items: taxes!.map((tax){
                                            return DropdownMenuItem(
                                                value: tax.id.toString(),
                                                child: Text(tax.name)
                                            );
                                          }).toList(),
                                        )
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
                                              return 'Molimo unesite ime proizvoda';
                                            }
                                            return null;
                                          },
                                          onSaved: (value) => product.name = value!,
                                          initialValue: product.name,
                                          cursorColor: Colors.orange,
                                          decoration: InputDecoration(
                                            hintText: "Ime proizvoda",
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(25),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(color: Colors.orange, width: 2),
                                              borderRadius: BorderRadius.circular(25),
                                            ),
                                            prefixIcon: const Icon(
                                              Icons.liquor,
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
                                              return 'Molimo unesite inventarni broj proizvoda';
                                            }
                                            return null;
                                          },
                                          onSaved: (value) => product.sku = value!,
                                          initialValue: product.sku,
                                          cursorColor: Colors.orange,
                                          decoration: InputDecoration(
                                            hintText: "Inventarni broj proizvoda",
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
                                    children: [
                                      Container(
                                        width: 250,
                                        child: TextFormField(
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Molimo unesite prodajnu cijenu proizvoda';
                                            }
                                            return null;
                                          },
                                          inputFormatters: [
                                            CurrencyTextInputFormatter(
                                              locale: 'hr',
                                              decimalDigits: 2,
                                              symbol: 'HRK ',
                                            )
                                          ],
                                          keyboardType: TextInputType.number,
                                          onSaved: (value) => product.price = unFormatPrice(value),
                                          initialValue: formatPrice(product.price),
                                          cursorColor: Colors.orange,
                                          decoration: InputDecoration(
                                            hintText: "Prodajna cijena proizvoda",
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(25),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(color: Colors.orange, width: 2),
                                              borderRadius: BorderRadius.circular(25),
                                            ),
                                            prefixIcon: const Icon(
                                              Icons.money,
                                              color: Colors.orange,
                                            ),
                                          ),
                                        )
                                      ),
                                      const SizedBox(width: 25),
                                      Container(
                                        width: 250,
                                        child: TextFormField(
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Molimo unesite nabavnu cijenu proizvoda';
                                            }
                                            return null;
                                          },
                                          inputFormatters: [
                                            CurrencyTextInputFormatter(
                                              locale: 'hr',
                                              decimalDigits: 2,
                                              symbol: 'HRK ',
                                            )
                                          ],
                                          keyboardType: TextInputType.number,
                                          onSaved: (value) => product.cost = unFormatPrice(value),
                                          initialValue: formatPrice(product.cost),
                                          cursorColor: Colors.orange,
                                          decoration: InputDecoration(
                                            hintText: "Nabavna cijena proizvoda",
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(25),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(color: Colors.orange, width: 2),
                                              borderRadius: BorderRadius.circular(25),
                                            ),
                                            prefixIcon: const Icon(
                                              Icons.monetization_on,
                                              color: Colors.orange,
                                            ),
                                          ),
                                        )
                                      ),
                                    ]
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Container(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(40),
                                          child: TextButton(
                                            onPressed: () {
                                              uploadFile();
                                            },
                                            child: const Text('Priloži sliku'),
                                            style: TextButton.styleFrom(
                                              padding: const EdgeInsets.fromLTRB(80, 20, 80, 20),
                                              primary: Colors.white,
                                              backgroundColor: Colors.orange,
                                              textStyle: const TextStyle(fontSize: 18),
                                            ),
                                          ),
                                        )
                                      ),
                                      const SizedBox(width: 25),
                                      Container(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(40),
                                          child: TextButton(
                                            onPressed: () {
                                              if (_formKey.currentState!.validate()) {
                                                _formKey.currentState!.save();
                                                updateProduct(product);
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
              const SizedBox(
                width: 5.0
              ),
              SizedBox(
                width: 30.0,
                height: 30.0,
                child: Tooltip(
                  message: 'Obriši proizvod ${product.name}',
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
                    onPressed: () async {
                      bool fetchAgain = await deleteDialog(
                          context,
                          "Obriši proizvod ${product.name}",
                          "Jeste li sigurni da želite obrisati proizvod ${product.name}?",
                          "${dotenv.env['SHOP_API_URI']}/api/products/${product.id}",
                          "Uspješno izbrisan proizvod"
                      );
                      if (fetchAgain) {
                        callback("");
                      }
                    },
                    child: const Icon(Icons.delete, size: 15.0),
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
  int get rowCount => products!.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}

class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}