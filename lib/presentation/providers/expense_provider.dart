import 'package:flutter/foundation.dart';
import '../../data/models/expense_model.dart';
import '../../data/repositories/expense_repository.dart';

class ExpenseProvider with ChangeNotifier {
  final ExpenseRepository _expenseRepository;

  ExpenseProvider(this._expenseRepository);

  List<ExpenseModel> _expenses = [];
  bool _isLoading = false;
  String? _error;

  List<ExpenseModel> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalExpenses {
    return _expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  // Obtener gastos por categoría
  Map<ExpenseCategory, double> get expensesByCategory {
    final Map<ExpenseCategory, double> categoryTotals = {};
    
    for (final expense in _expenses) {
      categoryTotals.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    
    return categoryTotals;
  }

  // ✅ CORREGIDO: Método para eliminar todos los gastos
  Future<void> deleteAllExpenses() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Eliminar gastos uno por uno
      for (final expense in _expenses) {
        await _expenseRepository.deleteExpense(expense.id);
      }
      
      // Limpiar la lista local
      _expenses.clear();
      _error = null;
      
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar todos los gastos: $e';
      if (kDebugMode) {
        print('Error deleting all expenses: $e');
      }
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ CORREGIDO: Método para obtener gastos del mes actual
  List<ExpenseModel> get currentMonthExpenses {
    final now = DateTime.now();
    return _expenses.where((expense) =>
      expense.date.year == now.year && expense.date.month == now.month
    ).toList();
  }

  // ✅ CORREGIDO: Método para obtener gastos de hoy
  List<ExpenseModel> get todayExpenses {
    final today = DateTime.now();
    return _expenses.where((expense) =>
      expense.date.year == today.year &&
      expense.date.month == today.month &&
      expense.date.day == today.day
    ).toList();
  }

  // ✅ CORREGIDO: Método para obtener gastos de la semana actual
  List<ExpenseModel> get currentWeekExpenses {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return _expenses.where((expense) =>
      expense.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
      expense.date.isBefore(endOfWeek.add(const Duration(days: 1)))
    ).toList();
  }

  // ✅ CORREGIDO: Método para obtener gastos recientes (últimos 7 días)
  List<ExpenseModel> get recentExpenses {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _expenses.where((expense) => expense.date.isAfter(weekAgo)).toList();
  }

  // ✅ CORREGIDO: Método para obtener el gasto más grande
  ExpenseModel? get largestExpense {
    if (_expenses.isEmpty) return null;
    return _expenses.reduce((a, b) => a.amount > b.amount ? a : b);
  }

  // ✅ CORREGIDO: Método para obtener el promedio de gastos
  double get averageAmount {
    if (_expenses.isEmpty) return 0.0;
    return totalExpenses / _expenses.length;
  }

  // ✅ CORREGIDO: Método para obtener gastos recurrentes
  List<ExpenseModel> get recurringExpenses {
    return _expenses.where((expense) => expense.isRecurring).toList();
  }

  // ✅ CORREGIDO: Método para cargar gastos con manejo mejorado de errores
  Future<void> fetchExpenses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _expenses = await _expenseRepository.getExpenses();
      if (kDebugMode) {
        print('✅ Gastos cargados: ${_expenses.length}');
      }
    } catch (e) {
      _error = 'Error al cargar gastos: $e';
      if (kDebugMode) {
        print('❌ Error fetching expenses: $e');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ CORREGIDO: Método para agregar gasto con validación mejorada
  Future<void> addExpense(ExpenseModel expense) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Validar el gasto antes de agregar
      if (expense.name.isEmpty) {
        throw Exception('El nombre del gasto no puede estar vacío');
      }
      if (expense.amount <= 0) {
        throw Exception('El monto debe ser mayor a 0');
      }

      await _expenseRepository.addExpense(expense);
      if (kDebugMode) {
        print('✅ Gasto agregado: ${expense.name} - \$${expense.amount}');
      }
      
      // Refrescar la lista para incluir el nuevo gasto
      await fetchExpenses();
      
    } catch (e) {
      _error = 'Error al agregar gasto: $e';
      if (kDebugMode) {
        print('❌ Error adding expense: $e');
      }
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ CORREGIDO: Método para eliminar gasto
  Future<void> deleteExpense(String expenseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _expenseRepository.deleteExpense(expenseId);
      if (kDebugMode) {
        print('✅ Gasto eliminado: $expenseId');
      }
      
      // Refrescar la lista
      await fetchExpenses();
      
    } catch (e) {
      _error = 'Error al eliminar gasto: $e';
      if (kDebugMode) {
        print('❌ Error deleting expense: $e');
      }
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ CORREGIDO Y MEJORADO: Método para actualizar un gasto existente
  Future<void> updateExpense(ExpenseModel expense) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Validar el gasto antes de actualizar
      if (expense.name.isEmpty) {
        throw Exception('El nombre del gasto no puede estar vacío');
      }
      if (expense.amount <= 0) {
        throw Exception('El monto debe ser mayor a 0');
      }
      if (expense.id.isEmpty) {
        throw Exception('El ID del gasto no puede estar vacío');
      }

      // Validar que el gasto exista en la lista local
      final existingIndex = _expenses.indexWhere((e) => e.id == expense.id);
      if (existingIndex == -1) {
        throw Exception('Gasto no encontrado para actualizar');
      }

      if (kDebugMode) {
        print('🔄 Actualizando gasto: ${expense.toUpdateMap()}');
      }

      await _expenseRepository.updateExpense(expense);
      
      if (kDebugMode) {
        print('✅ Gasto actualizado exitosamente: ${expense.name} - \$${expense.amount}');
      }
      
      // Actualizar la lista local directamente sin recargar todo
      _expenses[existingIndex] = expense;
      _error = null;
      
    } catch (e) {
      _error = 'Error al actualizar gasto: $e';
      if (kDebugMode) {
        print('❌ Error updating expense: $e');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ CORREGIDO: Método para obtener gastos por rango de fechas
  List<ExpenseModel> getExpensesByDateRange(DateTime start, DateTime end) {
    return _expenses.where((expense) =>
      expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
      expense.date.isBefore(end.add(const Duration(days: 1)))
    ).toList();
  }

  // ✅ CORREGIDO: Método para obtener gastos por categoría específica
  List<ExpenseModel> getExpensesByCategory(ExpenseCategory category) {
    return _expenses.where((expense) => expense.category == category).toList();
  }

  // ✅ CORREGIDO: Método para obtener total por categoría específica
  double getTotalByCategory(ExpenseCategory category) {
    return _expenses
        .where((expense) => expense.category == category)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // ✅ NUEVO: Método para obtener estadísticas mensuales
  Map<String, dynamic> getMonthlyStats() {
    final now = DateTime.now();
    final monthExpenses = currentMonthExpenses;
    final total = monthExpenses.totalAmount;
    final byCategory = monthExpenses.amountByCategory;
    
    return {
      'total': total,
      'count': monthExpenses.length,
      'average': monthExpenses.averageAmount,
      'byCategory': byCategory,
      'largestExpense': monthExpenses.largestExpense,
    };
  }

  // ✅ NUEVO: Método para buscar gastos por nombre
  List<ExpenseModel> searchExpenses(String query) {
    if (query.isEmpty) return _expenses;
    
    final lowercaseQuery = query.toLowerCase();
    return _expenses.where((expense) =>
      expense.name.toLowerCase().contains(lowercaseQuery) ||
      (expense.description?.toLowerCase().contains(lowercaseQuery) ?? false)
    ).toList();
  }

  // ✅ NUEVO: Método para obtener gastos ordenados por diferentes criterios
  List<ExpenseModel> getExpensesSorted({bool byDateDesc = true, bool byAmount = false}) {
    List<ExpenseModel> sortedList = List.from(_expenses);
    
    if (byAmount) {
      sortedList.sort((a, b) => b.amount.compareTo(a.amount));
    } else if (byDateDesc) {
      sortedList.sort((a, b) => b.date.compareTo(a.date));
    } else {
      sortedList.sort((a, b) => a.date.compareTo(b.date));
    }
    
    return sortedList;
  }

  // ✅ NUEVO: Método para verificar si hay gastos duplicados
  bool hasDuplicateExpense(ExpenseModel newExpense) {
    return _expenses.any((expense) =>
      expense.name.toLowerCase() == newExpense.name.toLowerCase() &&
      expense.amount == newExpense.amount &&
      expense.date == newExpense.date &&
      expense.category == newExpense.category
    );
  }

  // ✅ NUEVO: Método para actualizar un gasto localmente (sin hacer fetch)
  void updateExpenseLocally(ExpenseModel updatedExpense) {
    final index = _expenses.indexWhere((expense) => expense.id == updatedExpense.id);
    if (index != -1) {
      _expenses[index] = updatedExpense;
      notifyListeners();
    }
  }

  // ✅ NUEVO: Método para obtener un gasto por su ID
  ExpenseModel? getExpenseById(String id) {
    try {
      return _expenses.firstWhere((expense) => expense.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ✅ CORREGIDO: Método para limpiar todos los datos
  void clearAll() {
    _expenses.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // ✅ NUEVO: Método para debuggear el estado actual
  void debugState() {
    if (kDebugMode) {
      print('=== EXPENSE PROVIDER STATE ===');
      print('Loading: $_isLoading');
      print('Error: $_error');
      print('Total expenses: ${_expenses.length}');
      print('Total amount: \$$totalExpenses');
      print('Categories: ${expensesByCategory.length}');
      if (_expenses.isNotEmpty) {
        print('Last expense: ${_expenses.first}');
      }
      print('==============================');
    }
  }

  // ✅ NUEVO: Método para verificar si el provider está listo
  bool get isReady => !_isLoading && _error == null;

  // ✅ NUEVO: Método para refrescar datos con opción de forzar recarga
  Future<void> refresh({bool force = false}) async {
    if (force || _expenses.isEmpty) {
      await fetchExpenses();
    }
  }
}