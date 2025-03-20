import 'package:flutter/material.dart';

class CustomScrollBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return RawScrollbar(
      controller: details.controller,
      thumbColor: const Color(0xFFFF5722),
      radius: const Radius.circular(10),
      thickness: 4,
      thumbVisibility: true,
      child: child,
    );
  }
}
