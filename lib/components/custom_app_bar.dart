import 'package:app/models/user.dart';
import 'package:app/pages/index/index.dart';
import 'package:app/providers/user_provider.dart';
import 'package:app/util/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'middleware.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {

  @override
  Widget build(BuildContext context) {

    User? user = Provider.of<UserProvider>(context).user;

    if (user == null) {
      return const Middleware();
    }

    return AppBar(
      leading: Builder(
        builder: (BuildContext context) {
          return Tooltip(
            message: 'Izbornik',
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
            child: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () { Scaffold.of(context).openDrawer(); },
            )
          );
        },
      ),
      backgroundColor: Colors.orange,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // TODO => Fetch cash register label from Corporate, storage it and display it here
          Text("Blagajna ${dotenv.env['CASH_REGISTER_ID']}", style: const TextStyle(fontSize: 14, color: Colors.white)),
          const Spacer(),
          Container(
            child: const CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 12,
              child: Icon(Icons.person_outlined, color: Colors.white, size: 20),
            ),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2.0,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text("${user.name} ${user.surname}", style: const TextStyle(fontSize: 14, color: Colors.white)),
          const SizedBox(width: 10),
        ]
      ),
      actions: <Widget>[
        Tooltip(
          message: 'Odjava',
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
          child: IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              // TODO => Remove user from app state and notify listeners. Implement logout
              SharedPref().remove("user");
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => const Index(),
                  transitionDuration: const Duration(seconds: 0),
                ),
              );
            },
          )
        )
      ],
    );
  }
}