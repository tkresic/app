import 'package:app/pages/index/components/background.dart';
import 'package:app/pages/index/index.dart';
import 'package:flutter/material.dart';

class Middleware extends StatelessWidget {
  const Middleware({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text("Pristup nedozvoljen", style: TextStyle(fontWeight: FontWeight.bold)),
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: TextButton(
                  onPressed: () {
                    // TODO => Delete user from app state, storage
                    // SharedPref().remove("user");
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) => const Index(),
                        transitionDuration: const Duration(seconds: 0),
                      ),
                    );
                  },
                  child: const Text(
                    'Početna',
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.fromLTRB(80, 20, 80, 20),
                    primary: Colors.white,
                    backgroundColor: Colors.orange,
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ]
          ),
        )
      )
    );  
  }
}