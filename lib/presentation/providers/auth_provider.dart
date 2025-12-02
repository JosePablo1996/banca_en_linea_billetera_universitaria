import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gotrue/gotrue.dart';
import '../../data/repositories/auth_repository.dart';
import '../../services/biometric_service.dart';
import '../../presentation/widgets/welcome_modal.dart';

class AuthProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  final AuthRepository _authRepository;
  final BiometricService _biometricService;

  AuthProvider(this._prefs, this._authRepository, this._biometricService);

  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  bool _isBiometricLoading = false;
  bool _isCheckingBiometrics = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  bool get isBiometricLoading => _isBiometricLoading;
  bool get isCheckingBiometrics => _isCheckingBiometrics;

  bool get isBiometricEnabled => _biometricService.isBiometricEnabled;
  User? get user => _authRepository.currentUser;
  User? get currentUser => _authRepository.currentUser;
  String? get userId => user?.id;

  // ✅ CORREGIDO: Usar método existente en lugar de getCurrentSession()
  Future<bool> checkAuthenticationStatus() async {
    try {
      // Usar la propiedad existente isAuthenticated del repositorio
      final hasSession = _authRepository.isAuthenticated;
      
      // Actualizar el estado interno
      _isAuthenticated = hasSession;
      
      if (kDebugMode) {
        print('🔍 Verificación de autenticación: $hasSession');
        if (hasSession && _authRepository.currentUser != null) {
          print('👤 Usuario autenticado: ${_authRepository.currentUser!.email}');
        }
      }
      
      return hasSession;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error verificando autenticación: $e');
      }
      _isAuthenticated = false;
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authRepository.signIn(email, password);
      _isAuthenticated = response.user != null;
      
      if (_isAuthenticated) {
        _error = null;
        
        // ✅ GUARDAR CREDENCIALES después del login exitoso
        await _authRepository.saveBiometricCredentials(email, password);
        
        if (kDebugMode) {
          print('✅ Login exitoso para: $email');
          print('🔐 Credenciales guardadas para biometría');
        }
      } else {
        _error = 'No se pudo iniciar sesión. Verifica tus credenciales.';
      }
      
      return _isAuthenticated;
    } catch (e) {
      _error = 'Error al iniciar sesión: ${e.toString().replaceAll('Exception: ', '')}';
      if (kDebugMode) {
        print('❌ Error en login: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp(
    String email, 
    String password, 
    String fullName, {
    String studentId = '',
    String university = '',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authRepository.signUp(
        email, 
        password, 
        fullName,
        studentId: studentId,
        university: university,
      );
      _isAuthenticated = response.user != null;
      
      if (_isAuthenticated) {
        _error = null;
        
        // ✅ GUARDAR CREDENCIALES después del registro exitoso
        await _authRepository.saveBiometricCredentials(email, password);
        
        if (kDebugMode) {
          print('✅ Registro exitoso para: $email');
          print('🔐 Credenciales guardadas para biometría');
        }
      } else {
        _error = 'No se pudo completar el registro. Intenta nuevamente.';
      }
      
      return _isAuthenticated;
    } catch (e) {
      _error = 'Error en el registro: ${e.toString().replaceAll('Exception: ', '')}';
      if (kDebugMode) {
        print('❌ Error en registro: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithBiometric() async {
    // Verificar si realmente se puede usar biometría
    final canUse = await _biometricService.canUseBiometric;
    if (!canUse) {
      _error = 'La biometría no está disponible o no está habilitada. '
               'Ve a Configuración Biométrica para activarla.';
      notifyListeners();
      return false;
    }

    _isBiometricLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (kDebugMode) {
        print('🔐 Iniciando autenticación biométrica...');
      }

      final biometricType = await _biometricService.getAvailableBiometricType();
      final biometricEmoji = await _biometricService.getBiometricEmoji();
      
      final result = await _biometricService.authenticateWithCustomDialog(
        title: 'Autenticación Biométrica',
        subtitle: 'Usa tu $biometricType $biometricEmoji para acceder a tu billetera universitaria',
        cancelButtonText: 'Usar contraseña',
      );
      
      if (result['success'] == true) {
        if (kDebugMode) {
          print('✅ Autenticación biométrica exitosa con $biometricType');
        }
        
        final email = result['email'];
        final password = result['password'];
        final hasCredentials = result['hasCredentials'] == true;
        
        if (hasCredentials && email != null && password != null) {
          if (kDebugMode) {
            print('🔐 Credenciales recuperadas: $email');
          }
          
          // Autenticar en Supabase con las credenciales recuperadas
          final success = await _authenticateWithCredentials(email, password);
          
          if (success) {
            _isAuthenticated = true;
            _error = null;
            
            if (kDebugMode) {
              print('✅ Usuario autenticado en Supabase después de biometría');
            }
            
            return true;
          } else {
            _error = 'No se pudo autenticar en el servidor. '
                    'Inicia sesión manualmente y vuelve a habilitar la biometría.';
            return false;
          }
        } else {
          _error = 'No hay credenciales guardadas para biometría. '
                  'Inicia sesión manualmente primero para guardar tus credenciales.';
          return false;
        }
      } else {
        final errorMsg = result['error'] ?? 'Error en autenticación biométrica';
        _error = errorMsg;
        
        if (kDebugMode) {
          print('❌ Error en biometría: $errorMsg');
        }
        
        return false;
      }
    } on PlatformException catch (e) {
      String errorMessage = 'Error en autenticación biométrica';
      
      switch (e.code) {
        case 'PasscodeNotSet':
          errorMessage = 'Configura un PIN o patrón de desbloqueo en tu dispositivo primero';
          break;
        case 'NotEnrolled':
          errorMessage = 'No hay huellas digitales registradas. '
                        'Registra al menos una huella en la configuración de tu dispositivo';
          break;
        case 'NotAvailable':
          errorMessage = 'La biometría no está disponible en este dispositivo';
          break;
        case 'LockedOut':
          errorMessage = 'Demasiados intentos fallidos. La biometría está bloqueada temporalmente';
          break;
        case 'PermanentlyLockedOut':
          errorMessage = 'La biometría está bloqueada permanentemente. '
                        'Debes configurar un nuevo método de desbloqueo';
          break;
        case 'no_fragment_activity':
          errorMessage = 'Error de configuración de la aplicación. '
                        'Reinicia la aplicación e intenta nuevamente';
          break;
        default:
          errorMessage = 'Error: ${e.message ?? e.code}';
      }
      
      _error = errorMessage;
      
      if (kDebugMode) {
        print('❌ PlatformException en biometría: ${e.code} - ${e.message}');
      }
      
      return false;
    } catch (e) {
      _error = 'Error inesperado en autenticación biométrica: $e';
      
      if (kDebugMode) {
        print('❌ Error genérico en biometría: $e');
      }
      
      return false;
    } finally {
      _isBiometricLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _authenticateWithCredentials(String email, String password) async {
    try {
      final response = await _authRepository.signIn(email, password);
      final success = response.user != null;
      
      if (kDebugMode) {
        print('🔐 Autenticación Supabase con credenciales: $success');
      }
      
      return success;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error autenticando con credenciales: $e');
      }
      return false;
    }
  }

  Future<void> saveCredentialsForBiometric(String email, String password) async {
    try {
      final success = await _authRepository.saveBiometricCredentials(email, password);
      
      if (success) {
        if (kDebugMode) {
          print('🔐 Credenciales guardadas de forma segura para biometría: $email');
        }
      } else {
        if (kDebugMode) {
          print('❌ Error guardando credenciales de forma segura');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error guardando credenciales: $e');
      }
    }
  }

  Future<void> clearBiometricCredentials() async {
    try {
      await _authRepository.clearBiometricCredentials();
      
      if (kDebugMode) {
        print('🔐 Credenciales biométricas limpiadas de forma segura');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error limpiando credenciales: $e');
      }
    }
  }

  Future<void> resetBiometricForNewUser() async {
    try {
      await _authRepository.setBiometricEnabled(false);
      await clearBiometricCredentials();
      
      if (kDebugMode) {
        print('🔄 Biometría reseteada para nuevo usuario');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error reseteando biometría: $e');
      }
    }
  }

  Future<void> toggleBiometric(bool enabled) async {
    try {
      await _authRepository.setBiometricEnabled(enabled);
      
      // Si se está habilitando, verificar que hay credenciales guardadas
      if (enabled && !_authRepository.hasBiometricCredentials) {
        _error = 'No hay credenciales guardadas. Inicia sesión manualmente primero.';
        notifyListeners();
        return;
      }
      
      if (kDebugMode) {
        print('🔧 Biometría ${enabled ? 'habilitada' : 'deshabilitada'}');
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Error al cambiar configuración biométrica: $e';
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getBiometricStatus() async {
    _isCheckingBiometrics = true;
    notifyListeners();

    try {
      final status = await _authRepository.getBiometricStatus();
      
      if (kDebugMode) {
        print('📊 Estado biométrico: $status');
      }
      
      _isCheckingBiometrics = false;
      notifyListeners();
      return status;
    } catch (e) {
      _isCheckingBiometrics = false;
      notifyListeners();
      
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

  // ✅ CORREGIDO: Cerrar sesión MANTENIENDO credenciales por defecto
  Future<void> signOut({bool keepBiometricCredentials = true}) async {
    try {
      await _authRepository.signOut();
      _isAuthenticated = false;
      _error = null;
      
      // ✅ SOLO limpiar credenciales si explícitamente se solicita
      if (!keepBiometricCredentials) {
        await clearBiometricCredentials();
        if (kDebugMode) {
          print('🚪 Sesión cerrada - Credenciales biométricas eliminadas por seguridad');
        }
      } else {
        if (kDebugMode) {
          print('🚪 Sesión cerrada - Credenciales biométricas PRESERVADAS para próximo inicio');
        }
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Error al cerrar sesión: $e';
      notifyListeners();
    }
  }

  // ✅ NUEVO: Método para cerrar sesión con confirmación
  Future<void> signOutWithConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Quieres mantener tus credenciales biométricas para el próximo inicio de sesión?\n\nRecomendado: MANTENER para acceso rápido con huella digital.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Eliminar Todo', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Mantener Huella', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );

    if (result == null) return;

    await signOut(keepBiometricCredentials: result);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result 
            ? 'Sesión cerrada - Huella digital preservada ✅'
            : 'Sesión cerrada - Todas las credenciales eliminadas 🗑️',
        ),
        backgroundColor: result ? Colors.green : Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ✅ MÉTODO SIMPLE de cierre de sesión (para compatibilidad)
  Future<void> simpleSignOut() async {
    await signOut(keepBiometricCredentials: true);
  }

  void checkAuthStatus() {
    _isAuthenticated = _authRepository.isAuthenticated;
    
    if (kDebugMode) {
      print('🔍 Estado de autenticación: $_isAuthenticated');
    }
    
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  bool get hasUser => _authRepository.isAuthenticated;
  String? get currentUserEmail => _authRepository.currentUser?.email;
  String? get currentUserId => userId;

  String? get currentUserFullName {
    final user = _authRepository.currentUser;
    if (user != null && user.userMetadata != null) {
      return user.userMetadata!['full_name'] as String?;
    }
    return null;
  }

  Future<bool> checkSupabaseConnection() async {
    try {
      final user = _authRepository.currentUser;
      return user != null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error de conexión con Supabase: $e');
      }
      return false;
    }
  }

  void resetAuthState() {
    _isLoading = false;
    _isBiometricLoading = false;
    _isCheckingBiometrics = false;
    _error = null;
    notifyListeners();
  }

  bool get isEmailVerified {
    final user = _authRepository.currentUser;
    return user?.emailConfirmedAt != null;
  }

  String get userAvatar {
    final user = _authRepository.currentUser;
    if (user == null) return 'U';
    
    if (currentUserFullName?.isNotEmpty == true) {
      return currentUserFullName![0].toUpperCase();
    } else if (user.email?.isNotEmpty == true) {
      return user.email![0].toUpperCase();
    }
    
    return 'U';
  }

  bool get hasBiometricCredentials => _authRepository.hasBiometricCredentials;

  Future<Map<String, dynamic>> getFullBiometricStatus() async {
    final status = await getBiometricStatus();
    status['hasCredentials'] = hasBiometricCredentials;
    status['canUseBiometric'] = await _biometricService.canUseBiometric;
    
    return status;
  }

  Future<void> forceClearAllCredentials() async {
    try {
      await clearBiometricCredentials();
      await _authRepository.setBiometricEnabled(false);
      
      if (kDebugMode) {
        print('🛡️ Todas las credenciales forzadas a limpiarse por seguridad');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error forzando limpieza de credenciales: $e');
      }
    }
  }

  @override
  void dispose() {
    if (kDebugMode) {
      print('🔄 AuthProvider disposed');
    }
    super.dispose();
  }
}