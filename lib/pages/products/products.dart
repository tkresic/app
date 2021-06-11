import 'package:app/components/custom_app_bar.dart';
import 'package:app/components/drawer_list.dart';
import 'package:app/components/middleware.dart';
import 'package:app/components/text_field_container.dart';
import 'package:app/mixins/delete_dialog.dart';
import 'package:app/mixins/format_price.dart';
import 'package:app/models/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:app/models/user.dart';
import 'package:app/providers/user_provider.dart';

class Products extends StatefulWidget {
  const Products({Key? key}) : super(key: key);

  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  String search = "";

  Future<List<Product>> fetchProducts() async {
    String uri = "${dotenv.env['SHOP_API_URI']}/api/products";
    if (search.isNotEmpty) {
      uri += "?search=$search";
    }
    var response = await http.get(Uri.parse(uri));
    return Product.parseProducts(response.body);
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
            child: FutureBuilder<List<Product>>(
              future: fetchProducts(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Došlo je do greške."));
                }
                if (snapshot.hasData) {
                  return SingleChildScrollView(
                    child: Container(
                      margin: const EdgeInsets.all(25),
                      child: ProductsList(context: context, products: snapshot.data, callback: callback)
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

class ProductsList extends StatefulWidget {
  ProductsList({
    Key? key,
    required this.context,
    this.products,
    required this.callback,
  }) : super(key: key);

  BuildContext context;
  List<Product>? products;
  Function callback;

  @override
  _ProductsListState createState() => _ProductsListState(context: context, products: products, callback: callback);
}

class _ProductsListState extends State<ProductsList> {
  _ProductsListState({
    required this.context,
    required this.products,
    required this.callback
  });

  @override
  BuildContext context;
  List<Product>? products;
  Function callback;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  @override
  Widget build(BuildContext context) {

    products = widget.products;
    var dts = DTS(context: context, products: products, callback: callback);

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
                    // TODO => Create new product
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
                    setState(() {
                      callback(value);
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

class DTS extends DataTableSource with FormatPrice, DeleteDialog {
  DTS({
    required this.context,
    required this.products,
    required this.callback,
  });

  final BuildContext context;
  final List<Product>? products;
  Function callback;

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
              Image.network(product.image, width: 50),
              const SizedBox(width: 10),
              Text(product.name)
            ],
          )
        ),
        DataCell(
          Text(formatPrice(product.price))
        ),
        DataCell(
          Text("${product.subcategory.name}")
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