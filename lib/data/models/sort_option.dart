import 'package:flutter/material.dart';

enum SortOption {
  dateDesc('Fecha (Nuevo a Viejo)', Icons.date_range),
  dateAsc('Fecha (Viejo a Nuevo)', Icons.date_range),
  amountDesc('Monto (Mayor a Menor)', Icons.attach_money),
  amountAsc('Monto (Menor a Mayor)', Icons.attach_money),
  nameAsc('Nombre (A-Z)', Icons.sort_by_alpha),
  nameDesc('Nombre (Z-A)', Icons.sort_by_alpha);

  final String label;
  final IconData icon;
  const SortOption(this.label, this.icon);
}