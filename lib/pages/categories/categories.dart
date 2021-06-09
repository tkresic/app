import 'package:app/components/custom_app_bar.dart';
import 'package:app/components/drawer_list.dart';
import 'package:app/components/middleware.dart';
import 'package:app/mixins/delete_dialog.dart';
import 'package:app/models/category.dart';
import 'package:app/models/subcategory.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:app/models/user.dart';
import 'package:app/providers/user_provider.dart';

class Categories extends StatefulWidget {
  const Categories({Key? key}) : super(key: key);

  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> with DeleteDialog {
  // TODO => Slice data table into a component
  final _formKey = GlobalKey<FormState>();

  Future<Map<String, List>> fetchData() async {
    var categories = await http.get(Uri.parse("${dotenv.env['SHOP_API_URI']}/api/categories"));
    var subcategories = await http.get(Uri.parse("${dotenv.env['SHOP_API_URI']}/api/subcategories"));
    return {
      "categories" : Category.parseCategories(categories.body),
      "subcategories" : Subcategory.parseSubcategories(subcategories.body)
    };
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
                  return const Center(child: Text("Došlo je do greške."));
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
                                                                              Padding(
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
                                                                                    hintText: "Unesite ime kategorije",
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
                                                                              const SizedBox(height: 10),
                                                                              ClipRRect(
                                                                                borderRadius: BorderRadius.circular(40),
                                                                                child: TextButton(
                                                                                  onPressed: () {
                                                                                    // TODO => Save category
                                                                                    if (_formKey.currentState!.validate()) {
                                                                                      _formKey.currentState!.save();
                                                                                      Navigator.of(context).pop();
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
                                                // TODO => Create new category
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
                                      child: SubcategoriesList(context: context, subcategories: snapshot.data!['subcategories'])
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
                  return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.orange)));
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
    this.subcategories
  }) : super(key: key);

  final BuildContext context;
  final List<dynamic>? subcategories;

  @override
  _SubcategoriesListState createState() => _SubcategoriesListState(context: this.context, subcategories: this.subcategories);
}

class _SubcategoriesListState extends State<SubcategoriesList> {
  _SubcategoriesListState({
    required this.context,
    required this.subcategories
  });

  @override
  final BuildContext context;
  List<dynamic>? subcategories;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  @override
  Widget build(BuildContext context) {
    subcategories = widget.subcategories;
    var dts = DTS(context: context, subcategories: subcategories);
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
                    // TODO => Create new subcategory
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

class DTS extends DataTableSource with DeleteDialog {
  DTS({
    required this.context,
    required this.subcategories
  });

  final BuildContext context;
  final List<dynamic>? subcategories;

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
                        // TODO => Reset state of the main widget
                        // resetState();
                        // fetchData();
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