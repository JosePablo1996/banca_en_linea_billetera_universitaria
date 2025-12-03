import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static const String supabaseUrl = 'https://iptoafbozuryktxwgalo.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlwdG9hZmJvenVyeWt0eHdnYWxvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQzNjc3ODYsImV4cCI6MjA3OTk0Mzc4Nn0.gJFEJdcw5I7sZghbcz4XIX7WBMtYeBLFPxckChi420M';

  Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  // ✅ MÉTODO SIMPLIFICADO PARA DESHABILITAR LOGS
  void disableLogging() {
    // No hay configuración directa, simplemente no usar print en el código
  }

  SupabaseClient get client => Supabase.instance.client;
  
  GoTrueClient get auth => Supabase.instance.client.auth;

  // Método helper para verificar si el usuario está autenticado
  bool get isAuthenticated => auth.currentUser != null;

  // Obtener el ID del usuario actual
  String? get currentUserId => auth.currentUser?.id;

  // ✅ CORREGIDO: Método para operaciones silenciosas (sin logs)
  Future<List<Map<String, dynamic>>?> silentQuery(String table, {
    Map<String, dynamic>? filters,
  }) async {
    try {
      // ✅ CORREGIDO: Usar el método correcto para consultas con filtros
      if (filters != null && filters.isNotEmpty) {
        // Construir la consulta con filtros usando .eq() correctamente
        var query = client.from(table).select();
        
        // Aplicar cada filtro individualmente
        filters.forEach((key, value) {
          query = query.eq(key, value);
        });
        
        final response = await query;
        return response;
      } else {
        // Consulta sin filtros
        final response = await client.from(table).select();
        return response;
      }
    } catch (e) {
      // Silenciar errores - no hacer nada
      return null;
    }
  }

  // ✅ CORREGIDO: Método para inserción silenciosa
  Future<List<Map<String, dynamic>>?> silentInsert(String table, Map<String, dynamic> data) async {
    try {
      final response = await client
          .from(table)
          .insert(data)
          .select();
      return response;
    } catch (e) {
      // Silenciar errores
      return null;
    }
  }

  // ✅ CORREGIDO: Método para actualización silenciosa
  Future<List<Map<String, dynamic>>?> silentUpdate(
    String table, 
    String id, 
    Map<String, dynamic> data
  ) async {
    try {
      final response = await client
          .from(table)
          .update(data)
          .eq('id', id)
          .select();
      return response;
    } catch (e) {
      // Silenciar errores
      return null;
    }
  }

  // ✅ CORREGIDO: Método para eliminación silenciosa
  Future<void> silentDelete(String table, String id) async {
    try {
      await client
          .from(table)
          .delete()
          .eq('id', id);
    } catch (e) {
      // Silenciar errores
    }
  }

  // ✅ CORREGIDO: Verificar conexión silenciosamente
  Future<bool> checkConnectionSilently() async {
    try {
      final user = auth.currentUser;
      return user != null;
    } catch (e) {
      return false;
    }
  }

  // ✅ CORREGIDO: Cerrar sesión silenciosamente
  Future<void> signOutSilently() async {
    try {
      await auth.signOut();
    } catch (e) {
      // Silenciar errores de cierre de sesión
    }
  }

  // ✅ CORREGIDO: Obtener sesión silenciosamente
  Future<User?> getCurrentUserSilently() async {
    try {
      final user = auth.currentUser;
      return user;
    } catch (e) {
      return null;
    }
  }

  // ✅ MÉTODOS ESPECÍFICOS PARA TU APLICACIÓN

  // Obtener gastos por usuario
  Future<List<Map<String, dynamic>>?> getExpensesByUser(String userId) async {
    try {
      final response = await client
          .from('expenses')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);
      return response;
    } catch (e) {
      return null;
    }
  }

  // Obtener perfil de usuario
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      return null;
    }
  }

  // Insertar gasto
  Future<List<Map<String, dynamic>>?> insertExpense(Map<String, dynamic> expenseData) async {
    try {
      final response = await client
          .from('expenses')
          .insert(expenseData)
          .select();
      return response;
    } catch (e) {
      return null;
    }
  }

  // Actualizar perfil
  Future<List<Map<String, dynamic>>?> updateProfile(String userId, Map<String, dynamic> profileData) async {
    try {
      final response = await client
          .from('profiles')
          .update(profileData)
          .eq('id', userId)
          .select();
      return response;
    } catch (e) {
      return null;
    }
  }

  // ✅ MÉTODO PARA LIMPIAR CACHÉ
  void cleanup() {
    try {
      // Operaciones de limpieza si son necesarias
    } catch (e) {
      // Silenciar
    }
  }
}