import 'package:flutter/material.dart';
import 'package:app/components/text_field_container.dart';

class RoundedPasswordField extends StatefulWidget{

  // TODO => Not being used


  final ValueChanged<String> onChanged;

  RoundedPasswordField({
    Key? key,
    required this.onChanged,
  }) : super(key: key);

  PasswordField createState()=> PasswordField();
}

class PasswordField extends State<RoundedPasswordField>{
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
        child: TextFormField(
          // The validator receives the text that the user has entered.
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Molimo unesite lozinku';
            }
            return null;
          },
          obscureText: _obscurePassword,
          onChanged: widget.onChanged,
          cursorColor: Colors.orange,
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
    );
  }
}