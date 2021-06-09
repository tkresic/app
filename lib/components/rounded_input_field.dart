import 'package:flutter/material.dart';
import 'package:app/components/text_field_container.dart';

class RoundedInputField extends StatelessWidget {

  // TODO => Not being used

  final ValueChanged<String> onChanged;
  const RoundedInputField({
    Key? key,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        // The validator receives the text that the user has entered.
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Molimo unesite korisničko ime';
          }
          return null;
        },
        onChanged: onChanged,
        onFieldSubmitted: (value) {
        },
        cursorColor: Colors.orange,
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
    );
  }
}