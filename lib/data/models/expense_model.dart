import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum ExpenseCategory {
  food('Alimentación', '🍔', 0xFFFF6B6B, Icons.restaurant),
  transport('Transporte', '🚌', 0xFF4ECDC4, Icons.directions_car),
  materials('Materiales', '📚', 0xFF45B7D1, Icons.book),
  tuition('Matrícula', '🎓', 0xFF96CEB4, Icons.school),
  housing('Vivienda', '🏠', 0xFFFFEAA7, Icons.house),
  entertainment('Entretenimiento', '🎬', 0xFFDDA0DD, Icons.movie),
  health('Salud', '🏥', 0xFF98D8C8, Icons.medical_services),
  other('Otros', '📦', 0xFFF7DC6F, Icons.category);

  const ExpenseCategory(this.displayName, this.emoji, this.colorValue, this.icon);
  final String displayName;
  final String emoji;
  final int colorValue;
  final IconData icon;

  // Método para obtener Color
  Color get color => Color(colorValue);

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

class ExpenseModel {
  final String id;
  final String userId;
  final String name;
  final double amount;
  final DateTime date;
  final ExpenseCategory category;
  final String? description;
  final String? receiptUrl;
  final bool isRecurring;
  final String? recurrencePattern;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExpenseModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.date,
    required this.category,
    this.description,
    this.receiptUrl,
    required this.isRecurring,
    this.recurrencePattern,
    required this.createdAt,
    required this.updatedAt,
  });

  // ✅ Verificar si el gasto es reciente (últimas 24 horas)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(date);
    return difference.inHours <= 24;
  }

  // ✅ Obtener nombre de recurrencia para mostrar
  String? get recurrenceDisplayName {
    if (!isRecurring || recurrencePattern == null) return null;
    
    switch (recurrencePattern) {
      case 'daily':
        return 'Diario';
      case 'weekly':
        return 'Semanal';
      case 'monthly':
        return 'Mensual';
      case 'yearly':
        return 'Anual';
      default:
        return recurrencePattern;
    }
  }

  // ✅ Obtener icono de recurrencia
  IconData? get recurrenceIcon {
    if (!isRecurring || recurrencePattern == null) return null;
    
    switch (recurrencePattern) {
      case 'daily':
        return Icons.today;
      case 'weekly':
        return Icons.calendar_view_week;
      case 'monthly':
        return Icons.calendar_today;
      case 'yearly':
        return Icons.calendar_view_month;
      default:
        return Icons.repeat;
    }
  }

  // ✅ Formatted date for display
  String get formattedDate {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // ✅ NUEVO: Formatted date for display (versión corta)
  String get shortFormattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final expenseDay = DateTime(date.year, date.month, date.day);

    if (expenseDay == today) {
      return 'Hoy';
    } else if (expenseDay == yesterday) {
      return 'Ayer';
    } else {
      final difference = now.difference(date).inDays;
      if (difference < 7) {
        return 'Hace $difference días';
      } else {
        return '${date.day}/${date.month}';
      }
    }
  }

  // ✅ NUEVO: Formatted amount
  String get formattedAmount {
    return '\$${amount.toStringAsFixed(2)}';
  }

  // ✅ Convert to map for database (para updates y lecturas)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'amount': amount,
      'date': date.toIso8601String().split('T')[0],
      'category': category.toSupabaseString(),
      'description': description,
      'receipt_url': receiptUrl,
      'is_recurring': isRecurring,
      'recurrence_pattern': recurrencePattern,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // ✅ CORREGIDO COMPLETAMENTE: toInsertMap() - SOLO campos que Supabase espera en INSERT
  Map<String, dynamic> toInsertMap() {
    final Map<String, dynamic> data = {
      'user_id': userId,
      'name': name,
      'amount': amount,
      'date': date.toIso8601String().split('T')[0], // Formato YYYY-MM-DD
      'category': category.toSupabaseString(),
      'is_recurring': isRecurring,
    };

    // ✅ SOLO agregar campos opcionales si tienen valor
    if (description != null && description!.isNotEmpty) {
      data['description'] = description;
    }

    if (receiptUrl != null && receiptUrl!.isNotEmpty) {
      data['receipt_url'] = receiptUrl;
    }

    if (isRecurring && recurrencePattern != null && recurrencePattern!.isNotEmpty) {
      data['recurrence_pattern'] = recurrencePattern;
    }

    // ❌ NO INCLUIR NUNCA estos campos en INSERT:
    // - 'id' (Supabase lo genera automáticamente con gen_random_uuid())
    // - 'created_at' (Supabase lo genera automáticamente con NOW())
    // - 'updated_at' (Supabase lo genera automáticamente con NOW())

    if (kDebugMode) {
      print('🔍 ExpenseModel.toInsertMap() - Campos a insertar:');
      data.forEach((key, value) {
        print('   $key: $value (${value.runtimeType})');
      });
      print('   ❌ Campos EXCLUIDOS: id, created_at, updated_at');
    }

    return data;
  }

  // ✅ NUEVO: Método para actualizaciones en Supabase
  Map<String, dynamic> toUpdateMap() {
    final Map<String, dynamic> data = {
      'name': name,
      'amount': amount,
      'date': date.toIso8601String().split('T')[0], // Formato YYYY-MM-DD
      'category': category.toSupabaseString(),
      'is_recurring': isRecurring,
      'updated_at': DateTime.now().toIso8601String(), // ✅ Actualizar fecha de modificación
    };

    // ✅ Incluir campos opcionales (incluso si son null para limpiarlos)
    data['description'] = description;
    data['receipt_url'] = receiptUrl;
    data['recurrence_pattern'] = isRecurring ? recurrencePattern : null;

    if (kDebugMode) {
      print('🔍 ExpenseModel.toUpdateMap() - Campos a actualizar:');
      data.forEach((key, value) {
        print('   $key: $value (${value.runtimeType})');
      });
      print('   ❌ Campos EXCLUIDOS: id, user_id, created_at (estos no se deben actualizar)');
    }

    return data;
  }

  // ✅ Create from database map
  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date']?.toString() ?? DateTime.now().toIso8601String()),
      category: ExpenseCategory.fromSupabaseString(map['category']?.toString() ?? 'other'),
      description: map['description']?.toString(),
      receiptUrl: map['receipt_url']?.toString(),
      isRecurring: map['is_recurring'] as bool? ?? false,
      recurrencePattern: map['recurrence_pattern']?.toString(),
      createdAt: DateTime.parse(map['created_at']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at']?.toString() ?? DateTime.now().toIso8601String()),
    );
  }

  // ✅ Copy with method for updates (YA EXISTE Y ESTÁ CORRECTO)
  ExpenseModel copyWith({
    String? id,
    String? userId,
    String? name,
    double? amount,
    DateTime? date,
    ExpenseCategory? category,
    String? description,
    String? receiptUrl,
    bool? isRecurring,
    String? recurrencePattern,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      description: description ?? this.description,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ✅ Método para validar si el modelo es válido para inserción
  bool get isValidForInsert {
    return userId.isNotEmpty &&
        name.isNotEmpty &&
        amount > 0 &&
        _isValidUUID(userId);
  }

  // ✅ Validar formato UUID
  bool _isValidUUID(String uuid) {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(uuid);
  }

  // ✅ Método para crear un ExpenseModel listo para inserción
  factory ExpenseModel.forInsert({
    required String userId,
    required String name,
    required double amount,
    required DateTime date,
    required ExpenseCategory category,
    String? description,
    bool isRecurring = false,
    String? recurrencePattern,
  }) {
    // Validar que el userId sea un UUID válido
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    
    if (!uuidRegex.hasMatch(userId)) {
      throw Exception('El userId debe ser un UUID válido: $userId');
    }

    return ExpenseModel(
      id: '', // Vacío - Supabase generará el UUID
      userId: userId,
      name: name,
      amount: amount,
      date: date,
      category: category,
      description: description,
      receiptUrl: null,
      isRecurring: isRecurring,
      recurrencePattern: isRecurring ? recurrencePattern : null,
      createdAt: DateTime.now(), // Será ignorado en toInsertMap()
      updatedAt: DateTime.now(), // Será ignorado en toInsertMap()
    );
  }

  // ✅ NUEVO: Método para debuggear el modelo
  Map<String, dynamic> get debugInfo {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category.toSupabaseString(),
      'isRecurring': isRecurring,
      'recurrencePattern': recurrencePattern,
      'isValidForInsert': isValidForInsert,
      'userIdIsValidUUID': _isValidUUID(userId),
    };
  }

  @override
  String toString() {
    return 'ExpenseModel(id: $id, name: $name, amount: $amount, category: ${category.toSupabaseString()}, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpenseModel &&
        other.id == id &&
        other.userId == userId &&
        other.name == name &&
        other.amount == amount &&
        other.date == date &&
        other.category == category &&
        other.description == description &&
        other.receiptUrl == receiptUrl &&
        other.isRecurring == isRecurring &&
        other.recurrencePattern == recurrencePattern &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      name,
      amount,
      date,
      category,
      description,
      receiptUrl,
      isRecurring,
      recurrencePattern,
      createdAt,
      updatedAt,
    );
  }
}

// ✅ Extensiones útiles para listas de gastos
extension ExpenseListExtensions on List<ExpenseModel> {
  // Ordenamientos básicos
  List<ExpenseModel> get sortedByDateDesc {
    return List.of(this)..sort((a, b) => b.date.compareTo(a.date));
  }

  List<ExpenseModel> get sortedByDateAsc {
    return List.of(this)..sort((a, b) => a.date.compareTo(b.date));
  }

  List<ExpenseModel> get sortedByAmountDesc {
    return List.of(this)..sort((a, b) => b.amount.compareTo(a.amount));
  }

  List<ExpenseModel> get sortedByAmountAsc {
    return List.of(this)..sort((a, b) => a.amount.compareTo(b.amount));
  }

  // ✅ NUEVO: Ordenamientos por nombre
  List<ExpenseModel> get sortedByNameAsc {
    return List.of(this)..sort((a, b) => a.name.compareTo(b.name));
  }

  List<ExpenseModel> get sortedByNameDesc {
    return List.of(this)..sort((a, b) => b.name.compareTo(a.name));
  }

  // Filtros por tiempo
  List<ExpenseModel> get currentMonthExpenses {
    final now = DateTime.now();
    return where((expense) =>
        expense.date.year == now.year && expense.date.month == now.month).toList();
  }

  List<ExpenseModel> get todayExpenses {
    final today = DateTime.now();
    return where((expense) =>
        expense.date.year == today.year &&
        expense.date.month == today.month &&
        expense.date.day == today.day).toList();
  }

  List<ExpenseModel> get currentWeekExpenses {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return where((expense) =>
        expense.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        expense.date.isBefore(endOfWeek.add(const Duration(days: 1)))).toList();
  }

  List<ExpenseModel> get recentExpenses {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return where((expense) => expense.date.isAfter(weekAgo)).toList();
  }

  // Filtros por tipo
  List<ExpenseModel> get recurringExpenses {
    return where((expense) => expense.isRecurring).toList();
  }

  // Métricas
  ExpenseModel? get largestExpense {
    if (isEmpty) return null;
    return reduce((a, b) => a.amount > b.amount ? a : b);
  }

  ExpenseModel? get smallestExpense {
    if (isEmpty) return null;
    return reduce((a, b) => a.amount < b.amount ? a : b);
  }

  ExpenseModel? get mostRecentExpense {
    if (isEmpty) return null;
    return reduce((a, b) => a.date.isAfter(b.date) ? a : b);
  }

  double get totalAmount {
    return fold(0, (sum, expense) => sum + expense.amount);
  }

  double get averageAmount {
    if (isEmpty) return 0.0;
    return totalAmount / length;
  }

  // Estadísticas por categoría
  Map<ExpenseCategory, double> get amountByCategory {
    final Map<ExpenseCategory, double> categoryTotals = {};
    
    for (final expense in this) {
      categoryTotals.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    
    return categoryTotals;
  }

  Map<ExpenseCategory, int> get countByCategory {
    final Map<ExpenseCategory, int> categoryCounts = {};
    
    for (final expense in this) {
      categoryCounts.update(
        expense.category,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }
    
    return categoryCounts;
  }

  // ✅ NUEVO: Filtrar gastos válidos para inserción
  List<ExpenseModel> get validForInsert {
    return where((expense) => expense.isValidForInsert).toList();
  }

  // ✅ NUEVO: Verificar si hay gastos con userId inválido
  bool get hasInvalidUserIds {
    return any((expense) => !expense._isValidUUID(expense.userId));
  }

  // ✅ NUEVO: Método para agrupar gastos por día
  Map<String, List<ExpenseModel>> get groupedByDay {
    final Map<String, List<ExpenseModel>> grouped = {};
    
    for (final expense in this) {
      final dayKey = '${expense.date.year}-${expense.date.month}-${expense.date.day}';
      grouped.putIfAbsent(dayKey, () => []).add(expense);
    }
    
    return grouped;
  }

  // ✅ NUEVO: Gastos por categoría específica
  List<ExpenseModel> byCategory(ExpenseCategory category) {
    return where((expense) => expense.category == category).toList();
  }

  // ✅ NUEVO: Gastos en un rango de fechas
  List<ExpenseModel> inDateRange(DateTime start, DateTime end) {
    return where((expense) => 
      expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
      expense.date.isBefore(end.add(const Duration(days: 1)))
    ).toList();
  }
}