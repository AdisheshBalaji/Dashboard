import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: label,
        labelText: label,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          filled: true,
          fillColor: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.1),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
