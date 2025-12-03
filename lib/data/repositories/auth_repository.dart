import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../services/biometric_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final SupabaseService _supabaseService = SupabaseService();
  late final BiometricService _biometricService;

  AuthRepository(SharedPreferences prefs) {
    _biometricService = BiometricService(prefs);
  }

  Future<AuthResponse> signUp(
    String email, 
    String password, 
    String fullName, {
    String studentId = '',
    String university = '',
  }) async {
    try {
      final response = await _supabaseService.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'student_id': studentId,
          'university': university,
        },
      );
      
      if (response.user != null) {
        await _biometricService.initializeBiometricForNewUser();
      }
      
      return response;
    } catch (e) {
      throw Exception('Error en registro: $e');
    }
  }

  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await _supabaseService.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        await _biometricService.saveCredentials(email, password);
      }
      
      return response;
    } catch (e) {
      throw Exception('Error en inicio de sesión: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _supabaseService.auth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  Future<bool> hasStoredCredentials() async {
    try {
      final credentials = await _biometricService.getStoredCredentials();
      return credentials['email'] != null && credentials['password'] != null;
    } catch (e) {
      return false;
    }
  }

  Future<bool> saveBiometricCredentials(String email, String password) async {
    try {
      return await _biometricService.saveCredentials(email, password);
    } catch (e) {
      return false;
    }
  }

  Future<void> clearBiometricCredentials() async {
    try {
      await _biometricService.clearStoredCredentials();
    } catch (e) {
      throw Exception('Error limpiando credenciales biométricas: $e');
    }
  }

  Future<Map<String, dynamic>> getBiometricStatus() async {
    try {
      return await _biometricService.getBiometricStatus();
    } catch (e) {
      return {
        'canAuthenticate': false,
        'hasBiometricsConfigured': false,
        'biometricType': 'Error',
        'biometricEmoji': '❌',
        'isEnabled': false,
        'hasCredentials': false,
        'error': e.toString(),
      };
    }
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _biometricService.setBiometricEnabled(enabled);
    } catch (e) {
      throw Exception('Error cambiando estado de biometría: $e');
    }
  }

  bool get isBiometricEnabled => _biometricService.isBiometricEnabled;
  bool get hasBiometricCredentials => _biometricService.hasStoredCredentials;

  User? get currentUser => _supabaseService.auth.currentUser;
  bool get isAuthenticated => _supabaseService.auth.currentUser != null;

  Map<String, dynamic>? get currentUserMetadata {
    final user = _supabaseService.auth.currentUser;
    return user?.userMetadata;
  }
}