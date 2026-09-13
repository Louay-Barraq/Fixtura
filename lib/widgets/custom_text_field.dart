import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String text;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.text,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            spreadRadius: 2,
            color: Color(0xFF000000).withValues(alpha: 0.25),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Center(
          child: TextField(
            controller: widget.controller,
            maxLines: 1,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: widget.text,
              hintStyle: TextStyle(
                fontFamily: 'RobotoMono',
                color: Colors.grey[500],
                fontSize: 13,
              ),
            ),
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 13,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
