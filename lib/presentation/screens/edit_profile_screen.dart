import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../../data/models/profile_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _studentIdController;
  late TextEditingController _universityController;
  late TextEditingController _currencyController;
  late TextEditingController _languageController;

  final Color _backgroundColor = const Color(0xFF0A0A0A);
  final Color _cardColor = const Color(0xFF1A1A1A);
  final Color _surfaceColor = const Color(0xFF121212);
  
  // Colores neon saturados (matching dashboard)
  final Color _neonRed = const Color(0xFFFF1744);
  final Color _neonGreen = const Color(0xFF00E676);
  final Color _neonBlue = const Color(0xFF2979FF);
  final Color _neonPurple = const Color(0xFFD500F9);
  final Color _neonYellow = const Color(0xFFFFEA00);
  final Color _neonCyan = const Color(0xFF18FFFF);

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    
    _fullNameController = TextEditingController(text: profile?.fullName ?? '');
    _studentIdController = TextEditingController(text: profile?.studentId ?? '');
    _universityController = TextEditingController(text: profile?.university ?? '');
    _currencyController = TextEditingController(text: profile?.currency ?? 'USD');
    _languageController = TextEditingController(text: profile?.language ?? 'es');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _studentIdController.dispose();
    _universityController.dispose();
    _currencyController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final profileProvider = context.read<ProfileProvider>();
      final currentProfile = profileProvider.profile!;

      final updatedProfile = currentProfile.copyWith(
        fullName: _fullNameController.text.trim(),
        studentId: _studentIdController.text.trim(),
        university: _universityController.text.trim(),
        currency: _currencyController.text.trim(),
        language: _languageController.text.trim(),
        updatedAt: DateTime.now(),
      );

      try {
        await profileProvider.updateProfile(updatedProfile);
        if (mounted) {
          Navigator.pop(context);
          _showSuccessSnackbar();
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog('Error al guardar: $e');
        }
      }
    }
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: _neonGreen),
            const SizedBox(width: 12),
            const Expanded(child: Text('Perfil actualizado exitosamente')),
          ],
        ),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: _neonGreen.withOpacity(0.3)),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: _neonGreen,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _neonRed.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: _neonRed.withOpacity(0.3),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _neonRed.withOpacity(0.8),
                        _neonRed.withOpacity(0.3),
                      ],
                    ),
                    border: Border.all(
                      color: _neonRed.withOpacity(0.5),
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Error',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.8),
                      fontFamily: 'SF Pro Text',
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _buildNeonButton(
                  text: 'ENTENDIDO',
                  onPressed: () => Navigator.pop(context),
                  color: _neonRed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showImagePickerOptions(ProfileProvider profileProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: _neonBlue.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: _neonBlue.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 5,
                    decoration: BoxDecoration(
                      color: _neonBlue.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(3),
                      gradient: LinearGradient(
                        colors: [_neonRed, _neonBlue],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _neonBlue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _neonBlue.withOpacity(0.4)),
                      ),
                      child: Icon(Icons.photo_library, size: 24, color: _neonBlue),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'SELECCIONAR FOTO',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Opción Galería
                _buildImageOptionTile(
                  'Galería',
                  Icons.photo_library,
                  _neonBlue,
                  () {
                    Navigator.pop(context);
                    _pickImageFromGallery(profileProvider);
                  },
                ),
                
                // Opción Cámara
                _buildImageOptionTile(
                  'Tomar Foto',
                  Icons.photo_camera,
                  _neonGreen,
                  () {
                    Navigator.pop(context);
                    _pickImageFromCamera(profileProvider);
                  },
                ),
                
                if (profileProvider.hasAvatar) ...[
                  const SizedBox(height: 20),
                  _buildImageOptionTile(
                    'Eliminar Foto',
                    Icons.delete,
                    _neonRed,
                    () {
                      Navigator.pop(context);
                      _deleteAvatar(profileProvider);
                    },
                    isDestructive: true,
                  ),
                ],
                
                const SizedBox(height: 30),
                _buildNeonButton(
                  text: 'CANCELAR',
                  onPressed: () => Navigator.pop(context),
                  color: Colors.white.withOpacity(0.3),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageOptionTile(String text, IconData icon, Color color, VoidCallback onTap, {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(isDestructive ? 0.4 : 0.2)),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.05),
                color.withOpacity(0.02),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(isDestructive ? 0.15 : 0.1),
                blurRadius: isDestructive ? 15 : 8,
                spreadRadius: isDestructive ? 1 : 0.5,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: color.withOpacity(isDestructive ? 0.5 : 0.3),
                    width: isDestructive ? 2 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(isDestructive ? 0.4 : 0.2),
                      blurRadius: 10,
                      spreadRadius: isDestructive ? 2 : 1,
                    ),
                  ],
                  gradient: RadialGradient(
                    colors: [
                      color.withOpacity(0.3),
                      color.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: isDestructive ? color : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SF Pro Display',
                    letterSpacing: isDestructive ? 0.3 : 0.2,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: color.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery(ProfileProvider profileProvider) async {
    try {
      await profileProvider.pickAndUpdateAvatarFromGallery();
      if (mounted) {
        _showSuccessSnackbarMessage('Foto actualizada exitosamente');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error al seleccionar imagen: $e');
      }
    }
  }

  Future<void> _pickImageFromCamera(ProfileProvider profileProvider) async {
    try {
      await profileProvider.pickAndUpdateAvatarFromCamera();
      if (mounted) {
        _showSuccessSnackbarMessage('Foto actualizada exitosamente');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error al tomar foto: $e');
      }
    }
  }

  Future<void> _deleteAvatar(ProfileProvider profileProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _neonRed.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: _neonRed.withOpacity(0.3),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _neonRed.withOpacity(0.8),
                        _neonRed.withOpacity(0.3),
                      ],
                    ),
                    border: Border.all(
                      color: _neonRed.withOpacity(0.5),
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    Icons.delete_forever,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Eliminar Foto',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '¿Estás seguro de que quieres eliminar tu foto de perfil?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.8),
                      fontFamily: 'SF Pro Text',
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: _buildNeonButton(
                        text: 'CANCELAR',
                        onPressed: () => Navigator.pop(context, false),
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildNeonButton(
                        text: 'ELIMINAR',
                        onPressed: () => Navigator.pop(context, true),
                        color: _neonRed,
                        isDestructive: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed == true) {
      try {
        await profileProvider.deleteCurrentAvatar();
        if (mounted) {
          _showSuccessSnackbarMessage('Foto eliminada exitosamente');
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog('Error al eliminar avatar: $e');
        }
      }
    }
  }

  void _showSuccessSnackbarMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: _neonGreen),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: _neonGreen.withOpacity(0.3)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.edit, color: _neonGreen, size: 22),
            const SizedBox(width: 8),
            const Text(
              'Editar Perfil',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 24,
                color: Colors.white,
                fontFamily: 'SF Pro Display',
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.95),
                Colors.black.withOpacity(0.98),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border(
              bottom: BorderSide(
                color: _neonRed.withOpacity(0.3),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: _neonRed.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: _neonGreen.withOpacity(0.1),
                blurRadius: 30,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        actions: [
          Consumer<ProfileProvider>(
            builder: (context, profileProvider, child) {
              if (profileProvider.isSaving) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(_neonGreen),
                    ),
                  ),
                );
              }
              return Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [_neonGreen, _neonCyan],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _neonGreen.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: IconButton(
                  icon: Icon(Icons.save, size: 20, color: Colors.white),
                  onPressed: _saveProfile,
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          if (profileProvider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [_neonRed, _neonGreen],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _neonRed.withOpacity(0.4),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Cargando...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Avatar Section
                  _buildAvatarSection(profileProvider),
                  const SizedBox(height: 20),
                  
                  // Personal Information
                  _buildPersonalInfoSection(),
                  const SizedBox(height: 16),
                  
                  // Academic Information
                  _buildAcademicInfoSection(),
                  const SizedBox(height: 16),
                  
                  // Preferences
                  _buildPreferencesSection(),
                  const SizedBox(height: 20),
                  
                  // Save Button
                  _buildSaveButton(profileProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatarSection(ProfileProvider profileProvider) {
    final profile = profileProvider.profile;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _cardColor.withOpacity(0.8),
            Colors.black.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: _neonBlue.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: _neonBlue.withOpacity(0.15),
            blurRadius: 25,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: _neonCyan.withOpacity(0.1),
            blurRadius: 35,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _neonBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: _neonBlue.withOpacity(0.4)),
                  gradient: RadialGradient(
                    colors: [
                      _neonBlue.withOpacity(0.3),
                      _neonBlue.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Icon(Icons.camera_alt, size: 24, color: _neonBlue),
              ),
              const SizedBox(width: 12),
              Text(
                'FOTO DE PERFIL',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFamily: 'SF Pro Display',
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              // Avatar con imagen o placeholder
              GestureDetector(
                onTap: () => _showImagePickerOptions(profileProvider),
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [_neonRed, _neonGreen],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _neonRed.withOpacity(0.6),
                        blurRadius: 25,
                        spreadRadius: 3,
                      ),
                      BoxShadow(
                        color: _neonGreen.withOpacity(0.4),
                        blurRadius: 35,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: profile?.avatarUrl != null 
                      ? Image.network(
                          profile!.avatarUrl!,
                          fit: BoxFit.cover,
                          width: 140,
                          height: 140,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return _buildAvatarPlaceholder(size: 140);
                          },
                        )
                      : _buildAvatarPlaceholder(size: 140),
                  ),
                ),
              ),
              
              // Botón para cambiar foto
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showImagePickerOptions(profileProvider),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_neonGreen, _neonCyan],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: _neonGreen.withOpacity(0.5),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: profileProvider.isUploadingImage
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.black),
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt,
                            size: 22,
                            color: Colors.black,
                          ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Estado de carga
          if (profileProvider.isUploadingImage) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _neonGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: _neonGreen.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _neonGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Subiendo imagen...',
                    style: TextStyle(
                      color: _neonGreen,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          // Información de formato
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _neonBlue.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: _neonBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Formatos: JPEG, PNG, WebP • Máx: 5MB',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      fontFamily: 'SF Pro Text',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder({double size = 140}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_neonRed, _neonGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.person,
          size: size * 0.4,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _cardColor.withOpacity(0.8),
            Colors.black.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: _neonPurple.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: _neonPurple.withOpacity(0.15),
            blurRadius: 25,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _neonPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: _neonPurple.withOpacity(0.4)),
                  gradient: RadialGradient(
                    colors: [
                      _neonPurple.withOpacity(0.3),
                      _neonPurple.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Icon(Icons.person_outline, size: 24, color: _neonPurple),
              ),
              const SizedBox(width: 12),
              Text(
                'INFORMACIÓN PERSONAL',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFamily: 'SF Pro Display',
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildNeonTextField(
            controller: _fullNameController,
            label: 'Nombre Completo *',
            icon: Icons.person,
            color: _neonPurple,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu nombre completo';
              }
              if (value.length < 2) {
                return 'El nombre debe tener al menos 2 caracteres';
              }
              return null;
            },
            hintText: 'Ej: Juan Pérez',
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _cardColor.withOpacity(0.8),
            Colors.black.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: _neonYellow.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: _neonYellow.withOpacity(0.15),
            blurRadius: 25,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _neonYellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: _neonYellow.withOpacity(0.4)),
                  gradient: RadialGradient(
                    colors: [
                      _neonYellow.withOpacity(0.3),
                      _neonYellow.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Icon(Icons.school_outlined, size: 24, color: _neonYellow),
              ),
              const SizedBox(width: 12),
              Text(
                'INFORMACIÓN ACADÉMICA',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFamily: 'SF Pro Display',
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildNeonTextField(
            controller: _studentIdController,
            label: 'ID de Estudiante',
            icon: Icons.badge,
            color: _neonYellow,
            validator: null,
            hintText: 'Opcional',
          ),
          const SizedBox(height: 16),
          
          _buildNeonTextField(
            controller: _universityController,
            label: 'Universidad',
            icon: Icons.school,
            color: _neonYellow,
            validator: null,
            hintText: 'Opcional',
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _cardColor.withOpacity(0.8),
            Colors.black.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: _neonGreen.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: _neonGreen.withOpacity(0.15),
            blurRadius: 25,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _neonGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: _neonGreen.withOpacity(0.4)),
                  gradient: RadialGradient(
                    colors: [
                      _neonGreen.withOpacity(0.3),
                      _neonGreen.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Icon(Icons.settings_outlined, size: 24, color: _neonGreen),
              ),
              const SizedBox(width: 12),
              Text(
                'PREFERENCIAS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFamily: 'SF Pro Display',
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildNeonTextField(
            controller: _currencyController,
            label: 'Moneda *',
            icon: Icons.currency_exchange,
            color: _neonGreen,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa la moneda';
              }
              if (value.length < 2) {
                return 'La moneda debe tener al menos 2 caracteres';
              }
              return null;
            },
            hintText: 'USD, EUR, MXN, etc.',
          ),
          const SizedBox(height: 16),
          
          _buildNeonTextField(
            controller: _languageController,
            label: 'Idioma *',
            icon: Icons.language,
            color: _neonGreen,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa el idioma';
              }
              if (value.length < 2) {
                return 'El idioma debe tener al menos 2 caracteres';
              }
              return null;
            },
            hintText: 'es, en, fr, etc.',
          ),
        ],
      ),
    );
  }

  Widget _buildNeonTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
    required String? Function(String?)? validator,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontFamily: 'SF Pro Display',
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 14,
          fontFamily: 'SF Pro Text',
          fontWeight: FontWeight.w500,
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.4),
          fontSize: 14,
          fontFamily: 'SF Pro Text',
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: color.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: color.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: color, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: _neonRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: _neonRed, width: 2),
        ),
        filled: true,
        fillColor: Colors.black.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        errorStyle: TextStyle(
          color: _neonRed,
          fontSize: 12,
          fontFamily: 'SF Pro Text',
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildSaveButton(ProfileProvider profileProvider) {
    return Column(
      children: [
        if (profileProvider.error != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _neonRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _neonRed.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: _neonRed.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _neonRed.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: _neonRed.withOpacity(0.5)),
                  ),
                  child: Icon(Icons.error_outline, color: _neonRed, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    profileProvider.error!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'SF Pro Text',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        SizedBox(
          width: double.infinity,
          height: 60,
          child: _buildNeonButton(
            text: profileProvider.isSaving ? 'GUARDANDO...' : 'GUARDAR CAMBIOS',
            onPressed: profileProvider.isSaving ? null : _saveProfile,
            color: _neonGreen,
            isLarge: true,
            isLoading: profileProvider.isSaving,
          ),
        ),
        
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'CANCELAR',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: 'SF Pro Display',
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNeonButton({
    required String text,
    required VoidCallback? onPressed,
    required Color color,
    bool isLarge = false,
    bool isLoading = false,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedOpacity(
        opacity: onPressed == null ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: double.infinity,
          padding: isLarge
              ? const EdgeInsets.symmetric(horizontal: 32, vertical: 18)
              : const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            gradient: onPressed == null
                ? LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  )
                : isDestructive
                    ? LinearGradient(
                        colors: [color.withOpacity(0.3), color.withOpacity(0.15)],
                      )
                    : LinearGradient(
                        colors: [
                          color.withOpacity(0.2),
                          color.withOpacity(0.05),
                        ],
                      ),
            borderRadius: BorderRadius.circular(isLarge ? 18 : 15),
            border: Border.all(
              color: onPressed == null
                  ? Colors.white.withOpacity(0.2)
                  : color.withOpacity(isDestructive ? 0.8 : 0.4),
              width: isDestructive ? 2 : 1.5,
            ),
            boxShadow: onPressed == null
                ? []
                : [
                    BoxShadow(
                      color: color.withOpacity(isDestructive ? 0.4 : 0.2),
                      blurRadius: isDestructive ? 20 : 15,
                      spreadRadius: isDestructive ? 3 : 1,
                    ),
                  ],
          ),
          child: isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: color,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLarge && onPressed != null)
                      Icon(
                        Icons.save,
                        color: color,
                        size: 20,
                      ),
                    if (isLarge && onPressed != null) const SizedBox(width: 12),
                    Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: onPressed == null ? Colors.white.withOpacity(0.5) : color,
                        fontSize: isLarge ? 16 : 14,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'SF Pro Display',
                        letterSpacing: isLarge ? 0.5 : 0.3,
                        shadows: onPressed != null && isDestructive
                            ? [
                                Shadow(
                                  color: color.withOpacity(0.5),
                                  blurRadius: 10,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}