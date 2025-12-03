import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import '../../services/supabase_service.dart';
import '../../services/storage_service.dart';

class ProfileRepository {
  final SupabaseService _supabaseService = SupabaseService();
  final StorageService _storageService = StorageService();

  Future<ProfileModel?> getProfile() async {
    try {
      final userId = _supabaseService.currentUserId;
      if (userId == null) return null;

      final response = await _supabaseService.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return ProfileModel.fromJson(response);
    } catch (e) {
      // Si no existe el perfil, crear uno por defecto
      return await _createDefaultProfile();
    }
  }

  Future<ProfileModel?> _createDefaultProfile() async {
    try {
      final user = _supabaseService.auth.currentUser;
      if (user == null) return null;

      final defaultProfile = ProfileModel.defaultProfile(
        user.id, 
        user.email ?? ''
      );

      await _supabaseService.client
          .from('profiles')
          .insert(defaultProfile.toJson());

      return defaultProfile;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateProfile(ProfileModel profile) async {
    try {
      final updateData = {
        'full_name': profile.fullName,
        'student_id': profile.studentId,
        'university': profile.university,
        'avatar_url': profile.avatarUrl,
        'currency': profile.currency,
        'language': profile.language,
        'monthly_budget': profile.monthlyBudget,
        'biometric_enabled': profile.biometricEnabled,
        'notifications_enabled': profile.notificationsEnabled,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Remove null values
      updateData.removeWhere((key, value) => value == null);

      await _supabaseService.client
          .from('profiles')
          .update(updateData)
          .eq('id', profile.id);
    } catch (e) {
      throw Exception('Error al actualizar perfil: $e');
    }
  }

  Future<void> updateFullProfile({
    required String userId,
    String? fullName,
    String? studentId,
    String? university,
    String? currency,
    String? language,
    double? monthlyBudget,
    bool? biometricEnabled,
    bool? notificationsEnabled,
  }) async {
    try {
      final updateData = {
        if (fullName != null) 'full_name': fullName,
        if (studentId != null) 'student_id': studentId,
        if (university != null) 'university': university,
        if (currency != null) 'currency': currency,
        if (language != null) 'language': language,
        if (monthlyBudget != null) 'monthly_budget': monthlyBudget,
        if (biometricEnabled != null) 'biometric_enabled': biometricEnabled,
        if (notificationsEnabled != null) 'notifications_enabled': notificationsEnabled,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabaseService.client
          .from('profiles')
          .update(updateData)
          .eq('id', userId);
    } catch (e) {
      throw Exception('Error al actualizar perfil completo: $e');
    }
  }

  Future<void> updateAvatar(String avatarUrl) async {
    try {
      final userId = _supabaseService.currentUserId;
      if (userId == null) return;

      await _supabaseService.client
          .from('profiles')
          .update({
            'avatar_url': avatarUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      throw Exception('Error al actualizar avatar: $e');
    }
  }

  Future<void> updateBudget(double monthlyBudget) async {
    try {
      final userId = _supabaseService.currentUserId;
      if (userId == null) return;

      await _supabaseService.client
          .from('profiles')
          .update({
            'monthly_budget': monthlyBudget,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      throw Exception('Error al actualizar presupuesto: $e');
    }
  }

  Future<void> updatePersonalInfo({
    required String fullName,
    String? studentId,
    String? university,
  }) async {
    try {
      final userId = _supabaseService.currentUserId;
      if (userId == null) return;

      final updateData = {
        'full_name': fullName,
        if (studentId != null) 'student_id': studentId,
        if (university != null) 'university': university,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabaseService.client
          .from('profiles')
          .update(updateData)
          .eq('id', userId);
    } catch (e) {
      throw Exception('Error al actualizar información personal: $e');
    }
  }

  Future<void> updatePreferences({
    required String currency,
    required String language,
    required bool notificationsEnabled,
  }) async {
    try {
      final userId = _supabaseService.currentUserId;
      if (userId == null) return;

      await _supabaseService.client
          .from('profiles')
          .update({
            'currency': currency,
            'language': language,
            'notifications_enabled': notificationsEnabled,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      throw Exception('Error al actualizar preferencias: $e');
    }
  }

  Future<void> updateSecuritySettings({
    required bool biometricEnabled,
  }) async {
    try {
      final userId = _supabaseService.currentUserId;
      if (userId == null) return;

      await _supabaseService.client
          .from('profiles')
          .update({
            'biometric_enabled': biometricEnabled,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      throw Exception('Error al actualizar configuración de seguridad: $e');
    }
  }

  // ========== MÉTODOS NUEVOS PARA MANEJO DE IMÁGENES ==========

  Future<String?> uploadAndUpdateAvatar(File imageFile, String userId) async {
    try {
      // Subir imagen a Supabase Storage
      final imageUrl = await _storageService.uploadProfileImage(imageFile, userId);
      
      if (imageUrl != null) {
        // Actualizar el perfil con la nueva URL del avatar
        await _supabaseService.client
            .from('profiles')
            .update({
              'avatar_url': imageUrl,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', userId);
      }
      
      return imageUrl;
    } catch (e) {
      throw Exception('Error al subir y actualizar avatar: $e');
    }
  }

  Future<void> updateProfileWithImage(ProfileModel profile, String imageUrl) async {
    try {
      final updateData = {
        'full_name': profile.fullName,
        'student_id': profile.studentId,
        'university': profile.university,
        'avatar_url': imageUrl,
        'currency': profile.currency,
        'language': profile.language,
        'monthly_budget': profile.monthlyBudget,
        'biometric_enabled': profile.biometricEnabled,
        'notifications_enabled': profile.notificationsEnabled,
        'updated_at': DateTime.now().toIso8601String(),
      };

      updateData.removeWhere((key, value) => value == null);

      await _supabaseService.client
          .from('profiles')
          .update(updateData)
          .eq('id', profile.id);
    } catch (e) {
      throw Exception('Error al actualizar perfil con imagen: $e');
    }
  }

  Future<void> deleteAvatar(String userId, String? currentAvatarUrl) async {
    try {
      if (currentAvatarUrl != null) {
        // Eliminar imagen del storage
        await _storageService.deleteProfileImage(currentAvatarUrl);
      }
      
      // Actualizar perfil para remover avatar_url
      await _supabaseService.client
          .from('profiles')
          .update({
            'avatar_url': null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      throw Exception('Error al eliminar avatar: $e');
    }
  }

  // ========== MÉTODOS DE UTILIDAD ==========

  Future<bool> checkProfileExists(String userId) async {
    try {
      final response = await _supabaseService.client
          .from('profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> deleteProfile() async {
    try {
      final userId = _supabaseService.currentUserId;
      if (userId == null) return;

      await _supabaseService.client
          .from('profiles')
          .delete()
          .eq('id', userId);
    } catch (e) {
      throw Exception('Error al eliminar perfil: $e');
    }
  }

  Future<List<ProfileModel>> searchProfiles(String query) async {
    try {
      final response = await _supabaseService.client
          .from('profiles')
          .select()
          .or('full_name.ilike.%$query%,email.ilike.%$query%')
          .limit(10);

      return (response as List)
          .map((json) => ProfileModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al buscar perfiles: $e');
    }
  }

  Future<bool> isEmailAvailable(String email) async {
    try {
      final response = await _supabaseService.client
          .from('profiles')
          .select('email')
          .eq('email', email)
          .maybeSingle();

      return response == null;
    } catch (e) {
      return true; // En caso de error, asumimos que está disponible
    }
  }

  // Verificar si el bucket de avatares está configurado correctamente
  Future<bool> isStorageConfigured() async {
    try {
      return await _storageService.checkAvatarsBucket();
    } catch (e) {
      return false;
    }
  }
}