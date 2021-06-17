import 'dart:convert';
import 'dart:io';
import 'package:app/components/custom_app_bar.dart';
import 'package:app/components/drawer_list.dart';
import 'package:app/components/loader.dart';
import 'package:app/components/middleware.dart';
import 'package:app/mixins/delete_dialog.dart';
import 'package:app/mixins/snackbar.dart';
import 'package:app/models/category.dart';
import 'package:app/models/subcategory.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:app/models/user.dart';
import 'package:app/providers/user_provider.dart';
import 'package:http_interceptor/http/intercepted_client.dart';
import 'package:app/util/http_interceptor.dart';
import 'package:http/http.dart' as http;

class Categories extends StatefulWidget {
  const Categories({Key? key}) : super(key: key);

  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> with DeleteDialog, CustomSnackBar {

  http.Client client = InterceptedClient.build(interceptors: [
    ApiInterceptor(),
  ]);
  final _formKey = GlobalKey<FormState>();
  Category category = Category();

  Future<Map<String, List>> fetchData() async {
    var categories = await client.get(Uri.parse("${dotenv.env['SHOP_API_URI']}/api/categories"));
    var subcategories = await client.get(Uri.parse("${dotenv.env['SHOP_API_URI']}/api/subcategories"));
    return {
      "categories" : Category.parseCategories(categories.body),
      "subcategories" : Subcategory.parseSubcategories(subcategories.body)
    };
  }

  void callback() {
    setState(() {});
  }

  void createCategory(Category category) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    http.Response response = await client.post(
      Uri.parse("${dotenv.env['SHOP_API_URI']}/api/categories"),
      body: json.encode({
        "name" : category.name,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Uspješno dodana nova kategorija", Colors.green));
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

    setState(() {});
  }

  void updateCategory(Category category) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    http.Response response = await client.put(
      Uri.parse("${dotenv.env['SHOP_API_URI']}/api/categories/${category.id}"),
      body: json.encode({
        "name" : category.name,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Uspješno ažurirana kategorija", Colors.green));
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
        child: DrawerList(index: 1),
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
                    return const Center(child: Text("Došlo je do greške."));
                  }
                }
                if (snapshot.hasData) {
                  return SingleChildScrollView(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(left: 25, top: 25, bottom: 10),
                                    child: const Text(
                                      "Kategorije",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  )
                                ]
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 80,
                                    margin: const EdgeInsets.only(left: 25),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: snapshot.data!['categories']!.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        return Container(
                                          margin: const EdgeInsets.all(5),
                                          padding: const EdgeInsets.only(top: 5),
                                          width: 120,
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
                                          child: ListTile(
                                              title: Text('${snapshot.data!['categories']![index].name}'),
                                              subtitle: Container(
                                                  margin: const EdgeInsets.only(top: 7),
                                                  child: Row(
                                                      children: [
                                                        SizedBox(
                                                          width: 25.0,
                                                          height: 25.0,
                                                          child: Tooltip(
                                                            message: 'Uredi kategoriju ${snapshot.data!['categories']![index].name}',
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
                                                                      title: const Text('Uredi kategoriju'),
                                                                      content: Form(
                                                                        key: _formKey,
                                                                        child: Column(
                                                                          mainAxisSize: MainAxisSize.min,
                                                                          children: <Widget>[
                                                                            Row(
                                                                              children: [
                                                                                Container(
                                                                                  width: 280,
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.all(8.0),
                                                                                    child: TextFormField(
                                                                                      validator: (value) {
                                                                                        if (value == null || value.isEmpty) {
                                                                                          return 'Molimo unesite ime kategorije';
                                                                                        }
                                                                                        return null;
                                                                                      },
                                                                                      onSaved: (value) => snapshot.data!['categories']![index].name = value!,
                                                                                      initialValue: snapshot.data!['categories']![index].name,
                                                                                      cursorColor: Colors.orange,
                                                                                      decoration: InputDecoration(
                                                                                        hintText: "Ime kategorije",
                                                                                        border: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(25),
                                                                                        ),
                                                                                        focusedBorder: OutlineInputBorder(
                                                                                          borderSide: const BorderSide(color: Colors.orange, width: 2),
                                                                                          borderRadius: BorderRadius.circular(25),
                                                                                        ),
                                                                                        prefixIcon: const Icon(
                                                                                          Icons.category,
                                                                                          color: Colors.orange,
                                                                                        ),
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
                                                                                ClipRRect(
                                                                                  borderRadius: BorderRadius.circular(40),
                                                                                  child: TextButton(
                                                                                    onPressed: () {
                                                                                      if (_formKey.currentState!.validate()) {
                                                                                        _formKey.currentState!.save();
                                                                                        updateCategory(snapshot.data!['categories']![index]);
                                                                                        Navigator.of(context).pop();
                                                                                      }
                                                                                    },
                                                                                    child: const Text('Spremi'),
                                                                                    style: TextButton.styleFrom(
                                                                                      padding: const EdgeInsets.fromLTRB(105, 20, 105, 20),
                                                                                      primary: Colors.white,
                                                                                      backgroundColor: Colors.orange,
                                                                                      textStyle: const TextStyle(fontSize: 18),
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              ]
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    );
                                                                  });
                                                              },
                                                              child: const Icon(Icons.edit, size: 12.0),
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
                                                          width: 25.0,
                                                          height: 25.0,
                                                          child: Tooltip(
                                                            message: 'Obriši kategoriju ${snapshot.data!['categories']![index].name}',
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
                                                                  "Obriši kategoriju ${snapshot.data!['categories']![index].name}",
                                                                  "Jeste li sigurni da želite obrisati kategoriju ${snapshot.data!['categories']![index].name}?",
                                                                  "${dotenv.env['SHOP_API_URI']}/api/categories/${snapshot.data!['categories']![index].id}",
                                                                  "Uspješno izbrisana kategorija",
                                                                );
                                                                if (fetchAgain) {
                                                                  setState(() {});
                                                                }
                                                              },
                                                              child: const Icon(Icons.delete, size: 12.0),
                                                              backgroundColor: Colors.red,
                                                              elevation: 3,
                                                              hoverElevation: 4,
                                                            ),
                                                          ),
                                                        ),
                                                      ]
                                                  )
                                              )
                                          ),
                                        );
                                      },
                                    )
                                  ),
                                  Container(
                                      margin: const EdgeInsets.only(left: 10),
                                      child: SizedBox(
                                        width: 30,
                                        child: Tooltip(
                                            message: 'Dodaj novu kategoriju',
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
                                                        title: const Text('Dodaj novu kategoriju'),
                                                        content: Form(
                                                          key: _formKey,
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: <Widget>[
                                                              Row(
                                                                children: [
                                                                  Container(
                                                                    width: 280,
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: TextFormField(
                                                                        validator: (value) {
                                                                          if (value == null || value.isEmpty) {
                                                                            return 'Molimo unesite ime kategorije';
                                                                          }
                                                                          return null;
                                                                        },
                                                                        onSaved: (value) => category.name = value!,
                                                                        cursorColor: Colors.orange,
                                                                        decoration: InputDecoration(
                                                                          hintText: "Ime kategorije",
                                                                          border: OutlineInputBorder(
                                                                            borderRadius: BorderRadius.circular(25),
                                                                          ),
                                                                          focusedBorder: OutlineInputBorder(
                                                                            borderSide: const BorderSide(color: Colors.orange, width: 2),
                                                                            borderRadius: BorderRadius.circular(25),
                                                                          ),
                                                                          prefixIcon: const Icon(
                                                                            Icons.category,
                                                                            color: Colors.orange,
                                                                          ),
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
                                                                  ClipRRect(
                                                                    borderRadius: BorderRadius.circular(40),
                                                                    child: TextButton(
                                                                      onPressed: () {
                                                                        if (_formKey.currentState!.validate()) {
                                                                          _formKey.currentState!.save();
                                                                          createCategory(category);
                                                                          Navigator.of(context).pop();
                                                                        }
                                                                      },
                                                                      child: const Text('Dodaj'),
                                                                      style: TextButton.styleFrom(
                                                                        padding: const EdgeInsets.fromLTRB(105, 20, 105, 20),
                                                                        primary: Colors.white,
                                                                        backgroundColor: Colors.orange,
                                                                        textStyle: const TextStyle(fontSize: 18),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ]
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    });
                                              },
                                              child: const Icon(Icons.add, size: 15.0),
                                              backgroundColor: Colors.orange,
                                              elevation: 3,
                                              hoverElevation: 4,
                                            )
                                        ),
                                      )
                                  )
                                ]
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.all(25),
                                      child: SubcategoriesList(context: context, client: client, categories: snapshot.data!['categories'], subcategories: snapshot.data!['subcategories'], callback: callback)
                                    )
                                  )
                                ]
                              ),
                            ],
                          ),
                        )
                      ]
                    )
                  );
                } else {
                  return const Loader(message: "Dohvaćam kategorije...");
                }
              },
            )
          )
        ],
      ),
    );
  }
}

class SubcategoriesList extends StatefulWidget {
  const SubcategoriesList({
    Key? key,
    required this.context,
    required this.client,
    required this.callback,
    this.categories,
    this.subcategories,
  }) : super(key: key);

  final BuildContext context;
  final http.Client client;
  final List<dynamic>? categories;
  final List<dynamic>? subcategories;
  final Function callback;

  @override
  _SubcategoriesListState createState() => _SubcategoriesListState(context: context, client: client, categories: categories, subcategories: subcategories, callback: callback);
}

class _SubcategoriesListState extends State<SubcategoriesList> with CustomSnackBar {
  _SubcategoriesListState({
    required this.context,
    required this.client,
    required this.callback,
    required this.categories,
    required this.subcategories,
  });

  final _formKey = GlobalKey<FormState>();
  Subcategory subcategory = Subcategory();

  @override
  final BuildContext context;
  http.Client client;
  List<dynamic>? categories;
  List<dynamic>? subcategories;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  Function callback;

  void createSubcategory(Subcategory subcategory) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    http.Response response = await client.post(
      Uri.parse("${dotenv.env['SHOP_API_URI']}/api/subcategories"),
      body: json.encode({
        "category_id" : subcategory.categoryId,
        "name" : subcategory.name,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Uspješno dodana nova potkategorija", Colors.green));
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

    callback();
  }

  @override
  Widget build(BuildContext context) {

    subcategory.categoryId = null;
    subcategories = widget.subcategories;
    categories = widget.categories;
    var dts = DTS(context: context, client: client, categories: categories, subcategories: subcategories, callback: callback);

    return PaginatedDataTable(
        header: Row(
          children: [
            const Text('Potkategorije'),
            const SizedBox(
              width: 10
            ),
            SizedBox(
              width: 30,
              child: Tooltip(
                message: 'Dodaj novu potkategoriju',
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
                            title: const Text('Dodaj novu potkategoriju'),
                            content: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Container(
                                        width: 275,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: DropdownButtonFormField(
                                            value: subcategory.categoryId,
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
                                            hint: const Text('Odaberite kategoriju'),
                                            isExpanded: true,
                                            onChanged: (value) {
                                              subcategory.categoryId = int.parse(value.toString());
                                            },
                                            validator: (value) {
                                              if (value == null) {
                                                return 'Molimo odaberite kategoriju';
                                              }
                                              return null;
                                            },
                                            items: categories!.map((category){
                                              return DropdownMenuItem(
                                                  value: category.id.toString(),
                                                  child: Text(category.name)
                                              );
                                            }).toList(),
                                          )
                                        ),
                                      )
                                    ]
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: 275,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Molimo unesite ime potkategorije';
                                              }
                                              return null;
                                            },
                                            onSaved: (value) => subcategory.name = value!,
                                            cursorColor: Colors.orange,
                                            decoration: InputDecoration(
                                              hintText: "Ime potkategorije",
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(color: Colors.orange, width: 2),
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                              prefixIcon: const Icon(
                                                Icons.category_outlined,
                                                color: Colors.orange,
                                              ),
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
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(40),
                                        child: TextButton(
                                          onPressed: () {
                                            if (_formKey.currentState!.validate()) {
                                              _formKey.currentState!.save();
                                              createSubcategory(subcategory);
                                              Navigator.of(context).pop();
                                            }
                                          },
                                          child: const Text('Dodaj'),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.fromLTRB(105, 20, 105, 20),
                                            primary: Colors.white,
                                            backgroundColor: Colors.orange,
                                            textStyle: const TextStyle(fontSize: 18),
                                          ),
                                        ),
                                      ),
                                    ]
                                  )
                                ],
                              ),
                            ),
                          );
                        });
                    },
                    child: const Text("+"),
                    backgroundColor: Colors.orange,
                    elevation: 3,
                    hoverElevation: 4,
                  )
              )
            ),
          ]
      ),
      columns: const [
        DataColumn(
          label: Text('Naziv'),
        ),
        DataColumn(
          label: Text('Kategorija'),
        ),
        DataColumn(
          label: Expanded(
            child: Text('Akcije', textAlign: TextAlign.right)
          )
        )
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

class DTS extends DataTableSource with DeleteDialog, CustomSnackBar {
  DTS({
    required this.context,
    required this.client,
    required this.callback,
    required this.categories,
    required this.subcategories,
  });

  final _formKey = GlobalKey<FormState>();
  final BuildContext context;
  http.Client client;
  Function callback;
  List<dynamic>? categories;
  final List<dynamic>? subcategories;

  void updateSubcategory(Subcategory subcategory) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    http.Response response = await client.put(
      Uri.parse("${dotenv.env['SHOP_API_URI']}/api/subcategories/${subcategory.id}"),
      body: json.encode({
        "category_id" : subcategory.categoryId,
        "name" : subcategory.name,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar("Uspješno ažurirana potkategorija", Colors.green));
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

    callback();
  }

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= subcategories!.length) return null;
    final subcategory = subcategories![index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(
          Text(subcategory.name)
        ),
        DataCell(
          Text('${subcategory.category.name}')
        ),
        DataCell(
          Row(
            children: <Widget>[
              const Spacer(),
              SizedBox(
                width: 30.0,
                height: 30.0,
                child: Tooltip(
                  message: 'Uredi potkategoriju ${subcategory.name}',
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
                            title: const Text('Uredi potkategoriju'),
                            content: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Container(
                                        width: 275,
                                        child:  Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: DropdownButtonFormField(
                                              value: subcategory.categoryId.toString(),
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
                                              hint: const Text('Odaberite kategoriju'),
                                              isExpanded: true,
                                              onChanged: (value) {
                                                subcategory.categoryId = int.parse(value.toString());
                                              },
                                              validator: (value) {
                                                if (value == null) {
                                                  return 'Molimo odaberite kategoriju';
                                                }
                                                return null;
                                              },
                                              items: categories!.map((category) {
                                                return DropdownMenuItem(
                                                    value: category.id.toString(),
                                                    child: Text(category.name)
                                                );
                                              }).toList(),
                                            )
                                        ),
                                      )
                                    ]
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Container(
                                        width: 275,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Molimo unesite ime potkategorije';
                                              }
                                              return null;
                                            },
                                            onSaved: (value) => subcategory.name = value!,
                                            initialValue: subcategory.name,
                                            cursorColor: Colors.orange,
                                            decoration: InputDecoration(
                                              hintText: "Ime potkategorije",
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(color: Colors.orange, width: 2),
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                              prefixIcon: const Icon(
                                                Icons.category_outlined,
                                                color: Colors.orange,
                                              ),
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
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(40),
                                        child: TextButton(
                                          onPressed: () {
                                            if (_formKey.currentState!.validate()) {
                                              _formKey.currentState!.save();
                                              updateSubcategory(subcategory);
                                              Navigator.of(context).pop();
                                            }
                                          },
                                          child: const Text('Spremi'),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.fromLTRB(105, 20, 105, 20),
                                            primary: Colors.white,
                                            backgroundColor: Colors.orange,
                                            textStyle: const TextStyle(fontSize: 18),
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
                  message: 'Obriši potkategoriju ${subcategory.name}',
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
                        "Obriši potkategoriju ${subcategory.name}",
                        "Jeste li sigurni da želite obrisati potkategoriju ${subcategory.name}?",
                        "${dotenv.env['SHOP_API_URI']}/api/subcategories/${subcategory.id}",
                        "Uspješno izbrisana potkategorija"
                      );
                      if (fetchAgain) {
                        callback();
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
  int get rowCount => subcategories!.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}