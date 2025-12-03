import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  BiometricService(this._prefs);

  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _storedEmailKey = 'biometric_stored_email';
  static const String _storedPasswordKey = 'biometric_stored_password';
  static const String _credentialsSavedKey = 'biometric_credentials_saved';

  // ✅ CORREGIDO: Getter mejorado para isBiometricEnabled
  bool get isBiometricEnabled {
    try {
      final isEnabled = _prefs.getBool(_biometricEnabledKey) ?? false;
      
      if (kDebugMode) {
        print('⚙️ Biometría habilitada en preferencias: $isEnabled');
      }
      
      return isEnabled;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo estado de biometría: $e');
      }
      return false;
    }
  }

  // ✅ NUEVO: Verificar si hay credenciales guardadas
  bool get hasStoredCredentials {
    try {
      final hasCredentials = _prefs.getBool(_credentialsSavedKey) ?? false;
      
      if (kDebugMode) {
        print('🔐 Credenciales guardadas: $hasCredentials');
      }
      
      return hasCredentials;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error verificando credenciales: $e');
      }
      return false;
    }
  }

  // ✅ NUEVO: Método para guardar credenciales de forma segura
  Future<bool> saveCredentials(String email, String password) async {
    try {
      // Guardar email y password de forma segura
      await _secureStorage.write(key: _storedEmailKey, value: email);
      await _secureStorage.write(key: _storedPasswordKey, value: password);
      
      // Marcar que hay credenciales guardadas
      await _prefs.setBool(_credentialsSavedKey, true);
      
      if (kDebugMode) {
        print('💾 Credenciales guardadas exitosamente para: $email');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error guardando credenciales: $e');
      }
      return false;
    }
  }

  // ✅ NUEVO: Método para recuperar credenciales
  Future<Map<String, String?>> getStoredCredentials() async {
    try {
      if (!hasStoredCredentials) {
        if (kDebugMode) {
          print('❌ No hay credenciales guardadas para biometría');
        }
        return {'email': null, 'password': null};
      }

      final email = await _secureStorage.read(key: _storedEmailKey);
      final password = await _secureStorage.read(key: _storedPasswordKey);
      
      if (kDebugMode) {
        print('🔍 Credenciales recuperadas - Email: ${email != null ? 'SÍ' : 'NO'}, Password: ${password != null ? 'SÍ' : 'NO'}');
      }
      
      return {
        'email': email,
        'password': password,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error recuperando credenciales: $e');
      }
      return {'email': null, 'password': null};
    }
  }

  // ✅ NUEVO: Método para limpiar credenciales
  Future<void> clearStoredCredentials() async {
    try {
      await _secureStorage.delete(key: _storedEmailKey);
      await _secureStorage.delete(key: _storedPasswordKey);
      await _prefs.setBool(_credentialsSavedKey, false);
      
      if (kDebugMode) {
        print('🗑️ Credenciales biométricas eliminadas');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error eliminando credenciales: $e');
      }
    }
  }

  // ✅ NUEVO: Método para verificar si se puede usar biometría
  Future<bool> get canUseBiometric async {
    try {
      final status = await getBiometricStatus();
      final canAuthenticate = status['canAuthenticate'] == true;
      final hasBiometrics = status['hasBiometricsConfigured'] == true;
      final isEnabled = isBiometricEnabled;
      final hasCredentials = hasStoredCredentials;
      
      if (kDebugMode) {
        print('🔐 Puede usar biometría: $canAuthenticate && $hasBiometrics && $isEnabled && $hasCredentials');
      }
      
      return canAuthenticate && hasBiometrics && isEnabled && hasCredentials;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error verificando uso de biometría: $e');
      }
      return false;
    }
  }

  // ✅ NUEVO: Método para inicializar biometría para nuevo usuario
  Future<void> initializeBiometricForNewUser() async {
    try {
      // Por defecto, no habilitar automáticamente para nuevos usuarios
      // El usuario debe habilitarla manualmente desde la configuración
      await setBiometricEnabled(false);
      await clearStoredCredentials();
      
      if (kDebugMode) {
        print('🔄 Biometría inicializada para nuevo usuario (deshabilitada por defecto)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error inicializando biometría para nuevo usuario: $e');
      }
    }
  }

  // Verificar si el dispositivo soporta biometría
  Future<bool> canAuthenticate() async {
    try {
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      
      if (kDebugMode) {
        print('📱 Soporte de biometría: $isDeviceSupported');
        print('🔍 Puede verificar biometría: $canCheckBiometrics');
      }
      
      return isDeviceSupported && canCheckBiometrics;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('❌ Error verificando biometría: ${e.code} - ${e.message}');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error inesperado verificando biometría: $e');
      }
      return false;
    }
  }

  // Obtener los métodos biométricos disponibles
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      if (kDebugMode) {
        print('🔐 Biometrías disponibles: $availableBiometrics');
      }
      
      return availableBiometrics;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo biometrías disponibles: ${e.code} - ${e.message}');
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error inesperado obteniendo biometrías: $e');
      }
      return [];
    }
  }

  // Autenticación básica con biometría
  Future<Map<String, dynamic>> authenticate() async {
    try {
      if (kDebugMode) {
        print('🔐 Iniciando autenticación biométrica...');
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Autentícate para acceder a tu billetera universitaria',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
      
      if (kDebugMode) {
        print('✅ Resultado autenticación: $didAuthenticate');
      }
      
      return {
        'success': didAuthenticate,
        'error': didAuthenticate ? null : 'Autenticación cancelada por el usuario',
      };
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('❌ PlatformException en autenticación: ${e.code} - ${e.message}');
      }
      
      String errorMessage = 'Error en autenticación biométrica';
      
      switch (e.code) {
        case 'PasscodeNotSet':
          errorMessage = 'No hay un PIN configurado en el dispositivo';
          break;
        case 'NotEnrolled':
          errorMessage = 'No hay huellas digitales registradas';
          break;
        case 'NotAvailable':
          errorMessage = 'Biometría no disponible en este dispositivo';
          break;
        case 'LockedOut':
          errorMessage = 'Demasiados intentos fallidos. La biometría está bloqueada temporalmente';
          break;
        case 'PermanentlyLockedOut':
          errorMessage = 'La biometría está bloqueada permanentemente';
          break;
        case 'no_fragment_activity':
          errorMessage = 'Error de configuración de la aplicación';
          break;
        default:
          errorMessage = 'Error: ${e.message ?? e.code}';
      }
      
      return {
        'success': false,
        'error': errorMessage,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error genérico en autenticación: $e');
      }
      
      return {
        'success': false,
        'error': 'Error inesperado en autenticación biométrica: $e',
      };
    }
  }

  // ✅ NUEVO: Autenticación con diálogo personalizado y recuperación de credenciales
  Future<Map<String, dynamic>> authenticateWithCustomDialog({
    required String title,
    required String subtitle,
    String cancelButtonText = 'Cancelar',
  }) async {
    try {
      if (kDebugMode) {
        print('🎯 Autenticación con diálogo personalizado: $subtitle');
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: subtitle,
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
          sensitiveTransaction: true,
        ),
      );
      
      if (kDebugMode) {
        print('✅ Resultado autenticación personalizada: $didAuthenticate');
      }

      // Si la autenticación fue exitosa, recuperar las credenciales
      Map<String, String?> credentials = {'email': null, 'password': null};
      if (didAuthenticate) {
        credentials = await getStoredCredentials();
        
        if (kDebugMode) {
          print('🔐 Credenciales después de autenticación: ${credentials['email'] != null ? 'EMAIL_DISPONIBLE' : 'SIN_EMAIL'}');
        }
      }
      
      return {
        'success': didAuthenticate,
        'error': didAuthenticate ? null : 'Autenticación cancelada por el usuario',
        'biometricType': await getAvailableBiometricType(),
        'email': credentials['email'],
        'password': credentials['password'],
        'hasCredentials': credentials['email'] != null && credentials['password'] != null,
      };
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('❌ PlatformException en autenticación personalizada: ${e.code} - ${e.message}');
      }
      
      String errorMessage = 'Error en autenticación biométrica';
      
      switch (e.code) {
        case 'PasscodeNotSet':
          errorMessage = 'Configura un PIN o patrón de desbloqueo en tu dispositivo para usar la biometría';
          break;
        case 'NotEnrolled':
          errorMessage = 'No hay métodos biométricos registrados en tu dispositivo. '
                        'Ve a Configuración del dispositivo > Seguridad > Huella digital';
          break;
        case 'NotAvailable':
          errorMessage = 'La biometría no está disponible en este dispositivo';
          break;
        case 'LockedOut':
          errorMessage = 'Demasiados intentos fallidos. La biometría está bloqueada temporalmente. '
                        'Espera unos minutos o usa tu PIN/patrón';
          break;
        case 'PermanentlyLockedOut':
          errorMessage = 'La biometría está bloqueada permanentemente. '
                        'Debes configurar un nuevo método de desbloqueo en tu dispositivo';
          break;
        case 'no_fragment_activity':
          errorMessage = 'Error de configuración de la aplicación. '
                        'Reinicia la aplicación e intenta nuevamente';
          break;
        default:
          errorMessage = 'Error de autenticación: ${e.message ?? e.code}';
      }
      
      return {
        'success': false,
        'error': errorMessage,
        'biometricType': await getAvailableBiometricType(),
        'email': null,
        'password': null,
        'hasCredentials': false,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error genérico en autenticación personalizada: $e');
      }
      
      return {
        'success': false,
        'error': 'Error inesperado en autenticación biométrica: $e',
        'biometricType': await getAvailableBiometricType(),
        'email': null,
        'password': null,
        'hasCredentials': false,
      };
    }
  }

  // Habilitar o deshabilitar la biometría
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _prefs.setBool(_biometricEnabledKey, enabled);
      
      // Si se deshabilita la biometría, limpiar las credenciales
      if (!enabled) {
        await clearStoredCredentials();
      }
      
      if (kDebugMode) {
        print('🔧 Biometría ${enabled ? 'HABILITADA' : 'DESHABILITADA'} en preferencias');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error guardando preferencia de biometría: $e');
      }
      rethrow;
    }
  }

  // Verificar si el dispositivo tiene biometría configurada
  Future<bool> hasBiometricsConfigured() async {
    try {
      final canAuthenticate = await _localAuth.canCheckBiometrics;
      if (!canAuthenticate) {
        if (kDebugMode) {
          print('❌ No se puede verificar biometría');
        }
        return false;
      }

      final availableBiometrics = await getAvailableBiometrics();
      final hasBiometrics = availableBiometrics.isNotEmpty;
      
      if (kDebugMode) {
        print('📋 Biometrías configuradas: $hasBiometrics ($availableBiometrics)');
      }
      
      return hasBiometrics;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('❌ PlatformException verificando configuración: ${e.code} - ${e.message}');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error inesperado verificando configuración: $e');
      }
      return false;
    }
  }

  // Obtener el tipo de biometría disponible
  Future<String> getAvailableBiometricType() async {
    try {
      final availableBiometrics = await getAvailableBiometrics();
      
      String biometricType = 'Biometría';
      
      if (availableBiometrics.contains(BiometricType.face)) {
        biometricType = 'Reconocimiento Facial';
      } else if (availableBiometrics.contains(BiometricType.iris)) {
        biometricType = 'Reconocimiento de Iris';
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        biometricType = 'Huella Digital';
      } else {
        biometricType = 'Método Biométrico';
      }
      
      if (kDebugMode) {
        print('👤 Tipo de biometría detectado: $biometricType');
      }
      
      return biometricType;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error detectando tipo de biometría: $e');
      }
      return 'Biometría';
    }
  }

  // Obtener el emoji correspondiente al tipo de biometría
  Future<String> getBiometricEmoji() async {
    try {
      final availableBiometrics = await getAvailableBiometrics();
      
      if (availableBiometrics.contains(BiometricType.face)) {
        return '👁️';
      } else if (availableBiometrics.contains(BiometricType.iris)) {
        return '👁️';
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return '👆';
      } else {
        return '🔐';
      }
    } catch (e) {
      return '🔐';
    }
  }

  // Verificar estado completo de biometría
  Future<Map<String, dynamic>> getBiometricStatus() async {
    try {
      final canAuth = await canAuthenticate();
      final hasBiometrics = await hasBiometricsConfigured();
      final biometricType = await getAvailableBiometricType();
      final biometricEmoji = await getBiometricEmoji();
      final isEnabled = isBiometricEnabled;
      final hasCredentials = hasStoredCredentials;

      final status = {
        'canAuthenticate': canAuth,
        'hasBiometricsConfigured': hasBiometrics,
        'biometricType': biometricType,
        'biometricEmoji': biometricEmoji,
        'isEnabled': isEnabled,
        'hasCredentials': hasCredentials,
        'error': null,
        'timestamp': DateTime.now().toIso8601String(),
      };

      if (kDebugMode) {
        print('📊 Estado biométrico completo: $status');
      }

      return status;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo estado biométrico: $e');
      }
      
      return {
        'canAuthenticate': false,
        'hasBiometricsConfigured': false,
        'biometricType': 'Error',
        'biometricEmoji': '❌',
        'isEnabled': false,
        'hasCredentials': false,
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  // Reiniciar configuración de biometría
  Future<void> resetBiometricSettings() async {
    try {
      await _prefs.remove(_biometricEnabledKey);
      await clearStoredCredentials();
      
      if (kDebugMode) {
        print('🔄 Configuración biométrica reiniciada');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error reiniciando configuración biométrica: $e');
      }
      rethrow;
    }
  }

  // Verificar compatibilidad con Face ID/Touch ID
  Future<Map<String, dynamic>> getBiometricCompatibility() async {
    try {
      final canAuth = await canAuthenticate();
      final availableBiometrics = await getAvailableBiometrics();
      final biometricType = await getAvailableBiometricType();
      
      final isFaceId = availableBiometrics.contains(BiometricType.face);
      final isTouchId = availableBiometrics.contains(BiometricType.fingerprint);
      final isIris = availableBiometrics.contains(BiometricType.iris);
      
      return {
        'isCompatible': canAuth,
        'isFaceId': isFaceId,
        'isTouchId': isTouchId,
        'isIris': isIris,
        'biometricType': biometricType,
        'availableMethods': availableBiometrics.map((b) => b.toString()).toList(),
      };
    } catch (e) {
      return {
        'isCompatible': false,
        'isFaceId': false,
        'isTouchId': false,
        'isIris': false,
        'biometricType': 'Error',
        'availableMethods': [],
        'error': e.toString(),
      };
    }
  }

  // Obtener estadísticas de uso (para analytics futuros)
  Map<String, dynamic> getUsageStats() {
    return {
      'isEnabled': isBiometricEnabled,
      'hasCredentials': hasStoredCredentials,
      'lastChecked': DateTime.now().toIso8601String(),
      'preferenceKey': _biometricEnabledKey,
    };
  }

  // ✅ NUEVO: Método para limpiar todas las configuraciones
  Future<void> clearAllSettings() async {
    try {
      await _prefs.remove(_biometricEnabledKey);
      await clearStoredCredentials();
      
      if (kDebugMode) {
        print('🗑️ Todas las configuraciones biométricas limpiadas');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error limpiando configuraciones: $e');
      }
    }
  }

  // ✅ NUEVO: Verificar si el dispositivo tiene hardware biométrico
  Future<bool> hasBiometricHardware() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      
      if (kDebugMode) {
        print('📱 Hardware biométrico disponible: $isSupported');
      }
      
      return isSupported;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error verificando hardware biométrico: $e');
      }
      return false;
    }
  }

  // ✅ NUEVO: Obtener lista de biometrías disponibles como texto
  Future<List<String>> getAvailableBiometricsAsText() async {
    try {
      final biometrics = await getAvailableBiometrics();
      return biometrics.map((type) {
        switch (type) {
          case BiometricType.face:
            return 'Reconocimiento Facial';
          case BiometricType.fingerprint:
            return 'Huella Digital';
          case BiometricType.iris:
            return 'Reconocimiento de Iris';
          case BiometricType.strong:
            return 'Biometría Fuerte';
          case BiometricType.weak:
            return 'Biometría Débil';
          default:
            return 'Método Biométrico';
        }
      }).toList();
    } catch (e) {
      return ['Error obteniendo biometrías'];
    }
  }
}