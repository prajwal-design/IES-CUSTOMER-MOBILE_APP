import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool loading;

  const AuthButton(
      {super.key,
      required this.title,
      required this.onTap,
      this.loading = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: title == "LOG IN" ? Colors.white : Color(0xff6610f2)),
        child: Center(
          child: Text(title,
              style: TextStyle(
                  color: title == "LOG IN" ? Colors.black : Colors.white,
                  fontSize: 23)),
        ),
      ),
    );
  }
}
