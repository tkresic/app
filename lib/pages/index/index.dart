import 'package:flutter/material.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/login/login.dart';
import 'package:app/pages/index/components/background.dart';

class Index extends StatelessWidget {
  final User? user;

  const Index({Key? key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Background(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                "Fiskalna Blagajna",
                style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold, fontSize: 30, color: Color(0xFFB3B3B3)),
              ),
              SizedBox(height: size.height * 0.05),
              Image.asset(
                "assets/images/Index.png",
                height: size.height * 0.45,
              ),
              SizedBox(height: size.height * 0.05),
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) => Login(),
                        transitionDuration: const Duration(seconds: 0),
                      ),
                    );
                  },
                  child: const Text(
                    'Prijava',
                  ),
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
      )
    );
  }
}