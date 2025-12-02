// lib/services/storage_service.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class StorageService {
  final SupabaseService _supabaseService = SupabaseService();

  Future<String?> uploadProfileImage(File imageFile, String userId) async {
    try {
      // Crear nombre único para la imagen
      final fileName = 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'profiles/$fileName';

      // Subir archivo a Supabase Storage
      await _supabaseService.client.storage
          .from('avatars')
          .upload(filePath, imageFile);

      // Obtener URL pública de la imagen
      final String publicUrl = _supabaseService.client.storage
          .from('avatars')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      // Extraer el nombre del archivo de la URL
      final uri = Uri.parse(imageUrl);
      final segments = uri.pathSegments;
      
      // El último segmento debería ser el nombre del archivo
      if (segments.isNotEmpty) {
        final fileName = segments.last;
        final filePath = 'profiles/$fileName';

        await _supabaseService.client.storage
            .from('avatars')
            .remove([filePath]);
      }
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  // Verificar si el bucket de avatares existe
  Future<bool> checkAvatarsBucket() async {
    try {
      final response = await _supabaseService.client.storage
          .from('avatars')
          .list();
      return true;
    } catch (e) {
      print('Avatars bucket might not exist: $e');
      return false;
    }
  }

  // Método para obtener la URL pública de una imagen
  String getPublicUrl(String filePath) {
    return _supabaseService.client.storage
        .from('avatars')
        .getPublicUrl(filePath);
  }

  // Método para listar archivos en el bucket (útil para debugging)
  Future<List<FileObject>> listProfileImages(String userId) async {
    try {
      final response = await _supabaseService.client.storage
          .from('avatars')
          .list(path: 'profiles');
      
      return response;
    } catch (e) {
      print('Error listing profile images: $e');
      return [];
    }
  }

  // Método para verificar si un archivo existe
  Future<bool> fileExists(String filePath) async {
    try {
      await _supabaseService.client.storage
          .from('avatars')
          .download(filePath);
      return true;
    } catch (e) {
      return false;
    }
  }
}