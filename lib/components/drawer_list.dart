import 'package:app/pages/products/products.dart';
import 'package:app/pages/bills/bills.dart';
import 'package:app/pages/dashboard/dashboard.dart';
import 'package:app/pages/settings/settings.dart';
import 'package:app/pages/shifts/shifts.dart';
import 'package:app/pages/categories/categories.dart';
import 'package:app/pages/users/users.dart';
import 'package:flutter/material.dart';

class DrawerList extends StatefulWidget {
  final int index;

  const DrawerList({Key? key, required this.index}) : super(key: key);

  @override
  _DrawerListState createState() => _DrawerListState();
}

class _DrawerListState extends State<DrawerList> {

  Image? logo;

  @override
  void initState() {
    super.initState();
    logo = Image.asset("assets/images/Logo.png");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(logo!.image, context);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        Container(
          height: 200.0,
          child: DrawerHeader(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage("assets/images/DrawerBackground.jpg")
              )
            ),
            child: Center(
              child: logo,
            )
          ),
        ),
        ListTile(
          selected: widget.index == 0,
          selectedTileColor: Colors.orange.withOpacity(0.75),
          title: Row(
            children: <Widget>[
              Icon(Icons.money, color: widget.index == 0 ? Colors.white : Colors.black),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text('Blagajna', style: TextStyle(color: widget.index == 0 ? Colors.white : Colors.black)),
              )
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => const Dashboard(),
                transitionDuration: const Duration(seconds: 0),
              ),
            );
          },
        ),
        ListTile(
          selected: widget.index == 1,
          selectedTileColor: Colors.orange.withOpacity(0.75),
          title: Row(
            children: <Widget>[
              Icon(Icons.category, color: widget.index == 1 ? Colors.white : Colors.black),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text('Kategorije', style: TextStyle(color: widget.index == 1 ? Colors.white : Colors.black)),
              )
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => const Categories(),
                transitionDuration: const Duration(seconds: 0),
              ),
            );
          },
        ),
        ListTile(
          selected: widget.index == 2,
          selectedTileColor: Colors.orange.withOpacity(0.75),
          title: Row(
            children: <Widget>[
              Icon(Icons.liquor, color: widget.index == 2 ? Colors.white : Colors.black),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text('Proizvodi', style: TextStyle(color: widget.index == 2 ? Colors.white : Colors.black)),
              )
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => const Products(),
                transitionDuration: const Duration(seconds: 0),
              ),
            );
          },
        ),
        ListTile(
          selected: widget.index == 3,
          selectedTileColor: Colors.orange.withOpacity(0.75),
          title: Row(
            children: <Widget>[
              Icon(Icons.receipt_long, color: widget.index == 3 ? Colors.white : Colors.black),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text('Računi', style: TextStyle(color: widget.index == 3 ? Colors.white : Colors.black)),
              )
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => const Bills(),
                transitionDuration: const Duration(seconds: 0),
              ),
            );
          },
        ),
        ListTile(
          selected: widget.index == 4,
          selectedTileColor: Colors.orange.withOpacity(0.75),
          title: Row(
            children: <Widget>[
              Icon(Icons.payment, color: widget.index == 4 ? Colors.white : Colors.black),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text('Smjene', style: TextStyle(color: widget.index == 4 ? Colors.white : Colors.black)),
              )
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => const Shifts(),
                transitionDuration: const Duration(seconds: 0),
              ),
            );
          },
        ),
        ListTile(
          selected: widget.index == 5,
          selectedTileColor: Colors.orange.withOpacity(0.75),
          title: Row(
            children: <Widget>[
              Icon(Icons.person, color: widget.index == 5 ? Colors.white : Colors.black),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text('Korisnici', style: TextStyle(color: widget.index == 5 ? Colors.white : Colors.black)),
              )
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => const Users(),
                transitionDuration: const Duration(seconds: 0),
              ),
            );
          },
        ),
        ListTile(
          selected: widget.index == 6,
          selectedTileColor: Colors.orange.withOpacity(0.75),
          title: Row(
            children: <Widget>[
              Icon(Icons.settings, color: widget.index == 6 ? Colors.white : Colors.black),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text('Postavke', style: TextStyle(color: widget.index == 6 ? Colors.white : Colors.black)),
              )
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => const Settings(),
                transitionDuration: const Duration(seconds: 0),
              ),
            );
          },
        ),
      ],
    );
  }
}