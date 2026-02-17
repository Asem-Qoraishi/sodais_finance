import 'package:flutter/material.dart';

// Kept only for persistence compatibility while icon UI is removed.
const String kDefaultPersistedCategoryIcon = 'inventory_2';

const List<String> kCategoryColorOptions = [
  '#3B82F6',
  '#EF4444',
  '#10B981',
  '#F59E0B',
  '#8B5CF6',
  '#EC4899',
  '#06B6D4',
  '#F97316',
  '#6366F1',
  '#84CC16',
  '#14B8A6',
  '#64748B',
];

Color hexToColor(String hex) {
  final normalized = hex.replaceFirst('#', '');
  final withAlpha = normalized.length == 6 ? 'FF$normalized' : normalized;
  return Color(int.parse(withAlpha, radix: 16));
}
