import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String? userId;
  final String name;
  final String icon;
  final String color;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryModel({
    required this.id,
    this.userId,
    required this.name,
    required this.icon,
    required this.color,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // ✅ CORREGIDO: Factory fromJson con manejo seguro de tipos
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      name: json['name']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '📦',
      color: json['color']?.toString() ?? '#666666',
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? DateTime.now().toIso8601String()),
    );
  }

  // ✅ CORREGIDO: toJson para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'icon': icon,
      'color': color,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // ✅ NUEVO: Método para insertar en Supabase (sin campos auto-generados)
  Map<String, dynamic> toInsertMap() {
    return {
      'user_id': userId,
      'name': name,
      'icon': icon,
      'color': color,
      'is_default': isDefault,
      // 'id', 'created_at', 'updated_at' son auto-generados por Supabase
    };
  }

  // ✅ CORREGIDO: Método para crear una categoría por defecto
  static List<CategoryModel> get defaultCategories {
    return [
      CategoryModel(
        id: '1',
        name: 'Alimentación',
        icon: '🍔',
        color: '#FF6B6B',
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CategoryModel(
        id: '2',
        name: 'Transporte',
        icon: '🚌',
        color: '#4ECDC4',
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CategoryModel(
        id: '3',
        name: 'Materiales',
        icon: '📚',
        color: '#45B7D1',
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CategoryModel(
        id: '4',
        name: 'Matrícula',
        icon: '🎓',
        color: '#96CEB4',
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CategoryModel(
        id: '5',
        name: 'Vivienda',
        icon: '🏠',
        color: '#FFEAA7',
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CategoryModel(
        id: '6',
        name: 'Entretenimiento',
        icon: '🎬',
        color: '#DDA0DD',
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CategoryModel(
        id: '7',
        name: 'Salud',
        icon: '🏥',
        color: '#98D8C8',
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CategoryModel(
        id: '8',
        name: 'Otros',
        icon: '📦',
        color: '#F7DC6F',
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // ✅ CORREGIDO: Método para obtener categorías por defecto desde Supabase
  static List<CategoryModel> getDefaultCategoriesFromSupabase(List<dynamic> supabaseData) {
    return supabaseData
        .map((data) => CategoryModel.fromJson(data))
        .where((category) => category.isDefault)
        .toList();
  }

  // ✅ CORREGIDO: Método para obtener categorías personalizadas desde Supabase
  static List<CategoryModel> getCustomCategoriesFromSupabase(List<dynamic> supabaseData, String userId) {
    return supabaseData
        .map((data) => CategoryModel.fromJson(data))
        .where((category) => !category.isDefault && category.userId == userId)
        .toList();
  }

  // ✅ CORREGIDO: Método simplificado - sin referencia a ExpenseCategory
  static CategoryModel fromDisplayName(String displayName) {
    final defaultCats = defaultCategories;
    final matchingCat = defaultCats.firstWhere(
      (cat) => cat.name == displayName,
      orElse: () => defaultCats.last, // Si no encuentra, devuelve "Otros"
    );
    return matchingCat;
  }

  // ✅ NUEVO: Método para convertir ExpenseCategory a CategoryModel
  static CategoryModel fromExpenseCategory(ExpenseCategory expenseCategory) {
    final defaultCats = defaultCategories;
    final matchingCat = defaultCats.firstWhere(
      (cat) => cat.name == expenseCategory.displayName,
      orElse: () => defaultCats.last,
    );
    return matchingCat;
  }

  // ✅ CORREGIDO: Método para obtener el color como Color (para widgets)
  int get colorValue {
    try {
      String hexColor = color.replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return int.parse(hexColor, radix: 16);
    } catch (e) {
      return 0xFF666666; // Color gris por defecto en caso de error
    }
  }

  // ✅ CORREGIDO: Método para obtener Color de Flutter
  Color get flutterColor {
    return Color(colorValue);
  }

  // ✅ CORREGIDO: Método para verificar si es una categoría por defecto
  bool get isCustom => !isDefault;

  // ✅ NUEVO: Método para verificar si la categoría pertenece al usuario
  bool belongsToUser(String userId) {
    return this.userId == userId;
  }

  // ✅ NUEVO: Método para validar la categoría
  bool get isValid {
    return name.isNotEmpty && 
           icon.isNotEmpty && 
           color.isNotEmpty &&
           color.startsWith('#');
  }

  // ✅ NUEVO: Método para obtener información de debug
  Map<String, dynamic> get debugInfo {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'icon': icon,
      'color': color,
      'isDefault': isDefault,
      'isValid': isValid,
    };
  }

  // ✅ CORREGIDO: Método para obtener una representación en string
  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name, icon: $icon, color: $color, isDefault: $isDefault)';
  }

  // ✅ CORREGIDO: Método para comparar categorías
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel &&
        other.id == id &&
        other.name == name &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, userId);
  }

  // ✅ CORREGIDO: Método para crear una copia con diferentes valores
  CategoryModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? icon,
    String? color,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ✅ NUEVO: Método para crear una categoría personalizada
  static CategoryModel createCustom({
    required String name,
    required String icon,
    required String color,
    required String userId,
  }) {
    return CategoryModel(
      id: '', // Será generado por Supabase
      userId: userId,
      name: name,
      icon: icon,
      color: color,
      isDefault: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

// ✅ CORREGIDO: Extensión para List<CategoryModel>
extension CategoryListExtension on List<CategoryModel> {
  // Filtrar categorías por defecto
  List<CategoryModel> get defaultCategories {
    return where((category) => category.isDefault).toList();
  }

  // Filtrar categorías personalizadas
  List<CategoryModel> get customCategories {
    return where((category) => !category.isDefault).toList();
  }

  // Filtrar categorías por usuario
  List<CategoryModel> forUser(String userId) {
    return where((category) => category.userId == userId || category.isDefault).toList();
  }

  // Buscar categoría por nombre
  CategoryModel? findByName(String name) {
    try {
      return firstWhere((category) => category.name == name);
    } catch (e) {
      return null;
    }
  }

  // Buscar categoría por ID
  CategoryModel? findById(String id) {
    try {
      return firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Buscar categoría por ExpenseCategory
  CategoryModel? findByExpenseCategory(ExpenseCategory expenseCategory) {
    final categoryName = expenseCategory.displayName;
    return findByName(categoryName);
  }

  // Ordenar por nombre
  List<CategoryModel> get sortedByName {
    return [...this]..sort((a, b) => a.name.compareTo(b.name));
  }

  // Ordenar por tipo (primero las por defecto, luego las personalizadas)
  List<CategoryModel> get sortedByType {
    return [...this]..sort((a, b) {
      if (a.isDefault && !b.isDefault) return -1;
      if (!a.isDefault && b.isDefault) return 1;
      return a.name.compareTo(b.name);
    });
  }

  // Verificar si existe una categoría con el nombre
  bool containsName(String name) {
    return any((category) => category.name == name);
  }

  // Verificar si existe una categoría personalizada con el nombre
  bool containsCustomName(String name) {
    return any((category) => category.name == name && !category.isDefault);
  }

  // Obtener nombres de categorías
  List<String> get names {
    return map((category) => category.name).toList();
  }

  // Obtener emojis de categorías
  List<String> get emojis {
    return map((category) => category.icon).toList();
  }

  // Obtener colores de categorías
  List<String> get colors {
    return map((category) => category.color).toList();
  }

  // Obtener colores como Color de Flutter
  List<Color> get flutterColors {
    return map((category) => category.flutterColor).toList();
  }

  // ✅ NUEVO: Método para combinar con categorías por defecto
  List<CategoryModel> combineWithDefaults(List<CategoryModel> defaultCats) {
    final combined = <CategoryModel>[];
    combined.addAll(defaultCats);
    
    // Agregar solo las categorías personalizadas que no existan en las por defecto
    for (final customCat in this) {
      if (!customCat.isDefault && !combined.any((cat) => cat.name == customCat.name)) {
        combined.add(customCat);
      }
    }
    
    return combined;
  }

  // ✅ NUEVO: Método para validar todas las categorías
  bool get allValid {
    return every((category) => category.isValid);
  }

  // ✅ NUEVO: Método para obtener estadísticas
  Map<String, dynamic> get stats {
    return {
      'total': length,
      'defaultCount': defaultCategories.length,
      'customCount': customCategories.length,
      'names': names,
    };
  }
}

// ✅ NUEVO: Enum ExpenseCategory para referencia
enum ExpenseCategory {
  food('Alimentación', '🍔', 0xFFFF6B6B),
  transport('Transporte', '🚌', 0xFF4ECDC4),
  materials('Materiales', '📚', 0xFF45B7D1),
  tuition('Matrícula', '🎓', 0xFF96CEB4),
  housing('Vivienda', '🏠', 0xFFFFEAA7),
  entertainment('Entretenimiento', '🎬', 0xFFDDA0DD),
  health('Salud', '🏥', 0xFF98D8C8),
  other('Otros', '📦', 0xFFF7DC6F);

  const ExpenseCategory(this.displayName, this.emoji, this.colorValue);
  final String displayName;
  final String emoji;
  final int colorValue;

  // ✅ CORREGIDO: Método para convertir a string para Supabase
  String toSupabaseString() {
    switch (this) {
      case ExpenseCategory.food:
        return 'food';
      case ExpenseCategory.transport:
        return 'transport';
      case ExpenseCategory.materials:
        return 'materials';
      case ExpenseCategory.tuition:
        return 'tuition';
      case ExpenseCategory.housing:
        return 'housing';
      case ExpenseCategory.entertainment:
        return 'entertainment';
      case ExpenseCategory.health:
        return 'health';
      case ExpenseCategory.other:
        return 'other';
    }
  }

  // ✅ CORREGIDO: Método estático para crear desde string de Supabase
  static ExpenseCategory fromSupabaseString(String value) {
    switch (value) {
      case 'food':
        return ExpenseCategory.food;
      case 'transport':
        return ExpenseCategory.transport;
      case 'materials':
        return ExpenseCategory.materials;
      case 'tuition':
        return ExpenseCategory.tuition;
      case 'housing':
        return ExpenseCategory.housing;
      case 'entertainment':
        return ExpenseCategory.entertainment;
      case 'health':
        return ExpenseCategory.health;
      case 'other':
        return ExpenseCategory.other;
      default:
        return ExpenseCategory.other;
    }
  }
}