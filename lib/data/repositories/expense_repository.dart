import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/expense_model.dart';

class ExpenseRepository {
  final SupabaseClient supabase;

  ExpenseRepository(this.supabase);

  // ✅ CORREGIDO: Método para agregar gasto sin enviar ID vacío
  Future<void> addExpense(ExpenseModel expense) async {
    try {
      // ✅ USAR toInsertMap() que excluye campos auto-generados
      final expenseData = expense.toInsertMap();
      
      print('📤 Enviando datos a Supabase: $expenseData');
      
      // ✅ VERIFICAR CRÍTICAMENTE los datos antes de insertar
      _validateExpenseData(expenseData);
      
      // ✅ LIMPIAR datos - asegurar que no se envíen campos auto-generados
      final cleanedData = _cleanExpenseData(expenseData);
      
      print('✅ Datos limpios para inserción: $cleanedData');
      
      // ✅ REALIZAR INSERCIÓN
      final response = await supabase
          .from('expenses')
          .insert(cleanedData)
          .select();
      
      if (response != null && response.isNotEmpty) {
        print('✅ Gasto agregado exitosamente. ID generado: ${response[0]['id']}');
      } else {
        print('⚠️ Inserción exitosa pero sin respuesta de retorno');
      }
      
    } catch (e) {
      print('❌ Error en repository al agregar gasto: $e');
      throw Exception('Error al agregar gasto: $e');
    }
  }

  // ✅ NUEVO: Validación exhaustiva de datos
  void _validateExpenseData(Map<String, dynamic> expenseData) {
    // Verificar user_id
    if (expenseData['user_id'] == null || expenseData['user_id']!.isEmpty) {
      throw Exception('El user_id no puede estar vacío. Usuario no autenticado.');
    }
    
    // Verificar que user_id sea un UUID válido
    final userId = expenseData['user_id'] as String;
    if (!_isValidUUID(userId)) {
      throw Exception('El user_id no es un UUID válido: $userId');
    }
    
    // Verificar nombre
    if (expenseData['name'] == null || (expenseData['name'] as String).isEmpty) {
      throw Exception('El nombre del gasto no puede estar vacío.');
    }
    
    // Verificar monto
    if (expenseData['amount'] == null || (expenseData['amount'] as double) <= 0) {
      throw Exception('El monto debe ser mayor a 0.');
    }
    
    // Verificar fecha
    if (expenseData['date'] == null || (expenseData['date'] as String).isEmpty) {
      throw Exception('La fecha no puede estar vacía.');
    }
    
    // Verificar categoría
    if (expenseData['category'] == null || (expenseData['category'] as String).isEmpty) {
      throw Exception('La categoría no puede estar vacía.');
    }
    
    print('✅ Validación de datos exitosa');
  }

  // ✅ NUEVO: Limpiar datos para asegurar que no se envíen campos auto-generados
  Map<String, dynamic> _cleanExpenseData(Map<String, dynamic> expenseData) {
    final cleanedData = Map<String, dynamic>.from(expenseData);
    
    // ❌ REMOVER campos que Supabase genera automáticamente
    cleanedData.remove('id');
    cleanedData.remove('created_at');
    cleanedData.remove('updated_at');
    
    // ✅ ASEGURAR tipos de datos correctos para Supabase
    if (cleanedData['amount'] != null) {
      cleanedData['amount'] = cleanedData['amount'].toDouble();
    }
    
    if (cleanedData['is_recurring'] != null) {
      cleanedData['is_recurring'] = cleanedData['is_recurring'] as bool;
    }
    
    // ✅ Limpiar campos nulos que puedan causar problemas
    if (cleanedData['description'] == null) {
      cleanedData.remove('description');
    }
    
    if (cleanedData['receipt_url'] == null) {
      cleanedData.remove('receipt_url');
    }
    
    if (cleanedData['recurrence_pattern'] == null) {
      cleanedData.remove('recurrence_pattern');
    }
    
    return cleanedData;
  }

  // ✅ NUEVO: Validar formato UUID
  bool _isValidUUID(String uuid) {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(uuid);
  }

  // ✅ CORREGIDO: Método para obtener gastos
  Future<List<ExpenseModel>> getExpenses() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await supabase
          .from('expenses')
          .select()
          .eq('user_id', user.id) // ✅ Solo gastos del usuario actual
          .order('date', ascending: false);

      if (response == null) {
        return [];
      }

      return (response as List)
          .map((data) => ExpenseModel.fromMap(data))
          .toList();
    } catch (e) {
      print('❌ Error al obtener gastos: $e');
      throw Exception('Error al cargar gastos: $e');
    }
  }

  // ✅ CORREGIDO Y MEJORADO: Método para actualizar gasto
  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      // Verificar que el gasto tenga ID válido
      if (expense.id.isEmpty) {
        throw Exception('No se puede actualizar un gasto sin ID');
      }
      
      // Verificar que el usuario sea el propietario del gasto
      final user = supabase.auth.currentUser;
      if (user == null || expense.userId != user.id) {
        throw Exception('No tienes permisos para actualizar este gasto');
      }
      
      // ✅ USAR toUpdateMap() en lugar de toMap()
      final updateData = expense.toUpdateMap();
      
      print('📤 Actualizando gasto ID: ${expense.id}');
      print('📤 Datos de actualización: $updateData');
      
      final response = await supabase
          .from('expenses')
          .update(updateData)
          .eq('id', expense.id)
          .eq('user_id', user.id); // ✅ Seguridad adicional
      
      print('✅ Gasto actualizado exitosamente. Respuesta: $response');
      
    } catch (e) {
      print('❌ Error al actualizar gasto: $e');
      throw Exception('Error al actualizar gasto: $e');
    }
  }

  // ✅ NUEVO: Método para actualizar solo campos específicos
  Future<void> partialUpdate(String expenseId, Map<String, dynamic> partialData) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Asegurar que se incluya la fecha de actualización
      final updateData = {
        ...partialData,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await supabase
          .from('expenses')
          .update(updateData)
          .eq('id', expenseId)
          .eq('user_id', user.id);

      print('✅ Actualización parcial exitosa: $response');
    } catch (e) {
      print('❌ Error en actualización parcial: $e');
      throw Exception('Error en actualización parcial: $e');
    }
  }

  // ✅ CORREGIDO: Método para eliminar gasto
  Future<void> deleteExpense(String expenseId) async {
    try {
      if (expenseId.isEmpty) {
        throw Exception('No se puede eliminar un gasto sin ID');
      }
      
      // Verificar que el usuario sea el propietario del gasto
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }
      
      print('🗑️ Eliminando gasto ID: $expenseId');
      
      final response = await supabase
          .from('expenses')
          .delete()
          .eq('id', expenseId)
          .eq('user_id', user.id); // ✅ Seguridad adicional
      
      print('✅ Gasto eliminado: $response');
      
    } catch (e) {
      print('❌ Error al eliminar gasto: $e');
      throw Exception('Error al eliminar gasto: $e');
    }
  }

  // ✅ NUEVO: Método para obtener gastos por rango de fechas
  Future<List<ExpenseModel>> getExpensesByDateRange(DateTime start, DateTime end) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final startStr = start.toIso8601String().split('T')[0];
      final endStr = end.toIso8601String().split('T')[0];

      final response = await supabase
          .from('expenses')
          .select()
          .eq('user_id', user.id)
          .gte('date', startStr)
          .lte('date', endStr)
          .order('date', ascending: false);

      if (response == null) {
        return [];
      }

      return (response as List)
          .map((data) => ExpenseModel.fromMap(data))
          .toList();
    } catch (e) {
      print('❌ Error al obtener gastos por fecha: $e');
      throw Exception('Error al cargar gastos por fecha: $e');
    }
  }

  // ✅ NUEVO: Método para obtener gastos por categoría
  Future<List<ExpenseModel>> getExpensesByCategory(String category) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await supabase
          .from('expenses')
          .select()
          .eq('user_id', user.id)
          .eq('category', category)
          .order('date', ascending: false);

      if (response == null) {
        return [];
      }

      return (response as List)
          .map((data) => ExpenseModel.fromMap(data))
          .toList();
    } catch (e) {
      print('❌ Error al obtener gastos por categoría: $e');
      throw Exception('Error al cargar gastos por categoría: $e');
    }
  }

  // ✅ NUEVO: Método para obtener un gasto por ID
  Future<ExpenseModel?> getExpenseById(String expenseId) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await supabase
          .from('expenses')
          .select()
          .eq('id', expenseId)
          .eq('user_id', user.id)
          .single();

      if (response == null) {
        return null;
      }

      return ExpenseModel.fromMap(response);
    } catch (e) {
      print('❌ Error al obtener gasto por ID: $e');
      return null;
    }
  }

  // ✅ NUEVO: Método de diagnóstico para verificar la inserción
  Future<void> debugExpenseInsertion(ExpenseModel expense) async {
    try {
      final insertData = expense.toInsertMap();
      
      print('🔍 DIAGNÓSTICO DE INSERCIÓN:');
      print('  - Campos a insertar: ${insertData.keys.toList()}');
      print('  - user_id: "${insertData['user_id']}" (tipo: ${insertData['user_id']?.runtimeType})');
      print('  - name: "${insertData['name']}"');
      print('  - amount: ${insertData['amount']} (tipo: ${insertData['amount']?.runtimeType})');
      print('  - date: "${insertData['date']}"');
      print('  - category: "${insertData['category']}"');
      print('  - is_recurring: ${insertData['is_recurring']} (tipo: ${insertData['is_recurring']?.runtimeType})');
      print('  - recurrence_pattern: "${insertData['recurrence_pattern']}"');
      
      // Verificar campos problemáticos
      if (insertData.containsKey('id')) {
        print('❌ PROBLEMA: Se está enviando el campo "id" con valor: "${insertData['id']}"');
      } else {
        print('✅ CORRECTO: No se envía el campo "id"');
      }
      
      if (insertData['user_id'] == null || insertData['user_id']!.isEmpty) {
        print('❌ PROBLEMA: user_id está vacío o es nulo');
      } else {
        print('✅ CORRECTO: user_id tiene un valor válido');
        
        // Verificar formato UUID
        if (_isValidUUID(insertData['user_id']!)) {
          print('✅ CORRECTO: user_id tiene formato UUID válido');
        } else {
          print('❌ PROBLEMA: user_id no tiene formato UUID válido');
        }
      }
      
      // Verificar otros campos auto-generados
      if (insertData.containsKey('created_at')) {
        print('❌ PROBLEMA: Se está enviando el campo "created_at"');
      }
      
      if (insertData.containsKey('updated_at')) {
        print('❌ PROBLEMA: Se está enviando el campo "updated_at"');
      }
      
    } catch (e) {
      print('❌ Error en diagnóstico: $e');
    }
  }

  // ✅ NUEVO: Método para verificar conexión con Supabase
  Future<bool> checkConnection() async {
    try {
      final user = supabase.auth.currentUser;
      return user != null;
    } catch (e) {
      print('❌ Error de conexión con Supabase: $e');
      return false;
    }
  }

  // ✅ NUEVO: Método para obtener estadísticas de gastos
  Future<Map<String, dynamic>> getExpenseStats() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener gastos del mes actual
      final now = DateTime.now();
      final firstDay = DateTime(now.year, now.month, 1);
      final lastDay = DateTime(now.year, now.month + 1, 0);
      
      final monthlyExpenses = await getExpensesByDateRange(firstDay, lastDay);
      
      // Calcular estadísticas
      final total = monthlyExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
      final byCategory = <String, double>{};
      
      for (final expense in monthlyExpenses) {
        final category = expense.category.toSupabaseString();
        byCategory[category] = (byCategory[category] ?? 0) + expense.amount;
      }
      
      return {
        'total': total,
        'count': monthlyExpenses.length,
        'byCategory': byCategory,
        'average': monthlyExpenses.isEmpty ? 0 : total / monthlyExpenses.length,
      };
    } catch (e) {
      print('❌ Error al obtener estadísticas: $e');
      throw Exception('Error al obtener estadísticas: $e');
    }
  }

  // ✅ NUEVO: Método para buscar gastos por texto
  Future<List<ExpenseModel>> searchExpenses(String query) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await supabase
          .from('expenses')
          .select()
          .eq('user_id', user.id)
          .or('name.ilike.%$query%,description.ilike.%$query%')
          .order('date', ascending: false);

      if (response == null) {
        return [];
      }

      return (response as List)
          .map((data) => ExpenseModel.fromMap(data))
          .toList();
    } catch (e) {
      print('❌ Error al buscar gastos: $e');
      throw Exception('Error al buscar gastos: $e');
    }
  }

  // ✅ CORREGIDO: Método para contar gastos totales - COMPATIBLE CON TU VERSIÓN
  Future<int> getTotalExpenseCount() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // FORMA SIMPLE: obtener todos y contar
      final response = await supabase
          .from('expenses')
          .select()
          .eq('user_id', user.id);

      return response?.length ?? 0;
    } catch (e) {
      print('❌ Error al contar gastos: $e');
      throw Exception('Error al contar gastos: $e');
    }
  }

  // ✅ NUEVO: Método para contar gastos eficientemente
  Future<int> getExpenseCountEfficient() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener solo los IDs para contar más rápido
      final response = await supabase
          .from('expenses')
          .select('id')
          .eq('user_id', user.id);

      return response?.length ?? 0;
    } catch (e) {
      print('❌ Error al contar gastos eficientemente: $e');
      return 0;
    }
  }

  // ✅ NUEVO: Método para verificar si un gasto existe
  Future<bool> expenseExists(String expenseId) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        return false;
      }

      final response = await supabase
          .from('expenses')
          .select('id')
          .eq('id', expenseId)
          .eq('user_id', user.id)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('❌ Error al verificar existencia de gasto: $e');
      return false;
    }
  }

  // ✅ NUEVO: Método para obtener el total de gastos por mes
  Future<double> getMonthlyTotal(int year, int month) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final firstDay = DateTime(year, month, 1);
      final lastDay = DateTime(year, month + 1, 0);
      final startStr = firstDay.toIso8601String().split('T')[0];
      final endStr = lastDay.toIso8601String().split('T')[0];

      final response = await supabase
          .from('expenses')
          .select('amount')
          .eq('user_id', user.id)
          .gte('date', startStr)
          .lte('date', endStr);

      if (response == null || response.isEmpty) {
        return 0.0;
      }

      double total = 0.0;
      for (final item in response) {
        total += (item['amount'] as num).toDouble();
      }

      return total;
    } catch (e) {
      print('❌ Error al obtener total mensual: $e');
      throw Exception('Error al obtener total mensual: $e');
    }
  }

  // ✅ NUEVO: Método para obtener gastos con paginación
  Future<List<ExpenseModel>> getExpensesPaginated(int page, int limit) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final from = page * limit;
      final to = from + limit - 1;

      final response = await supabase
          .from('expenses')
          .select()
          .eq('user_id', user.id)
          .order('date', ascending: false)
          .range(from, to);

      if (response == null) {
        return [];
      }

      return (response as List)
          .map((data) => ExpenseModel.fromMap(data))
          .toList();
    } catch (e) {
      print('❌ Error al obtener gastos paginados: $e');
      throw Exception('Error al obtener gastos paginados: $e');
    }
  }
}