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

    void doLogin() {
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
                pageBuilder: (context, animation1, animation2) => const Dashboard(),
                transitionDuration: const Duration(seconds: 0),
              ),
            );
          } else {
            final snackBar = SnackBar(
              action: SnackBarAction(
                textColor: Colors.white,
                label: 'X',
                onPressed: () {},
              ),
              content: Row(
                children: const [
                   Text("Prijava neuspješna. Molimo provjerite unesene vrijednosti")
                ]
              ),
              backgroundColor: Colors.blue,
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
          _loggingIn = false;
        });
      } else {
        _loggingIn = false;
      }
    }

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
                        onFieldSubmitted: (value) {
                          if (!_loggingIn) {
                            doLogin();
                          } else {
                            return;
                          }
                        },
                        cursorColor: Colors.orange,
                        decoration: InputDecoration(
                          hintText: "Unesite korisničko ime",
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
                        onFieldSubmitted: (value) {
                          if (!_loggingIn) {
                            doLogin();
                          } else {
                            return;
                          }
                        },
                        cursorColor: Colors.orange,
                        decoration: InputDecoration(
                          hintText: "Unesite lozinku",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(29),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.orange, width: 2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Colors.orange,
                          ),
                          suffixIcon: GestureDetector(
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
                                    pageBuilder: (context, animation1, animation2) => const Index(),
                                    transitionDuration: const Duration(seconds: 0),
                                  ),
                                );
                              } else {
                                return;
                              }
                            },
                            child: const Text(
                              'Natrag',
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.fromLTRB(80, 20, 80, 20),
                              primary: Colors.white,
                              backgroundColor: Colors.orange,
                              textStyle: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 50), // give it width
                        ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: TextButton(
                            onPressed: () {
                              if (!_loggingIn) {
                                doLogin();
                              } else {
                                return;
                              }
                            },
                            child: auth.loggedInStatus == Status.authenticating ?
                              Row(
                                children: const [
                                  SizedBox(
                                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white)),
                                    height: 15.0,
                                    width: 15.0,
                                  ),
                                  SizedBox(width: 20),
                                  Text("Prijavljujem se...")
                                ]
                              )
                              :
                              const Text("Prijava"),
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