import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/models/profile_model.dart';
import '../../services/image_picker_service.dart';
import '../../services/storage_service.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileRepository _profileRepository;
  final ImagePickerService _imagePickerService = ImagePickerService();
  final StorageService _storageService = StorageService();

  ProfileProvider(this._profileRepository);

  ProfileModel? _profile;
  bool _isLoading = false;
  String? _error;
  bool _isSaving = false;
  bool _isUploadingImage = false;

  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isUploadingImage => _isUploadingImage;
  String? get error => _error;
  bool get hasProfile => _profile != null;
  bool get hasCompleteProfile => _profile?.hasCompleteProfile ?? false;
  bool get hasAcademicInfo => _profile?.hasAcademicInfo ?? false;
  bool get hasAvatar => _profile?.avatarUrl != null && _profile!.avatarUrl!.isNotEmpty;

  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _profileRepository.getProfile();
      
      if (kDebugMode) {
        print('✅ Perfil cargado: ${_profile?.displayName}');
      }
    } catch (e) {
      _error = 'Error al cargar perfil: $e';
      if (kDebugMode) {
        print('❌ Error cargando perfil: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(ProfileModel newProfile) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      // Validar el perfil antes de guardar
      final validationErrors = newProfile.validate();
      if (validationErrors.isNotEmpty) {
        throw Exception(validationErrors.values.first);
      }

      await _profileRepository.updateProfile(newProfile);
      _profile = newProfile;
      
      if (kDebugMode) {
        print('✅ Perfil actualizado exitosamente: ${newProfile.displayName}');
      }
    } catch (e) {
      _error = 'Error al actualizar perfil: $e';
      if (kDebugMode) {
        print('❌ Error actualizando perfil: $e');
      }
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> updateFullProfile({
    String? fullName,
    String? studentId,
    String? university,
    String? currency,
    String? language,
    double? monthlyBudget,
    bool? biometricEnabled,
    bool? notificationsEnabled,
  }) async {
    if (_profile == null) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final updatedProfile = _profile!.copyWith(
        fullName: fullName,
        studentId: studentId,
        university: university,
        currency: currency,
        language: language,
        monthlyBudget: monthlyBudget,
        biometricEnabled: biometricEnabled,
        notificationsEnabled: notificationsEnabled,
      );

      // Validar el perfil antes de guardar
      final validationErrors = updatedProfile.validate();
      if (validationErrors.isNotEmpty) {
        throw Exception(validationErrors.values.first);
      }

      await _profileRepository.updateFullProfile(
        userId: _profile!.id,
        fullName: fullName,
        studentId: studentId,
        university: university,
        currency: currency,
        language: language,
        monthlyBudget: monthlyBudget,
        biometricEnabled: biometricEnabled,
        notificationsEnabled: notificationsEnabled,
      );

      _profile = updatedProfile;
      
      if (kDebugMode) {
        print('✅ Perfil completo actualizado exitosamente');
      }
    } catch (e) {
      _error = 'Error al actualizar perfil: $e';
      if (kDebugMode) {
        print('❌ Error actualizando perfil completo: $e');
      }
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> updatePersonalInfo({
    required String fullName,
    String? studentId,
    String? university,
  }) async {
    if (_profile == null) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      if (fullName.isEmpty) {
        throw Exception('El nombre completo es requerido');
      }

      final updatedProfile = _profile!.copyWith(
        fullName: fullName,
        studentId: studentId,
        university: university,
      );

      await _profileRepository.updatePersonalInfo(
        fullName: fullName,
        studentId: studentId,
        university: university,
      );

      _profile = updatedProfile;
      
      if (kDebugMode) {
        print('✅ Información personal actualizada: $fullName');
      }
    } catch (e) {
      _error = 'Error al actualizar información personal: $e';
      if (kDebugMode) {
        print('❌ Error actualizando información personal: $e');
      }
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> updatePreferences({
    required String currency,
    required String language,
    required bool notificationsEnabled,
  }) async {
    if (_profile == null) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      if (currency.isEmpty || language.isEmpty) {
        throw Exception('Moneda e idioma son requeridos');
      }

      final updatedProfile = _profile!.copyWith(
        currency: currency,
        language: language,
        notificationsEnabled: notificationsEnabled,
      );

      await _profileRepository.updatePreferences(
        currency: currency,
        language: language,
        notificationsEnabled: notificationsEnabled,
      );

      _profile = updatedProfile;
      
      if (kDebugMode) {
        print('✅ Preferencias actualizadas: $currency, $language');
      }
    } catch (e) {
      _error = 'Error al actualizar preferencias: $e';
      if (kDebugMode) {
        print('❌ Error actualizando preferencias: $e');
      }
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> updateMonthlyBudget(double budget) async {
    if (_profile == null) return;

    _isSaving = true;
    notifyListeners();

    try {
      if (budget < 0) {
        throw Exception('El presupuesto no puede ser negativo');
      }

      final updatedProfile = _profile!.copyWith(monthlyBudget: budget);
      await _profileRepository.updateBudget(budget);
      _profile = updatedProfile;
      
      if (kDebugMode) {
        print('✅ Presupuesto actualizado: \$${budget.toStringAsFixed(2)}');
      }
    } catch (e) {
      _error = 'Error al actualizar presupuesto: $e';
      if (kDebugMode) {
        print('❌ Error actualizando presupuesto: $e');
      }
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> updateAvatar(String avatarUrl) async {
    if (_profile == null) return;

    _isSaving = true;
    notifyListeners();

    try {
      final updatedProfile = _profile!.copyWith(avatarUrl: avatarUrl);
      await _profileRepository.updateAvatar(avatarUrl);
      _profile = updatedProfile;
      
      if (kDebugMode) {
        print('✅ Avatar actualizado');
      }
    } catch (e) {
      _error = 'Error al actualizar avatar: $e';
      if (kDebugMode) {
        print('❌ Error actualizando avatar: $e');
      }
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> updateSecuritySettings({
    required bool biometricEnabled,
  }) async {
    if (_profile == null) return;

    _isSaving = true;
    notifyListeners();

    try {
      final updatedProfile = _profile!.copyWith(biometricEnabled: biometricEnabled);
      await _profileRepository.updateSecuritySettings(biometricEnabled: biometricEnabled);
      _profile = updatedProfile;
      
      if (kDebugMode) {
        print('✅ Configuración de seguridad actualizada: $biometricEnabled');
      }
    } catch (e) {
      _error = 'Error al actualizar configuración de seguridad: $e';
      if (kDebugMode) {
        print('❌ Error actualizando seguridad: $e');
      }
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ========== MÉTODOS NUEVOS PARA MANEJO DE IMÁGENES ==========

  Future<void> updateProfileWithImage(File imageFile) async {
    if (_profile == null) return;

    _isUploadingImage = true;
    _error = null;
    notifyListeners();

    try {
      // Subir imagen a Supabase
      final imageUrl = await _profileRepository.uploadAndUpdateAvatar(
        imageFile, 
        _profile!.id
      );

      if (imageUrl != null) {
        // Actualizar perfil local con nueva URL
        final updatedProfile = _profile!.copyWith(avatarUrl: imageUrl);
        _profile = updatedProfile;
        
        if (kDebugMode) {
          print('✅ Avatar actualizado exitosamente: $imageUrl');
        }
      } else {
        throw Exception('Error al subir la imagen');
      }
    } catch (e) {
      _error = 'Error al actualizar avatar: $e';
      if (kDebugMode) {
        print('❌ Error actualizando avatar: $e');
      }
      rethrow;
    } finally {
      _isUploadingImage = false;
      notifyListeners();
    }
  }

  Future<void> pickAndUpdateAvatarFromGallery() async {
    if (_profile == null) return;

    try {
      final imageFile = await _imagePickerService.pickImageFromGallery();
      
      if (imageFile != null) {
        await updateProfileWithImage(imageFile);
      }
    } catch (e) {
      _error = 'Error al seleccionar imagen de la galería: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> pickAndUpdateAvatarFromCamera() async {
    if (_profile == null) return;

    try {
      final imageFile = await _imagePickerService.pickImageFromCamera();
      
      if (imageFile != null) {
        await updateProfileWithImage(imageFile);
      }
    } catch (e) {
      _error = 'Error al tomar foto con la cámara: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteCurrentAvatar() async {
    if (_profile == null || _profile!.avatarUrl == null) return;

    _isSaving = true;
    notifyListeners();

    try {
      // Eliminar avatar usando el repository
      await _profileRepository.deleteAvatar(
        _profile!.id, 
        _profile!.avatarUrl
      );
      
      // Actualizar perfil local
      final updatedProfile = _profile!.copyWith(avatarUrl: null);
      _profile = updatedProfile;
      
      if (kDebugMode) {
        print('✅ Avatar eliminado exitosamente');
      }
    } catch (e) {
      _error = 'Error al eliminar avatar: $e';
      if (kDebugMode) {
        print('❌ Error eliminando avatar: $e');
      }
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<String?> getAvatarUrl() async {
    return _profile?.avatarUrl;
  }

  // ========== MÉTODOS DE UTILIDAD ==========

  Future<bool> checkProfileExists() async {
    if (_profile == null) return false;
    
    try {
      return await _profileRepository.checkProfileExists(_profile!.id);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error verificando existencia de perfil: $e');
      }
      return false;
    }
  }

  Future<bool> isEmailAvailable(String email) async {
    try {
      return await _profileRepository.isEmailAvailable(email);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error verificando disponibilidad de email: $e');
      }
      return true; // En caso de error, asumimos disponible
    }
  }

  Future<bool> isStorageConfigured() async {
    try {
      return await _profileRepository.isStorageConfigured();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error verificando configuración de storage: $e');
      }
      return false;
    }
  }

  // Método para resetear el perfil
  void resetProfile() {
    _profile = null;
    _error = null;
    _isLoading = false;
    _isSaving = false;
    _isUploadingImage = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Método para forzar una recarga del perfil
  Future<void> refreshProfile() async {
    await loadProfile();
  }

  // Método para verificar si hay cambios sin guardar
  bool hasUnsavedChanges(ProfileModel editedProfile) {
    return _profile?.hasChanges(editedProfile) ?? false;
  }

  // Método para obtener el progreso de completitud del perfil
  double get profileCompleteness {
    if (_profile == null) return 0.0;
    
    int completedFields = 0;
    int totalFields = 6; // Campos importantes (incluyendo avatar)
    
    if (_profile!.fullName?.isNotEmpty ?? false) completedFields++;
    if (_profile!.studentId?.isNotEmpty ?? false) completedFields++;
    if (_profile!.university?.isNotEmpty ?? false) completedFields++;
    if (_profile!.currency.isNotEmpty) completedFields++;
    if (_profile!.monthlyBudget > 0) completedFields++;
    if (_profile!.avatarUrl != null && _profile!.avatarUrl!.isNotEmpty) completedFields++;
    
    return completedFields / totalFields;
  }

  String get profileCompletenessText {
    final percentage = (profileCompleteness * 100).round();
    return '$percentage% completado';
  }

  // Métodos para manejar notificaciones
  Future<void> toggleNotifications(bool enabled) async {
    if (_profile == null) return;

    try {
      final updatedProfile = _profile!.copyWith(notificationsEnabled: enabled);
      await _profileRepository.updateFullProfile(
        userId: _profile!.id,
        notificationsEnabled: enabled,
      );
      _profile = updatedProfile;
      notifyListeners();
      
      if (kDebugMode) {
        print('✅ Notificaciones ${enabled ? 'activadas' : 'desactivadas'}');
      }
    } catch (e) {
      _error = 'Error al actualizar configuración de notificaciones: $e';
      if (kDebugMode) {
        print('❌ Error actualizando notificaciones: $e');
      }
      rethrow;
    }
  }

  // Método para verificar si el perfil necesita completarse
  bool get needsProfileCompletion {
    if (_profile == null) return true;
    
    return _profile!.fullName == null || 
           _profile!.fullName!.isEmpty ||
           _profile!.currency.isEmpty ||
           _profile!.language.isEmpty;
  }

  // Método para obtener campos faltantes
  List<String> get missingFields {
    if (_profile == null) return ['Todos los campos'];
    
    final missing = <String>[];
    if (_profile!.fullName == null || _profile!.fullName!.isEmpty) {
      missing.add('Nombre completo');
    }
    if (_profile!.currency.isEmpty) {
      missing.add('Moneda');
    }
    if (_profile!.language.isEmpty) {
      missing.add('Idioma');
    }
    if (_profile!.avatarUrl == null || _profile!.avatarUrl!.isEmpty) {
      missing.add('Foto de perfil');
    }
    
    return missing;
  }

  // Método para actualizar múltiples campos a la vez
  Future<void> updateMultipleFields(Map<String, dynamic> fields) async {
    if (_profile == null) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final updatedProfile = _profile!.copyWith(
        fullName: fields['fullName'] as String?,
        studentId: fields['studentId'] as String?,
        university: fields['university'] as String?,
        currency: fields['currency'] as String?,
        language: fields['language'] as String?,
        monthlyBudget: fields['monthlyBudget'] as double?,
        biometricEnabled: fields['biometricEnabled'] as bool?,
        notificationsEnabled: fields['notificationsEnabled'] as bool?,
      );

      // Validar el perfil antes de guardar
      final validationErrors = updatedProfile.validate();
      if (validationErrors.isNotEmpty) {
        throw Exception(validationErrors.values.first);
      }

      await _profileRepository.updateFullProfile(
        userId: _profile!.id,
        fullName: fields['fullName'] as String?,
        studentId: fields['studentId'] as String?,
        university: fields['university'] as String?,
        currency: fields['currency'] as String?,
        language: fields['language'] as String?,
        monthlyBudget: fields['monthlyBudget'] as double?,
        biometricEnabled: fields['biometricEnabled'] as bool?,
        notificationsEnabled: fields['notificationsEnabled'] as bool?,
      );

      _profile = updatedProfile;
      
      if (kDebugMode) {
        print('✅ Múltiples campos actualizados exitosamente');
      }
    } catch (e) {
      _error = 'Error al actualizar campos: $e';
      if (kDebugMode) {
        print('❌ Error actualizando múltiples campos: $e');
      }
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // Método para obtener el estado de carga de imágenes
  String get imageUploadStatus {
    if (_isUploadingImage) return 'Subiendo imagen...';
    if (_isSaving) return 'Guardando cambios...';
    if (_isLoading) return 'Cargando perfil...';
    return 'Listo';
  }
}