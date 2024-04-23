import 'package:flutter/material.dart';

class CustomMenuButton extends StatelessWidget {
  final Function onTapCallback;
  final String buttonText;
  final Color buttonColor;

  const CustomMenuButton({
    required this.buttonText,
    this.buttonColor = Colors.blue,
    required this.onTapCallback,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: MaterialButton(
          minWidth: 200,
          height: 50,
          color: buttonColor,
          onPressed: () => onTapCallback(),
          child: Text(
            buttonText,
            style: const TextStyle(fontSize: 24.0),
          ),
        ));
  }
}
