import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../providers/auth_provider.dart';
import '../../data/models/profile_model.dart';
import '../../services/biometric_service.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Icon(Icons.person, color: _neonGreen, size: 22),
          const SizedBox(width: 8),
          const Text(
            'Mi Perfil',
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
        Container(
          margin: const EdgeInsets.only(right: 12),
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
            icon: Icon(Icons.edit, size: 20, color: Colors.white),
            onPressed: _editProfile,
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        if (profileProvider.isLoading && profileProvider.profile == null) {
          return _buildLoadingState();
        }

        if (profileProvider.error != null) {
          return _buildErrorState(profileProvider);
        }

        final profile = profileProvider.profile;
        if (profile == null) {
          return _buildEmptyState();
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header del perfil
              _buildProfileHeader(profile, profileProvider),
              const SizedBox(height: 20),
              
              // Información personal
              _buildPersonalInfoSection(profile),
              const SizedBox(height: 16),
              
              // Configuración
              _buildSettingsSection(),
              const SizedBox(height: 16),
              
              // Acciones
              _buildActionsSection(),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
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
            'Cargando perfil...',
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

  Widget _buildErrorState(ProfileProvider profileProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [_neonRed.withOpacity(0.8), _neonRed.withOpacity(0.3)],
                ),
                border: Border.all(color: _neonRed.withOpacity(0.5), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: _neonRed.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(Icons.error_outline, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'Error al cargar perfil',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                fontFamily: 'SF Pro Display',
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                profileProvider.error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 15,
                  fontFamily: 'SF Pro Text',
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildNeonButton(
              text: 'Reintentar',
              onPressed: () => profileProvider.loadProfile(),
              color: _neonRed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [_neonRed, _neonGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: _neonRed.withOpacity(0.4),
                    blurRadius: 30,
                  ),
                  BoxShadow(
                    color: _neonGreen.withOpacity(0.3),
                    blurRadius: 40,
                  ),
                ],
              ),
              child: Icon(Icons.person_add_alt_1, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'Perfil no encontrado',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                fontFamily: 'SF Pro Display',
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Completa tu información de perfil\npara una mejor experiencia',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
                fontFamily: 'SF Pro Text',
              ),
            ),
            const SizedBox(height: 32),
            _buildNeonButton(
              text: 'Completar Perfil',
              onPressed: _editProfile,
              color: _neonGreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ProfileModel profile, ProfileProvider profileProvider) {
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
        border: Border.all(color: _neonRed.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: _neonRed.withOpacity(0.15),
            blurRadius: 25,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: _neonGreen.withOpacity(0.1),
            blurRadius: 35,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar con funcionalidad de toque
              GestureDetector(
                onTap: () => _showAvatarModal(profile),
                child: _buildAvatar(profile, size: 90),
              ),
              const SizedBox(width: 20),
              
              // Información del usuario
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontFamily: 'SF Pro Display',
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.email,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.8),
                        fontFamily: 'SF Pro Text',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    
                    // Barra de progreso de completitud
                    if (!profileProvider.hasCompleteProfile) ...[
                      _buildCompletenessProgress(profileProvider),
                      const SizedBox(height: 12),
                    ],
                    
                    if (profile.university != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _neonGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: _neonGreen.withOpacity(0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: _neonGreen.withOpacity(0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.school, size: 16, color: _neonGreen),
                            const SizedBox(width: 8),
                            Text(
                              profile.university!,
                              style: TextStyle(
                                fontSize: 13,
                                color: _neonGreen,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'SF Pro Display',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          // Información adicional de completitud
          if (!profileProvider.hasCompleteProfile) ...[
            const SizedBox(height: 20),
            _buildCompletenessInfo(profileProvider),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(ProfileModel profile, {double size = 90}) {
    return Stack(
      children: [
        // Contenedor del avatar con imagen o placeholder
        Container(
          width: size,
          height: size,
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
                blurRadius: 20,
                spreadRadius: 3,
              ),
              BoxShadow(
                color: _neonGreen.withOpacity(0.4),
                blurRadius: 30,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipOval(
            child: profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
                ? Image.network(
                    profile.avatarUrl!,
                    fit: BoxFit.cover,
                    width: size,
                    height: size,
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
                      return _buildAvatarPlaceholder(size: size);
                    },
                  )
                : _buildAvatarPlaceholder(size: size),
          ),
        ),
        
        // Badge de verificado
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: size * 0.35,
            height: size * 0.35,
            decoration: BoxDecoration(
              color: _neonGreen,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: _neonGreen.withOpacity(0.5),
                  blurRadius: 15,
                ),
              ],
            ),
            child: Icon(
              Icons.verified,
              size: size * 0.18,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarPlaceholder({double size = 90}) {
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
          size: size * 0.5,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCompletenessProgress(ProfileProvider profileProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'COMPLETITUD DEL PERFIL',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w600,
                fontFamily: 'SF Pro Text',
                letterSpacing: 0.5,
              ),
            ),
            Text(
              profileProvider.profileCompletenessText,
              style: TextStyle(
                fontSize: 14,
                color: _neonGreen,
                fontWeight: FontWeight.w700,
                fontFamily: 'SF Pro Display',
                shadows: [
                  Shadow(
                    color: _neonGreen.withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: FractionallySizedBox(
            widthFactor: profileProvider.profileCompleteness,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_neonGreen, _neonCyan],
                ),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: _neonGreen.withOpacity(0.6),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletenessInfo(ProfileProvider profileProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _neonRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _neonRed.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: _neonRed.withOpacity(0.5)),
            ),
            child: Icon(Icons.info_outline, size: 18, color: _neonRed),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Perfil incompleto',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Completa tu información para desbloquear todas las funciones',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                    fontFamily: 'SF Pro Text',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildNeonButton(
            text: 'COMPLETAR',
            onPressed: _editProfile,
            color: _neonRed,
            isSmall: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(ProfileModel profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: _neonBlue.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: _neonBlue.withOpacity(0.15),
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
                child: Icon(Icons.person_outline, size: 24, color: _neonBlue),
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
          
          _buildNeonInfoItem('Nombre Completo', profile.displayName, Icons.person_outlined, _neonBlue),
          _buildNeonInfoItem('ID Estudiantil', profile.displayStudentId, Icons.badge_outlined, _neonPurple),
          _buildNeonInfoItem('Universidad', profile.displayUniversity, Icons.school_outlined, _neonYellow),
          _buildNeonInfoItem('Moneda', profile.currency, Icons.currency_exchange_outlined, _neonGreen),
          _buildNeonInfoItem('Idioma', profile.language.toUpperCase(), Icons.language_outlined, _neonCyan),
        ],
      ),
    );
  }

  Widget _buildNeonInfoItem(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2)),
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.05),
            color.withOpacity(0.02),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                    fontFamily: 'SF Pro Text',
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'SF Pro Display',
                    shadows: [
                      Shadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: color.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    final authProvider = context.read<AuthProvider>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
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
                child: Icon(Icons.settings_outlined, size: 24, color: _neonPurple),
              ),
              const SizedBox(width: 12),
              Text(
                'CONFIGURACIÓN',
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
          
          // Biometría
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _neonGreen.withOpacity(0.2)),
              gradient: LinearGradient(
                colors: [
                  _neonGreen.withOpacity(0.05),
                  _neonGreen.withOpacity(0.02),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _neonGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _neonGreen.withOpacity(0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: _neonGreen.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                    gradient: RadialGradient(
                      colors: [
                        _neonGreen.withOpacity(0.3),
                        _neonGreen.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: Icon(Icons.fingerprint_outlined, size: 22, color: _neonGreen),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AUTENTICACIÓN BIOMÉTRICA',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                      Text(
                        'Usar huella/rostro para iniciar sesión',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                          fontFamily: 'SF Pro Text',
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: authProvider.isBiometricEnabled,
                  onChanged: (value) async {
                    await authProvider.toggleBiometric(value);
                    setState(() {});
                  },
                  activeColor: _neonGreen,
                  inactiveTrackColor: Colors.grey.shade800,
                  activeTrackColor: _neonGreen.withOpacity(0.3),
                  trackOutlineColor: MaterialStatePropertyAll(_neonGreen.withOpacity(0.5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: _neonRed.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: _neonRed.withOpacity(0.15),
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
                child: Icon(Icons.touch_app_outlined, size: 24, color: _neonYellow),
              ),
              const SizedBox(width: 12),
              Text(
                'ACCIONES',
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
          
          _buildNeonActionTile('Editar Perfil', Icons.edit_outlined, _editProfile, _neonGreen),
          _buildNeonActionTile('Cerrar Sesión', Icons.logout_outlined, _logout, _neonRed, isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildNeonActionTile(String text, IconData icon, VoidCallback onPressed, Color color, {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onPressed,
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
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    fontFamily: 'SF Pro Display',
                    letterSpacing: isDestructive ? 0.3 : 0.2,
                    shadows: isDestructive ? [
                      Shadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ] : null,
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

  Widget _buildNeonButton({required String text, required VoidCallback onPressed, required Color color, bool isSmall = false, bool isDestructive = false}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: isSmall
            ? const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
            : const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDestructive
                ? [color.withOpacity(0.3), color.withOpacity(0.15)]
                : [
                    color.withOpacity(0.2),
                    color.withOpacity(0.05),
                  ],
          ),
          borderRadius: BorderRadius.circular(isSmall ? 12 : 18),
          border: Border.all(
            color: color.withOpacity(isDestructive ? 0.8 : 0.4),
            width: isDestructive ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(isDestructive ? 0.4 : 0.2),
              blurRadius: isDestructive ? 20 : 15,
              spreadRadius: isDestructive ? 3 : 1,
            ),
          ],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: isSmall ? 13 : 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'SF Pro Display',
            letterSpacing: isSmall ? 0.3 : 0.5,
            shadows: [
              Shadow(
                color: color.withOpacity(0.5),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAvatarModal(ProfileModel profile) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.85),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
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
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: _neonGreen.withOpacity(0.4),
                        blurRadius: 40,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
                        ? Image.network(
                            profile.avatarUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  color: _neonGreen,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 80,
                              );
                            },
                          )
                        : Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 80,
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  profile.displayName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'SF Pro Display',
                    shadows: [
                      Shadow(
                        color: _neonGreen.withOpacity(0.5),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  profile.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: _neonGreen.withOpacity(0.8),
                    fontFamily: 'SF Pro Text',
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'Toca para cerrar',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                    fontFamily: 'SF Pro Text',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfileScreen(),
      ),
    ).then((_) {
      // Recargar el perfil cuando regrese de la edición
      context.read<ProfileProvider>().loadProfile();
    });
  }

  void _logout() {
    final profileProvider = context.read<ProfileProvider>();
    final profile = profileProvider.profile;
    
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
                color: _neonRed.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
              BoxShadow(
                color: _neonGreen.withOpacity(0.1),
                blurRadius: 40,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _showAvatarModal(profile!),
                  child: Container(
                    width: 100,
                    height: 100,
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
                          color: _neonRed.withOpacity(0.4),
                          blurRadius: 20,
                        ),
                        BoxShadow(
                          color: _neonGreen.withOpacity(0.3),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        _buildAvatar(profile!, size: 94),
                        Positioned(
                          bottom: 5,
                          right: 5,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: _neonGreen,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _neonGreen.withOpacity(0.5),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.visibility,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  profile!.displayName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'SF Pro Display',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Text(
                  '¿Listo para cerrar sesión?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: _neonRed.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                    fontFamily: 'SF Pro Text',
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: _buildNeonButton(
                        text: 'Cancelar',
                        onPressed: () => Navigator.of(context).pop(),
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildNeonButton(
                        text: 'Cerrar Sesión',
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.read<AuthProvider>().signOut();
                          Navigator.pushReplacementNamed(context, '/login');
                        },
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
  }
}