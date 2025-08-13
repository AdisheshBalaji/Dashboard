import 'package:flutter/material.dart';

class MeasureSize extends StatefulWidget {
  final Widget child;
  final ValueChanged<Size> onChange;

  const MeasureSize({required this.onChange, required this.child, Key? key})
      : super(key: key);

  @override
  State<MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<MeasureSize> {
  Size oldSize = Size.zero;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newSize = context.size ?? Size.zero;
      if (oldSize != newSize) {
        oldSize = newSize;
        widget.onChange(newSize);
      }
    });
    return widget.child;
  }
}
