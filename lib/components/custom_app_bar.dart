import 'package:app/models/shift.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/index/index.dart';
import 'package:app/providers/user_provider.dart';
import 'package:app/util/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  // TODO => Either always fetch last shift when changing routes or keep app bar state in between routes
  Shift? shift;
  Widget text = Text('Smjena trenutno nije aktivna', style: TextStyle(fontSize: 14, color: Colors.white));

  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<UserProvider>(context).user;

    if (user == null) {
      return Middleware();
    }

    String _getCurrentDateTimeString() {
      DateTime now = new DateTime.now();
      DateFormat formatter = new DateFormat('dd.MM.yyyy HH:mm:ss');
      return  formatter.format(now);
    }

    void _startShift() {
      // TODO => Start shift
      setState(() {
        shift = new Shift(id: 1, start: _getCurrentDateTimeString(), end: null, user: user, gross: 0);
        text = Text('Smjena započeta u ${shift!.start}', style: TextStyle(fontSize: 14, color: Colors.white));
      });
    }

    void _endShift() {
      // TODO => End shift
      setState(() {
        shift!.end = _getCurrentDateTimeString();
        // Shift.getData().add(shift!);
        shift = null;
        text = Text('Smjena trenutno nije aktivna', style: TextStyle(fontSize: 14, color: Colors.white));
      });
    }

    return AppBar(
      leading: Builder(
        builder: (BuildContext context) {
          return Tooltip(
            message: 'Navigacija',
            textStyle: TextStyle(color: Colors.black, fontSize: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () { Scaffold.of(context).openDrawer(); },
            )
          );
        },
      ),
      backgroundColor: Colors.orange,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.person, color: Colors.white),
          SizedBox(width: 5),
          Text(user.username, style: TextStyle(color: Colors.white)),
          SizedBox(width: 30),
          ElevatedButton(
            onPressed: (shift == null) ? () =>  _startShift() : null,
            child: Text("Započni smjenu", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(primary: Colors.deepOrange),
          ),
          SizedBox(width: 30),
          ElevatedButton(
            onPressed: (shift != null) ? () =>  _endShift() : null,
            child: Text("Završi smjenu", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(primary: Colors.deepOrange),
          ),
          SizedBox(width: 30),
          text,
        ],
      ),
      actions: <Widget>[
        Tooltip(
          message: 'Odjava',
          textStyle: TextStyle(color: Colors.black, fontSize: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              // TODO => Remove user from app state and notify listeners. Implement logout
              SharedPref().remove("user");
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => Index(),
                  transitionDuration: Duration(seconds: 0),
                ),
              );
            },
          )
        )
      ],
    );
  }
}