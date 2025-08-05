import 'package:flutter/material.dart';
const List<Color> kColorPalette = [
  Color(0xFF6C63FF), // Indigo
  Color(0xFFFF6584), // Vivid Pink
  Color(0xFF00B8D9), // Cyan
  Color(0xFF7F53AC), // Purple
  Color(0xFF009688), // Teal
  Color(0xFF607D8B), // Blue Grey
  Color(0xFF2196F3), // Blue
  Color(0xFFE91E63), // Pink
  Color(0xFF00C9A7), // Teal
  Color(0xFF3F51B5), // Indigo
  Color(0xFF9C27B0), // Purple
  Color(0xFF00BCD4), // Cyan
  Color(0xFF673AB7), // Deep Purple
];

final Map<String, Color> _titleColorMap = {};

Color getColorForTitle(String title) {
  if (_titleColorMap.containsKey(title)) {
    return _titleColorMap[title]!;
  }

  final usedColors = _titleColorMap.values.toSet();
  final availableColors =
      kColorPalette.where((color) => !usedColors.contains(color)).toList();

  final color = availableColors.isNotEmpty
      ? availableColors.first
      : kColorPalette[title.hashCode.abs() % kColorPalette.length];

  _titleColorMap[title] = color;
  return color;
}
