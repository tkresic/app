import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/components/text_field_container.dart';
import 'package:app/pages/dashboard/dashboard.dart';
import 'package:app/pages/index/index.dart';
import 'package:app/models/user.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/providers/user_provider.dart';
import 'package:app/pages/login/components/background.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  String _username = "", _password = "";
  bool _obscurePassword = true;
  bool _loggingIn = false;

  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context);
    Size size = MediaQuery.of(context).size;

    var doLogin = () {
      _loggingIn = true;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      final form = _formKey.currentState;

      if (form!.validate()) {
        form.save();
        final Future<Map<String, dynamic>> successfulMessage = auth.login(_username, _password);

        successfulMessage.then((response) {
          if (response['status']) {
            User user = response['user'];
            Provider.of<UserProvider>(context, listen: false).setUser(user);
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => Dashboard(),
                transitionDuration: Duration(seconds: 0),
              ),
            );
          } else {
            // TODO => If invalid data display the snackbar. If error, something else
            final snackBar = SnackBar(
              action: SnackBarAction(
                textColor: Colors.white,
                label: 'X',
                onPressed: () {},
              ),
              content: Row(
                  children: <Widget>[
                    Text("Prijava neuspješna. Molimo provjerite unesene vrijednosti")
                  ]
              ),
              backgroundColor: Colors.blue,
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
          _loggingIn = false;
        });
      }
    };

    return Scaffold(
      body: Background(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: size.height * 0.03),
              Image.asset(
                "assets/images/Login.png",
                height: size.height * 0.35,
              ),
              SizedBox(height: size.height * 0.03),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFieldContainer(
                      child: TextFormField(
                        validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Molimo unesite korisničko ime';
                        }
                          return null;
                        },
                        enabled: !_loggingIn,
                        onSaved: (value) => _username = value!,
                        cursorColor: Colors.orange,
                        initialValue: "tonikresic1997@gmail.com",
                        decoration: InputDecoration(
                          hintText: "Unesite korisničko ime",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.orange, width: 2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          prefixIcon: Icon(
                            Icons.person,
                            color: Colors.orange,
                          ),
                        ),
                      )
                    ),
                    TextFieldContainer(
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Molimo unesite lozinku';
                          }
                          return null;
                        },
                        enabled: !_loggingIn,
                        obscureText: _obscurePassword,
                        onSaved: (value) => _password = value!,
                        cursorColor: Colors.orange,
                        initialValue: "to102030ni",
                        decoration: InputDecoration(
                          hintText: "Unesite lozinku",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(29),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.orange, width: 2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Colors.orange,
                          ),
                          suffixIcon: new GestureDetector(
                            onTap: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            child:
                            Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off,  color: Colors.orange),
                          ),
                        ),
                      )
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: TextButton(
                            onPressed: () {
                              if (!_loggingIn) {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation1, animation2) => Index(),
                                    transitionDuration: Duration(seconds: 0),
                                  ),
                                );
                              } else {
                                return null;
                              }
                            },
                            child: Text(
                              'Natrag',
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.fromLTRB(80, 20, 80, 20),
                              primary: Colors.white,
                              backgroundColor: Colors.orange,
                              textStyle: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        SizedBox(width: 50), // give it width
                        ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: TextButton(
                            onPressed: () {
                              if (!_loggingIn) {
                                doLogin();
                              } else {
                                return null;
                              }
                            },
                            child: Text(
                              auth.loggedInStatus == Status.Authenticating ? 'Prijavljujem se...' : 'Prijava'
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.fromLTRB(80, 20, 80, 20),
                              primary: Colors.white,
                              backgroundColor: Colors.orange,
                              textStyle: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}